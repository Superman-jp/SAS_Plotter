*--------------------------------------------------------;
*grouped paired raincloud data generation (second dataset in example/raincloudpaired_example.sas);
*--------------------------------------------------------;
/* Two-population (FAS) by type x treatment design with normal-distributed
   responses. The population label "FAS" is set once and carried into
   every output row (implicit retain on character literal). %RainCloudPaired
   downstream uses cat= as the x-axis category and group=type for color. */

proc format;
value trtf
1="Placebo"
2="Drug A"
;

value groupf
1="Factor XXX (-)"
2="Factor XXX (+)";
run;

data raincloudtest2;

call streaminit(1234);
format trt trtf. type groupf.;
label response="log(AUC)" cat="population";

cat="FAS";
do type=1 to 2;
do i=1 to 25;
do trt=1 to 2;

	usubjid="A" || strip(put(i,z3.0));

	     if type=1 and trt=1 then response=rand("normal",0.8,0.15);
	else if type=1 and trt=2 then response=rand("normal",1.3,0.25);
	else if type=2 and trt=1 then response=rand("normal",1.0,0.17);
	else if type=2 and trt=2 then response=rand("normal",2.1 ,0.22);

	output;
end;
end;
end;
run;

proc print data=raincloudtest2(obs=12);
   title "first 12 subjects: cat, type, trt, response";
run;

proc means data=raincloudtest2 mean std min max maxdec=3;
   var response;
   class type trt;
   title "summary by type x treatment";
run;
