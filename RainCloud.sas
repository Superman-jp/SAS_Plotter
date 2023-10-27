*--------------------------------------------------------;
*SAS_plotter;
*raincloud plot macro;
*author: SupermanJP;
*version: 1.1;
*--------------------------------------------------------;

%macro RainCloud(
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
		 outlinewidth=1,
		 palette=sns);
		 
				 
/*store ods setting*/

ods graphics / push;
ods graphics / reset=all;	
		
		
*--------------------------------------------------------;
*parameter check;
*--------------------------------------------------------;


%if %upcase("&palette.") ^= "SAS" and
    %upcase("&palette.") ^= "SNS" and
    %upcase("&palette.") ^= "STATA" and
    %upcase("&palette.") ^= "TABLEAU" %then %do;
    
    data _null_;
    put "WAR" "NING: palette parameter must be set SAS, SNS, STATA or Tableau";
    run;
    
    %goto exit;
    
    
%end;

%if "&xlabel." ="" %then %do;
	%let xlabel=%nrstr( );
%end;

%if "&ylabel." = "" %then %do;
	%let ylabel = %nrstr( );
%end;

*--------------------------------------------------------;
*get category format and  group format;
*--------------------------------------------------------;
*copy input data;
data rain_temp1;
set &data.;

%if "&group."^="None" or "&group."^="&x." %then %do;
	proc sort; by &x. &group.;
	run;
%end;

%else %do;
	proc sort; by &x.;
	run;
%end;

*add sequence by x and group;
data rain_temp2;
set rain_temp1;


%if "&group."^="None" and "&group." ^="&x." %then %do;
	by &x. &group.;
	retain x group 0;
	if first.&x. then do;
		x+1;
		group=1;
	end;
	
	else if not first.&x. and first.&group. then group+1;
%end;

%else %do;
	by &x.;
	retain x 0;
	if first.&x. then x+1;
	%if "&group."^="&x." %then %do;
		group=1;
	%end;

	%else %do;
		group=x;
	%end;
%end;
run;

*generate x variable format;
proc sort data=rain_temp2 nodupkey out=rain_temp3; by x;
data rain_xfmt;
length label $1000;
set rain_temp3;
fmtname="xfmt";
start=x;
end=x;
label = vvalue(&x.);
run;

proc format cntlin=rain_xfmt;

*generate group format;
%if "&group."^="None" %then %do;

	proc sort data=rain_temp2 nodupkey out=rain_temp4; by group ;
	run;
	data rain_grpfmt ;
	length label $1000;
	set rain_temp4 end=eof;
	
	fmtname="grpfmt";
	start=group;
	end=group;
	label=strip(vvalue(&group.));
	
	*get label of group variable;
	if eof then call symputx("grplabel", vlabel(&group.));
	
	keep fmtname start end label;
	run;
	proc format cntlin=rain_grpfmt;
	run;
				
%end;
	

*apply format;

data rain_dat;
set rain_temp2;

%if "&group."^="None" %then %do;
	format x xfmt. group grpfmt.;
%end;

%else %do;
	format x xfmt.;
%end;

y=&y.;
keep x y group;
run;

*--------------------------------------------------------;
*KDE;
*--------------------------------------------------------;

proc kde data=rain_dat;
	univar y / out=rain_density 
			ngrid=&gridsize.
			method=&bw_method.
			bwm=&bw_adjust.;
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

*scaling based on area (areas of all violin plot are same);
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

proc sort data=rain_dat(keep=x ) nodupkey out=rain_cat;
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

data rain_density2;
	merge rain_density_scale rain_stat;
	by x group;
	retain dens_id 0;

	if first.group then
		dens_id+1;
	output;

proc sort;
	by x;
run;

data rain_density3;
	merge rain_density2 rain_dummy(keep=x dum_x);
	by x;
	dens=-density_scaled + dum_x - &element_iv.;
	
*define violin plot range;
	%if %upcase("&trim")= "TRUE" %then 
	if min<=value<=max;
	;
proc sort; by dens_id value;
	
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
	dens = dum_x - &element_iv.;
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
		format group2 grpfmt.;;
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
*vertical Graph template;
*--------------------------------------------------------;

proc template;
	define statgraph Raincloud_v;
		dynamic _XLABEL _YLABEL _ORIENT _CONNECT 
				_XTICKS _YTICKS _VMIN _VMAX _JW  _LEGEND _OUTLINEW;
		nmvar _NLEVEL ;
		
		begingraph / subpixel=on;
		
		layout overlay / walldisplay=none
		xaxisopts=(label=_XLABEL 
			linearopts=(
				tickvalueformat=cat. tickvaluelist=_XTICKS) offsetmin=0.1 
				offsetmax=0.1) 
		yaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_YTICKS 
			viewmin=_VMIN viewmax=_VMAX));
		
		/*density plot (fill)*/
		if (_NLEVEL>1 and "&x."^= "&group.")
		
			polygonplot x=dens y=value id=dens_id / 
					display=(fill )
					group=group
					fillattrs=(transparency=0.3);
					
		else
			polygonplot x=dens y=value id=dens_id / 
					display=(fill )
					group=group;
		endif;
		
		/*density plot (outline)*/
		seriesplot y=value x=dens / group=dens_id lineattrs=(color=black thickness=_OUTLINEW);			
		
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
				connectattrs=(thickness=2)
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
				connectattrs=(thickness=2)
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
				markerattrs=(symbol=circlefilled size=5 transparency=0.5)
				jitter=auto
			jitteropts=(axis=x width=_JW);
		else
			scatterplot x=dum_x3 y=y3 / 
				group=group3
				markerattrs=(symbol=circlefilled size=5)
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
*horizontal Graph template;
*--------------------------------------------------------;
proc template;
	define statgraph Raincloud_h;
		dynamic _XLABEL _YLABEL _ORIENT _CONNECT 
				_XTICKS _YTICKS _VMIN _VMAX _JW  _LEGEND _OUTLINEW;
		nmvar _NLEVEL ;
		
		begingraph /subpixel=on;
	
		layout overlay / walldisplay=none
		yaxisopts=(label=_XLABEL reverse=true
			linearopts=(
				tickvalueformat=cat. tickvaluelist=_XTICKS) offsetmin=0.1 
				offsetmax=0.1) 
		xaxisopts=(label=_YLABEL linearopts=(tickvaluelist=_YTICKS 
			viewmin=_VMIN viewmax=_VMAX));
			
			
		
		/*density plot (fill)*/		
		if (_NLEVEL>1 and "&x." ^= "&group.")
		
					polygonplot y=dens x=value id=dens_id / 
					display=(fill)
					group=group
					fillattrs=(transparency=0.3);
					
		else
			polygonplot y=dens x=value id=dens_id / 
					display=(fill)
					group=group;
		endif;
		
		/*deinsity plot (outline)*/
		seriesplot x=value y=dens / group=dens_id lineattrs=(color=black thickness=_OUTLINEW);		
		
		/* 	 box plot    */
		if (upcase(_CONNECT)="TRUE") 
			boxplot x=dum_x2 y=y2 / 
				display=(mean median outliers connect)
				capshape=none
				orient=horizontal
				outlierattrs=(symbol=diamondfilled size=5)
				outlineattrs=(thickness=_OUTLINEW)
				medianattrs=(thickness=_OUTLINEW)
				whiskerattrs=(thickness=_OUTLINEW)
				meanattrs=(symbol=circlefilled size=7)
				connectattrs=(thickness=2)
				groupdisplay=cluster
				grouporder=reversedata
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
				connectattrs=(thickness=2)
				groupdisplay=cluster
				grouporder=reversedata
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
				markerattrs=(symbol=circlefilled size=5 transparency=0.5)
				jitter=auto
			jitteropts=(axis=y width=_JW);
		else
			scatterplot y=dum_x3 x=y3 / 
				group=group3
				markerattrs=(symbol=circlefilled size=5)
				jitter=auto
			jitteropts=(axis=y width=_JW);
		endif;
		
		/*if set group option, display legend*/
		
		if (upcase(_LEGEND)="TRUE")
			discretelegend "box" / 
				title="&group." 
				location=outside 
				sortorder=reverseauto
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
ods listing style=&palette.;
ods graphics / antialiasmax=999999;

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
		_YTICKS="&yticks."
		_VMIN=%scan(&yticks., 1, " ") 
		_VMAX=%scan(&yticks., -1, " ") 
		_JW=&jitterwidth.
		_NLEVEL=&nlevel.
		_LEGEND ="&legend."
		_OUTLINEW =&outlinewidth.;
run;
%exit:

%mend RainCloud;