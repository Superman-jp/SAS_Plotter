*--------------------------------------------------------;
*SAS_plotter;
*Mirrored histogram macro;
*author: SupermanJP;
*version: 1.0;
*--------------------------------------------------------;

%macro mirroredhist(
data=,
group=,
x=,
y=,
xticks=None,
yticks=,
xaxistype=discrete,
xlabel=x,
ylabel=y,
ytickfmt=9.9,
orient=v,
legend=true,
barwidth=1,
ymargin=1.1,
outline=true
);

/*initialize*/
%let stop=;
%let min_view=;
%let max_view=;
%let max_cat=;
%let catno=;
%let line=;
%let margin_err=;

*--------------------------------------------------------;
*Data check;
*--------------------------------------------------------;
%if %upcase("&outline.")="TRUE" %then
	%let line=outline;
;

/*number of category*/
proc sql noprint;
select count(distinct &group.) into: catno
from &data.;

select max(&group.) into: max_cat
from &data.;

quit;

/*if number of category  and max category is not two, stop macro*/

%if &max_cat.^=2 or &catno.^=2 %then %do;
	data _null_;
	put "ERROR: " "category is wrong";
	run;
	%goto exit;
%end;

/*if xaxistype is wrong stop macro*/
%if %upcase("&xaxistype.")^="DISCRETE" and %upcase("&xaxistype.")^="LINEAR" %then %do;
	data _null_;
	put "ERROR:" "xaxistype must be linear or discrete";
	run;
	%goto exit;
%end;

/*if orient is wrong, stop macro*/

%if %upcase("&orient.")^="H" and %upcase("&orient.")^="V" %then %do;
	data _null_;
	put "ERROR:" "orient setting is wrong";
	run;
	%goto exit;
%end;

/*if xticks option is "none", xticks will be genereated automatically*/

%if %upcase("&xticks.")="NONE" %then %do;

	proc sql noprint;
		select distinct &x. into : xticks separated by " "
		from &data.;
	quit;
	%put &xticks.;

%end;

/*generate yticks sequence*/
%inc "generate_ytick.sas";

/*if terminate flg is true, stop macro*/

%if &stop.=1 %then %do;
	data _null_;
	put "ERROR:" "yticks is wrong";
	run;
	%goto exit;
%end;

/*margin factor check*/

data _null_;
if prxmatch('/^\d\.?\d*$/',"&ymargin.")=0 then 
call symput("margin_err","1");

else if &ymargin.<1 then
call symput("margin_err","1");
run;

%if &margin_err.=1 %then %do;
	data _null_;
	put "ERROR:" "ymargin must be numeric and greater than 1";
	run;
	%goto exit;
%end;

*--------------------------------------------------------;
*generate plot;
*--------------------------------------------------------;
/*input data*/
data indata;
set &data.;
cat=&group.;
x=&x.;
y=&y.;
keep cat x y;
proc sort; by cat x;
run;

/*generate picture*/
proc format;
picture val(round default=10)
low-high="&ytickfmt.";
Run;


/*vertical style*/
proc template;
define statgraph vhist;
dynamic _XLABEL _YLABEL;
begingraph;

layout overlay / 
  walldisplay=none

  yaxisopts=(label=_YLABEL display=(line label ticks tickvalues) type=linear 
			linearopts=( tickvalueformat=val. tickvaluelist=(&yticks.)
			viewmin=&min_view. viewmax=&max_view. ))

%if %upcase("&xaxistype.")="DISCRETE" %then %do;
  xaxisopts=(label=_XLABEL display=(line label ticks tickvalues) type=discrete)
%end;

%if %upcase("&xaxistype.")="LINEAR" %then %do;
	xaxisopts=(label=_XLABEL display=(line label ticks tickvalues) type=linear linearopts=(tickvaluelist=(&xticks.)))
%end;
;

  barchartparm category=x response=eval(ifn(cat=2,-y,y))/
    group=cat
	display=(fill &line.)
    barwidth=&barwidth.
    outlineattrs=(color=black thickness=1)
    name="hist";

	%if %upcase("&legend.")="TRUE" %then %do;
	    discretelegend "hist";
	%end;

  referenceline y=0 / lineattrs=(color=black thickness=1);
    

endlayout;

endgraph;
end;
run;

/*horizontal style*/

proc template;
define statgraph hhist;
dynamic _XLABEL _YLABEL;
begingraph;

layout overlay / 
  walldisplay=none

  xaxisopts=(label=_YLABEL display=(line ticks label tickvalues) type=linear 
			linearopts=( tickvalueformat=val. tickvaluelist=(&yticks.)
			viewmin=&min_view. viewmax=&max_view. ))

%if %upcase("&xaxistype.")="DISCRETE" %then %do;
  yaxisopts=(label=_XLABEL reverse=true display=(line ticks label tickvalues) type=discrete)
%end;

%if %upcase("&xaxistype.")="LINEAR" %then %do;
  yaxisopts=(label=_XLABEL display=(line ticks label tickvalues) type=linear linearopts=(tickvaluelist=(&xticks.)))
%end;
;

  barchartparm category=x response=eval(ifn(cat=1,-y,y))/
    group=cat
	display=(fill &line.)
    barwidth=&barwidth.
    outlineattrs=(color=black thickness=1)
	orient=HORIZONTAL
    name="hist";

	%if %upcase("&legend.")="TRUE" %then %do;
	    discretelegend "hist";
	%end;
    
referenceline x=0 / lineattrs=(color=black thickness=1);

endlayout;

endgraph;
end;
run;


proc sgrender data=indata template=&orient.hist;

dynamic _XLABEL="&xlabel."
        _YLABEL="&ylabel.";
run;

%exit:
%mend;



