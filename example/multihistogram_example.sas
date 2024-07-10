
*-------------------------------;
*multihistogram example;
*-------------------------------;

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
proc sort; by region eyes hair;
run;

/* dummy data */
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


*--------------------------------------------------------;
* basic multiple histogram;
*--------------------------------------------------------;

ods graphics / height=15cm width=15cm imagefmt=png imagename="multihisto_basic_v" ;
title "basic multiple histogram(vertical)";

%multihistogram(
    data=freq(where=(region=1)),
    category=eyes,
    level=hair,
    response=count,
    levelfmt =haircolorf,
	title=%nrstr(entrytitle 'your title here'),
	footnote=%nrstr(entryfootnote halign=left 'your footnote here';
				    entryfootnote halign=left 'your footnote here 2';)
);

ods graphics / height=15cm width=15cm imagefmt=png imagename="multihisto_basic_h" ;
title "basic multiple histogram(horizontal)";

%multihistogram(
    data=freq(where=(region=1)),
    category=eyes,
    level=hair,
    response=count,
	orient=h,
    levelfmt =haircolorf 
);

*--------------------------------------------------------;
* multiple histogram using pair variable;
*--------------------------------------------------------;
ods graphics / height=15cm width=15cm imagefmt=png imagename="multihisto_pair" ;
title " multiple histogram using pair variable";
%multihistogram(
    data=freq,
    category=eyes,
    pair=region,
    level=hair,
    response=count,
    levelfmt =haircolorf 
);

*--------------------------------------------------------;
* split node;
*--------------------------------------------------------;
ods graphics / height=15cm width=15cm imagefmt=png imagename="multihisto_split" ;
title "split mode";
%multihistogram(
    data=freq,
    category=eyes,
    pair=region,
    level=hair,
    response=count,
	pairsplit=true,
    levelfmt =haircolorf 
);
*--------------------------------------------------------;
* display response value;
*--------------------------------------------------------;
ods graphics / height=15cm width=15cm imagefmt=png imagename="multihisto_restxt" ;
title "basic multiple histogram";

%multihistogram(
    data=freq,
    category=eyes,
    pair=region,
    level=hair,
    response=count,
	responsetxt=true,
    levelfmt =haircolorf 
);
