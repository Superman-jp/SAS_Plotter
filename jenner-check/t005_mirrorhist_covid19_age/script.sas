*-------------------------------------------;
*covid19 age-by-sex categorical prep (from example/mirrored_histogram_example.sas);
*-------------------------------------------;
/* Public COVID-19 case counts for Tokyo 2021, broken out by age band
   and sex. The string age bands ("<10", "10s", ..., ">100", "unknown")
   are mapped via select/when to numeric codes whose order matches the
   agegrpf format. The %MirroredHist macro consumes this to draw a
   horizontal mirrored age pyramid by sex. */

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


proc print data=covid19_tokyo_2021;
   title "covid19_tokyo_2021: age band x sex x patient count";
run;

proc means data=covid19_tokyo_2021 sum;
   var patients;
   class sex;
   title "totals by sex";
run;
