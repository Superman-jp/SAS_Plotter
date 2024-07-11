*--------------------------------------------------------;
*raincloud example ;
*--------------------------------------------------------;

filename raw url "https://raw.githubusercontent.com/mwaskom/seaborn-data/master/tips.csv";

PROC IMPORT OUT= WORK.raw 
            DATAFILE= raw 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 guessingrows=max;
RUN;

proc format;
value dayf
1="Mon"
2="Tue"
3="Wed"
4="Thu"
5="Fri"
6="Sat"
7="Sun"
;
run;

data tips;
set raw(rename=(day=day_old));
format day dayf.;
label total_bill="Total bill (USD)"
      day="day of week";

select (day_old);
	when ("Thur") day=4;
	when ("Fri") day=5;
	when("Sat") day=6;
	when("Sun") day=7;
	otherwise put "WAR" "NING: irregular string" day_old;
end;
drop day_old;
run;


*--------------------------------------------------------;
*simple raincloud plot;
*--------------------------------------------------------;
title "simple vertical raincloud plot";
ods graphics /reset=all height=15cm width=25cm imagename="rain_simple" imagefmt=png;
 %RainCloud(data=tips,
             x=day,
             y=total_bill,
			 cat_iv=2.5,
			 element_iv=0.5,
             group=day,
             yticks=0 20 40 60,
             bw_method=srot,
			 note=%nrstr(entrytitle 'your title here';
			 		     entryfootnote halign=left 'your footnote here';
				   	     entryfootnote halign=left 'your footnote here 2';)
             );

title "simple horizontal raincloud plot";
ods graphics /reset=all height=25cm width=15cm imagename="rain_simple_h" imagefmt=png;
 %RainCloud(data=tips,
             x=day,
             y=total_bill,
			 cat_iv=2.5,
			 element_iv=0.5,
             group=day,
             yticks=0 20 40 60,
			 orient=h,
             bw_method=srot,
			 note=%nrstr(entrytitle 'your title here';
			 		     entryfootnote halign=left 'your footnote here';
				         entryfootnote halign=left 'your footnote here 2';)
             );

*--------------------------------------------------------;
*grouped raincloud plot;
*--------------------------------------------------------;
title "grouped raincloud plot";
ods graphics /reset=all height=25cm width=15cm imagename="rain_grouped" imagefmt=png;


 %RainCloud(data=tips,
             x=day,
             y=total_bill,
             group=smoker,
             cat_iv=2.5,
             element_iv=0.5,
             yticks=%str(0 20 40 60),
             bw_method=srot,
             orient=h,
             legend=True
             );

title "raincloud plot with connect line";
ods graphics /reset=all height=15cm width=25cm imagename="rain_grouped_connect" imagefmt=png;

/*add connect line*/
 %RainCloud(data=tips,
             x=day,
             y=total_bill,
             group=smoker,
             cat_iv=2.5,
             element_iv=0.5,
             yticks=%str(0 20 40 60),
             bw_method=srot,
             orient=v,
			 connect=true,
             legend=True
             );

*--------------------------------------------------------;
*trim parameter;
*--------------------------------------------------------;
title "raincloud plot with trim parameter";
ods graphics /reset=all height=25cm width=15cm imagename="rain_trim" imagefmt=png;


 %RainCloud(data=tips,
             x=day,
             y=total_bill,
             group=smoker,
             cat_iv=2.5,
             element_iv=0.5,
             yticks=-20 0 20 40 60,
             bw_method=srot,
			 trim=false,
             orient=h,
             legend=True
             );


*--------------------------------------------------------;
*scale parameter;
*--------------------------------------------------------;
title "raincloud plot with scale parameter (area)";
ods graphics /reset=all height=15cm width=25cm imagename="rain_area" imagefmt=png;

 %RainCloud(data=sashelp.iris,
             x=species,
             y=petalwidth,
             group=species,
             xlabel=Species,
             ylabel=Petal Width (cm),
             yticks=0 10 20 30 40,
             cat_iv=1.5,
			 orient=h,
             element_iv=0.3,
             trim=false,
             scale=area,
             bw_method=srot
             );

title "raincloud plot with scale parameter (width)";
ods graphics /reset=all height=15cm width=25cm imagename="rain_width" imagefmt=png;

 %RainCloud(data=sashelp.iris,
             x=species,
             y=petalwidth,
             group=species,
             xlabel=Species,
             ylabel=Petal Width (cm),
             yticks=0 10 20 30 40,
             cat_iv=1.5,
			 orient=h,
             element_iv=0.3,
             trim=false,
             scale=width,
             bw_method=srot
             );
