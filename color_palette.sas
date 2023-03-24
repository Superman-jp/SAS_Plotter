*-------------------------------------------;
*Color Palette for SAS
import color palettes of seaborn and matplotlib to SAS style;

*-------------------------------------------;

proc template ;

define style sns_default;
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
       'gcdata11' = cxB7AEF1
       'gcdata12' = cxDDD17E
       
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
       'gdata11' = cxB7AEF1
       'gdata12' = cxDDD17E;
end;

define style mpl_set2;
parent = styles.HTMLblue;
class GraphColors /
       'gcdata' = cx808080
       'gcdata1' = cx66c2a5
       'gcdata2' = cxfc8d62
       'gcdata3' = cx8da0cb
       'gcdata4' = cxe78ac3
       'gcdata5' = cxa6d854
       'gcdata6' = cxffd92f
       'gcdata7' = cxe5c494
       'gcdata8' = cxb3b3b3
       'gcdata9' = cxCF974B
       'gcdata10' = cx87C873
       'gcdata11' = cxB7AEF1
       'gcdata12' = cxDDD17E

       'gdata' = cx808080
       'gdata1' = cx66c2a5
       'gdata2' = cxfc8d62
       'gdata3' = cx8da0cb
       'gdata4' = cxe78ac3
       'gdata5' = cxa6d854
       'gdata6' = cxffd92f
       'gdata7' = cxe5c494
       'gdata8' = cxb3b3b3
       'gcdata9' = cxCF974B
       'gcdata10' = cx87C873
       'gcdata11' = cxB7AEF1
       'gcdata12' = cxDDD17E
;
end;

run;



