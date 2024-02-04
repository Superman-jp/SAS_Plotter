#######################################
MultiHistogram
#######################################

***************
What's this?
***************

Macro for multihistogram using SAS GRAPH.

multihitogram is histogram created by each category variable and pair variable. Box width of histogram is reflect the response variable.
multihistogram is used for frequency comparison of multiple category in small display area.

This macro was designed based on the report of Wierenga, Madison R et al. :footcite:p:`multiplehistogram`



***************
Input data
***************

Input data should be summarized data. To summarize raw data, proc univariate is useful.
the format of category, pair, and level variable is required.

.. csv-table:: 

   "**key**", "**variable** ", "**type**"
   "1","category","numeric"
   "2","pair(optional)","numeric"
   "3","level", "numeric"
   "","response", "numeric"

***************
Syntax
***************

 ::

    ods graphics / < graphics option > ;
    ods listing gpath=< output path >;

    %macro multihistogram(
    	data=,
    	group=,
    	pair=none,
    	level=,
    	levelfmt=,
    	response=,
    	leveltitle=level,
    	responsetxt=false,
    	orient=v,
    	pairsplit=false,
    	pairtitle=pair,
    	legend=true,
    	palette=sns
    );

***************
Parameters
***************

- **data : dataset name (required)**

   input data. where and rename options are available but keep option is not.

- **category : variable name (required)**

   category variable. 

- **pair : variable name (optional)**

   binomial variable such as YES/NO or Male/Female etc. default is "None".

- **level : variable name (required)**

   level variable. 

- **levelfmt : format name (required)**

   format of level variable. 

- **response : variable name (required)**

   response variable such as frequency or percentage.

- **leveltitle : text (optional)**

   label of level axis. default is "Level".

- **responsetxt : bool (optional)**

   if True the response value will be displayed. default is "false".

- **orient : keyword  (optional)**

   Define the orientation of graph, vertical(v) or horizontal(h). default is "v".

- **pairsplit : bool (optional)**

   if True the histogram will be split by pair variable. default is "False".

- **pairtitle : text  (optional)**

   title of pair variable legend. if legend parameter is set "False", this parameter will be ignored.
   default is "Pair".

- **legend : bool (optional)**

   if "True" the legend of pair variable is displayed.if pair parameter is "None", this parameter will be ignored.
   default is "True".

- **palette : keyword (optional)**

   color palette for fill, line and markers. the palettes described below is available.
   see color palette section of introduction page. default is "SNS" (Seaborn default palette).

      * SAS
      * SNS (Seaborn)
      * STATA
      * TABLEAU

***************
example
***************
=============================
Basic multiple histogram
=============================

before use, the aggregation of data is required.

code ::

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

    /* basic multiple histogram */

    ods listing gpath="output path";
    ods graphics / height=15cm width=15cm imagefmt=svg imagename="multihisto_basic" ;

    %multihistogram(
        data=freq,
        category=eyes,
        pair=region,
        level=hair,
        response=count,
        levelfmt = haircolorf,
        leveltitle=hair color,
        pairtitle=region
    );

.. image:: ./img/multihisto_basic.svg

Pair parameter is optional. If pair parameter is not set, the bar color will be defined based on the level.

code ::

    %multihistogram(
        data=freq(where=(region=1)),
        category=eyes,
        level=hair,
        response=count,
        levelfmt = haircolorf,
        leveltitle=hair color,
        pairtitle=region
    );

.. image:: ./img/multihisto_basic_nopair.svg

=============================
orientation
=============================

To create horizontal multiple histogram, the orient parameter is set "h".

code ::

    %multihistogram(
        data=freq,
        category=eyes,
        pair=region,
        level=hair,
        response=count,
        orient=h,
        levelfmt = haircolorf,
        leveltitle=hair color,
        pairtitle=region
    );

.. image:: ./img/multihisto_h.svg

=============================
split mode
=============================

when normal mode (pairsplit=false),  the bar of histogram will be extended side by side symmetrically like violin plot.

whereas when split mode (pairsplit=true), the symmetrical histogram will be separated based on pair variable.

code ::

    %multihistogram(
        data=freq,
        category=eyes,
        pair=region,
        level=hair,
        response=count,
        pairsplit=true,
        levelfmt = haircolorf,
        leveltitle=hair color,
        pairtitle=region
    );

.. image:: ./img/multihisto_pairsplit.svg

=============================
display response value
=============================
Basic multiple histogram is difficult to read the response value from the plot because there is not response variable axis.
but if responsetxt parameter is set "true". the response value will be displayed.
code ::

    %multihistogram(
        data=freq,
        category=eyes,
        pair=region,
        level=hair,
        response=count,
        responsetxt=true,
        levelfmt = haircolorf,
        leveltitle=hair color,
        pairtitle=region
    );

.. image:: ./img/multihisto_resvalue.svg

***************
Reference
***************
.. footbibliography::