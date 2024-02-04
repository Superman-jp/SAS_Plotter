*--------------------------------------------------------;
*SAS_plotter;
*sankey diagram macro;
*author: SupermanJP;
*version: 1.2;
*--------------------------------------------------------;

%macro sankey(
	data=,
	
	domain=,
	domainfmt=,
	domaintextattrs=(color=black size=11),
	gap=5,
	
	nodefmt=auto,
	nodewidth=0.2,
	nodeattrs=auto,
	nodename=true,
	nodetextattrs=(color=black size=9),
	
	linktext=true,
	linktext_offset=0.05,
	linkattrs=auto,
	linktextattrs=(color=black size=8),
	
	focus=None,
	stat=both,
	unit=,
	reverse=false,
	endFollowup=None,
	
	legend=false,
	palette=sns);
	

ods graphics / push;
ods graphics / reset=all;	

*slope parameter for sigmoid curve;
%let slope = 8;

*copy the input data;

data dat;
set &data.;
keep &domain.;
run;

*-------------------------------;
* step1: data and parameter check;
*-------------------------------;

*macro terminate flag;
%let exitflg=0;


*domain format exist check;

proc format lib=work cntlout=fmt;
run;

proc sql noprint;
select count(*) into : domainexist
from fmt
where fmtname=upcase("&domainfmt.");
quit;

%if &domainexist.=0 %then %do;
	data _null_;
	if &domainexist=0 then 
		put "WAR" "NING: domain format is not exist.";
	run;
%goto exit;
%end;


* palette parameter check;
%if %upcase("&palette.") ^= "SAS" and
    %upcase("&palette.") ^= "SNS" and
    %upcase("&palette.") ^= "STATA" and
    %upcase("&palette.") ^= "TABLEAU" %then %do;
    
    data _null_;
    put "WAR" "NING: palette parameter must be set SAS, SNS, STATA or Tableau";
    run;
    
    %goto exit;
%end;

* stat parameter check;
%if %upcase("&stat.") ^= "FREQ" and
    %upcase("&stat.") ^= "PCT" and
    %upcase("&stat.") ^= "BOTH" and 
    %upcase("&stat.") ^= "NONE" %then %do;
    
    data _null_;
    put "WAR" "NING: stat parameter must be set FRQ(Frequency), PCT(percentage) or BOTH(Frequency and Percentage)";
    run;
    
    %goto exit;
%end;

*domain variable type check;

data _null_;
set sashelp.vcolumn(
	where=(libname="WORK" and memname="DAT")
	);
if type ="char" then do;
	call symputx("exitflg", "1");
	put "WAR" "NING: domain variable should be numeric.";
end;
run;

%if &exitflg.=1 %then %goto exit;

*-------------------------------;
* step2: set the domain format;
*-------------------------------;
proc format library=work cntlout=domainlist;
   select &domainfmt.;               
run;

data domainlist2;
length tmp $1000;
set domainlist end=eof;
retain tmp;

tmp = catx(" ", tmp, strip(start));
if eof then call symputx("domainlist", tmp);
run;



*-------------------------------;
* step3: data preparation ;
*-------------------------------;

/* count the records */
proc sql noprint;

select count(*) into: total
from dat;
quit;

%macro make_long;

	data raw_sankey;
	set
	%do name = 1 %to %sysfunc(countw(&domain.," "))-1;
		dat(keep = %scan(&domain., &name., " ") %scan(&domain., %eval(&name.+1), " ")
			rename=(%scan(&domain., &name., " ")=node %scan(&domain., %eval(&name.+1), " ") =next_node) in=d&name.)
		
	%end;
	;
	
	%do name = 1 %to %sysfunc(countw(&domain.," "))-1;
		if d&name. then do;
			domain=%scan(&domainlist., &name., " ");
			next_domain=%scan(&domainlist., %eval(&name.+1), " ");
		end;
				
	%end;
	run;
%mend make_long;


%make_long;


*-------------------------------;
* step4: calculate node ;
*-------------------------------;

/*-------- frequency by domain ---------------------------------------*/

*generate node shapes;
%macro nodeshape(domain=, node=, width=, height=, gap=);

	
	x=&domain.-&width./2;
	y=offset;
	output;
	
	y=offset+&height.;
	

	
	/* 	text position for count of node */
	
	if upcase("&nodename.")="TRUE" then do;
		
		%if %upcase("&nodefmt.")="AUTO" %then %do;
			node_text=strip(vvalue(&node.));
		%end;
		%else %do;
			node_text=strip(put(&node., &nodefmt..));
		%end;
		
	end;
	
	if upcase("&stat.")^="NONE " then do;
		if upcase("&stat.")="FREQ" then
			node_text=catx("#", node_text, cat(strip(put(count,best.)),"&unit."));
			
		if upcase("&stat.")="PCT" then
			node_text=catx("#", node_text, cat(strip(put(round(count/&total.*100,0.01), 8.2)), "%"));
			
		if upcase("&stat.")="BOTH" then
			node_text=catx("#", node_text, cat(strip(put(count,best.)),"&unit."), cat(strip(put(round(count/&total.*100,0.01), 8.2)), "%"));
	end;

	node_text_x=&domain.;
	node_text_y=(offset+y)/2;
	
	output;
	
	x=&domain.+&width./2;
	node_text="";
	node_text_x=.;
	node_text_y=.;
	
	output;
	
	y=offset;
	output;
	
	id+1;
	offset+&height.+ &gap.;
%mend nodeshape;


proc freq data=raw_sankey noprint;
tables domain*node  /out=domain1;
run;

data domain2;
length node_text $50;
set domain1;
by domain node;

retain offset;

if first.domain then offset=0;

%nodeshape(domain=domain, node=node, width=&nodewidth., height=count, gap=&gap.);
keep domain node x y node_text node_text_x node_text_y;
run;


/*-------- frequency by next domain(last domain only) ----------------------*/
proc freq data=raw_sankey noprint;
tables next_domain*next_node / out=next_domain;
where next_domain = %scan(&domainlist.,%sysfunc(countw(&domain.," ")), " ");

run;


data next_domain2;
length node_text $50;
set next_domain;
by next_domain next_node;
retain next_node;
retain offset;


if first.next_domain then offset=0;
%nodeshape(domain=next_domain, node=next_node, width=&nodewidth., height=count, gap=&gap.);

keep next_domain next_node x y node_text node_text_x node_text_y;
rename next_domain=domain next_node=node;
run;

data domain3;
set domain2 next_domain2;
proc sort; by domain node;
run;

data node;
length node_id $50;
set domain3;
by domain node;
retain tmp;

if first.node then tmp+1;
node_id="node" || strip(put(tmp,best.));
drop tmp;

run;

*-------------------------------;
* step5: calculate percentage of followup ;
*-------------------------------;
%if %upcase("&endfollowup.")^="NONE" %then %do;

	proc sql noprint ;
	create table followup as
	
	select 
		   domain,
		   sum(count) as total,
	       sum(case when node^=&endfollowup. then count else 0 end) as followup,
	       calculated followup / calculated total * 100 as pct

	from (
		select domain,
		       node,
		       count
		from domain1
		
		union all
		
		select next_domain as domain,
			   next_node as node,
			   count
		from next_domain
	)
	
	group by domain;
	quit;

	data domaintxt;
	length domaintext $2000;
	set followup;
	
	if upcase("&endfollowup.")^="NONE" then do;
	  domaintext_x = domain;
	  domaintext_y = "number in#follow-up";
	  domaintext= strip(put(followup,8.0)) || "# (" || strip(put(round(pct,0.01),8.2)) || "%)";
	end;
	
	keep domaintext:;
	run;
	
%end;

%else %do;
	data domaintxt;
		length domaintext $2000;
		  domaintext_x = .;
		  domaintext_y = "";
		  domaintext= "";
	run;

%end;

*-------------------------------;
* step6: calculate link ;
*-------------------------------;


/* calculate cordinate of start posisiton of links */
/* rename node */
/* node >> source_node */
/* next_node >> target_node */

proc freq data=raw_sankey noprint;
tables domain*node*next_domain*next_node / out=link1(rename=(node=source_node next_node=target_node));
run;

data link2;
set link1;
retain bottom top;
by domain source_node;


if first.domain and first.source_node then do;
	bottom=0;
	top=count;
end;

else if first.source_node then do;
	bottom=top+&gap.;
	top+&gap.+count;
end;

else do;
	bottom=top;
	top+count;
end;

keep domain source_node next_domain target_node bottom top;
run;

proc sort data=link1; by next_domain target_node domain source_node;run;

data link2_next;
set link1;
retain next_bottom next_top;
by next_domain target_node;

if first.next_domain and first.target_node then do;
	next_bottom=0;
	next_top=count;
end;

else if first.target_node then do;
	next_bottom=next_top+&gap.;
	next_top+&gap.+count;
end;

else do;

	next_bottom=next_top;
	next_top+count;
end;

run;
proc sort; by domain source_node next_domain target_node;
run;


data link3;
length link_text link_id $50;
merge link2
      link2_next;
by domain source_node next_domain target_node;
retain tmp 0;
tmp+1;

link_id="link" || strip(put(tmp,best.));


/* text for link */


if upcase("&stat.")="FREQ" then
	link_text= cat(strip(put(count,best.)),"&unit.");
	
if upcase("&stat.")="PCT" then
	link_text=strip(put(round(count/&total.*100 ,0.01),6.2)) || "%";
	
if upcase("&stat.")="BOTH" then	
	link_text= cat(strip(put(count,best.)),"&unit. (" , put(round(count/&total.*100 ,0.01), 6.2) , "%)");
	
if upcase("&stat.")="NONE" then	
	link_text= "";
		

link_text_x=domain+(&nodewidth./2) + &linktext_offset.;
link_text_y=(top + bottom) / 2;


*link text of the links except for source node set in focus parameter will be deleted;

%if  %upcase("&focus.")^="NONE" %then %do;


	if not &focus. and link_text^=""  then link_text="";
	
%end;

run;

*-------------------------------;
* step7: create attribute map dataset;
*-------------------------------;

/* node type */
/* get node type from node type format */
/* if nodefmt parameter is not set, node type format will be get from the input dataset */

%if %upcase("&nodefmt.")="AUTO" %then %do;

	proc sort data=node out=nodelist(keep= node) nodupkey;
	by  node;
	run;
	
	data nodelist;
	set nodelist;
	retain node_attr;
	node_attr+1;
	run;
	
	data attrmap_nodetype;
	length value fillstyle $50;
	set nodelist
	      ;
	     
	id="attrmap_nodetype";
	value=vvalue(node);
	fillstyle="GraphData" || strip(put(node_attr,best.));

	keep id value fillstyle node;
	run;

%end;
%else %do;
	proc format library=work cntlout=nodelist;
	   select &nodefmt.;               
	run;
	
	data nodelist;
	set nodelist;
	retain node_attr;
	node_attr+1;
	node=input(strip(start),best.);
	format node &nodefmt..;
	
	run;
	
	data attrmap_nodetype;
	length value fillstyle $50;
	set nodelist
	      ;
	     
	id="attrmap_nodetype";
	value=label;
	fillstyle="GraphData" || strip(put(node_attr,best.));
	keep id value fillstyle ;
run;
%end;


/* node shape id */
proc sort data=node; by node; run;


data attrmap_node;
length value fillstyle $50;
merge node(in=a)
      nodelist
      ;
      
by node;

id="attrmap_node";
value=node_id;
	
fillstyle="GraphData" || strip(put(node_attr,best.));

if a;

keep domain node id value fillstyle  ;
proc sort nodupkey; by value;
run;


/* link shape id */

proc sort data=link3 out=link_attrmap1(keep=link_id domain source_node target_node next_domain) nodupkey;
by link_id;
run;


proc sort data=link_attrmap1;by source_node;run;

data attrmap_link;
length value fillstyle $50;
merge link_attrmap1 (in=a) nodelist(rename=(node=source_node));
by source_node;

id="attrmap_link";
value=link_id;
fillstyle="GraphData" || strip(put(node_attr,best.));
keep domain next_domain source_node target_node id value fillstyle ;

if a;

run;

data attrmap;
length fillcolor $50;
set attrmap_nodetype
    attrmap_node
    attrmap_link;

if id="attrmap_node" then filltransparency=0;
else if id="attrmap_link" then filltransparency=0.5;
fillcolor="";

*fill color of the links except for source node set in focus parameter is set grey;

%if %upcase("&focus.")^="NONE" %then %do; 

	if  (&focus.) and id="attrmap_link" then filltransparency=0.4;

	if  not (&focus.) and id="attrmap_link" then do;
		fillcolor="grey";
		filltransparency=0.8;
	end;
	
%end;

%if %upcase("&Endfollowup.")^="NONE" %then %do;
	if id in ("attrmap_node","attrmap_nodetype") and node=&endfollowup. then 
		fillcolor="grey";
	if id ="attrmap_link" and source_node=&endfollowup. then
		fillcolor="grey";

%end;

keep domain node source_node target_node id value fillstyle fillcolor filltransparency;
run;



*-------------------------------;
* step8: create link shape(sigmoid curve);
*-------------------------------;

data link4;
set link3;

/*sigmid curve */

do i = -&slope. to &slope. by 0.02;

	if i^=-&slope. then do;
		link_text="";
		link_text_x=.;
		link_text_y=.;
	end;
	
	m=exp(i) / (exp(i)+1);
	
	link_x=(i + &slope.) / (&slope. * 2) * ((next_domain - &nodewidth./2) - (domain+&nodewidth./2)) + (domain+&nodewidth./2);
	link_bottom=m*(next_bottom - bottom) +bottom;
	link_top=m*(next_top - top) + top;
	output;
end;



run;

*-------------------------------;
* step9: Graph data ;
*-------------------------------;


data graph;
merge node
    link4
    domaintxt;
    
run;


*-------------------------------;
* step10: Graph template ;
*-------------------------------;
proc template;

/* sankey only */
define statgraph sankey;
begingraph;

discreteattrvar attrmap="attrmap_node" var=node_id attrvar=_grp_node;
discreteattrvar attrmap="attrmap_link" var=link_id attrvar=_grp_link;


	layout overlay /walldisplay=none 
		x2axisopts=(display=(tickvalues) 
			  offsetmin=0.05
			  offsetmax=0.05
			  tickvalueattrs=&domaintextattrs.
			  linearopts=(
	
				tickvaluelist=(&domainlist.)
				tickvalueformat=&domainfmt..))
		
		yaxisopts=(reverse=&reverse. display=none linearopts=(viewmin=0) offsetmin=0.02 offsetmax=0.02);

	
	if (upcase("&nodeattrs")="AUTO")
	
		polygonplot id=node_id x=x y=y / 
			group=_grp_node
			display=(fill)
			xaxis=x2
			;
			
	endif;
	
	if (upcase("&nodeattrs.")^="AUTO")
		polygonplot id=node_id x=x y=y / 
			group=_grp_node
			display=(fill)
			fillattrs=&nodeattrs.
			xaxis=x2
			;
	endif;
	if (upcase("&linkattrs.")="AUTO")	
	
		bandplot x=link_x limitlower=link_bottom limitupper=link_top / 
			group=_grp_link
			xaxis=x2
			;
	endif;
	
	if (upcase("&linkattrs.")^="AUTO")	
	
		bandplot x=link_x limitlower=link_bottom limitupper=link_top / 
			group=_grp_link
			fillattrs=&linkattrs.
			xaxis=x2
			;
	endif;
	
	
		textplot x=node_text_x y=node_text_y text=node_text / 
			splitchar="#"
			splitpolicy=splitalways
			textattrs=&nodetextattrs.
			xaxis=x2;
	
	
	if (upcase("&linktext")="TRUE")	
	textplot x=link_text_x y=link_text_y text=link_text / 
		textattrs=&linktextattrs.
		position=right
		xaxis=x2;
		
		
	endif;
	
	if (upcase("&legend.")="TRUE")
			discretelegend "attrmap_nodetype" /type=fill;
	endif;
	
endlayout;
endgraph;
end;


/* sankey + followup  */
define statgraph sankey_followup;
begingraph;

discreteattrvar attrmap="attrmap_node" var=node_id attrvar=_grp_node;
discreteattrvar attrmap="attrmap_link" var=link_id attrvar=_grp_link;

layout lattice / rows=2 rowweights=(0.95 0.05) column2datarange=union;

column2axes;
columnaxis / display=(tickvalues) 
			  offsetmin=0.05
			  offsetmax=0.05
			  tickvalueattrs=&domaintextattrs.
			  linearopts=(
	
				tickvaluelist=(&domainlist.)
				tickvalueformat=&domainfmt..);
endcolumn2axes;


/* diagram area */
	layout overlay /walldisplay=none 
		yaxisopts=(reverse=&reverse. display=none linearopts=(viewmin=0) offsetmin=0.02 offsetmax=0.02);

	
	if (upcase("&nodeattrs")="AUTO")
	
		polygonplot id=node_id x=x y=y / 
			group=_grp_node
			display=(fill)
			xaxis=x2
			;
			
	endif;
	
	if (upcase("&nodeattrs.")^="AUTO")
		polygonplot id=node_id x=x y=y / 
			group=_grp_node
			display=(fill)
			fillattrs=&nodeattrs.
			;
	endif;
	if (upcase("&linkattrs.")="AUTO")	
	
		bandplot x=link_x limitlower=link_bottom limitupper=link_top / 
			group=_grp_link
			xaxis=x2
			;
	endif;
	
	if (upcase("&linkattrs.")^="AUTO")	
	
		bandplot x=link_x limitlower=link_bottom limitupper=link_top / 
			group=_grp_link
			fillattrs=&linkattrs.
			xaxis=x2
			;
	endif;
	
	
		textplot x=node_text_x y=node_text_y text=node_text / 
			splitchar="#"
			splitpolicy=splitalways
			textattrs=&nodetextattrs.
			xaxis=x2;
	
	
	if (upcase("&linktext")="TRUE")	
	textplot x=link_text_x y=link_text_y text=link_text / 
		textattrs=&linktextattrs.
		position=right
		xaxis=x2;
		
		
	endif;
	

endlayout;

/* domain and percentage of followup area */
	layout overlay / walldisplay=none
		yaxisopts=(display=(tickvalues) offsetmin=0 offsetmax=0
				discreteopts=(tickvaluesplitchar="#" tickvaluefitpolicy=splitalways)
				);
		
		textplot x=domaintext_x 
		         y=domaintext_y
		         text=domaintext / 
		         splitchar="#"
		         splitpolicy=splitalways
		         textattrs=(size=9 color=black)
		         xaxis=x2;
		         
	         
	endlayout;
	
	sidebar / align=bottom spacefill=false;
	
	if (upcase("&legend.")="TRUE")
			discretelegend "attrmap_nodetype" /type=fill;
	endif;
		
	endsidebar;
	
	
endlayout;
endgraph;
end;
run;

*-------------------------------;
* final step: generate graph image ;
*-------------------------------;
ods graphics / pop;
ods listing style=&palette.;
ods graphics / antialiasmax=999999;

%if %upcase("&endFollowup.")^="NONE" %then %do;
	proc sgrender data=graph template=sankey_followup dattrmap=attrmap;
	run;
%end;

%else %do;
	proc sgrender data=graph template=sankey dattrmap=attrmap;
	run;
%end;
%exit:

%mend sankey;


