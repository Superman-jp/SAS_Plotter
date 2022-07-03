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
		 xlabel=x,
		 ylabel=y,
		 ticklst=, 
		 cat_iv=2.5,
		 element_iv=0.02,
		 scale=area, 
		 connect=false,
		 gridsize=100,
		 bw=sjpi,
		 orient=h, 
		 legend=false,
		 jitterwidth=0.1);
		 
		 
	/*store ods setting*/
	ods graphics / push;
	ods graphics / reset=all;
	
	*--------------------------------------------------------;
	*get category format and group format;
	*--------------------------------------------------------;
	proc contents data=&data. noprint out=catalog;
	run;
	
	data _null_;
	set catalog;
	if name="&group." then call symputx("grpfmt",format );
	if name="&x." then call symputx("xfmt",format );
	run;

	*--------------------------------------------------------;
	*Data preparation;
	*--------------------------------------------------------;

	%if "&group."="None" %then %do;

		data dat;
			set &data.(rename=(&x.=x &y.=y));
			group=1;
			keep x y group;
		run;

	%end;
	%else %do;
		%if "&group." ^= "&x." %then %do;
		
			data dat;
				set &data.(rename=(&x.=x &y.=y &group.=group));
				keep x y group;
			run;
		%end;
		%else %do;
			data dat;
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

	proc kde data=dat;
		univar y / out=density ngrid=&gridsize. method=&bw.;
		by x group;
	run;

	*--------------------------------------------------------;
	*Scaling density;
	*--------------------------------------------------------;

	proc means data=density nway noprint;
		var value;
		class x group;
		where count^=0;
		output out=stat min=min max=max;
	run;

	*scaling based on area (areas of all violin plot is same);
	*scale the max density of input data to 1;
	proc means data=density noprint;
		var density count;
		class x group;
		output out=max max(density)=max_density max(count)=max_count;
	run;



	%if "&scale."="area" %then %do;

		proc sql noprint;
			create table density_scale as 
				select a.*,
					   a.density / b.max_density as density_scaled
				from (
					select *, 1 as dmy
					from density
					)as a
				inner join (select max_density ,1 as dmy
							from max 
							where x=. and group=.) as b
				on a.dmy=b.dmy;
		quit;

	%end;
	
	*scaling based on violin plot width;
	*scale the max density of each violin plot to 1;

	%if "&scale."="width" %then %do;

		proc sql noprint;
			create table density_scale as 
				select a.*,
					   a.density / b.max_density as density_scaled
				from density as a
				inner join (select * 
							from max 
							where x^=. and group^=.) as b
				on a.x=b.x and a.group=b.group;
		quit;

	%end;

	*--------------------------------------------------------;
	*Adjust plot interval;
	*--------------------------------------------------------;

	proc sql noprint;
		select max(density_scaled)*&cat_iv. into:cat_width 
		from density_scale;
		
		
		*number of group level;
		select count(distinct group) into:nlevel from dat;
	quit;

	*--------------------------------------------------------;
	*Generate dummy axis variable and axis format;
	*--------------------------------------------------------;

	proc sort data=dat(keep=x) nodupkey out=cat;
		by x;
	run;

	data dummy;
		length tickvalue $2000;
		set cat end=eof;
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
	
	proc format cntlin=dummy;
	run;

*--------------------------------------------------------;
*Generate dataset for half violin plot;
*--------------------------------------------------------;
*作図用変数の作成,ダミー軸変数の値だけプロットを右へ平行移動させる;
*x変数とgroup毎に密度にたいして連番を付与する。;

data density2;
	merge density_scale stat;
	by x group;
	retain group_dens 0;

	if first.group then
		group_dens+1;

proc sort;
	by x;
run;

data density3;
	merge density2 dummy(keep=x dum_x);
	by x;
	dens=-density_scaled + dum_x - &element_iv.;
	dens2=dum_x - &element_iv.;

	if min<=value<=max;
run;

*--------------------------------------------------------;
*Generate dataset for box plot;
*--------------------------------------------------------;

proc sort data=dat;
	by x;
run;

data dat2;
	merge dat dummy(keep=x dum_x);
	by x;
	dum_x2=dum_x;
	drop dum_x;
	group2=group;
	y2=y;
	format group2 &grpfmt..;
	keep dum_x2 y2 group2;
run;

*--------------------------------------------------------;
*Generate dataset for strip plot;
*--------------------------------------------------------;

data dat3;
	set dat2;
	dum_x3=dum_x2 + &element_iv.*1.2;
	group3=group2;
	y3=y2;
	keep dum_x3 y3 group3;
run;

*--------------------------------------------------------;
*Plot dataset;
*--------------------------------------------------------;

data plot;
	merge density3 dat2 dat3;
run;

*--------------------------------------------------------;
*horizontal Graph template;
*--------------------------------------------------------;

proc template;
	define statgraph Raincloud_h;
		dynamic _XLABEL _YLABEL _ORIENT _CONNECT 
				_XTICKS _YTICKS _VMIN _VMAX _JW  _LEGEND;
		nmvar _NLEVEL;
		
		begingraph;
		
		layout overlay / 
		xaxisopts=(label=_XLABEL 
			linearopts=(
				tickvalueformat=cat. tickvaluelist=_XTICKS) offsetmin=0.1 
				offsetmax=0.1) 
		yaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_YTICKS 
			viewmin=_VMIN viewmax=_VMAX));
		
		/*band plot*/
		if (_NLEVEL>1)
		
			bandplot y=value limitupper=dens limitlower=dens2 / group=group_dens 
				display=(fill) fillattrs=(transparency=0.6) index=group;
		else
			bandplot y=value limitupper=dens limitlower=dens2 / group=group_dens 
				display=(fill) index=group;
		endif;
		
		
		/* 	 box plot    */
		if (upcase(_CONNECT)="TRUE") 
			boxplot x=dum_x2 y=y2 / 
				display=(mean median outliers connect)
				capshape=none
				outlierattrs=(symbol=diamondfilled size=5)
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
				_XTICKS _YTICKS _VMIN _VMAX _JW  _LEGEND;
		nmvar _NLEVEL;
		
		begingraph;
	
		layout overlay / 
		yaxisopts=(label=_XLABEL reverse=true
			linearopts=(
				tickvalueformat=cat. tickvaluelist=_XTICKS) offsetmin=0.1 
				offsetmax=0.1) 
		xaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_YTICKS 
			viewmin=_VMIN viewmax=_VMAX));
		
		/*band plot*/
		if (_NLEVEL>1 and "&x." ^= "&group.")
		
			bandplot x=value limitupper=dens limitlower=dens2 / group=group_dens 
				display=(fill) fillattrs=(transparency=0.6) index=group;
		else
			bandplot x=value limitupper=dens limitlower=dens2 / group=group_dens 
				display=(fill) index=group;
		endif;
		
		
		/* 	 box plot    */
		if (upcase(_CONNECT)="TRUE") 
			boxplot x=dum_x2 y=y2 / 
				display=(mean median outliers connect)
				capshape=none
				orient=horizontal
				outlierattrs=(symbol=diamondfilled size=5)
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

	/*vertical plot*/
	/* 	define statgraph Raincloud_v; */
	/* 	dynamic  _XLABEL  _YLABEL _ORIENT _CONNECT */
	/* 			_TICKS _VMIN _VMAX _JW */
	/* 			_MCOLOR ; */
	/* 	nmvar _NLEVEL ; */
	/* 			 */
	/* 	begingraph; */
	/* 	layout overlay /  */
	/* 	    yaxisopts=(label=_XLABEL reverse=True linearopts=(tickvalueformat=cat. tickvaluelist=(&valuelist.)) */
	/* 	    offsetmin=0.05 offsetmax=0.05) */
	/* 	    xaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_TICKS  */
	/* 	    									viewmin=_VMIN */
	/* 	    									viewmax=_VMAX)); */
	/* 	if (_NLEVEL = 1) */
	/* 		bandplot x=value limitupper=dens limitlower=dens2 /  */
	/* 		    group=dum_x */
	/* 		    display=(fill ) */
	/* 		    fillattrs=(color=GraphData1:color); */
	/* 	else */
	/* 		bandplot x=value limitupper=dens limitlower=dens2 /  */
	/* 		    group=group */
	/* 		    display=(fill ); */
	/* 	endif; */
	/* 	     */
	/* 		 box plot    */
	/* 	if (_CONNECT="TRUE")      */
	/* 		boxplot x=dum_x2 y=y2 /  */
	/* 			display=( mean median outliers connect) */
	/* 			capshape=none  */
	/* 			orient=horizontal */
	/* 			outlierattrs=(symbol=diamondfilled color=black size=5) */
	/* 			outlineattrs=(color=black thickness=1) */
	/* 			whiskerattrs=(color=black thickness=1) */
	/* 			medianattrs=(color=black thickness=1) */
	/* 			meanattrs=(symbol=circlefilled size=8) */
	/* 			connectattrs=(color=_MCOLOR thickness=2) */
	/* 			boxwidth=0.1  */
	/* 			group=group2 */
	/* 			groupdisplay=cluster */
	/* 			spread=true; */
	/* 	endif; */
	/* 	 */
	/* 	if (_CONNECT="FALSE") */
	/* 		boxplot x=dum_x2 y=y2 /  */
	/* 			display=( mean median outliers ) */
	/* 			capshape=none  */
	/* 			orient=horizontal */
	/* 			outlierattrs=(symbol=diamondfilled color=black size=5) */
	/* 			outlineattrs=(color=black thickness=1) */
	/* 			whiskerattrs=(color=black thickness=1) */
	/* 			medianattrs=(color=black thickness=1) */
	/* 			meanattrs=(symbol=circlefilled size=8) */
	/* 			boxwidth=0.1  */
	/* 			group=group2 */
	/* 			groupdisplay=cluster */
	/* 			spread=true; */
	/* 	endif; */
	/* 	 */
	/* 	scatterplot y=dum_x3 x=y3 /  */
	/* 				group=group3 */
	/* 				markerattrs=(symbol=circlefilled size=5 transparency=0.5) */
	/* 				jitter =auto  */
	/* 				jitteropts=(axis=y width=_JW); */
	/* 			 */
	/* 	 */
	/* 	endlayout; */
	/* 	endgraph; */
	/* 	end; */
/* run; */

*--------------------------------------------------------;
*Generate plot;
*--------------------------------------------------------;
	ods graphics / pop;
	
	%if "&orient."="h" %then
	%do;

		proc sgrender data=plot template=Raincloud_h;
		
	%end;
	
	%else %if "&orient."="v" %then
	%do;

		proc sgrender data=plot template=Raincloud_v;
		
	%end;
	
	dynamic _XLABEL="&xlabel."
			_YLABEL="&ylabel."
			_CONNECT="&connect." 
			_XTICKS = "&xvaluelist."
			_YTICKS="&ticklst."
			_VMIN=%scan(&ticklst., 1, " ") 
			_VMAX=%scan(&ticklst., -1, " ") 
			_JW="&jitterwidth."  
			_NLEVEL="&nlevel."
			_LEGEND ="&legend.";
	run;
	%put -----------------&nlevel.;
%mend;