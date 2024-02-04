*--------------------------------------------------------;
*SAS_plotter;
*ridgeline plot macro;
*author: SupermanJP;
*version: 1.2;
*--------------------------------------------------------;
%macro ridgeline(
	data=,
	x=,
	y=,
	group=None,
	xlabel=x,
	ylabel=y,
	yticks=,
	cat_iv = 1.2,
	gridsize = 401,
	bw_method = sjpi,
	bw_adjust = 1,
	
	quartile=False,
	mean=False,	
	
	legend = False,
	grouplegendtitle=group,
	
	rug = False,
	ruglength = 2,
	
	fillstyle=None,
	qgradient=1,
	palette=sns);
		
/*store ods setting*/

ods graphics / push;
ods graphics / reset=all;	

*--------------------------------------------------------;
*step1: parameter check and setting;
*--------------------------------------------------------;

%if %upcase("&group.")="NONE" and %upcase("&fillstyle.")="GROUP" %then %do;
    data _null_;
    put "WAR" "NING: group parameter should be set when fillstyle parameter is set 'GROUP'.";
    run;
    
    %goto exit;
%end;

%if %upcase("&group.")="NONE" and %upcase("&fillstyle.")="QUARTILE" %then %do;
    data _null_;
    put "WAR" "NING: group parameter should be set when fillstyle parameter is set 'QUARTILE'.";
    run;
    
    %goto exit;
%end;


%if %upcase("&fillstyle.") ^= "NONE" and
    %upcase("&fillstyle.") ^= "GROUP" and
    %upcase("&fillstyle.") ^= "QUARTILE"  %then %do;
    
    data _null_;
    put "WAR" "NING: fillstyle parameter should be set NONE, GROUP, STATA or QUARTILE";
    run;
    
    %goto exit;
%end;

%if %upcase("&palette.") ^= "SAS" and
    %upcase("&palette.") ^= "SNS" and
    %upcase("&palette.") ^= "STATA" and
    %upcase("&palette.") ^= "TABLEAU" %then %do;
    
    data _null_;
    put "WAR" "NING: palette parameter should be set SAS, SNS, STATA or Tableau";
    run;
    
    %goto exit;
    
%end;

%if "&xlabel." ="" %then %do;
	%let xlabel=%nrstr( );
%end;

%if "&ylabel." = "" %then %do;
	%let ylabel = %nrstr( );
%end;

/* quartile color gradient name */

%let gradname = gradient4_%lowcase(&qgradient.);

/* fill transparency  */
%let fill_transparency = 0.5;
*--------------------------------------------------------;
*step2: get category format and  group format;
*--------------------------------------------------------;
*copy input data;
data ridge_temp1;
set &data.;

%if %upcase("&group.")^="NONE" and "&group."^="&x." %then %do;
	proc sort; by &x. &group.;
	run;
%end;

%else %do;
	proc sort; by &x.;
	run;
%end;

*add sequence by x and group;
data ridge_temp2;
set ridge_temp1;


%if %upcase("&group.")^="NONE" and "&group." ^="&x." %then %do;
	by &x. &group.;
	retain x group 0;
	if first.&x. then do;
		x+1;
		group=1;
	end;
	
	else if not first.&x. and first.&group. then group+1;
%end;

%else %do;
	by &x.;
	retain x 0;
	if first.&x. then x+1;
	
	%if "&group."^="&x." %then %do;
	group=1;
	%end;
	
	%else %do;
	group=x;
	%end;
	
%end;
run;

*generate x format and value list;
proc sort data=ridge_temp2 nodupkey out=ridge_temp3; by x ;
run;
data ridge_xfmt;
length label $1000 tickvalue $2000;
set ridge_temp3 end=eof;
retain tickvalue;



fmtname="xfmt";
start=x*&cat_iv.;
end=x*&cat_iv.;
label=strip(vvalue(&x.));

if _N_=1 then
	tickvalue=strip(put(start, best.));
else
	tickvalue=catx(" ", tickvalue, strip(put(start, best.)));


if eof then call symputx("xvaluelist", tickvalue);
keep fmtname start end label;
run;
proc format cntlin=ridge_xfmt;
run;


*initialize macro variable for legenditem;
%let legenditem =;
%let legendname =;
%let grplabel = ;

*generate group format;
/* %if %upcase("&group.")^="NONE" and "&group"^="&x." %then %do; */

	proc sort data=ridge_temp2 nodupkey out=ridge_temp3; by group ;
	run;
	data ridge_grpfmt ;
	length label $1000;
	set ridge_temp3 end=eof;
	
	fmtname="grpfmt";
	start=group;
	end=group;
	label=strip(vvalue(&group.));
	
	*get label of group variable;
	if eof then call symputx("grplabel", vlabel(&group.));
	
	keep fmtname start end label;
	run;
	proc format cntlin=ridge_grpfmt;
	run;
	
/* %end; */

/* %else %do; */
/* 	data ridge_grpfmt; */
/* 	length label $1000; */
/*  */
/* 	call missing(start,end ,label); */
/* 	run; */
/* %end; */

*apply format;

data ridge_dat;
set ridge_temp2;

%if %upcase("&group.")^="NONE" %then %do;
	format x xfmt. group grpfmt.;
%end;

%else %do;
	format x xfmt.;
%end;

	
x=x*&cat_iv.;
y=&y.;
keep x y group;
run;

/* proc datasets lib=work noprint; */
/* delete ridge_temp: ridge_grp:; */
/* quit; */


*--------------------------------------------------------;
*step3: number of group;
*--------------------------------------------------------;
proc sql noprint;
select count(distinct group) into: nlevel
from ridge_dat;
quit;


options locale=en_US;
*--------------------------------------------------------;
*step4: KDE;
*--------------------------------------------------------;

ods output UnivariateStatistics=ridge_ustat Percentiles=ridge_q;
proc kde data=ridge_dat;

univar y / 
	out=ridge_density
	unistats
	percentiles
	ngrid=&gridsize.
	method=&bw_method.
	bwm=&bw_adjust.
	;
by x group;
run;

*--------------------------------------------------------;
*step5: marge descriptive stats and kde data;
*--------------------------------------------------------;
data ridge_kde_qtr1;

set ridge_ustat ridge_q;
if descr = "Mean" then stat="mean"; 
if percent = 25 then stat="q1"; 
if percent = 50 then stat="q2"; 
if percent = 75 then stat="q3"; 
if stat^="";
rename y=value;
keep x y group stat;
proc sort; by x group value;
run;

proc transpose data=ridge_kde_qtr1 out=ridge_kde_qtr2;
id stat;
by x group;
run;

/* quartile group */
data ridge_kde_qtr3;
merge ridge_density ridge_kde_qtr2;
by x group;

if value<=q1 then quartile_group=1;
else if value<=q2 then quartile_group=2;
else if value<=q3 then quartile_group=3;
else quartile_group=4;

if value >= mean then mean_group=1;

run;

*--------------------------------------------------------;
*step6: scaling density;
*--------------------------------------------------------;

proc means data=ridge_kde_qtr3 noprint;
var density;
output out=ridge_density_max max=max_density;
run;

proc means data=ridge_kde_qtr3 noprint nway;
var value;
class x group;
output out=ridge_value_minmax min=value_min max=value_max;
where count not in(.,0);
run;

proc sql noprint;

create table ridge_density_scale as
select a.*,
	a.density / b.max_density as density_scaled,
	c.value_min,
	c.value_max
from (
	select *,
		1 as dmy
	from ridge_kde_qtr3) as a

left join (
	select max_density,
		1 as dmy
		from ridge_density_max) as b
		
on a.dmy = b.dmy

left join (
	select x,
		group,
		value_min,
		value_max
	from ridge_value_minmax
	) as c
	
on a.x=c.x and a.group =c.group
order by a.x, a.group, a.value;
quit;

*--------------------------------------------------------;
*step7: generate stat data for vector plot;
*--------------------------------------------------------;
data ridge_outline_qtr;
set ridge_density_scale(rename=(group=q_group));
by x q_group quartile_group;

lag_density = lag(density_scaled);


if quartile_group^=1 and first.quartile_group then do;

select(quartile_group);
	when(2) q_start_x=q1;
	when(3) q_start_x=q2;
	when(4) q_start_x=q3;
end;

q_start_y=x;
q_end_x=q_start_x;
q_end_y = -((density_scaled+lag_density)/2) + x;

output;
end;

keep q_:;
run;

data ridge_outline_mean;
set ridge_density_scale(rename=(group=m_group));
by x m_group mean_group;
lag_density = lag(density_scaled);

if first.mean_group and mean_group=1 then do;
	m_start_x=mean;
	m_start_y=x;
	m_end_x=mean;
	m_end_y = -((density_scaled+lag_density)/2) + x;
	output;
end;

keep m_:;
run;

*--------------------------------------------------------;
*step8: Generate data for rugplot;
*--------------------------------------------------------;

data ridge_rugplot;
set ridge_dat;


y_start = y;
y_end = y;
x_start= x ;
x_end= x + &cat_iv. / 20 *&ruglength.;
rug_group=group;

%if %upcase("&group.")^="NONE" %then %do;
	format rug_group grpfmt.;
%end;

keep x_start y_start x_end y_end  rug_group;
run;


*--------------------------------------------------------;
*step9: generate KDE plot data;
*--------------------------------------------------------;
data ridge_kdeplot1;
set ridge_density_scale;
by x group quartile_group;

retain fst_val group_dens group_dens_qtr 0;

/* bandplot group */
if first.group then group_dens+1;
if first.quartile_group then group_dens_qtr+1;


dens = -density_scaled + x;

if first.x then fst_val=value;

run;
*--------------------------------------------------------;
*step10: plot data;
*--------------------------------------------------------;
data ridge_plot;
merge ridge_kdeplot1 
      ridge_rugplot
      ridge_outline_qtr
      ridge_outline_mean;
      
rename value=density_x;
run;

*--------------------------------------------------------;
*step11: attribute map dataset;
*--------------------------------------------------------;

proc sort data=ridge_kdeplot1 
		  out=_attrmap1 (keep=group_dens group) nodupkey;
by group_dens;
run;

proc sort data=ridge_kdeplot1 
		  out=_attrmap2(keep=group_dens_qtr quartile_group) nodupkey;
by group_dens_qtr;
run;

proc sort data=ridge_kdeplot1 
		  out=_attrmap3(keep= quartile_group) nodupkey;
by quartile_group;
run;

/* group name attribute (for legend)*/
data attrmap_groupname;
length id value $1000;
set ridge_grpfmt;
id="attrmap_groupname";
value=label;
fillstyle="GraphData" || strip(put(start,best.));
linestyle="GraphData" || strip(put(start,best.));
filltransparency=&fill_transparency.;
keep id value fillstyle linestyle filltransparency;
run;

/* group name  (for bandplot)*/
data attrmap_group;
length id value $1000;
set _attrmap1;
id="attrmap_group";
value=strip(vvalue(group_dens));
fillstyle="GraphData" || strip(put(group,best.));
linestyle="GraphData" || strip(put(group,best.));
filltransparency=&fill_transparency.;
keep id value fillstyle linestyle filltransparency ;
run;

/* quartile attribute (for bandplot)*/
data attrmap_qtr;
length id value $1000;
set _attrmap2;
id="attrmap_qtr";
value=strip(vvalue(group_dens_qtr));
fillcolor=scan("&&&gradname.",quartile_group, "#");
filltransparency=&fill_transparency.;
keep id value fillcolor filltransparency;
run;

/* quartile attribute (for legend)*/
data attrmap_qtrname;
length id value $1000;

set _attrmap3;
id ="attrmap_qtrname";
value=strip(vvalue(quartile_group));
fillcolor=scan("&&&gradname.",quartile_group, "#");
filltransparency=&fill_transparency.;
keep id value fillcolor filltransparency;
run;

%if %upcase("&group.")^="NONE" %then %do;
	data attrmap_mean;
	length id value $1000;
	set ridge_grpfmt;
	
		id ="attrmap_mean";
		
		value=label;
		
	    linestyle="GraphData" || strip(put(start,best.));
		
	
	keep id value linestyle;
	run;	
%end;

%else %do;
	data attrmap_mean;
	length id value $1000;
	set ridge_grpfmt;
	
		id ="attrmap_mean";
		
		value="";
		
	    linecolor="black";
		
	
	keep id value linecolor;
	run;	
%end;	

data attrmap;
set attrmap_groupname
	attrmap_group
	attrmap_qtrname
    attrmap_qtr
    attrmap_mean;
run;


*--------------------------------------------------------;
*step12: graph template;
*--------------------------------------------------------;
proc template;
define statgraph ridge;

begingraph /subpixel=on;

discreteattrvar attrmap="attrmap_qtr" var=group_dens_qtr attrvar=_grpqtr;
discreteattrvar attrmap="attrmap_group" var=group_dens attrvar=_grp;
discreteattrvar attrmap="attrmap_group" var=q_group attrvar=_qgrp;
discreteattrvar attrmap="attrmap_group" var=m_group attrvar=_mgrp;

layout overlay / walldisplay=none
	yaxisopts=(reverse=true label="&xlabel."
				linearopts=(tickvalueformat=xfmt. tickvaluelist=(&xvaluelist.)))
	
	xaxisopts=(label="&ylabel." linearopts=(tickvaluelist=(&yticks.) viewmin=%scan(&yticks., 1, " ") viewmax=%scan(&yticks., -1, " ") ))
	;


/*     fill of density plot */

if (upper("&group.")^="NONE" and upper("&fillstyle.")="GROUP")
bandplot x=density_x limitupper=dens limitlower=x / 
		display=(fill)
		group =_grp
		name="band";
endif;

if (upper("&group.")^="NONE" and upper("&fillstyle.")="QUARTILE")
bandplot x=density_x limitupper=dens limitlower=x / 
		display=(fill)
		group =_grpqtr
		name="band";
endif;
	
/* outline of quartile */

if (upper("&quartile.")="TRUE" and upper("&fillstyle.")^="NONE")
	vectorplot x=q_end_x y=q_end_y 
			xorigin=q_start_x yorigin=q_start_y /
			arrowheads=false
			lineattrs=(color=black thickness=1 pattern=solid);
endif;

if (upper("&quartile.")="TRUE" and upper("&fillstyle.")="NONE")
	vectorplot x=q_end_x y=q_end_y 
			xorigin=q_start_x yorigin=q_start_y /
			arrowheads=false
			group=_qgrp
			lineattrs=(thickness=1 pattern=shortdash);
endif;


if (upper("&quartile.")="TRUE" and upper("&group.")="NONE")
	vectorplot x=q_end_x y=q_end_y 
			xorigin=q_start_x yorigin=q_start_y /
			arrowheads=false
			group =_qgrp
			lineattrs=(color=black thickness=1 pattern=shortdash);
endif;

/* outline of mean */
if (upper("&group.")^="NONE" and upper("&mean.")="TRUE")

vectorplot x=m_end_x y=m_end_y 
		xorigin=m_start_x yorigin=m_start_y /
		arrowheads=false
		group=_mgrp
		lineattrs=(thickness=2 pattern=solid);
endif;

if (upper("&group.")="NONE" and upper("&mean.")="TRUE")

vectorplot x=m_end_x y=m_end_y 
		xorigin=m_start_x yorigin=m_start_y /
		arrowheads=false
		group=_mgrp
		lineattrs=(color=black thickness=2 pattern=solid);
endif;

/*rug plot*/

if (upper("&rug.")="TRUE" and upper("&group.")^="NONE")
vectorplot x=y_end y=x_end xorigin=y_start yorigin=	x_start / 
		group =rug_group
		arrowheads=false
		lineattrs=(pattern=solid)
		name="rug";
endif;

if (upper("&rug.")="TRUE" and upper("&group.")="NONE")
vectorplot x=y_end y=x_end xorigin=y_start yorigin=	x_start / 
		group =rug_group
		arrowheads=false
		lineattrs=(color=black pattern=solid)
		name="rug";
endif;


/*density plot (outline)*/
if (upper("&fillstyle.")="GROUP" or upper("&fillstyle.")="QUARTILE")
	seriesplot x=density_x y=dens /
	group=group_dens
	lineattrs=(color=black thickness=2 pattern=solid)
	;
endif;

if (upper("&fillstyle.")="NONE")
	seriesplot x=density_x y=dens /
	group=_grp
	lineattrs=(thickness=2 pattern=solid)
	;
endif;

if (upper("&group.")="NONE")
	seriesplot x=density_x y=dens /
	group=_grp
	lineattrs=(color=black thickness=2 pattern=solid)
	;
endif;

referenceline y=x / lineattrs=(color=black);


endlayout;


%if %upcase("&legend.")="TRUE" and (
   (%upcase("&fillstyle.")="GROUP" and %upcase("&group.")^="NONE") or
   (%upcase("&fillstyle.")="QUARTILE" and %upcase("&group.")^="NONE")or
    %upcase("&mean.")="TRUE") 
     %then %do;

	layout globallegend;
	
		if  (upper("&fillstyle.")="GROUP" and upper("&group.")^="NONE") 
			discretelegend "attrmap_groupname" / type=fillcolor title="&grouplegendtitle.";
		endif;		
	
		if (upper("&fillstyle.")="QUARTILE" and upper("&group.")^="NONE") 
			discretelegend "attrmap_qtrname" / type=fillcolor title="Quartile";
		endif;
		
		if (upper("&mean.")="TRUE")
			discretelegend "attrmap_mean"/ type=line title="Mean";
		endif;
		
	endlayout;

%end;



%else %if %upcase("&legend.")="TRUE" and 
	%upcase("&group.")^="NONE" and
	%upcase("&fillstyle.")="NONE" %then %do;

	layout globallegend;
	
		discretelegend "attrmap_groupname" / type=line title="&grouplegendtitle.";
	
		
		if (upper("&mean.")="TRUE")
			discretelegend "attrmap_mean"/ type=line title="Mean";
		endif;
		
	endlayout;

%end;
endgraph;
end;
run;
*--------------------------------------------------------;
*final step: graph output;
*--------------------------------------------------------;
ods graphics / pop;
ods listing style=&palette.;
ods graphics / antialiasmax=999999;

proc sgrender data=ridge_plot template=ridge  dattrmap=attrmap;

run;

%exit:
%mend;



