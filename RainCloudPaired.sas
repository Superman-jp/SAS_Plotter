
*--------------------------------------------------------;
*SAS_plotter;
*raincloud plot (paired) macro;
*author: SupermanJP;
*version: 1.0;
*--------------------------------------------------------;

%macro RainCloudPaired(
		 data=,
		 x=,
		 y=,
		 repeat=,
		 subject=,
		 group=None,
		 yticks=, 
		 ylabel=y,
		 cat_iv=1.6,
		 element_iv=0.4,
		 connect=False,
		 spaghetti=True,
		 scale=area,
		 trim=True,
		 gridsize=401,
		 bw_method=sjpi,
		 bw_adjust=1,
		 orient=v, 
		 legend=false,
		 jitterwidth=0.05,
		 outlinewidth=1);
		 
/*store ods setting*/

ods graphics / push;
ods graphics / reset=all;		
	
data rain_temp1;
set &data.;
%if "&group" ^="None" and "&group." ^= "&x." %then %do;
proc sort; by &x. &repeat. &group.;
%end;
%else %do; 
proc sort; by &x. &repeat.;
%end;
run;


*--------------------------------------------------------;
*generate sequence by x, repeat and group;
*sort: sequence of combination of x and repeat;
*--------------------------------------------------------;

%let legenditem = ;
%let legendname = ;
%let grplabel = ;

%if "&group."^="None" and "&group." ^="&x." %then %do;
		
	data rain_temp2;
	set rain_temp1;
	by &x. &repeat. &group.;
	retain x sort group 0;
	
	if first.&x. then x+1;
	
	if first.&repeat. then sort+1;
	if first.&repeat. and first.&group. then group=2*(x-1)+1;
	else if first.&group. then group+1;
	run;
%end;
%else %do;
	
	data rain_temp2;
	set rain_temp1;
	by &x. &repeat.;
	retain x sort 0;
	if first.&x. then x+1;
	
	if first.&repeat. then sort+1;
	
	%if "&group." ^="&x." %then %do;
		group=1;
	%end;
	%else %do;
		group=x;
	%end;
	run;
%end;


*--------------------------------------------------------;
*generate group format;
*--------------------------------------------------------;

%if "&group."^="None" and "&group"^="&x." %then %do;

	proc sort data=rain_temp2 out=rain_grpfmt1(keep=&group. group) nodupkey; by group;
	run;
	
	data rain_grpfmt2;
	length label $1000;
	set rain_grpfmt1 end=eof;
	fmtname="grpfmt";
	start=group;
	end=group;
	label=vvalue(&group.);
	
	*get label of group variable;
	if eof then call symputx("grplabel", vlabel(&group.));
	
	keep fmtname start end label;
	run;
	
	proc format cntlin=rain_grpfmt2;
	run;

*--------------------------------------------------------;
*generate legend item;
*--------------------------------------------------------;

	data rain_grpattr;
	length tmp1 item item $5000 code $10000;
	set rain_grpfmt1 end=eof;
	retain code item;
	

		tmp1 = "legenditem type=fill name='group" || strip(put(_N_,8.0)) ||
				"' / fillattrs=GraphData" || strip(put(_N_, 8.0)) || 
				" label='" || strip(vvalue(&group.)) || "';";
		tmp2 = "'group" || strip(put(_N_, 8.0)) || "'";

		code = catx(" ", code, tmp1);
		item = catx(" ", item, tmp2);
		
		if eof then do;
			call symput('legenditem', code);
			call symput('legendname', item);
		end;
	
	
	run;
%end;
%else %do;
	data ridge_grpattr;
	length value $1000 id FillStyleElement $100;
	call missing(id ,value ,FillStyleElement);
	run;
%end;


*--------------------------------------------------------;
*generate x-ticks and repeat-ticks;
*input data;
*--------------------------------------------------------;
data rain_dat;

length xtick reptick $100 subject $500;
set rain_temp2;
y=&y.;

%if "&group"^="None" and "&group."^="&x." %then %do;
	subject=catx("-", put(x,8.0), put(group, 8.0), put(&subject.,best.));
%end;

%else %do;
	subject=catx("-", put(x,8.0), put(&subject.,best.));
%end;

xtick=strip(vvalue(&x.));
reptick=strip(vvalue(&repeat.));

keep x y sort group subject xtick reptick ;
proc sort; by x sort group;
run;

*--------------------------------------------------------;
*KDE;
*--------------------------------------------------------;

proc kde data=rain_dat;

univar y / out=rain_density
		   method=&bw_method. 
		   bwm=&bw_adjust.;
		   
by x sort group;
run;


*--------------------------------------------------------;
*Scaling density;
*--------------------------------------------------------;

proc means data=rain_density nway noprint;
	var value;
	class x sort group;
	where count^=0;
	output out=rain_stat(keep=x sort group min max) min=min max=max;
run;

*scaling based on area (areas of all violin plot are same);
*scale the max density of input data to 1;
proc means data=rain_density noprint;
	var density count;
	class x sort group;
	output out=rain_max max(density)=max_density max(count)=max_count;
run;


%if %upcase("&scale.") ="AREA" %then %do;

	proc sql noprint;
		create table rain_density_scale as 
			select a.*,
				   a.density / b.max_density as density_scaled
			from (
				select *, 1 as dmy
				from rain_density
				)as a
			inner join (select max_density ,
							   1 as dmy
						from rain_max 
						where x=. and sort=. and group=.) as b
			on a.dmy=b.dmy
			order by a.sort, a.group;
	quit;

%end;

*scaling based on violin plot width;
*scale the max density of each violin plot to 1;

%if %upcase("&scale.") ="WIDTH" %then %do;

	proc sql noprint;
		create table rain_density_scale as 
			select a.*,
				   a.density / b.max_density as density_scaled
			from rain_density as a
			inner join (select * 
						from rain_max 
						where x^=. and sort^=.  and group^=.) as b
			on a.x=b.x and a.sort=b.sort and a.group = b.group
			order by a.sort, a.group;
	quit;

%end;

*--------------------------------------------------------;
*Adjust plot interval;
*--------------------------------------------------------;

	proc sql noprint;
		select max(density_scaled)*&cat_iv. into:cat_width 
		from rain_density_scale;
		
		
		*number of group level;
		select count(distinct group) into:nlevel from rain_dat;
	quit;

*--------------------------------------------------------;
*Generate dummy axis variable;
*--------------------------------------------------------;

	proc sort data=rain_dat(keep=sort ) nodupkey out=rain_cat;
		by sort;
	run;

	data rain_dummy;
		length tickvalue $2000;
		set rain_cat end=eof;
		retain tickvalue;
		retain dum_x 0;
		
		if mod(sort, 2)=0 then dum_x + round(&cat_width., 0.001);
		else dum_x + round(&cat_width.* 2, 0.001);
		
		if _N_=1 then
			tickvalue=strip(put(dum_x, best.));
		else
			tickvalue=catx(" ", tickvalue, strip(put(dum_x, best.)));


	if eof then
		call symputx("xvaluelist", tickvalue);

	run;

	*--------------------------------------------------------;
	*Generate dataset for half violin plot;
	*--------------------------------------------------------;

	*generate density identifier;
	proc sql noprint;

	create table rain_density2 as
	select a.*,
		b.min,
		b.max,
		c.dum_x
	from rain_density_scale as a
	left join rain_stat as b

	on a.sort=b.sort and a.group=b.group

	left join rain_dummy as c
	on a.sort = c.sort
	order by a.sort, a.group;
	quit;

	data rain_density3;
		set rain_density2;
		by sort group;
		
		retain dens_id 0;
		
		if first.group then
			dens_id+1;

		if mod(sort,2) = 1 then 
			dens = -density_scaled + dum_x - &element_iv.;
		else 
			dens = density_scaled + dum_x + &element_iv.;
		proc sort; by dens_id value;
		run;
	*define violin plot range;
		%if %upcase("&trim")= "TRUE" %then %do;
		data rain_density3;
		set rain_density3;
			where  min<=value<=max;
		run;
		%end;
		run;


	*generate shape;

	data rain_density4;
	set rain_density3;
	by dens_id;
	retain fst_val fst_dens;

	if first.dens_id then do;
		fst_val = value;
		fst_dens=dens;
	end;

	output;

	if last.dens_id then do;

		if mod(sort,2) = 1 then dens = dum_x - &element_iv.;
		else dens = dum_x + &element_iv.;

		output;
		
		value=fst_val;
		output;
		dens = fst_dens;
		output;

		
	end;
	run;	




	*--------------------------------------------------------;
	*Generate dataset for box plot;
	*--------------------------------------------------------;

	proc sort data=rain_dat;
		by sort group;
	run;

	data rain_box;
		merge rain_dat rain_dummy(keep=sort dum_x);
		by sort ;
		
		dum_x2=dum_x;
		drop dum_x;
		y2=y;
		group2 = group;

	keep sort dum_x2 y2 group2 subject;
	run;


	*--------------------------------------------------------;
	*Generate dataset for strip plot;
	*--------------------------------------------------------;

	data rain_strip;
		set rain_box;
		
		call streaminit(1234);
		
		if mod(sort,2)=1 then dum_x3=rand("normal", dum_x2 + &element_iv.*1.2, &cat_width.*&jitterwidth.);
		else dum_x3 = rand("normal", dum_x2 - &element_iv. * 1.2, &cat_width.*&jitterwidth.);
		
		group3=group2;
		y3=y2;
		keep dum_x3 y3 group3 subject;
	run;


	*--------------------------------------------------------;
	*calculate coordinate of tickvalue;
	*--------------------------------------------------------;
	proc sort data=rain_dat out=rain_tickvalue1 nodupkey; by sort;
	run;

	data rain_tickvalue2;
	merge rain_dummy(keep=sort dum_x) rain_tickvalue1 (keep=sort xtick reptick);
	by sort;
	dum_x_pre=lag(dum_x);

	dum_x_rep  =dum_x;
	dum_y_rep = 2;
	if mod(sort,2)=0 then do;
	dum_x_x = (dum_x+dum_x_pre) / 2;
	dum_y_x = 1;
	end;

	keep dum_x_rep dum_y_rep dum_x_x dum_y_x xtick reptick;
	run;

	*--------------------------------------------------------;
	*Plot dataset;
	*--------------------------------------------------------;

	data rain_plot;
		merge rain_density4
			rain_box(drop=sort)
			rain_strip
			rain_tickvalue2;
	format group;
	run;

	*--------------------------------------------------------;
	*vertical Graph template;
	*--------------------------------------------------------;

	proc template;
		define statgraph Raincloud_v;
			dynamic _XLABEL _YLABEL _ORIENT _CONNECT _SPAGHETTI
					_XTICKS _YTICKS _VMIN _VMAX _JW  _LEGEND _OUTLINEW;
			nmvar _NLEVEL ;
			
			begingraph / subpixel=on;
			/*legenditem*/
			&legenditem.;
			
			layout lattice / rows=2 rowweights=(0.9 0.1) columndatarange=union;
			
	*--------------------------------------------------------;
	*graph area;
	*--------------------------------------------------------;
			
			layout overlay / walldisplay=none
			xaxisopts=(display=(ticks line) 
				linearopts=(tickvaluelist=_XTICKS) offsetmin=0.1 
					offsetmax=0.1) 
			yaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_YTICKS 
				viewmin=_VMIN viewmax=_VMAX));
				
				
			/*density plot (fill)*/

				polygonplot x=dens y=value id=dens_id / 
						display=(fill )
						group=group
						fillattrs=(transparency=0.3);
			
			/*deinsity plot (outline)*/
			seriesplot x=dens y=value / group=dens_id lineattrs=(color=black thickness=_OUTLINEW);
			
			
			*box plot;
			if (upcase(_CONNECT)="TRUE")
				boxplot x=dum_x2 y=y2 / 
					display=(mean median outliers connect )
					capshape=none
					outlierattrs=(symbol=diamondfilled size=5)
					outlineattrs=(thickness=_OUTLINEW)
					medianattrs=(thickness=_OUTLINEW)
					whiskerattrs=(thickness=_OUTLINEW)
					meanattrs=(symbol=circlefilled size=7) 
					connectattrs=(thickness=2)
					groupdisplay=cluster
					clusterwidth=0.3
					boxwidth=0.7
					group=group2
					spread=true
					name="box";
				else
				boxplot x=dum_x2 y=y2 / 
					display=(mean median outliers )
					capshape=none
					outlierattrs=(symbol=diamondfilled size=5)
					outlineattrs=(thickness=_OUTLINEW)
					medianattrs=(thickness=_OUTLINEW)
					whiskerattrs=(thickness=_OUTLINEW)
					meanattrs=(symbol=circlefilled size=7) 
					groupdisplay=cluster
					clusterwidth=0.3
					boxwidth=0.7
					group=group2
					spread=true
					name="box";
				endif;

				*strip plot;
				if (upcase(_SPAGHETTI)="TRUE")
					seriesplot x=dum_x3 y=y3 / 
						group=subject
						linecolorgroup=group3
						display=standard
						lineattrs=(pattern=solid)
						datatransparency=0.7;
						
					scatterplot x=dum_x3 y=y3 / 
						group=group3
						markerattrs=(symbol=circlefilled size=5);
				else
					scatterplot x=dum_x3 y=y3 / 
						group=group3
						markerattrs=(symbol=circlefilled size=5)
						datatransparency=0.7;
					

				endif;
		

	/*legend*/
		if (upcase(_LEGEND)="TRUE")
			discretelegend  &legendname. "dummy"/ 
				title="&grplabel." 
				location=outside 
				across=1
				exclude=(".")
				halign=right;
		endif;
				
			endlayout;
	*--------------------------------------------------------;
	*tickvalue area;
	*--------------------------------------------------------;
		layout overlay / walldisplay=none
			xaxisopts=(display=none)
			yaxisopts=(display=none linearopts=(viewmin=1 viewmax=2));
			
			textplot x=dum_x_rep y=dum_y_rep text=reptick / 
				textattrs=(size=10);
			textplot x=dum_x_x y=dum_y_x text=xtick /
				textattrs=(size=10);
		endlayout;
		
		
		
	endlayout;
	endgraph;
	end;
	run;
	*--------------------------------------------------------;
	*horizontal Graph template;
	*--------------------------------------------------------;
	proc template;
		define statgraph Raincloud_h;
			dynamic _XLABEL _YLABEL _ORIENT _CONNECT _SPAGHETTI
					_XTICKS _YTICKS _VMIN _VMAX _JW  _LEGEND _OUTLINEW;
			nmvar _NLEVEL ;
			
			begingraph / subpixel=on;
			/*legenditem*/
			&legenditem.;
			
			layout lattice / columns=2 columnweights=(0.1 0.9) rowdatarange=union;
	*--------------------------------------------------------;
	*tickvalue area;
	*--------------------------------------------------------;
		layout overlay / walldisplay=none
			yaxisopts=(reverse=true display=none)
			xaxisopts=(display=none linearopts=(viewmin=1 viewmax=2));
			
			textplot y=dum_x_rep x=dum_y_rep text=reptick / 
				textattrs=(size=10);
			textplot y=dum_x_x x=dum_y_x text=xtick /
				textattrs=(size=10 )
				rotate=90;
		endlayout;
			
	*--------------------------------------------------------;
	*graph area;
	*--------------------------------------------------------;
			
			layout overlay / walldisplay=none
			yaxisopts=(reverse=true display=(ticks line) 
				linearopts=(tickvaluelist=_XTICKS) offsetmin=0.1 
					offsetmax=0.1) 
			xaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_YTICKS 
				viewmin=_VMIN viewmax=_VMAX));
				
				
			/*density plot (fill)*/

			
				polygonplot y=dens x=value id=dens_id / 
						display=(fill )
						group=group
						fillattrs=(transparency=0.3);

			
			/*deinsity plot (outline)*/
			seriesplot y=dens x=value / group=dens_id lineattrs=(color=black thickness=_OUTLINEW);
			
			
			*box plot;
			if (upcase(_CONNECT)="TRUE")
				boxplot x=dum_x2 y=y2 / 
					display=(mean median outliers connect )
					capshape=none
					outlierattrs=(symbol=diamondfilled size=5)
					outlineattrs=(thickness=_OUTLINEW)
					medianattrs=(thickness=_OUTLINEW)
					whiskerattrs=(thickness=_OUTLINEW)
					meanattrs=(symbol=circlefilled size=7)
					connectattrs=(thickness=2)
					groupdisplay=cluster
					orient=horizontal
					clusterwidth=0.3
					boxwidth=0.7
					group=group2
					spread=true
					name="box";
			else
				boxplot x=dum_x2 y=y2 / 
					display=(mean median outliers )
					capshape=none
					outlierattrs=(symbol=diamondfilled size=5)
					outlineattrs=(thickness=_OUTLINEW)
					medianattrs=(thickness=_OUTLINEW)
					whiskerattrs=(thickness=_OUTLINEW)
					meanattrs=(symbol=circlefilled size=7) 
					groupdisplay=cluster
					orient=horizontal
					clusterwidth=0.3
					boxwidth=0.7
					group=group2
					spread=true
					name="box";
				endif;
			

				*strip plot;
				if (upcase(_SPAGHETTI)="TRUE")
					seriesplot y=dum_x3 x=y3 / 
						group=subject
						linecolorgroup=group3
						display=standard
						lineattrs=(pattern=solid)
						datatransparency=0.7;
		
					scatterplot y=dum_x3 x=y3 / 
						group=group3
						markerattrs=(symbol=circlefilled size=5);
				else
					scatterplot y=dum_x3 x=y3 / 
						group=group3
						markerattrs=(symbol=circlefilled size=5)
						datatransparency=0.7;
				endif;

	/*legend*/
		if (upcase(_LEGEND)="TRUE")
			discretelegend  &legendname. "dummy"/ 
				title="&grplabel." 
				location=outside 
				across=1
				exclude=(".")
				halign=right;
		endif;
				
		endlayout;
	endlayout;

	endgraph;
	end;
	run;

	*--------------------------------------------------------;
	*Generate plot;
	*--------------------------------------------------------;
		ods graphics / pop;
		ods graphics / antialiasmax=999999;
		
		%if "&orient."="h" %then
		%do;

			proc sgrender data=rain_plot template=Raincloud_h;
			
		%end;
		
		%else %if "&orient."="v" %then
		%do;

			proc sgrender data=rain_plot template=Raincloud_v;
			
		%end;
		
		dynamic 
				_YLABEL="&ylabel."
				_XTICKS = "&xvaluelist."
				_YTICKS="&yticks."
				_VMIN=%scan(&yticks., 1, " ") 
				_VMAX=%scan(&yticks., -1, " ") 
				_CONNECT="&connect."
				_SPAGHETTI="&spaghetti."
				_JW=&jitterwidth.
				_NLEVEL=&nlevel.
				_LEGEND ="&legend."
				_OUTLINEW =&outlinewidth.;
		run;
	%exit:
%mend;
