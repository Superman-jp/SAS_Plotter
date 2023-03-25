#######################################
Raincloud plot
#######################################

***************
What's this?
***************

Macro for generate raincloud plot using SAS GRAPH.

Raincloud plot is contained density plot (half-violin plot) , box plot and strip plot.

density plot displays distribution estimated by KDE (kernel density estimation) of input data.

box plot displays discriptive statistics (mean, q1, q2, q3 outlier).

strip plot is jittered scatterplot and displays individual data. 

more information is described in following paper.

Allen M, Poggiali D, Whitaker K et al. Raincloud plots: a multi-platform tool for robust data visualization [version 2; peer review: 2 approved]. Wellcome Open Res 2021, 4:63 (https://doi.org/10.12688/wellcomeopenres.15191.2)


*****************
Input data
*****************

.. csv-table:: 

   "**key**", "**variable** ", "**type**"
   "1","category","numeric or string"
   "2","group", "numeric or string"
   "","response", "numeric"


group variable is optional. 

I recommended that the variable type of category and group are set to numeric with format.
if the variable type is string, item order is defined as acending character order.


***************
Syntax
***************
before use this macro, macro file described below is loaded by %include statement.

- RainCloud.sas

 ::

   ods graphics / < graphics option > ;
   ods listing gpath=< output path >;

    %RainCloud(
		 data=,
		 x=,
		 y=,
		 group=None,
		 yticks=, 
		 xlabel=x,
		 ylabel=y,
		 cat_iv=2.5,
		 element_iv=0.02,
		 scale=area,
		 trim=True,
		 connect=false,
		 gridsize=401,
		 bw_method=sjpi,
		 bw_adjust=1,
		 orient=v, 
		 legend=false,
		 jitterwidth=0.1,
		 outlinewidth=1);
		 

***************
Parameters
***************
- **data : dataset name (required)**

   input data. keep, rename and  where options are available.

- **x : variable name (required)**

   category variable


- **y : variable name (required)**

   response variable


- **group : variable name (optional)**

   group variable for grouping data at each category.

   when the parameter is not set, all of graph object is set same color.

   when the parameter is set category variable, the graph object of rach category is 
   set  different color.

   default is "None".


- **xlabel : string (optional)**

   label string of category axis.
   default is "x". when the label is not displayed , set like below.

   xlabel=,


- **ylabel : string (optional)**

   optional. label string of response axis.
   default is "y". when the label is not displayed , set like below.

   ylabel=,


- **yticks : numeric list (required)**

   tickvalue list of response axis.
   the list is set as the numeric list separated by space .
   the item of the list should be set ascending order.

   ex. yticks = 10 20 30 40,


- **cat_iv : numeric (optional)**

   the interval of category.
   the default is 2.5.

- **element_iv : numeric (optional)**

   the interval of density plot, boxplot and strip plot.
   the default is 0.02.

- **scale: area or width (optional)**

    The method used to scale the width of each density plot.

    If area, each plot will have the same area. 
    If width, each plot will have the same width.

    when the density plots are far different each other, width keyword may be useful.
    the default is "area".

- **trim: bool (optional)**

    if True the density outside of observed data range will be trimmed.
    the default is "True".

    If area, each plot will have the same area. 
    If width, each plot will have the same width.

    when the density plots are far different each other, width keyword may be useful.

- **connect: bool (optional)**

    if True the mean values in same group are connected by solid line.
    the default is "False". 

- **gridsize : integer (optional)**

   the number of KDE gridsize.
   default is 401 (the default of proc kde)


- **bw_method : keyword (optional)**

   the bandwidth estimation method of KDE.
   default is "sjpi" (the default of proc kde).

   method keyword described below is available.

      * sjpi (Sheather-Jones plug-in)
      * snr (simple normal reference)
      * snrq (simple normal reference that uses the interquartile range)
      * srot (Silverman's rule of thumb)
      * os (oversmoothed)

- **bw_adjust : numeric (optional)**

   the bandwidth multiplier. Increasing will make the curve smoother.

   the default is 1. 

- **legend : bool (optional)**

   if "True", legend of group item is displayed.
   if group parameter is "None", the parameter will be ignored.

   default is "False".

- **orient : v or h (optional)**

    Orientation of the plot (vertical or horizontal). 

    the default is "v".

- **jitterwidth : numeric(between 0 and 1) (optional)**

    jitter width of strip plot. Increasing this parameter may be made the data point overlapped on boxplot.

    the default is "0.05".

- **outlinewidth : numeric (optional)**

    outline width of density plot and boxplot.

    the default is "1".



***************
example
***************

Simple raincloud plot
=======================

in this example, dataframe "tips" in python package "Seaborn" is used.

datasets (tips)

.. csv-table:: 

   "**variable** ", "**detail**"
   "day","Thur, Fri, Sat, Sun"
   "total_bill", "numeric"
   "smoker","numeric with format, 1=Yes, 2=No"
   "time","numeric with format, 1=Lunch, 2=Dinner"

code ::

   ods graphics /reset=all height=15cm width=25cm imagename="rain_simple" imagefmt=svg;
   ods listing  gpath="/home/user/sasuser.v94/image" style=sns_default ;

    %RainCloud(data=import,
                x=day,
                y=total_bill,
                group=day,
                cat_iv=2.5,
                element_iv=0.5,
                xlabel=day, 
                ylabel=Total bill(USD),
                yticks=%str(0 20 40 60),
                bw_method=srot
                );

output

.. image:: ./img/rain_simple.svg

when orient parameter is set "h", the orientation of plot is changed horizontal (x=response, y=category)


.. image:: ./img/rain_simple_h.svg

    
Grouped raincloud plot
=======================

code ::

   ods graphics /reset=all height=15cm width=25cm imagename="rain_simple" imagefmt=svg;
   ods listing  gpath="/home/user/sasuser.v94/image" style=sns_default ;

    %RainCloud(data=import,
                x=day,
                y=total_bill,
                group=smoker,
                cat_iv=2.5,
                element_iv=0.5,
                xlabel=day, 
                ylabel=Total bill(USD),
                yticks=%str(0 20 40 60),
                bw_method=srot
                orient=h,
                legend=True
                );

output

.. image:: ./img/rain_group.svg

when connect parameter is set "True", mean of each group is connected.

connect = True

.. image:: ./img/rain_group_connect.svg


Trim parameter
=======================

if Trim parameter is set "False", the density plot is displayed at all range.
but the density outside of observed data range may be ambiguos.

code ::

   ods graphics /reset=all height=15cm width=25cm imagename="rain_simple" imagefmt=svg;
   ods listing  gpath="/home/user/sasuser.v94/image" style=sns_default ;

    %RainCloud(data=import,
                x=day,
                y=total_bill,
                group=smoker,
                cat_iv=2.5,
                element_iv=0.5,
                xlabel=day, 
                ylabel=Total bill(USD),
                yticks=%str(-20 0 20 40 60),
                trim=False,
                bw_method=srot
                orient=h,
                legend=True
                );

output

.. image:: ./img/rain_group_nontrim.svg

Scale parameter
=======================

if scale parameter is set "area", all areas under density plot is same.
In below example, the density plot of the "vesicolor" and "Verginica" is broad so 
density peak is displayed small.   

code ::

   ods graphics /reset=all height=15cm width=25cm imagename="rain_area" imagefmt=svg;
   ods listing  gpath="/home/user/sasuser.v94/image" style=sns_default ;

    %RainCloud(data=sashelp.iris,
                x=species,
                y=petalwidth,
                group=species,
                xlabel=Species,
                ylabel=Petal Width (cm),
                yticks=0 10 20 30 40,
                cat_iv=1.5,
                element_iv=0.3,
                trim=false,
                scale=area,
                bw_method=srot
                );

output

.. image:: ./img/rain_area.svg

if scale parameter is set "width", width od all density plot is same.
the density plot of the "vesicolor" and "Verginica" is magnified.
it is easy to see density peak.

note:
density plot is "non-quantitative". and density plots using "width" keyword can't be performed relative comparison.

code ::

   ods graphics /reset=all height=15cm width=25cm imagename="rain_width" imagefmt=svg;
   ods listing  gpath="/home/user/sasuser.v94/image" style=sns_default ;

    %RainCloud(data=sashelp.iris,
                x=species,
                y=petalwidth,
                group=species,
                xlabel=Species,
                ylabel=Petal Width (cm),
                cat_iv=1.5,
                element_iv=0.3,
                trim=false,
                scale=width,
                gridsize=401,
                bw_method=srot,
                yticks=0 10 20 30 40
                );

.. image:: ./img/rain_width.svg