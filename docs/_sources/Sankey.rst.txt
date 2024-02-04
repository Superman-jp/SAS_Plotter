#######################################
Sankey diagram (Alluvial Diagram)
#######################################

***************
What's this?
***************

Macro for Sankey diagram using SAS GRAPH.

To be more precise, it is called alluvial Diagram.

A Sankey diagram is a visualization used to depict a flow from one domain of values to another domain. 
Sankey graphs is useful for showing flow and relationships among multiple categories.



In pharmacoepidemiology study, this diagram is used for changes of the state of a patient over time, such as medication switching, disease stage progression,
or movement through treatment pathways. :footcite:p:`https://doi.org/10.1002/pds.5529`.

In the past, there are reports of sankey diagram example using SAS GRAPH :footcite:p:`barchartSankey`:footcite:p:`SASofficialSankey`. 
But in this macro, more options such as statistics display and node focus are available.

If you can allow the use of HTML, I suggest you refer to the case study of using D3.js and SAS :footcite:p:`sankeywithSASandD3js`. 


============================
Elements of Sankey diagram
============================
Sankey diagram is contained the three elements.

.. image:: ./img/elements_of_sankey_diagram.png

- domain

   the group of data as x-axis

- Node

   the category. displays as rectangle shape.

- link (flow)

   sigmoid shapes connected from node (source node) to next node (target node). amounts of flow are displays as widths of sigmoid shapes.
   the links connect the nodes in order left domain to right domain.

============================
Rules
============================

      * the nodes are stacked in node category order.
      * all records of the input data are displayed in the all domains.
      * nodes in the first domain should be source node only, not target node.
      * the nodes of last domain should be target node only, not source node.  
      * Circular links are not allowed. 

*****************
Input data
*****************
the node categories are set to each domain variables like below.
I recommended that the node category format is applied to each domain variable.
the domain variables should be numeric. 

null value is allowed. null value is defined as null node and same as other nodes.


.. csv-table:: 

   "**domain1**", "**domain2** ", "**domain3**"
   "node A", "node B", "node C"
   "node B", "node A", "node C"
   "node D", "node A", "node B"


the domain format is required. 


code ::

    proc format;
      value domainfmt
      1="Domain 1"
      2="Domain 2"
      3="Domain 3"
    ;
    run;

***************
Syntax
***************

::

    ods graphics / < graphics option > ;
    ods listing gpath=< output path >;

   %macro sankey(
      data=,
      
      domain=,
      domainfmt=,
      domaintextattrs=(color=black size=11),
      gap=5,
      
      nodefmt=auto,
      nodewidth=0.2,
      nodeattrs=auto,
      nodename=true,
      nodetextattrs=(color=black size=9),
      
      linktext=true,
      linktext_offset=0.05,
      linkattrs=auto,
      linktextattrs=(color=black size=8),
      
      reverse=false,
      focus=None,
      endFollowup=None,
      stat=both,
      unit=,
      
      legend=false,
      palette=sns);
            

***************
Parameters
***************

- **data : dataset name (required)**

   input data. keep and rename options are available but keep option is not.
   input data is copied to work library and keep only domain variable set to domain parameter.

================
Domain settings
================

- **domain : variable name (required)**

   domain variable. domain variables are set in link order.
   for example, if domain parameter is set as "var1 var2 var3", the var1 and var2, var2 and var3 are connected.

- **domainfmt : variable name (required)**

   format for domain variable. format catalog should be saved in work library and value should be numeric.
   interval of domains is depends on the values of format. labels of the format are displayed on plot.

- **domaintextattrs : text appearance (optional)**
- 
   The appearance (font size, font color and font weights) of domain text. it is same as textattrs of GTL. default is “(size=11 color=black).

================
Node settings
================

- **gap : numeric (optional)**

   the gap between nodes. default is 5.

- **nodefmt : keyword or format name (optional)**

   format for nodes. if "auto" is set, format is obtained from domain variable in input data.
   if you want to display the node which is not existed in input data in the legend. the node format should be set to this parameter. format catalog should be saved in work library.
   default is "auto".


- **nodewidth : numeric (optional)**

   the width of node shapes. the default is 0.2.

.. image:: ./img/nodewidth.png

- **nodeattrs : keyword or fill appearance  (optional)**

   node appearance (color, transparency). it is same as fillattrs option of GTL.
   if "auto" is set, the fill color of nodes are set based on the node category. 
   if you want to be set same color to all the nodes.fill attribute is set to this parameter.

   for example, the fill appearance described below is set and the all nodes is set blue.

   nodeattrs=(color=blue)

   default is "auto".

- **nodename : bool (optional)**
   displays the node name (node category name) in the sankey diagram.
   default is "true".

- **nodetextattrs : text appearance  (optional)**

   The node text appearance (font size, font color and font weights).
   It is same as textattrs option of GTL.
   default is "(size=9 color=black).

================
Link settings
================

- **linkattrs : fill appearance (optional)**

   fill appearance of link shapes (color, transparency). it is same as fillattrs option of GTL. if the fill appearance is set to this parameter, all the links will be applied.
   default is "auto". fill color is defined as source node type.

- **linktext : bool (optional)**

   display the link text (frequency or percentage). the text will be displays at the source node side of the links.default is "true".


- **linktext_offset : numeric (optional)**

   the gap between node shape and link text.
   default is 0.15.

.. image:: ./img/linktext_offset.png

- **linktextattrs : text appearance  (optional)**

   the appearance (font size, font color and font weights) of link text. It is same as textattrs option of GTL.
   default is "(size=8 color=black).

================
Other settings
================

- **reverse : bool (optional)**

   if True the y-axis will be reversed. default is False.

- **focus : subset-if statement (optional)**

   specify the focused links. The links except for focused links will be set grey color and link text will be not displayed.
   The focused links are specified by nodes connected by focused links using subset if statement.
   variables that can be used for subset if are as follows.

      * domain: domain of source_node
      * next_domain:  domain of target_node
      * source_node: source node of focused link
      * target_node: target node of focused link


   for example, when links connected from "type A" node (source node) of domain 2 is focused, set the parameter described below. value of type A node is 1.

   focus=(source_node=1 and domain=2)

   default is "none" (not focused).

- **EndFollowup : node (optional)**

   specify the node of end of follow-up. 
   The color of node specified this parameter will be set grey and the percentage of follow-up at each domain will be displayed at the bottom of Sankey diagram.
   default is "none" (not specified). 

   the percentage of follow-up is calculated using following equation.

   %follow-up = (total number - number of EndFollowup) / Total number * 100

- **stat : keyword (optional)**

   displays the frequency or percentage of nodes and links.
   the keyword described below is available. default is "both".

      * FREQ: frequency
      * PCT:  percentage(displays second decimal place)
      * BOTH: frequency and percentage
      * NONE: not displayed

    the percentage is calculated using following equation.

    percentage = frequency of nodes or links / number observation of input data * 100

- **unit : text (optional)**

   the units of frequency (suffix). if "FREQ" or "BOTH" keyword is set to the stat parameter, 
   the units of frequency is displayed in the node text and link text.

   default is "" (null).

- **legend : bool (optional)**

   if "True" the legend of node category item is displayed.
   default is "false".

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
Basic sankey diagram
=============================

the regimen changes of the patients is displayed as sankey diagram using this macro.
variables (day0, day30, day60, day120) are selected regimen of the patient at 0 ,30, 60 and 120days.
these variables is set the regimen types.

code ::

    proc format;
    value domainf
    1="day0"
    2="day30"
    3="day60"
    4="day120";

    value nodef
    0="Regimen A"
    1="Regimen B"
    2="Regimen C"
    3="Regimen D"
    4="Regimen E"
    5="Regimen F"
    6="Regimen G"
    7="Regimen H"
    8="Regimen I"
    ;
    run;

    data graph;
    set raw;
    format day0 day30 day60 day120 nodef.;
    run;

    ods graphics / height=15cm width=20cm imagefmt=svg imagename="sankey_basic" noborder;
    ods listing gpath="<output path>";
    %sankey(
        data=graph,
        domain=day0 day30 day60,
        domainfmt=domainf
    );

.. image:: ./img/sankey_basic.svg

=============================
Adjust the domain interval
=============================

The interval of the domain is defined as the values of the domain format.
when the domain format values are adjusted, then interval of the domain will be changed.

if the format is changed described below, the plot of the previous section "basic sankey diagram"
is as follows.

code ::

    proc format;
    value domainf
    1="day0"
    2="day30"
    4="day60"
    8="day120";

.. image:: ./img/sankey_change_interval.svg

=============================
Node format and legend
=============================

If the codes of the previous section "basic sankey diagram" is changed as described below, the color of the "Regimen E", "Regimen G" and 
"Regimen I" is different from the previous section.

By default, the color of the nodes is defined based on the input data and domain variables. 
when the input dataset is modified, the color of the nodes might be changed even though same node.

code ::

    %sankey(
        data=raw,
        domain=day0 day30,
        domainfmt=domainf,
        legend=true
    );

.. image:: ./img/sankey_not_set_nodefmt.svg

if nodefmt parameter is set, the color of the nodes defined based on the node format. The node color is independent from dataset.
All elements of the format is displayed in the legend if legend parameter is true.

code ::

    %sankey(
        data=raw,
        domain=day0 day30,
        domainfmt=domainf,
        ndoefmt=nodef,
        legend=true
    );

.. image:: ./img/sankey_set_nodefmt.svg

=============================
Change the fill appearance
=============================
By default, the node color and the link color are defined based on the node category.
If the nodeattrs or linkattrs are set, the fill color of the all the nodes or links will be changed.
Nodefmt parameter will be ignored.

code ::

    %sankey(
        data=raw,
        domain=day0 day30 day60 ,
        domainfmt=domainf,
        nodeattrs=(color=grey)
    );

.. image:: ./img/sankey_set_nodeattrs.svg

code ::

    %sankey(
        data=raw,
        domain=day0 day30 day60 ,
        domainfmt=domainf,
        linkattrs=(color=skyblue transparency=0.7)
    );

.. image:: ./img/sankey_set_linkattrs.svg

=============================
Change the text appearance
=============================

The domaintextattrs, nodetextattrs and linktextattrs parameters are useful for modify text appearance of 
domains, nodes and links.

code ::

    %sankey(
        data=raw,
        domain=day0 day30 day60 ,
        domainfmt=domainf,
        domaintextattrs=(color=red size=12),
        nodetextattrs=(color=blue size=12),
        linktext_offset=0.05,
        linktextattrs=(color=green size=8)
    );

.. image:: ./img/sankey_set_textattrs.svg


=============================
Focus parameter
=============================
The focus parameter is useful for the highlighting specified links.
The not-highlighted links are set grey color and the link texts are not displayed.

focus links are specified by nodes connected by focus links and
the nodes is specified conditional statement (subset-if).

the nodes described below are available to specify the focus links.


code ::

    proc format;
    value domainf
    1="day 0"
    2="day 30"
    3="day 60"
    4="day 90";

    value nodef

    1="Drug A"
    2="Drug B"
    3="Drug C"
    4="Drug D"
    5="Lost to Follow-up"
    ;
    run;

    data graph;
    set raw;

    format var1-var4 nodef.;
    run;

------------------------------------------------------------
example 1: links whose source_node is 1 (Drug A)
------------------------------------------------------------
code ::

   ods graphics / height=20cm width=25cm imagefmt=svg imagename="sankey_focus" noborder;
   ods listing gpath="<output path>";

   %sankey(
      data=raw,
      focus=(source_node=1),
      domain=var1 var2 var3 var4,
      domainfmt=domainf,
      gap=1,
      reverse=true,
      nodewidth=0.1,
      nodename=false,
      stat=freq,
      legend=true,
      linktext_offset=0.03,
      palette=sns);


.. image:: ./img/sankey_focus1.svg

------------------------------------------------------------
example 2: links whose target_node is 5 (Lost to followup)
------------------------------------------------------------

::

   focus=(target_node=5)

.. image:: ./img/sankey_focus2.svg

------------------------------------------------------------
example 3: links whose domain is 2 (Day 30)
------------------------------------------------------------

::

   focus=(domain=2)

.. image:: ./img/sankey_focus3.svg

------------------------------------------------------------
example 4: multiple condition
------------------------------------------------------------

::

	focus=((domain=1 and source_node=2) or (next_domain=4 and target_node=5)) 

.. image:: ./img/sankey_focus4.svg


=============================
Percentage of Followup
=============================

code ::

   ods graphics / height=20cm width=25cm imagefmt=svg imagename="sankey_endfollowup" noborder;
   ods listing gpath="<output path>";

   %sankey(
      data=raw,
      domain=var1 var2 var3 var4,
      domainfmt=domainf,
      gap=1,
      reverse=true,
      nodewidth=0.1,
      nodename=false,
      stat=freq,
      legend=true,
      linktext_offset=0.03,
      endfollowup=5,
      palette=sns);

.. image:: ./img/sankey_endfollowup.svg

***************
Reference
***************
.. footbibliography::