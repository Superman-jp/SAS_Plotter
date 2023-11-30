*--------------------------------------------------------;
*SAS_plotter;

*author: SupermanJP;
*version: 1.1;

*--------------------------------------------------------;

*--------------------------------------------------------;
*settings;
*--------------------------------------------------------;

%let plotter_dir = /home/centraldogma7771/sasuser.v94/SAS_Plotter/;



*--------------------------------------------------------;
*Load components;
*--------------------------------------------------------;

%include "&plotter_dir.\color_palette.sas";
%include "&plotter_dir.\RainCloud.sas";
%include "&plotter_dir.\RainCloudPaired.sas";
%include "&plotter_dir.\Ridgeline.sas";
%include "&plotter_dir.\mirrored_histogram.sas";
%include "&plotter_dir.\kde2d.sas";
%include "&plotter_dir.\sankey.sas";