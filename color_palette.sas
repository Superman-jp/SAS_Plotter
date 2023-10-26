*-------------------------------------------;
*Color Palette for SAS
*color scheme and color code list;
*-------------------------------------------;



proc template ;

*-------------------------------------------;
*SAS 9.4;
*-------------------------------------------;
define style sas;
parent = styles.HTMLblue;
class GraphColors /
       'gcdata' = cx808080
       'gcdata1' = cx445694
       'gcdata2' = cxA23A2E
       'gcdata3' = cx01665E
       'gcdata4' = cx543005
       'gcdata5' = cx9D3CDB
       'gcdata6' = cx7F8E1F
       'gcdata7' = cx2597FA
       'gcdata8' = cxB26084
       'gcdata9' = cxD17800
       'gcdata10' = cx47A82A

       'gdata' = cx808080
       'gdata1' = cx445694
       'gdata2' = cxA23A2E
       'gdata3' = cx01665E
       'gdata4' = cx543005
       'gdata5' = cx9D3CDB
       'gdata6' = cx7F8E1F
       'gdata7' = cx2597FA
       'gdata8' = cxB26084
       'gdata9' = cxD17800
       'gdata10' = cx47A82A
;

 class GraphData1 /
       fillpattern = "L1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata1')
       color = GraphColors('gdata1');
       
    class GraphData2 /
       fillpattern = "X1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata2')
       color = GraphColors('gdata2');
       
    class GraphData3 /
       fillpattern = "R1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata3')
       color = GraphColors('gdata3');
       
    class GraphData4 /
       fillpattern = "L2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata4')
       color = GraphColors('gdata4');
       
    class GraphData5 /
       fillpattern = "X2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata5')
       color = GraphColors('gdata5');
       
    class GraphData6 /
       fillpattern = "R2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata6')
       color = GraphColors('gdata6');
       
    class GraphData7 /
       fillpattern = "L3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata7')
       color = GraphColors('gdata7');
       
    class GraphData8 /
       fillpattern = "X3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata8')
       color = GraphColors('gdata8');
       
    class GraphData9 /
       fillpattern = "R3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata9')
       color = GraphColors('gdata9');
    class GraphData10 /
       fillpattern = "L4"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata10')
       color = GraphColors('gdata10');      
end;




%let  sas=
cx445694$
cxA23A2E$
cx01665E$
cx543005$
cx9D3CDB$
cx7F8E1F$
cx2597FA$
cxB26084$
cxD17800$
cx47A82A
;



*-------------------------------------------;
*Seaborn;
*-------------------------------------------;
define style sns;
parent = styles.HTMLblue;
class GraphColors /
       'gcdata' = cx808080
       'gcdata1' = cx4c72b0
       'gcdata2' = cxdd8452
       'gcdata3' = cx55a868
       'gcdata4' = cxc44e52
       'gcdata5' = cx8172b3
       'gcdata6' = cx937860
       'gcdata7' = cxda8bc3
       'gcdata8' = cx8c8c8c
       'gcdata9' = cxccb974
       'gcdata10' = cx64b5cd
       
       'gdata' = cx808080
       'gdata1' = cx4c72b0
       'gdata2' = cxdd8452
       'gdata3' = cx55a868
       'gdata4' = cxc44e52
       'gdata5' = cx8172b3
       'gdata6' = cx937860
       'gdata7' = cxda8bc3
       'gdata8' = cx8c8c8c
       'gdata9' = cxccb974
       'gdata10' = cx64b5cd
;
       
 class GraphData1 /
       fillpattern = "L1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata1')
       color = GraphColors('gdata1');
       
    class GraphData2 /
       fillpattern = "X1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata2')
       color = GraphColors('gdata2');
       
    class GraphData3 /
       fillpattern = "R1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata3')
       color = GraphColors('gdata3');
       
    class GraphData4 /
       fillpattern = "L2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata4')
       color = GraphColors('gdata4');
       
    class GraphData5 /
       fillpattern = "X2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata5')
       color = GraphColors('gdata5');
       
    class GraphData6 /
       fillpattern = "R2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata6')
       color = GraphColors('gdata6');
       
    class GraphData7 /
       fillpattern = "L3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata7')
       color = GraphColors('gdata7');
       
    class GraphData8 /
       fillpattern = "X3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata8')
       color = GraphColors('gdata8');
       
    class GraphData9 /
       fillpattern = "R3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata9')
       color = GraphColors('gdata9');
    class GraphData10 /
       fillpattern = "L4"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata10')
       color = GraphColors('gdata10');
       

end;

%let  sns=
cx4c72b0$
cxdd8452$
cx55a868$
cxc44e52$
cx8172b3$
cx937860$
cxda8bc3$
cx8c8c8c$
cxccb974$
cx64b5cd$
cxB7AEF1$
cxDDD17E
;

*-------------------------------------------;
*Stata S2;
*-------------------------------------------;

define style stata;
parent = styles.HTMLblue;
class GraphColors /
       'gcdata' = cx808080
       'gcdata1' = cx1A476F
       'gcdata2' = cx90353B
       'gcdata3' = cx55752F
       'gcdata4' = cxE37E00
       'gcdata5' = cx6E8E84
       'gcdata6' = cxC10534
       'gcdata7' = cx938DD2
       'gcdata8' = cxCAC27E
       'gcdata9' = cxA0522D
       'gcdata10' = cx7B92A8
       'gcdata11' = cxF4F5F7
       'gcdata12' = cx9C8847

       'gdata' = cx808080
       'gdata1' = cx1A476F
       'gdata2' = cx90353B
       'gdata3' = cx55752F
       'gdata4' = cxE37E00
       'gdata5' = cx6E8E84
       'gdata6' = cxC10534
       'gdata7' = cx938DD2
       'gdata8' = cxCAC27E
       'gdata9' = cxA0522D
       'gdata10' = cx7B92A8
       'gdata11' = cxF4F5F7
       'gdata12' = cx9C8847
       ;
 class GraphData1 /
       fillpattern = "L1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata1')
       color = GraphColors('gdata1');
       
    class GraphData2 /
       fillpattern = "X1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata2')
       color = GraphColors('gdata2');
       
    class GraphData3 /
       fillpattern = "R1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata3')
       color = GraphColors('gdata3');
       
    class GraphData4 /
       fillpattern = "L2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata4')
       color = GraphColors('gdata4');
       
    class GraphData5 /
       fillpattern = "X2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata5')
       color = GraphColors('gdata5');
       
    class GraphData6 /
       fillpattern = "R2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata6')
       color = GraphColors('gdata6');
       
    class GraphData7 /
       fillpattern = "L3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata7')
       color = GraphColors('gdata7');
       
    class GraphData8 /
       fillpattern = "X3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata8')
       color = GraphColors('gdata8');
       
    class GraphData9 /
       fillpattern = "R3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata9')
       color = GraphColors('gdata9');
    class GraphData10 /
       fillpattern = "L4"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata10')
       color = GraphColors('gdata10');
       
;
end;

%let stata= 
cx1A476F$
cx90353B$
cx55752F$
cxE37E00$
cx6E8E84$
cxC10534$
cx938DD2$
cxCAC27E$
cxA0522D$
cx7B92A8$
cxF4F5F7$
cx9C8847
;


*-------------------------------------------;
*tableau;
*-------------------------------------------;



define style tableau;
parent = styles.HTMLblue;
class GraphColors /
       'gcdata' = cx808080		
       'gcdata1' = cx1f77b4		
       'gcdata2' = cxff7f0e		
       'gcdata3' = cx2ca02c		
       'gcdata4' = cxd62728		
       'gcdata5' = cx9467bd		
       'gcdata6' = cx8c564b		
       'gcdata7' = cxe377c2		
       'gcdata8' = cx7f7f7f		
       'gcdata9' = cxbcbd22		
       'gcdata10' = cx17becf		
	
       'gdata' = cx808080		
       'gdata1' = cx1f77b4		
       'gdata2' = cxff7f0e		
       'gdata3' = cx2ca02c		
       'gdata4' = cxd62728		
       'gdata5' = cx9467bd		
       'gdata6' = cx8c564b		
       'gdata7' = cxe377c2		
       'gdata8' = cx7f7f7f		
       'gdata9' = cxbcbd22		
       'gdata10' = cx17becf		
		

;

 class GraphData1 /
       fillpattern = "L1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata1')
       color = GraphColors('gdata1');
       
    class GraphData2 /
       fillpattern = "X1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata2')
       color = GraphColors('gdata2');
       
    class GraphData3 /
       fillpattern = "R1"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata3')
       color = GraphColors('gdata3');
       
    class GraphData4 /
       fillpattern = "L2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata4')
       color = GraphColors('gdata4');
       
    class GraphData5 /
       fillpattern = "X2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata5')
       color = GraphColors('gdata5');
       
    class GraphData6 /
       fillpattern = "R2"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata6')
       color = GraphColors('gdata6');
       
    class GraphData7 /
       fillpattern = "L3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata7')
       color = GraphColors('gdata7');
       
    class GraphData8 /
       fillpattern = "X3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata8')
       color = GraphColors('gdata8');
       
    class GraphData9 /
       fillpattern = "R3"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata9')
       color = GraphColors('gdata9');
    class GraphData10 /
       fillpattern = "L4"
       markersymbol = "circlefilled"
       linestyle = 1
       contrastcolor = GraphColors('gcdata10')
       color = GraphColors('gdata10');
       
end;

%let tableau= 
cx1f77b4$
cxff7f0e$
cx2ca02c$
cxd62728$
cx9467bd$
cx8c564b$
cxe377c2$
cx7f7f7f$
cxbcbd22$
cx17becf
;


run;


