
options mprint;
%macro kde2d(
dat=,
x=,
y=,
group=None,
xlabel=x,
ylabel=y,
univar_grid=401,
bw_method=sjpi,
bw_adjust=1,
univar_style=line,
bivar_grid=60,
bivar_nlevel=10,
bivar_style=line,
thresh=0,
legend=true,
scatter=false,
rug=false,
palette=sns

);


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
    put "WAR" "NING: palette parameter must be set SAS, SNS, STATA or TABLEAU";
    run;
    
    %goto exit;
    
    
%end;

%if %upcase("&bivar_style.") ^="LINE" and
    %upcase("&bivar_style.") ^= "FILL" and 
    %upcase("&bivar_style.") ^= "LINEFILL" %then %do;
    data _null_;
    put "WAR" "NING: bivar_style parameter must be set LINE, FILL or LINEFILL";
    run;
    
    %goto exit;
%end;

%if %upcase("&univar_style.") ^="LINE" and
    %upcase("&univar_style.") ^= "FILL" %then %do;
    data _null_;
    put "WAR" "NING: univar_style parameter must be set LINE or FILL";
    run;
    
    %goto exit;
%end;


*--------------------------------------------------------;
* data preparation;
*--------------------------------------------------------;		

%if "&group."="None" %then %do;

	data dat;
	set dat.;
	x=&x.;
	y=&y.;
	group=1;
	keep x y group;
%end;

/* grp2: group variable for 2D-KDE */

%else %do;
	data dat;
	length grp2 $5000;
	set &dat.;
	x=&x.;
	y=&y.;
	rename &group.=group;
	grp2=vvalue(&group.);
	keep x y &group. grp2;
	proc sort; by group;
	run;

%end;

/* get group name */

proc sort data=&dat. out=grp(keep=&group. rename=(&group.=group)) nodupkey; by &group.;run;

data _null_;
length list $5000;
set grp end=eof;
retain list;

list = catx("$", list, vvalue(group));
if eof then call symputx("grplist",list);
run;


%put &grplist.;

*--------------------------------------------------------;
* KDE;
*--------------------------------------------------------;	


proc kde data=dat;
univar x  / out=kde_x(
			rename=(group=univar_x_group value=univar_x_value density=univar_x_density)
			keep=group value density)
			
			ngrid=&univar_grid.
			method=&bw_method.
			bwm=&bw_adjust.;
by group;
run;

proc kde data=dat;
univar y  / out=kde_y(
			rename=(group=univar_y_group value=univar_y_value density=univar_y_density)
			keep=group value density)
			
			ngrid=&univar_grid.
			method=&bw_method.
			bwm=&bw_adjust.;
by group;
run;

/* get maximum density */
proc sql noprint;

select max(univar_x_density) into : max_dens_x from kde_x;
select max(univar_y_density) into : max_dens_y from kde_y;
quit;



*--------------------------------------------------------;
* 2D KDE;
*--------------------------------------------------------;	

proc sort data=dat; by group grp2;run;

proc kde data=dat;
bivar x y / out=kde_xy(rename=(group=bivar_group grp2=bivar_group_name value1=bivar_x value2=bivar_y density=bivar_density)
		keep=group grp2 value1 value2 density)
		ngrid=&bivar_grid.;
by group grp2;
run;

*--------------------------------------------------------;
* Plot data;
*--------------------------------------------------------;	

data graph;
merge dat kde_xy kde_x kde_y;

/* line of rug plot  */

if x^=. then do;
	linex_st=0;
	linex_en=&max_dens_x. / 10;
	liney_st=0;
	liney_en=&max_dens_y. / 10;
end;

run;

*--------------------------------------------------------;
* template;
*--------------------------------------------------------;	

%macro template;
%let n=1;

proc template;
define statgraph marginal;

begingraph;
layout lattice / rows=2 columns=2 
                rowweights=(0.2 0.8) columnweights=(0.8 0.2)  
                columndatarange=union rowdatarange=union
                rowgutter=5 columngutter=5;
     

        /*left top*/
        layout overlay /xaxisopts=(display=none griddisplay=on offsetmin=0 offsetmax=0 linearopts=(thresholdmin=0 thresholdmax=0))
                        yaxisopts=(display=none griddisplay=on offsetmin=0 ) ;
                        
        	if (upcase("&univar_style.")="FILL")
            	bandplot x=univar_x_value limitupper=univar_x_density limitlower=0 / name="kde" fillattrs=(transparency=0.5) group=univar_x_group;
            endif;
            
            if (upcase("&univar_style.")="LINE")
            	seriesplot x=univar_x_value y=univar_x_density / name="kde" group=univar_x_group  lineattrs=(thickness=2) ;
            endif;
            
            if (upcase("&rug.")="TRUE")
            	vectorplot x=x y=linex_en xorigin=x yorigin=linex_st / datatransparency=0.3 arrowheads=false group=group ;
            endif;
            
        endlayout;

        /*right top*/
        layout overlay;
            entry " ";
        endlayout;
        
        /*left bottom*/
        layout overlay / 
        
       					 xaxisopts=(label="&xlabel." offsetmin=0 offsetmax=0 linearopts=(thresholdmin=0 thresholdmax=0))
         	             yaxisopts=(label="&ylabel.");
         	             
        
            if (upcase("&bivar_style")="FILL")
	            %do name = 1 %to %sysfunc(countw(&grplist.,"$"));
	            
		            contourplotparm x=eval(ifn(bivar_group_name="%scan(&grplist.,&name.,"$")" and bivar_density >=&thresh. ,bivar_x,.))
		            				y=eval(ifn(bivar_group_name="%scan(&grplist.,&name.,"$")" and bivar_density >=&thresh. ,bivar_y,.))
		            				z=eval(ifn(bivar_group_name="%scan(&grplist.,&name.,"$")" and bivar_density >=&thresh. ,bivar_density,.))
		            	/contourtype=fill 
		            	 colormodel=(white  %scan(&&&palette.,&name.,"$"))
	
		            	 nlevels=&bivar_nlevel.
		            	 name="contour&name."
		            	 lineattrs=GraphData&n.(thickness=2)
		            	 primary=true
		            	 ;
		            	 
		            %let n=%eval(&n.+1);
		        %end;
	        endif;
	        
            if (upcase("&bivar_style")="LINE")
	            %do name = 1 %to %sysfunc(countw(&grplist.,"$"));
	            
		            contourplotparm x=eval(ifn(bivar_group_name="%scan(&grplist.,&name.,"$")" and bivar_density >=&thresh. ,bivar_x,.))
		            				y=eval(ifn(bivar_group_name="%scan(&grplist.,&name.,"$")" and bivar_density >=&thresh. ,bivar_y,.))
		            				z=eval(ifn(bivar_group_name="%scan(&grplist.,&name.,"$")" and bivar_density >=&thresh. ,bivar_density,.))
		            	/contourtype=line 
		            	 lineattrs=GraphData&name.(thickness=2)	
		            	 nlevels=&bivar_nlevel.
		            	 name="contour&name."
		            	 primary=true

		            	 ;
		            	 
		            %let n=%eval(&n.+1);
		        %end;
	        endif;	  
	        
            if (upcase("&bivar_style")="LINEFILL")
	            %do name = 1 %to %sysfunc(countw(&grplist.,"$"));
	            
		            contourplotparm x=eval(ifn(bivar_group_name="%scan(&grplist.,&name.,"$")" and bivar_density >=&thresh. ,bivar_x,.))
		            				y=eval(ifn(bivar_group_name="%scan(&grplist.,&name.,"$")" and bivar_density >=&thresh. ,bivar_y,.))
		            				z=eval(ifn(bivar_group_name="%scan(&grplist.,&name.,"$")" and bivar_density >=&thresh. ,bivar_density,.))
		            	/contourtype=linefill 
		            	 colormodel=(white  %scan(&&&palette.,&name.,"$"))
	
		            	 nlevels=&bivar_nlevel.
		            	 name="contour&name."
	 	            	 lineattrs=GraphData&name.(thickness=1 color=black)	
	 	            	 primary=true
		            	 ;
		            	 
		            %let n=%eval(&n.+1);
		        %end;
	        endif;
	        
	        if (upcase("&scatter.")="TRUE")
	        	scatterplot x=x y=y /group=group name="scatter"
	        		filledoutlinedmarkers=true
	        		markerattrs=(size=6)
	        		markeroutlineattrs=(color=black);
	        	
	        endif;
	        
	        
	        endlayout;
        
        /*right bottom*/
        layout overlay /xaxisopts=(display=none griddisplay=on offsetmin=0)
                        yaxisopts=(display=none griddisplay=on offsetmin=0 offsetmax=0 linearopts=(thresholdmin=0 thresholdmax=0));
        
            if (upcase("&univar_style.")="FILL")
            	bandplot y=univar_y_value limitupper=univar_y_density limitlower=0 / name="kde" fillattrs=(transparency=0.5) group=univar_y_group;
            endif;
            
            if (upcase("&univar_style.")="LINE")
            	seriesplot  y=univar_y_value x=univar_y_density / group=univar_y_group  lineattrs=(thickness=2) ;
            endif;
            
            if (upcase("&rug.")="TRUE")
            	vectorplot x=liney_en y=y xorigin=liney_st yorigin=y / datatransparency=0.3 arrowheads=false group=group;
            endif;
            

        endlayout;
           
    endlayout;
    
    if (upcase("&legend.")="TRUE")

	  layout globallegend ;
	    	discretelegend "kde" / exclude=("." " " "");
	  endlayout;
	    
	endif;
	
endgraph;
end;
run;

%mend template;

%template;
ods listing style=&palette.;


ods graphics / pop;
ods graphics  /  ANTIALIASMAX=1000000 ;


proc sgrender data=graph template=marginal;

run;

%exit:

%mend kde2d;





