*--------------------------------------------------------;
*SAS_plotter;
*ridgeline plot macro;
*author: SupermanJP;
*version: 1.1;
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
	legend = False,
	fill_density = True,
	stat = mean,
	rug = False,
	ruglength = 1,
	meancolor = red,
	qcolor = white,
	iqrcolor = cx89D0F5,
	palette=sns);
		
/*store ods setting*/

ods graphics / push;
ods graphics / reset=all;	

*--------------------------------------------------------;
*parameter check;
*--------------------------------------------------------;



%if %upcase("&palette.") ^= "SAS" and
    %upcase("&palette.") ^= "SNS" and
    %upcase("&palette.") ^= "STATA" and
    %upcase("&palette.") ^= "TABLEAU" %then %do;
    
    data _null_;
    put "WAR" "NING: palette parameter must be set SAS, SNS, STATA or Tableau";
    run;
    
    %goto exit;
    
%end;


	

%if "&xlabel." ="" %then %do;
	%let xlabel=%nrstr( );
%end;

%if "&ylabel." = "" %then %do;
	%let ylabel = %nrstr( );
%end;


*--------------------------------------------------------;
*get category format and  group format;
*--------------------------------------------------------;
*copy input data;
data ridge_temp1;
set &data.;

%if "&group."^="None" and "&group."^="&x." %then %do;
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


%if "&group."^="None" and "&group." ^="&x." %then %do;
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
%if "&group."^="None" and "&group"^="&x." %then %do;

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
	
*generate legend item;

	data ridge_grpattr;
	length tmp1 item item $5000 code $10000;
	set ridge_temp3 end=eof;
	retain code item;
	

		tmp1 = "legenditem type=fill name='group" || strip(put(_N_,8.0)) ||
				"' / fillattrs=GraphData" || strip(put(_N_, 8.0)) || 
				" label='" || strip(vvalue(&group.)) || "';";
		tmp2 = "'group" || strip(put(_N_, 8.0)) || "'";

		code = catx(" ", code, tmp1);
		item = catx(" ", item, tmp2);
		
		if eof then do;
			call symput('legenditem', code);
			call symput('legendname', item);
		end;
	
	
	run;
	
%end;

%else %do;
	data ridge_grpattr;
	length value $1000 id FillStyleElement $100;
	call missing(id ,value ,FillStyleElement);
	run;
%end;



*apply format;

data ridge_dat;
set ridge_temp2;

%if "&group."^="None" %then %do;
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
*number of group;
*--------------------------------------------------------;
proc sql noprint;
select count(distinct group) into: nlevel
from ridge_dat;
quit;


options locale=en_US;
*--------------------------------------------------------;
*KDE;
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
*marge descriptive stats and kde data;
*--------------------------------------------------------;
data ridge_kde_stat;

set ridge_ustat ridge_q;
if descr = "Mean" then stat="mean"; 
if percent = 25 then stat="q1"; 
if percent = 50 then stat="q2"; 
if percent = 75 then stat="q3"; 
if stat^="";
rename y=value;
keep x y group stat;
run;

data ridge_density_stat1;
set ridge_density ridge_kde_stat;
proc sort; by x group value;
run;

*--------------------------------------------------------;
*scaling density;
*--------------------------------------------------------;

proc means data=ridge_density_stat1 noprint;
var density;
output out=ridge_density_stat2 max=max_density;
run;

proc means data=ridge_density_stat1 noprint nway;
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
	from ridge_density_stat1) as a

left join (
	select max_density,
		1 as dmy
		from ridge_density_stat2) as b
		
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
*generate stat data for vector plot;
*--------------------------------------------------------;
*if density corresponding to descriptive stats is null,
then density is inserted the density of orevious record;

data ridge_density_scale2;
set ridge_density_scale;
by x group;

retain iqr;
lag_stat=lag(stat);
lag_dens = lag(density_scaled);

if first.group then iqr=.;

if stat^="" then density_scaled2 = lag_dens;


if stat="q1" then iqr=1;
if lag_stat="q3" then iqr=.;
drop lag_:;
run;
*--------------------------------------------------------;
*Generate data for rugplot;
*--------------------------------------------------------;

data ridge_rugplot;
set ridge_dat;
%if "&group."^="None" %then %do;
	format rug_group grpfmt.;
%end;

y_start = y;
y_end = y;
x_start= x ;
x_end= x + &cat_iv. / 20 *&ruglength.;
rug_group=group;
keep x_start y_start x_end y_end  rug_group;
run;


*--------------------------------------------------------;
*generate KDE plot data;
*--------------------------------------------------------;
data ridge_kdeplot1;
set ridge_density_scale2;
by x group;

retain fst_val group_dens 0;

if first.group then group_dens+1;


if stat="" then dens = -density_scaled + x;
else dens_stat = -density_scaled2 + x;

if first.x then fst_val=value;

run;
*--------------------------------------------------------;
*plot data;
*--------------------------------------------------------;
data ridge_plot;
merge ridge_kdeplot1 ridge_rugplot;
run;




proc template;
define statgraph ridge;
dynamic _XTICKS _YTICKS _XLABEL _YLABEL _VMIN _VMAX
		_STAT _FILL_KDE _MEANC _QC _IQRC  _LEGEND;
nmvar _NLEVEL;

begingraph /subpixel=on;

/*legenditem*/
&legenditem.;



layout overlay / walldisplay=none
	yaxisopts=(reverse=true label=_XLABEL
				linearopts=(tickvalueformat=xfmt. tickvaluelist=_XTICKS))
	
	xaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_YTICKS viewmin=_VMIN viewmax=_VMAX))
	;

referenceline y=x / lineattrs=(color=black);

if (upcase(_FILL_KDE)="TRUE" and _NLEVEL=1)
bandplot x=value limitupper=dens limitlower=x / 
		display=(fill)
		group =group_dens
		index=group
		name="band";
endif;	

if (upcase(_FILL_KDE)="TRUE" and _NLEVEL>1)
bandplot x=value limitupper=dens limitlower=x / 
		display=(fill)
		group =group_dens
		datatransparency=0.2
		index=group
		name="band";
endif;	


/*iqr*/
if (find(upcase(_STAT),"IQR")^=0)
vectorplot x=value y=eval(ifn(iqr=1, dens,.)) 
		xorigin=value yorigin=x /
		arrowheads=false
		lineattrs=(color=_IQRC thickness=3);
endif;
		
/* mean    */
if (find(upcase(_STAT), "MEAN")^=0)
vectorplot x=value y=eval(ifn(stat="mean", dens_stat,.)) 
		xorigin=value yorigin=x /
		arrowheads=false
		lineattrs=(color=_MEANC thickness=2);
endif;

/*q1*/
if (find(upcase(_STAT), "Q1")^=0)

vectorplot x=value y=eval(ifn(stat="q1", dens_stat,.)) 
		xorigin=value yorigin=x /
		arrowheads=false

		lineattrs=(color=_QC pattern=shortdash thickness=2);
endif;

/*q2 median*/

if (find(upcase(_STAT), "Q2")^=0)

vectorplot x=value y=eval(ifn(stat="q2", dens_stat,.)) 
		xorigin=value yorigin=x /
		arrowheads=false

		lineattrs=(color=_QC pattern=shortdash thickness=2);
endif;

/*q3*/
if (find(upcase(_STAT), "Q3")^=0)

vectorplot x=value y=eval(ifn(stat="q3", dens_stat,.)) 
		xorigin=value yorigin=x /
		arrowheads=false
		lineattrs=(color=_QC pattern=shortdash thickness=2);
endif;
	
/*rug plot*/

if (upper(_RUG)="TRUE")
vectorplot x=y_end y=x_end xorigin=y_start yorigin=	x_start / 
		group =rug_group
		arrowheads=false
		name="rug";
endif;


/*density plot (outline)*/

seriesplot x=value y=dens /
group=group_dens
lineattrs=(color=black thickness=2 pattern=solid)
;




/*legend*/
if (_NLEVEL^=1)
	if (upcase(_LEGEND)="TRUE" and upcase(_FILL_KDE)="TRUE")
		discretelegend  &legendname. "dummy"/ 
			title="&grplabel." 
			location=outside 
			across=1
			exclude=(".")
			halign=right;
	else 
		discretelegend "rug" / 
			title="&grplabel."
			location=outside 
			across=1
			exclude=(".")
			halign=right;
	endif;
endif;

endlayout;
endgraph;
end;
run;

ods graphics / pop;
ods listing style=&scheme.;
ods graphics / antialiasmax=999999;

proc sgrender data=ridge_plot template=ridge  ;
dynamic 
	_XTICKS="&xvaluelist."
		_YTICKS="&yticks."
		_XLABEL="&xlabel."
		_YLABEL="&ylabel."
		_VMIN=%scan(&yticks., 1, " ") 
		_VMAX=%scan(&yticks., -1, " ") 
		_STAT="&stat."
		_FILL_KDE="&fill_density"
		_RUG="&RUG."
		_MEANC = "&meancolor."
		_QC="&qcolor."
		_IQRC="&iqrcolor."
		_NLEVEL=&nlevel.
		_LEGEND="&legend."

		;
run;
%put &stat.;
%exit:
%mend;



