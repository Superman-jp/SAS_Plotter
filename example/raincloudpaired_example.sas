
*--------------------------------------------------------;
*raincloud paired example;
*--------------------------------------------------------;


*--------------------------------------------------------;
*simple paired raincloud plot;
*--------------------------------------------------------;

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
do i=1 to 100;
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

title " paired raincloud plot (vertical)";
ods graphics / reset=all imagefmt=png imagename="rainpair_simple_v" width=20cm height=20cm;

%RainCloudPaired(
		 data=raincloudtest,
		 x=trt,
		 y=response,
		 group=trt,
		 repeat=repno,
		 subject=usubjid,
		 orient=v,
		 yticks= 0 20 40 60 80,
		 note=%nrstr(entrytitle 'your title here';
		 			 entryfootnote halign=left 'your footnote here';
				     entryfootnote halign=left 'your footnote here 2';)
);

title "paired raincloud plot (horizontal)";
ods graphics / reset=all imagefmt=png imagename="rainpair_simple_h" width=20cm height=20cm;

%RainCloudPaired(
		 data=raincloudtest,
		 x=trt,
		 y=response,
		 group=trt,
		 repeat=repno,
		 subject=usubjid,
		 orient=h,
		 scale=width,
		 yticks= 0 20 40 60 80,
		 note=%nrstr(entrytitle 'your title here';
		 			 entryfootnote halign=left 'your footnote here';
				     entryfootnote halign=left 'your footnote here 2';)
);

*--------------------------------------------------------;
*grouped paired raincloud plot;
*--------------------------------------------------------;

data raincloudtest2;

call streaminit(1234);
format trt trtf. type groupf.; 
label response="log(AUC)" cat="population";

cat="FAS";
do type=1 to 2;
do i=1 to 100;
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

title "paired raincloud plot (grouped)";
ods graphics / reset=all imagefmt=png imagename="rainpaird_group" width=20cm height=15cm;

%RainCloudPaired(
		 data=raincloudtest2,
		 x=cat,
		 y=response,
		 group=type,
		 repeat=trt,
		 subject=usubjid,
		 orient=v,
		 legend=true,
		 yticks=0 0.5 1 1.5 2 2.5 3.0
);

*--------------------------------------------------------;
*connect line;
*--------------------------------------------------------;
title "paired raincloud plot with connect line";

ods graphics / reset=all imagefmt=png imagename="rainpaird_group_connect" width=20cm height=15cm;

%RainCloudPaired(
		 data=raincloudtest2,
		 x=cat,
		 y=response,
		 group=type,
		 repeat=trt,
		 subject=usubjid,
		 orient=v,
		 legend=true,
	     connect=true,
		 yticks=0 0.5 1 1.5 2 2.5 3.0
);
