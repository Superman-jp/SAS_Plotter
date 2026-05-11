*--------------------------------------------------------;
*raincloud paired data generation (from example/raincloudpaired_example.sas);
*--------------------------------------------------------;
/* Seeded simulation of a two-period crossover design.
   Two treatments (placebo / drug A) measured at two repeats each.
   Subject-level lognormal response distributions with hand-tuned
   means and dispersions for each (trt, repno) cell. The %RainCloudPaired
   macro consumes this layout to draw the paired distributions side by
   side with subject connect lines. */

proc format;
value repeatf
1="period 1"
2="period 2";

value seqf
1="sequence A (placebo to drug A)"
2="sequence B (drug A to lacebo)"
;

value trtf
1="Placebo"
2="Drug A"
;

value groupf
1="Factor XXX (-)"
2="Factor XXX (+)";

run;

data raincloudtest;
call streaminit(1234);
format repno repeatf. trt seqf.;
label response="activity";


do trt=1 to 2;
do i=1 to 25;
do repno=1 to 2;

	usubjid="A" || strip(put(i,z3.0));

	     if trt=1 and repno=1 then response=rand("lognormal",3,0.2);
	else if trt=1 and repno=2 then response=rand("lognormal",3.5,0.23);
	else if trt=2 and repno=1 then response=rand("lognormal",3.4,0.21);
	else if trt=2 and repno=2 then response=rand("lognormal",2.8,0.17);

	if response < 0 then response=0;

	output;
end;
end;
end;
run;

proc print data=raincloudtest(obs=12);
   title "first 12 subjects: trt, repeat, response";
run;

proc means data=raincloudtest mean std min max maxdec=3;
   var response;
   class trt repno;
   title "summary by treatment and period";
run;
