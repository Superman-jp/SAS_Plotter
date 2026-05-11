*-------------------------------;
*multihistogram data prep (from example/multihistogram_example.sas);
*-------------------------------;
/* Two-region survey of hair-color x eye-color counts. The raw data are
   sparse (some combinations have zero observations), so the pattern
   merges a full dummy grid (region x eyes x hair) with the observed
   counts to produce a dense table that %multihistogram can render. */

proc format;
value regionf
    1="Region 1"
    2="Region 2"
    ;
value eyecolorf
    1="blue"
    2="brown"
    3="green"
    ;

value haircolorf
    1="black"
    2="dark"
    3="fair"
    4="medium"
    5="red";
run;

data Color;
format region regionf. eyes eyecolorf. hair haircolorf.;
input Region Eyes Hair Count @@;
label Eyes  ='Eye Color'
        Hair  ='Hair Color'
        Region='Geographic Region';

datalines;
1 1 3 23  1 1 5 7   1 1 4 24
1 1 2 11  1 3 3 19  1 3 5 7
1 3 4 18  1 3 2 14  1 2 3 34
1 2 5 5   1 2 4 41  1 2 2 40
1 2 1 3   2 1 3 46  2 1 5 21
2 1 4 44  2 1 2 40  2 1 1 6
2 3 3 50  2 3 5 31  2 3 4 37
2 3 2 23  2 2 3 56  2 2 5 42
2 2 4 53  2 2 2 54  2 2 1 13
;
proc sort data=color; by region eyes hair;
run;

/* dummy data: full grid of region x eyes x hair so missing cells are 0 */
data dummy;
do region =1 to 2;
do eyes = 1 to 3;
do hair = 1 to 5;
output;
end;
end;
end;
run;

data freq;
merge dummy color;
by region eyes hair;
if count=. then count=0;
run;

proc print data=freq(obs=15);
   title "freq: dense grid after merge with dummy";
run;

proc means data=freq sum;
   var count;
   class region eyes;
   title "totals by region x eyes";
run;
