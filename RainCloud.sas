options locale=en_US;
*Load styles;
ods escapechar="^";
%include "/home/centraldogma7771/sasuser.v94/GTL/color_palette.sas";

/* -------------------------------------------------------------- */
%macro RainCloud(
		 data=,
		 x=,
		 y=,
		 group=None,
		 ticklst=, 
		 xlabel=x,
		 ylabel=y,
		 cat_iv=2.5,
		 element_iv=0.02,
		 scale=area,
		 violin_observed=True,
		 connect=false,
		 gridsize=401,
		 bw=sjpi,
		 orient=v, 
		 legend=false,
		 jitterwidth=0.1,
		 outlinewidth=1);
		 
		 
	/*store ods setting*/
	ods graphics / push;
	ods graphics / reset=all;
	
	*--------------------------------------------------------;
	*get category format,  group format;
	*--------------------------------------------------------;
	proc contents data=&data. noprint out=rain_catalog;
	run;
	
	data _null_;
	set rain_catalog;
	
	%if "&group"^="None" %then 
	
	if name="&group." then call symputx("grpfmt",format );
	;
	
	if name="&x." then call symputx("xfmt",format );
	run;
	


	*--------------------------------------------------------;
	*Data preparation;
	*--------------------------------------------------------;

	%if "&group."="None" %then %do;

		data rain_dat;
			set &data.(rename=(&x.=x &y.=y));
			group=1;
			keep x y group;
		run;

	%end;
	%else %do;
		%if "&group." ^= "&x." %then %do;
		
			data rain_dat;
				set &data.(rename=(&x.=x &y.=y &group.=group));
				keep x y group;
			run;
		%end;
		%else %do;
			data rain_dat;
				set &data.(rename=(&x.=x &y.=y ));
				group=x;
				keep x y group;
			run;
		%end;
	%end;
	
	

	proc sort;
		by x group;
	run;
	
	*--------------------------------------------------------;
	*KDE;
	*--------------------------------------------------------;

	proc kde data=rain_dat;
		univar y / out=rain_density ngrid=&gridsize. method=&bw.;
		by x group;
	run;

	*--------------------------------------------------------;
	*Scaling density;
	*--------------------------------------------------------;

	proc means data=rain_density nway noprint;
		var value;
		class x group;
		where count^=0;
		output out=rain_stat min=min max=max;
	run;

	*scaling based on area (areas of all violin plot is same);
	*scale the max density of input data to 1;
	proc means data=rain_density noprint;
		var density count;
		class x group;
		output out=rain_max max(density)=max_density max(count)=max_count;
	run;



	%if "&scale."="area" %then %do;

		proc sql noprint;
			create table rain_density_scale as 
				select a.*,
					   a.density / b.max_density as density_scaled
				from (
					select *, 1 as dmy
					from rain_density
					)as a
				inner join (select max_density ,1 as dmy
							from rain_max 
							where x=. and group=.) as b
				on a.dmy=b.dmy;
		quit;

	%end;
	
	*scaling based on violin plot width;
	*scale the max density of each violin plot to 1;

	%if "&scale."="width" %then %do;

		proc sql noprint;
			create table rain_density_scale as 
				select a.*,
					   a.density / b.max_density as density_scaled
				from rain_density as a
				inner join (select * 
							from rain_max 
							where x^=. and group^=.) as b
				on a.x=b.x and a.group=b.group;
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
	*Generate dummy axis variable and axis format;
	*--------------------------------------------------------;

	proc sort data=rain_dat(keep=x) nodupkey out=rain_cat;
		by x;
	run;

	data rain_dummy;
		length tickvalue $2000;
		set rain_cat end=eof;
		retain tickvalue;
		dum_x=_N_*round(&cat_width., 0.001);

		if _N_=1 then
			tickvalue=strip(put(dum_x, best.));
		else
			tickvalue=catx(" ", tickvalue, strip(put(dum_x, best.)));
		start=dum_x;
	end=dum_x;

	if eof then
		call symputx("xvaluelist", tickvalue);
	fmtname="cat";
	label=vvalue(x);
	run;
	
	proc format cntlin=rain_dummy;
	run;

*--------------------------------------------------------;
*Generate dataset for half violin plot;
*--------------------------------------------------------;
*作図用変数の作成,ダミー軸変数の値だけプロットを右へ平行移動させる;
*x変数とgroup毎に密度にたいして連番を付与する。;

data rain_density2;
	merge rain_density_scale rain_stat;
	by x group;
	retain group_dens 0;

	if first.group then
		group_dens+1;
	output;

proc sort;
	by x;
run;

data rain_density3;
	merge rain_density2 rain_dummy(keep=x dum_x);
	by x;
	dens=-density_scaled + dum_x - &element_iv.;
	
*define violin plot range;
	%if "&violin_observed"= "True" %then 
	if min<=value<=max;
	;
proc sort; by group_dens value;
	
run;

*generate shape;

data rain_density4;
set rain_density3;
by group_dens;
retain fst_val;

if first.group_dens then fst_val = value;
output;

if last.group_dens then do;
	dens = dum_x - &element_iv.;
	output;
	value=fst_val;
	output;
end;
run;



*--------------------------------------------------------;
*Generate dataset for box plot;
*--------------------------------------------------------;

proc sort data=rain_dat;
	by x;
run;

data rain_box;
	merge rain_dat rain_dummy(keep=x dum_x);
	by x;
	dum_x2=dum_x;
	drop dum_x;
	group2=group;
	y2=y;
	%if "&group"^="None" %then
		format group2 &grpfmt..;;
	keep dum_x2 y2 group2;
run;

*--------------------------------------------------------;
*Generate dataset for strip plot;
*--------------------------------------------------------;

data rain_strip;
	set rain_box;
	dum_x3=dum_x2 + &element_iv.*1.2;
	group3=group2;
	y3=y2;
	keep dum_x3 y3 group3;
run;

*--------------------------------------------------------;
*Plot dataset;
*--------------------------------------------------------;

data rain_plot;
	merge rain_density4 rain_box rain_strip;
run;

*--------------------------------------------------------;
*horizontal Graph template;
*--------------------------------------------------------;

proc template;
	define statgraph Raincloud_h;
		dynamic _XLABEL _YLABEL _ORIENT _CONNECT 
				_XTICKS _YTICKS _VMIN _VMAX _JW  _LEGEND _OUTLINEW;
		nmvar _NLEVEL ;
		
		begingraph;
		
		layout overlay / walldisplay=none
		xaxisopts=(label=_XLABEL 
			linearopts=(
				tickvalueformat=cat. tickvaluelist=_XTICKS) offsetmin=0.1 
				offsetmax=0.1) 
		yaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_YTICKS 
			viewmin=_VMIN viewmax=_VMAX));
		
		/*density plot*/
		if (_NLEVEL>1 and "&x."^= "&group.")
		
			polygonplot x=dens y=value id=group_dens / 
					display=(fill outline)
					group=group
					outlineattrs=(color=grey thickness=_OUTLINEW)
					fillattrs=(transparency=0.3);
					
		else
			polygonplot x=dens y=value id=group_dens / 
					display=(fill outline)
					outlineattrs=(color=grey thickness=_OUTLINEW)
					group=group;
		endif;
		
		
		/* 	 box plot    */
		if (upcase(_CONNECT)="TRUE") 
			boxplot x=dum_x2 y=y2 / 
				display=(mean median outliers connect)
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
		if (upcase(_CONNECT)="FALSE") 
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
		
		/* strip plot*/
		
		if (_NLEVEL^=1)
			scatterplot x=dum_x3 y=y3 / 
				group=group3
				markerattrs=(symbol=circlefilled size=4 transparency=0.5)
				jitter=auto
			jitteropts=(axis=x width=_JW);
		else
			scatterplot x=dum_x3 y=y3 / 
				group=group3
				markerattrs=(symbol=circlefilled size=4)
				jitter=auto
			jitteropts=(axis=x width=_JW);
		endif;
		
		/*if set group option, display legend*/
		
		if (upcase(_LEGEND)="TRUE")
			discretelegend "box" / 
				title="&group." 
				location=outside 
				across=1
				halign=right;
		endif;
		
		endlayout;
		endgraph;
	end;
run;

*--------------------------------------------------------;
*vertical Graph template;
*--------------------------------------------------------;
proc template;
	define statgraph Raincloud_v;
		dynamic _XLABEL _YLABEL _ORIENT _CONNECT 
				_XTICKS _YTICKS _VMIN _VMAX _JW  _LEGEND _OUTLINEW;
		nmvar _NLEVEL ;
		
		begingraph;
	
		layout overlay / walldisplay=none
		yaxisopts=(label=_XLABEL reverse=true
			linearopts=(
				tickvalueformat=cat. tickvaluelist=_XTICKS) offsetmin=0.1 
				offsetmax=0.1) 
		xaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_YTICKS 
			viewmin=_VMIN viewmax=_VMAX));
			
			
		
		/*density plot*/
		if (_NLEVEL>1 and "&x." ^= "&group.")
					polygonplot y=dens x=value id=group_dens / 
					display=(fill outline)
					group=group
					outlineattrs=(color=grey thickness=_OUTLINEW)
					fillattrs=(transparency=0.3);
					
		else
			polygonplot y=dens x=value id=group_dens / 
					display=(fill outline)
					outlineattrs=(color=grey thickness=_OUTLINEW)
					group=group;
		endif;
		
		
		/* 	 box plot    */
		if (upcase(_CONNECT)="TRUE") 
			boxplot x=dum_x2 y=y2 / 
				display=(mean median outliers connect)
				capshape=none
				orient=horizontal
				outlierattrs=(symbol=diamondfilled size=5)
				outlineattrs=(thickness=3)
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
		if (upcase(_CONNECT)="FALSE") 
			boxplot x=dum_x2 y=y2 / 
				display=(mean median outliers )
				capshape=none
				orient=horizontal
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
		
		/* strip plot*/
		
		if (_NLEVEL^=1)
			scatterplot y=dum_x3 x=y3 / 
				group=group3
				markerattrs=(symbol=circlefilled size=4 transparency=0.5)
				jitter=auto
			jitteropts=(axis=y width=_JW);
		else
			scatterplot y=dum_x3 x=y3 / 
				group=group3
				markerattrs=(symbol=circlefilled size=4)
				jitter=auto
			jitteropts=(axis=y width=_JW);
		endif;
		
		/*if set group option, display legend*/
		
		if (upcase(_LEGEND)="TRUE")
			discretelegend "box" / 
				title="&group." 
				location=outside 
				across=1
				halign=right;
		endif;
		
		endlayout;
		endgraph;
	end;
run;


*--------------------------------------------------------;
*Generate plot;
*--------------------------------------------------------;
	ods graphics / pop;
	
	%if "&orient."="h" %then
	%do;

		proc sgrender data=rain_plot template=Raincloud_h;
		
	%end;
	
	%else %if "&orient."="v" %then
	%do;

		proc sgrender data=rain_plot template=Raincloud_v;
		
	%end;
	
	dynamic _XLABEL="&xlabel."
			_YLABEL="&ylabel."
			_CONNECT="&connect." 
			_XTICKS = "&xvaluelist."
			_YTICKS="&ticklst."
			_VMIN=%scan(&ticklst., 1, " ") 
			_VMAX=%scan(&ticklst., -1, " ") 
			_JW=&jitterwidth.
			_NLEVEL=&nlevel.
			_LEGEND ="&legend."
			_OUTLINEW =&outlinewidth.;
	run;

%mend;