.. SAS Plotter documentation master file, created by
   sphinx-quickstart on Sun Jul 24 18:24:25 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.
   
#######################################
Introduction
#######################################

The data visualization method widely used at present lacks information on the distribution pattern hidden in the raw data, and has a drawback that it is difficult to judge whether the sample distribution assumption, which is the premise of the hypothesis test, is correct.

In recent years, new data visualization methods that overcome such drawbacks have been announced and are already available in open source languages such as R and python. In contrast, the SAS language has made little effort as seen in open source languages.

"SAS plotter" is modern graph package for SAS. You can easily create advanced graphs for journals with little knowledge of SAS GTL (Graph Template Language) or sgplot procedures.

the lengthens data format is suitable.


******************
history
******************

- 0.1 (beta version)

   three macros were added.
      * Raincloud plot
      * RainCloud plot (paired)
      * Ridgeline plot



******************
requirement
******************

SAS base 9.4 or later

SAS GRAPH 9.4 or later

******************
custom style
******************

this package is contained following custom styles.

these styles make the SAS defalut color palette (GraphData1-GraphData10) replaced.

all graph font is set "Times New Roman".

- **sns_default**

   default color palette of python grahics package,"Seaborn".

- **mpl_set2**
   color palette "set2" of python graphics package, "Matplotlib".





