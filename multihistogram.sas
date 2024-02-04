*--------------------------------------------------------;
*SAS_plotter;
*multihistogram macro;
*author: SupermanJP;
*version: 1.1;
*--------------------------------------------------------;

%macro multihistogram(
	data=,
	category=,
	pair=none,
	level=,
	levelfmt=,
	response=,
	leveltitle=Level,
	responsetxt=false,
	orient=v,
	pairsplit=false,
	pairtitle=Pair,
	legend=true,
	palette=sns
);

*-------------------------------;
* step1: data and parameter check;
*-------------------------------;
ods graphics / push;
ods graphics / reset=all;	

/*if orient is wrong, stop macro*/

%if %upcase("&orient.")^="H" and %upcase("&orient.")^="V" %then %do;
  data _null_;
  put "ERROR:" "orient setting is wrong";
  run;
  %goto exit;
%end;

%if %upcase("&pair.")^="NONE" %then %do;
	data raw;
	set &data.;
	keep &category. &pair. &level. &response.;
	rename &category.=category
		   &pair.=pair
		   &level.=level
		   &response.=response;
	
	run;
%end;

%else %do;
	data raw;
	set &data.;
	keep &category. pair &level. &response.;
	
	pair=&category.;
	rename &category.=category
		   &level.=level
		   &response.=response;
	
	run;
%end;

/* pair variable should be binomial */
%if %upcase("&pair.")^="NONE" %then %do;
	proc sql noprint;
	select count(distinct &pair.) into: npair
	from &data.;
	quit;

	%if &npair.> 2 %then %do;
		data _null_;
		put "WAR" "NING: pair variable should be binomial.";
		run;
		
		%goto exit;
	%end;
%end;

/* if pair variable is not set, legend will not be displaied */

%if %upcase("&pair.")="NONE" %then %do;
	%let legend = FALSE;
%end;

*-------------------------------;
* step2: setting of interval parameter;
*-------------------------------;
%if %upcase("&orient.") = "V" %then %do;

	%if %upcase("&pairsplit.")="TRUE" %then %do;
	
		%if &npair.= 2 %then %do;
			%let tree_iv = 2;
		%end;
		%else %do;
			%let tree_iv=1.5;
		%end;
		
		%let pair_iv = 1;
		%let txtposparm=0.125;
		
	%end;
	
	%if %upcase("&pairsplit.")^="TRUE" %then %do;
		%let tree_iv = 4;
		%let pair_iv = 2;
		%let txtposparm=0.25;
	%end;
	
%end;

%if %upcase("&orient.") ="H" %then %do;

		%if %upcase("&pairsplit.")="TRUE" %then %do;
		
			%if &npair.= 2 %then %do;
				%let tree_iv = 2;
				%let pair_iv = 1.5;

			%end;
			%else %do;
				%let tree_iv = 1.5;				
				%let pair_iv = 1;
			%end;
			%let txtposparm=0.125;
		%end;
	
	%if %upcase("&pairsplit.")^="TRUE" %then %do;
		%let tree_iv = 6;
		%let pair_iv = 3;
		%let txtposparm=0.6;
	%end;
	
%end;
*-------------------------------;
* step3: data and parameter check;
*-------------------------------;

proc sql noprint;
select max(response) into : max_response
from raw;

create table catlist as
select distinct category, pair
from raw;
quit;

data catlist2;
length categorylabel pairlabel $100;
set catlist end=eof;
by category pair ;
retain grpid ;
if first.category then grpid+&tree_iv.;
else  grpid+&pair_iv.;
categorylabel=vvalue(category);
pairlabel=vvalue(pair);
run;

/* grpid for split mode */
proc sql noprint;
create table grpid_split as
select category,
       mean(grpid) as grpid_split
from catlist2
group by category;
quit;


*-------------------------------;
* step4: x-axis text;
*-------------------------------;

proc sql noprint;

create table xticks as

/* category label */
select mean(grpid) as xtick_x,
	   1 as xtick_y,
	   categorylabel as xtick_text,
	   "category_normal" length=20 as cat
	   
from catlist2
group by  categorylabel

union all
select mean(grpid) as xtick_x,
	   1 as xtick_y,
	   categorylabel as xtick_text,
	   "category_pairsplit" length=20 as cat
from catlist2
group by categorylabel

;
quit;
*-------------------------------;
* step5: tickvalue list;
*-------------------------------;
proc format cntlout=fmt;
select &levelfmt.;
run;

data _null_;
length tmp $5000;
set fmt end=eof;
retain tmp;

tmp=catx(" ", tmp, strip(start));
if eof then call symputx("yticklist", strip(tmp));
run;


proc sort data=raw ; by category pair;
run;

*-------------------------------;
* step6:calculate histogram cordinate;
*-------------------------------;
data wk0;
merge catlist2 raw;
by category pair;
run;

data wk1;
merge wk0 grpid_split;
by category;
run;


%if %upcase("&pairsplit.")^="TRUE" %then %do;
	data wk2;
	set wk1;
	by category pair;
	
	retain factor;
	
	pct = response / &max_response ;
	
	if first.category and first.pair then factor=-1;
	else if first.pair then factor=1;
	
/* define start and end of highlow plot 	 */
    start=grpid-pct;
	end=grpid+pct;
	run;
	
	proc sort data=wk2 nodupkey out=wk3; by category pair level factor; run; 
	
	data restext;
	length response_text txtpos $20;
	set wk3;
	by category pair;
		response_text_x=grpid + (pct + &txtposparm.) * factor;
		response_text_y=level;
		response_text=strip(vvalue(response));

		
/* 	response text position parameter */
	if factor=1 then txtpos="right";
	else if factor=-1 then txtpos="left";
	
	keep txtpos response_text:;
	run;
	
%end;

*split mode;
%if %upcase("&pairsplit.")="TRUE" %then %do;
	data wk2;
	set wk1;
	by category pair;
	
	retain factor;
	
/* 	factor:define the cordinate of the bars for pairsplit mode */
/* first of the pair : left(factor=-1) */
/* second of the pair : right(factor=1) */

	if first.category and first.pair then factor=-1;
	else if first.pair then factor=1;

/* define bar cordinate	 */
	pct = response / &max_response ;

	if factor=-1 then do;
		start=grpid_split+pct*factor;
		end=grpid_split;
	end;
	else if factor=1 then do;
		start=grpid_split;
		end=grpid_split+pct*factor;
	end;
	
	run;
	proc sort data=wk2 nodupkey out=wk3; by category pair level factor; run; 
	
	data restext;
	length response_text $20;
	set wk3;
	by category pair;
		response_text_x=grpid_split + (pct + &txtposparm.) * factor;
		response_text_y=level;
		response_text=strip(vvalue(response));
		
/* 	response text position parameter */
	if factor=1 then txtpos="right";
	else if factor=-1 then txtpos="left";
	
	keep txtpos response_text:;

	
%end;

*-------------------------------;
* step7:  attribute dataset;
*-------------------------------;
proc sort data=wk3 nodupkey out=attrmap_(keep=grpid pair); by grpid; run;
proc sort data=attrmap_; by pair; run;

data attrmap1;
length id fillstyle $20 value $100;
set attrmap_;
by pair;
retain tmp;
if first.pair then tmp+1;

id="pairattrmap";
value=strip(put(grpid, best.));
fillstyle="GraphData" || strip(put(tmp,best.));
keep pair id value fillstyle;

run;

proc sort data=attrmap1 nodupkey out=attrmap2(keep=pair fillstyle); by pair;
data attrmap;
length id fillstyle $20 value $100;
set attrmap1 attrmap2(in=a);

if a then do;
	id="pairname";
	value=strip(vvalue(pair));
end;

keep id value fillstyle;
run;

*-------------------------------;
* step8: graph data;
*-------------------------------;
%if %upcase("&pairsplit.")^="TRUE" %then %do;

	data graph;
	
	merge wk2 
		  xticks(where=(cat="category_normal"))
		  restext;

	run;
%end;

%if %upcase("&pairsplit.")="TRUE" %then %do;

	data graph;
	merge wk2 
		  xticks(where=(cat="category_pairsplit"))
		  restext;

	run;
%end;

*-------------------------------;
* step9: template;
*-------------------------------;
options mprint;
proc template;
*-------------------------------;
* vertical histogram;
*-------------------------------;
define statgraph histotree_v;
begingraph;

discreteattrvar attrmap="pairattrmap" var=grpid attrvar=_grp;

layout lattice / rows=2  rowweights=(8 2) columndatarange=union;

	columnaxes;
		columnaxis / display=none offsetmin=0.1 offsetmax=0.1;
	endcolumnaxes;
	
	 
	layout overlay / 
		yaxisopts=(offsetmin=0.15 offsetmax=0.15 label="&leveltitle." reverse=true
				linearopts=(tickvaluelist=(&yticklist.) tickvalueformat=&levelfmt..))
		;
	highlowplot y=level low=start high=end / 
		type=bar
		barwidth=1
		display=(fill outline) 
		group=_grp 
		outlineattrs=(color=black);
	
	if (upcase("&responsetxt.")="TRUE")
	
		textplot x=eval(ifn(txtpos="right",response_text_x,.)) y=response_text_y text=response_text / 
					position=right;
					
		textplot x=eval(ifn(txtpos="left",response_text_x,.)) y=response_text_y text=response_text / 
				position=left;
		
	endif;
		
	endlayout;
	
	
	layout overlay / walldisplay=none
		yaxisopts=(display=none);
		
		textplot x=xtick_x y=xtick_y text=xtick_text / position=center textattrs=(size=10);
	endlayout;
	
	sidebar / align=bottom spacefill=false;
	if (upcase("&legend.")="TRUE")
		discretelegend "pairname" /title="&pairtitle." type=fill;
	endif;
	endsidebar;

endlayout;

endgraph;
end;
*-------------------------------;
* horizontal histogram;
*-------------------------------;
define statgraph histotree_h;
begingraph;

discreteattrvar attrmap="pairattrmap" var=grpid attrvar=_grp;

layout lattice / columns=2  columnweights=(2 8) rowdatarange=union;

	rowaxes;
		rowaxis / display=none offsetmin=0.1 offsetmax=0.1 reverse=true;
	endrowaxes;
	
	
	layout overlay / walldisplay=none
		xaxisopts=( display=none);
		
		textplot y=xtick_x x=xtick_y text=xtick_text / position=center textattrs=(size=10);
	endlayout;
	 
	layout overlay / 
	
		xaxisopts=(offsetmin=0.15 offsetmax=0.15 label="&leveltitle." reverse=true
				linearopts=(tickvaluelist=(&yticklist.) tickvalueformat=&levelfmt..))
		;
	highlowplot x=level low=start high=end / 
		type=bar
		barwidth=1
		display=(fill outline) 
		group=_grp 
		outlineattrs=(color=black);
	
	if (upcase("&responsetxt.")="TRUE")
	
		textplot y=response_text_x x=response_text_y text=response_text;
			
	endif;
		
	endlayout;
	
	
	sidebar / align=bottom spacefill=false;
	if (upcase("&legend.")="TRUE")
		discretelegend "pairname" /title="&pairtitle." type=fill;
	endif;
	endsidebar;

endlayout;

endgraph;
end;
run;


*-------------------------------;
* final step: graph output;
*-------------------------------;

ods graphics / pop;
ods listing style=&palette.;
ods graphics / antialiasmax=999999;

%if %upcase("&orient.")="V" %then %do;
	proc sgrender data=graph template=histotree_v dattrmap=attrmap ;
	run;
%end;

%if %upcase("&orient.")="H" %then %do;
	proc sgrender data=graph template=histotree_h dattrmap=attrmap ;
	run;
%end;	
%exit:

%mend multihistogram;
