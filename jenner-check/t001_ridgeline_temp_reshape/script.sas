*-------------------------------------------;
/*ridgeline data preparation (from example/ridgeline_example.sas)*/
/* Tokyo and Naha daily maximum temperatures Jan-Jul 2023, then
   reshape long for ridgeline plotting (one row per region per day) */
*-------------------------------------------;

data raw;
infile datalines delimiter=',';
length col1 $10;
format date yymmdd10.;
input col1 $  tokyo  naha ;
date = input(col1,yymmdd10.);
drop col1;

datalines;
2023/1/1,13,19.8
2023/1/2,12.1,19.4
2023/1/3,11,21.4
2023/1/4,11,19.5
2023/1/5,10.6,20.4
2023/1/6,9.9,21.7
2023/1/7,10.4,19.4
2023/1/8,12.5,21.2
2023/1/9,13.9,22.5
2023/1/10,9.9,22.8
2023/1/11,10.7,23.3
2023/1/12,12.6,24.3
2023/1/13,14,25.4
2023/1/14,14.2,25.3
2023/1/15,12,22.6
2023/2/1,13.1,23.2
2023/2/15,7.8,17.2
2023/3/1,19.4,23.5
2023/3/15,17.9,24.1
2023/4/1,23.3,24.3
2023/4/15,18,26
2023/5/1,22.5,24.6
2023/5/15,18.1,25.3
2023/6/1,26.2,26.6
2023/6/15,24.1,28
2023/7/1,27.8,32
2023/7/15,32.9,32.8
2023/7/31,36.1,30.9
;
run;


proc format ;
value regionf
1="Tokyo"
2="Naha";
run;

data max_temp;
set raw;
format region regionf.;
label max_temp="maximum temperature (degree Celsius)"
      month="Month"
      region="Region";

month=month(date);
year=year(date);
region=1; max_temp=tokyo;output;
region=2; max_temp=naha; output;
keep year month  date region max_temp;
run;

proc print data=max_temp(obs=15); title "max_temp: long form, 2 rows per date"; run;

proc means data=max_temp mean min max maxdec=2;
   var max_temp;
   class month region;
   title "monthly summary by city";
run;
