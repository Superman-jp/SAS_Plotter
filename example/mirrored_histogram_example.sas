*-------------------------------------------;
/*Mirrored histogram example*/
*-------------------------------------------;

proc univariate data=sashelp.heart;
var diastolic systolic;
histogram   diastolic systolic /
  outhistogram=histo
  vscale=percent
  noplot
  midpoints=50 to 400 by 5;
run;

proc format;
value catf
1="Diastolic"
2="Systolic";
run;

data graph_data;
set histo;
if _VAR_="Diastolic" then cat=1;
if _VAR_="Systolic" then cat=2;
format cat catf.;
keep cat _midpt_ _obspct_;
run;

*-------------------------------------------;
/*vertical histogram*/
*-------------------------------------------;
title "vertical mirrored histogram";

ods graphics / height=15cm width=25cm imagefmt=png imagename="mirroredhist_v";
%MirroredHist(
	data=graph_data,
	group=cat,
	x=_midpt_,
	y=_obspct_,
	xaxistype=linear,
	xticks=50 100 150 200 250 300,
	yticks=5 10 15 20 25,
	xlabel=Blood pressure (mmHg),
	note=%nrstr(entrytitle 'your title here';
			    entryfootnote halign=left 'your footnote here';
				entryfootnote halign=left 'your footnote here 2';)
);

*-------------------------------------------;
/*adjust y-tick format*/
*-------------------------------------------;
title "mirrored histogram with y-tick format";

ods graphics / height=15cm width=25cm imagefmt=png imagename="mirroredhist_v_fmt";
%MirroredHist(
	data=graph_data,
	group=cat,
	x=_midpt_,
	y=_obspct_,
	xaxistype=linear,
	ytickfmt=09.00,
	xticks=50 100 150 200 250 300,
	yticks=5 10 15 20 25 ,
	xlabel=Blood pressure (mmHg)
);

*-------------------------------------------;
/*horizontal histogram (linear) */
*-------------------------------------------;
title "horizontal mirrored histogram (linear)";

ods graphics / height=15cm width=25cm imagefmt=png imagename="mirroredhist_h_linear";
%MirroredHist(
	data=graph_data,
	group=cat,
	x=_midpt_,
	y=_obspct_,
	xaxistype=linear,
	xticks=50 100 150 200 250 300,
	yticks=5 10 15 20 25,
	orient=h,
	xlabel=Blood pressure (mmHg),
	note=%nrstr(entrytitle 'your title here';
			    entryfootnote halign=left 'your footnote here';
				entryfootnote halign=left 'your footnote here 2';)
);

*-------------------------------------------;
/*horizontal histogram (discrete) */
*-------------------------------------------;

proc format;
value sexf
1="Male"
2="Female";

value agegrpf
1="<10"
2="10s"
3="20s"
4="30s"
5="40s"
6="50s"
7="60s"
8="70s"
9="80s"
10="90s"
11=">100"
99="unknown"
;

run;

data covid19_tokyo_2021;

infile datalines delimiter=",";
length sexc $10 agec $20 patients 8;
format sex sexf. agegrp agegrpf.;
input sexc $ agec $ patients;

select (sexc);
	when ("Male") sex=1;
	when("Female")sex=2;
end;

select(agec);
	when("<10") agegrp=1;
	when("10s") agegrp=2;
	when("20s") agegrp=3;
	when("30s") agegrp=4;
	when("40s") agegrp=5;
	when("50s") agegrp=6;
	when("60s") agegrp=7;
	when("70s") agegrp=8;
	when("80s") agegrp=9;
	when("90s") agegrp=10;
	when(">100") agegrp=11;
	when("unknown")agegrp=99;
end;

datalines;
Male,<10,8011
Male,10s,13821
Male,20s,49695
Male,30s,37503
Male,40s,30862
Male,50s,21952
Male,60s,8544
Male,70s,5202
Male,80s,2930
Male,90s,654
Male,>100,22
Male,unknown,4
Female,<10,7519
Female,10s,12359
Female,20s,43162
Female,30s,25594
Female,40s,20121
Female,50s,15931
Female,60s,6238
Female,70s,4872
Female,80s,4196
Female,90s,1765
Female,>100,116
;
run;


title "horizontal mirrored histogram (discrete)";

ods graphics / height=15cm width=25cm imagefmt=png imagename="mirroredhist_h_discrete";
%MirroredHist(
	data=covid19_tokyo_2021,
	group=sex,
	x=agegrp,
	y=patients,
	xaxistype=discrete,
	yticks=0 10000 20000 30000 40000 50000,
    ytickfmt=%str(00,009),
	xlabel=age,
	ylabel=number of patients,
	orient=h
);
