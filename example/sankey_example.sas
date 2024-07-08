*--------------------------------------------------------;
*sankey example;
*--------------------------------------------------------;

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
*--------------------------------------------------------;
*basic sankey;
*--------------------------------------------------------;
ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_basic" noborder;
title "Bacic Sankey";
ods html;
%sankey(
    data=raw,
    domain=day0 day30 day60 day120,
    domainfmt=domainf
);


*--------------------------------------------------------;
*Adjust the domain interval;
*--------------------------------------------------------;

proc format;
value domain2f
1="day0"
2="day30"
3="day60"
5="day120";
run;

ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_change_intervals" noborder;
title "Adjust the domain interval";
ods html;
%sankey(
    data=raw,
    domain=day0 day30 day60 day120,
    domainfmt=domain2f
);

*--------------------------------------------------------;
*Node format and legend;
*--------------------------------------------------------;

proc format;
value domain3f
1="day0"
2="day60"
;
run;
ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_not_set_nodefmt" noborder;
title "not set nodefmt parameter";
ods html;
%sankey(
    data=raw,
    domain=day0 day60,
    domainfmt=domain3f,
	legend=true
);
ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_set_nodefmt" noborder;
title "set nodefmt parameter";
ods html;
%sankey(
    data=raw,
    domain=day0 day60,
    domainfmt=domain3f,
	nodefmt=nodef,
	legend=true
);
*--------------------------------------------------------;
*change the node appearance;
*--------------------------------------------------------;

ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_set_nodeattrs" noborder;
title "change_the_node color";
ods html;
%sankey(
    data=raw,
    domain=day0 day30 day60 day120,
    domainfmt=domainf,
	nodeattrs=(color=grey)
);


*--------------------------------------------------------;
*change the link appearance;
*--------------------------------------------------------;
ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_set_linkattrs" noborder;
title "change the link color";
ods html;
%sankey(
    data=raw,
    domain=day0 day30 day60 day120,
    domainfmt=domainf,
	linkattrs=(color=skyblue transparency=0.7)
);

*--------------------------------------------------------;
*change the text appearance;
*--------------------------------------------------------;

ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_set_textattrs" noborder;
title "change the text appearance";
ods html;
%sankey(
    data=raw,
    domain=day0 day30 day60 day120,
    domainfmt=domainf,
	 domaintextattrs=(color=red size=12),
    nodetextattrs=(color=blue size=12),
    linktext_offset=0.05,
    linktextattrs=(color=green size=8)
);

*--------------------------------------------------------;
*focus parameter;
*--------------------------------------------------------;
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
A031 2 2 4 4
A032 2 3 4 4
A033 2 3 4 4
A034 2 99 99 99
A035 2 99 99 99
A036 3 1 4 2
A037 3 2 4 4
A038 3 3 4 99
A039 3 1 99 99
A040 3 1 99 99
A041 3 99 99 99
A042 4 4 3 99
A043 4 1 99 99
A044 4 2 99 99
;
run;



ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_focus1" noborder;
title "focus parameter example 1";
%sankey(
   data=drug_switch,
   domain=day0 day30 day60 day90,
   domainfmt=timef,
   focus=(source_node=1),
   gap=1,
   reverse=true,
   nodewidth=0.1,
   nodename=false,
   stat=freq,
   legend=true,
   linktext_offset=0.03,
   palette=sns);

ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_focus2" noborder;
title "focus parameter example 2";
%sankey(
   data=drug_switch,
   domain=day0 day30 day60 day90,
   domainfmt=timef,
   focus=(target_node=99),
   gap=1,
   reverse=true,
   nodewidth=0.1,
   nodename=false,
   stat=freq,
   legend=true,
   linktext_offset=0.03,
   palette=sns);

   ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_focus3" noborder;
title "focus parameter example 3";
%sankey(
   data=drug_switch,
   domain=day0 day30 day60 day90,
   domainfmt=timef,
   focus=(domain=2),
   gap=1,
   reverse=true,
   nodewidth=0.1,
   nodename=false,
   stat=freq,
   legend=true,
   linktext_offset=0.03,
   palette=sns);

   ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_focus4" noborder;
title "focus parameter example 4";
%sankey(
   data=drug_switch,
   domain=day0 day30 day60 day90,
   domainfmt=timef,
   focus=((domain=1 and source_node=2) or (next_domain=4 and target_node=99)),
   gap=1,
   reverse=true,
   nodewidth=0.1,
   nodename=false,
   stat=freq,
   legend=true,
   linktext_offset=0.03,
   palette=sns);

*--------------------------------------------------------;
* percentage of Followup;
*--------------------------------------------------------;   

   ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_endfollowup" noborder;
title "percentage of Followup";
%sankey(
   data=drug_switch,
   domain=day0 day30 day60 day90,
   domainfmt=timef,
   gap=1,
   reverse=true,
   nodewidth=0.1,
   nodename=false,
   endfollowup=99,
   stat=freq,
   legend=true,
   palette=sns);
