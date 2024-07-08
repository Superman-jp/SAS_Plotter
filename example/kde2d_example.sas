*-------------------------------------------;
/*2D-KDE example*/
*-------------------------------------------;

filename raw url "https://raw.githubusercontent.com/mwaskom/seaborn-data/master/penguins.csv";

PROC IMPORT OUT= WORK.penguines 
            DATAFILE= raw 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 guessingrows=max;
RUN;
*-------------------------------------------;
/* grouped KDE plot */
*-------------------------------------------;

ods graphics /  height=24cm width=24cm imagename="groupedKDE" imagefmt=svg;
%kde2d(
   data=penguines,
   x=bill_length_mm,
   y=bill_depth_mm,
   group=species,
   univar_style=line,
   bivar_nlevel=10,
   bivar_style=line,
   xlabel=bill_length (mm),
   ylabel=bill_depth (mm),
   legend=true

);


*-------------------------------------------;
/* style of KDE plot */
*-------------------------------------------;

ods graphics /  height=24cm width=24cm imagename="linefillKDE" imagefmt=svg;

%kde2d(
   data=penguines(where=(species='Chinstrap')),
   x=bill_length_mm,
   y=bill_depth_mm,
   group=species,
   univar_style=fill,
   bivar_nlevel=10,
   bivar_style=linefill,
   bivar_grid=100,
   xlabel=bill_length (mm),
   ylabel=bill_depth (mm),
   legend=true,
   legendtitle=
);


*-------------------------------------------;
/* Diaplay individual data?*/
*-------------------------------------------;


ods graphics /  height=24cm width=24cm imagename="rugscatterKDE" imagefmt=svg;

%kde2d(
   data=penguines(where=(species='Chinstrap')),
	x=bill_length_mm,
	y=bill_depth_mm,
	group=species,
	univar_style=line,
	bivar_nlevel=10,
	bivar_style=line,
	bivar_grid=100,
	xlabel=bill_length (mm),
	ylabel=bill_depth (mm),
	legend=true,
	rug=true,
	scatter=true
);

*-------------------------------------------;
/* Thresh parameter*/
*-------------------------------------------;

ods graphics /  height=24cm width=24cm imagename="threshKDE" imagefmt=svg;

%kde2d(
       data=penguines(where=(species='Chinstrap')),
      x=bill_length_mm,
      y=bill_depth_mm,
      group=species,
      univar_style=line,
      bivar_nlevel=10,
      bivar_style=linefill,
      bivar_grid=100,
      xlabel=bill_length (mm),
      ylabel=bill_depth (mm),
      thresh=0.002,
      legend=true,
      rug=true,
      scatter=true
);
