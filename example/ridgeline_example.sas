
*-------------------------------------------;
/*ridgeline example*/
*-------------------------------------------;



*-------------------------------------------;
/*basic ridgeline*/
*-------------------------------------------;

data raw;
infile datalines delimiter=',';
length col1 $10;
format date yymmdd10.;
input col1 $  tokyo  naha ;
date = input(col1,yymmdd10.);
drop col1;

datalines;
2023/1/1,13,19.8
2023/1/2,12.1,19.4
2023/1/3,11,21.4
2023/1/4,11,19.5
2023/1/5,10.6,20.4
2023/1/6,9.9,21.7
2023/1/7,10.4,19.4
2023/1/8,12.5,21.2
2023/1/9,13.9,22.5
2023/1/10,9.9,22.8
2023/1/11,10.7,23.3
2023/1/12,12.6,24.3
2023/1/13,14,25.4
2023/1/14,14.2,25.3
2023/1/15,12,22.6
2023/1/16,7.7,17.9
2023/1/17,7.6,19.1
2023/1/18,12.4,17.9
2023/1/19,9.1,18.6
2023/1/20,12.3,18.7
2023/1/21,9,20.7
2023/1/22,8.9,24.1
2023/1/23,6.1,22.7
2023/1/24,11.8,20.2
2023/1/25,3.7,15.5
2023/1/26,8.5,20.6
2023/1/27,6.6,17.5
2023/1/28,8.3,14.8
2023/1/29,8.8,16.1
2023/1/30,10,16.6
2023/1/31,9,19.5
2023/2/1,13.1,23.2
2023/2/2,9.2,21.6
2023/2/3,6.2,19.8
2023/2/4,11.2,18.6
2023/2/5,12,21.3
2023/2/6,13.6,22.7
2023/2/7,15.4,22.9
2023/2/8,11.7,22.9
2023/2/9,10.6,23
2023/2/10,3.5,23.6
2023/2/11,14.1,22.8
2023/2/12,16.9,25
2023/2/13,10.3,25.6
2023/2/14,10.7,19.9
2023/2/15,7.8,17.2
2023/2/16,9.6,21.2
2023/2/17,10.8,22.5
2023/2/18,15,23.6
2023/2/19,18.5,24.2
2023/2/20,14.7,19
2023/2/21,9.2,19.1
2023/2/22,10.4,22.1
2023/2/23,14.4,23.2
2023/2/24,12.1,23.5
2023/2/25,12.7,19.4
2023/2/26,10.7,17.9
2023/2/27,15,18.3
2023/2/28,19.4,21.8
2023/3/1,19.4,23.5
2023/3/2,20,19.2
2023/3/3,13.4,18.1
2023/3/4,17.4,20.9
2023/3/5,13.1,21.1
2023/3/6,15,21.1
2023/3/7,18.8,22
2023/3/8,21.3,23.9
2023/3/9,22.2,24
2023/3/10,22.9,22.9
2023/3/11,20.8,24.3
2023/3/12,18.8,24
2023/3/13,16.7,19.3
2023/3/14,14.6,20.7
2023/3/15,17.9,24.1
2023/3/16,20.9,24.5
2023/3/17,15.1,24.8
2023/3/18,9.5,22.8
2023/3/19,15.5,22.9
2023/3/20,19.2,21.7
2023/3/21,18.5,25.9
2023/3/22,23.8,26.3
2023/3/23,19.7,26.9
2023/3/24,25,27.3
2023/3/25,14.1,22.9
2023/3/26,12.5,20.3
2023/3/27,16.9,21.7
2023/3/28,13.4,23.9
2023/3/29,18.6,23.1
2023/3/30,19.7,23.2
2023/3/31,20.1,24.4
2023/4/1,23.3,24.3
2023/4/2,19,23.8
2023/4/3,18.4,25.2
2023/4/4,21,25
2023/4/5,21.8,24.7
2023/4/6,23.4,25.9
2023/4/7,21.3,23.8
2023/4/8,21.1,20.8
2023/4/9,17.7,21.9
2023/4/10,21.6,23.7
2023/4/11,25,26.3
2023/4/12,24.5,26.4
2023/4/13,21.3,24.9
2023/4/14,22.5,26.5
2023/4/15,18,26
2023/4/16,24.5,27.2
2023/4/17,20.3,28.7
2023/4/18,21,27.1
2023/4/19,24.9,26.5
2023/4/20,26,25.8
2023/4/21,26.8,26.2
2023/4/22,18.4,25.2
2023/4/23,20.5,25.8
2023/4/24,16,26.2
2023/4/25,19.1,27.1
2023/4/26,19.7,22.3
2023/4/27,23.8,24.4
2023/4/28,24.1,27
2023/4/29,23.8,28.4
2023/4/30,22,25.3
2023/5/1,22.5,24.6
2023/5/2,23,25.4
2023/5/3,23.4,25.8
2023/5/4,25.7,27.4
2023/5/5,26.6,27.5
2023/5/6,27.9,28.1
2023/5/7,22.3,26.6
2023/5/8,16.6,23.4
2023/5/9,20.6,25
2023/5/10,25,25.4
2023/5/11,23.4,25.7
2023/5/12,21.9,26.1
2023/5/13,18.1,26.6
2023/5/14,21.2,23.5
2023/5/15,18.1,25.3
2023/5/16,27.5,28.2
2023/5/17,31.6,27.6
2023/5/18,32.2,27.8
2023/5/19,24.5,27
2023/5/20,22.8,27
2023/5/21,26.3,27.4
2023/5/22,29.4,28.5
2023/5/23,17.2,25.2
2023/5/24,23.9,26.4
2023/5/25,23.8,28
2023/5/26,24.9,27.6
2023/5/27,26.7,27.3
2023/5/28,25.8,27.8
2023/5/29,21.3,30
2023/5/30,26.3,29.4
2023/5/31,22.2,29.6
2023/6/1,26.2,26.6
2023/6/2,23.8,26.5
2023/6/3,24,27.7
2023/6/4,27.5,29.3
2023/6/5,29.8,30.5
2023/6/6,25.1,29.1
2023/6/7,29.6,30.1
2023/6/8,28.7,29.9
2023/6/9,22.2,31.2
2023/6/10,26,30.2
2023/6/11,22.8,30.9
2023/6/12,22.5,29.4
2023/6/13,29.4,28
2023/6/14,25.8,25.8
2023/6/15,24.1,28
2023/6/16,30.7,28.5
2023/6/17,30.9,27.6
2023/6/18,31.1,30.3
2023/6/19,27.7,28.1
2023/6/20,27,30
2023/6/21,27.2,30.5
2023/6/22,22.6,29.9
2023/6/23,24.9,30.2
2023/6/24,29.5,31.9
2023/6/25,30.9,31.4
2023/6/26,30.4,31.5
2023/6/27,29.6,31.7
2023/6/28,32.3,30.7
2023/6/29,33.8,32.8
2023/6/30,30.5,32.3
2023/7/1,27.8,32
2023/7/2,31.7,32.5
2023/7/3,32.2,32.7
2023/7/4,30.6,32
2023/7/5,28.7,32.3
2023/7/6,33.4,32.6
2023/7/7,34.2,33.3
2023/7/8,30.9,32.8
2023/7/9,33,33.5
2023/7/10,36.5,34.1
2023/7/11,34.3,33.8
2023/7/12,37.5,34.2
2023/7/13,30.3,33.9
2023/7/14,30.5,33.7
2023/7/15,32.9,32.8
2023/7/16,35.3,32.7
2023/7/17,36.2,31.5
2023/7/18,37.5,32.8
2023/7/19,33.9,33.1
2023/7/20,32.6,33
2023/7/21,31.6,33.9
2023/7/22,33.4,33.9
2023/7/23,33.4,34.3
2023/7/24,35.7,33.2
2023/7/25,36.6,32.9
2023/7/26,37.7,31.3
2023/7/27,36.9,29.6
2023/7/28,36.2,32
2023/7/29,35.7,32.3
2023/7/30,36.6,32.6
2023/7/31,36.1,30.9
;
run;


proc format ;
value regionf
1="Tokyo"
2="Naha";
run;

data max_temp;
set raw;
format region regionf.;
label max_temp="maximum temperature (��)"
      month="Month"
	  region="Region";

month=month(date);
year=year(date);
region=1; max_temp=tokyo;output;
region=2; max_temp=naha; output;
keep year month  date region max_temp;
run;



options mprint;
ods graphics / height=15cm width=15cm imagefmt=png imagename="ridge_simple" ;
%ridgeline(
	data=max_temp(where=(region=1)),
	x=month,
	y=max_temp,
	
	yticks=0 5 10 15 20 25 30 35 40,
	title=%nrstr(entrytitle 'your title here'),
	footnote=%nrstr(entryfootnote halign=left 'your footnote here';
				    entryfootnote halign=left 'your footnote here 2';)

	);



*-------------------------------------------;
/*grouped ridgeline*/
*-------------------------------------------;

options mprint;
ods graphics / height=15cm width=25cm imagefmt=png imagename="ridge_group" ;
%ridgeline(
	data=max_temp,
	x=month,
	y=max_temp,
	group=region,
	yticks=0 5 10 15 20 25 30 35 40,
	legend=true
	);

*-------------------------------------------;
/*ridgeline plot with statistics and individual value*/
*-------------------------------------------;
ods graphics /reset=all height=15cm width=25cm imagename="ridgeline_stat" imagefmt=png;


%ridgeline(
   data=max_temp(where=(region=1)),
   x=month,
   y=max_temp,
   group=region,
   yticks=0 5 10 15 20 25 30 35 40,
   legend=true,
   mean=true,
   quartile=true,
   rug=true,
   deletedata=false
   );
*-------------------------------------------;
/*fill style*/
*-------------------------------------------;

ods graphics /reset=all height=15cm width=25cm imagename="ridgeline_fill" imagefmt=png;


%ridgeline(
	data=max_temp,
	x=month,
	y=max_temp,
	group=region,
	yticks=0 5 10 15 20 25 30 35 40,
	fillstyle=group,
	legend=true,
	mean=false,
	quartile=true,
	rug=true
   );

ods graphics /reset=all height=15cm width=25cm imagename="ridgeline_qtr" imagefmt=png;


%ridgeline(
	data=max_temp (where=(region=1)),
	x=month,
	y=max_temp,
	group=region,
	yticks=0 5 10 15 20 25 30 35 40,
	fillstyle=quartile,
	legend=true,
	mean=false,
	quartile=true,
	rug=true
   );

/*quartile gradient style*/

 %macro qgrad;

 %do i = 1 %to 7;
 ods graphics /reset=all height=15cm width=25cm 
	imagename="ridgeline_qgradient&i." imagefmt=png;

%ridgeline(
	data=max_temp (where=(region=1 and month=&i)),
	x=month,
	y=max_temp,
	group=region,
	ylabel=Quartile Gradient Style &i.,
	yticks=0 5 10 15 20 25 30 35 40,
	fillstyle=quartile,
	mean=false,
	quartile=true,
	qgradient=&i.
   );
%end;
%mend qgrad;

%qgrad;

