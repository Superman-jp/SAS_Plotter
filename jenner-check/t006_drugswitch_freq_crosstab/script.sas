*--------------------------------------------------------;
*drug-switch data prep (second dataset in example/sankey_example.sas);
*--------------------------------------------------------;
/* Drug switching with a "lost to follow-up" sink (code 99) at four
   visits. Each subject (usubjid) has Day0, Day30, Day60, Day90 drug
   codes. The %sankey focus=... parameter examples downstream filter
   this dataset to highlight flows of interest. */

proc format;
value druglist
1="Drug A"
2="Drug B"
3="Drug C"
4="Drug D"
99="Lost to follow-up";

value timef
1="Day 0"
2="Day 30"
3="Day 60"
4="day 90"
;
run;

data drug_switch;
length usubjid $10 Day0 Day30 Day60 Day90 8;
format Day0 Day30 Day60 Day90 druglist.;
input usubjid $ Day0 Day30 Day60 Day90;
datalines;
A001 1 1 1 3
A002 1 1 1 4
A003 1 1 1 4
A004 1 1 1 4
A005 1 2 1 4
A006 1 3 1 4
A007 1 3 1 4
A008 1 4 1 99
A009 1 4 1 99
A010 1 1 2 2
A011 1 1 2 3
A012 1 1 2 3
A013 1 1 2 3
A014 1 2 2 4
A015 1 2 2 4
A016 1 3 2 4
A017 1 1 3 1
A018 1 1 3 2
A019 1 2 3 4
A020 1 2 3 4
A021 1 2 3 4
A022 1 3 3 4
A023 1 3 3 99
A024 2 4 2 4
A025 2 1 3 3
A026 2 1 3 3
A027 2 1 4 1
A028 2 1 4 2
A029 2 2 4 3
A030 2 2 4 4
;
run;

proc print data=drug_switch(obs=10);
   title "drug_switch: first 10 subjects (Day0 -> Day90)";
run;

proc freq data=drug_switch;
   tables Day0 Day90;
   title "univariate frequency at Day 0 and Day 90";
run;

proc freq data=drug_switch;
   tables Day0*Day90 / nopercent norow nocol;
   title "Day 0 x Day 90 crosstab (the source -> sink flow)";
run;
