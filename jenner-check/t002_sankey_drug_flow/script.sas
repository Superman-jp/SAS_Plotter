*--------------------------------------------------------;
*sankey data prep (from example/sankey_example.sas);
*--------------------------------------------------------;
/* Drug switching across four timepoints: day0, day30, day60, day120.
   Wide-form input; each subject (usubjid) has the drug code assigned
   at each visit. The %sankey macro consumes this layout and produces
   a Sankey diagram showing flow between drugs across visits. */

proc format;
value domainf
1="day0"
2="day30"
3="day60"
4="day120";

value nodef
0="Drug A"
1="Drug B"
2="Drug C"
3="Drug D"
4="Drug E"
;
run;


data raw;
usubjid+1;
input day0 day30 day60 day120;
format day0 day30 day60 day120 nodef.;
cards;
0 2 3 4
0 2 3 4
0 2 3 4
2 1 2 4
2 1 2 4
2 1 2 4
2 1 2 4
2 1 2 4
2 1 4 3
4 3 2 1
4 3 2 1
4 3 2 1
4 3 2 1
;
run;

proc print data=raw; title "raw: wide-form drug at each visit"; run;
proc freq data=raw; tables day0 day30 day60 day120; title "frequency of each drug at each visit"; run;
