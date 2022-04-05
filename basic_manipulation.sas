/* switch to your file path */
%let dirn = C:\Users\NTPU Computer Center\Downloads\;

data lead;
infile "&dirn\tlc.txt" firstobs = 32;
/*firstobs：skip the first n rows*/
input id group $ lead0 lead1 lead4 lead6;
run;

proc print data = lead; run;

proc means data = lead; 
var lead0 lead1 lead4 lead6;
run;

proc means data = lead;
class group;
var lead0 lead1 lead4 lead6;
run;

/* CTRL + TAB：shift to the right window */
/* CTRL + TAB + SHIFT：shift to the left window */

/* histogram */
proc sort data = lead;
by group;
proc sgplot data  = lead;
by group;
histogram lead0; 
run;

/* two independent sample t-test */
/* Compare lead0 between different group*/
proc ttest data = lead;
class group;
var lead0;
run;

/* paired t test */
proc ttest data = lead;
paired lead0*lead6;
where group = "P";
run;

/* rho */
proc corr data = lead;
var lead0 lead6;
run;

/* check for significant difference */
data newlead;
set lead;
diff = lead0 - lead6;
run;

proc ttest data = newlead;
class group;
var diff;
run;

/* scatter plot for all variables */
proc sgscatter data = newlead;
matrix lead0 lead1 lead4 lead6;
run;

/* scatter plot by group */
proc sgscatter data = newlead;
by group;
matrix lead0 lead1 lead4 lead6;
run;

/* scatter plot by different color group */
proc sgscatter data = newlead;
matrix lead0 lead1 lead4 lead6/ group = group;
run;

/* wide to long */
proc sort data = lead;
by group id;

proc transpose data = lead prefix = y out= tlead;
by group id;
var lead0  lead1 lead4 lead6;
run;
proc print data = tlead;
run;

/* substr(var, start, num)：get substring */
/* compress：remove blank space */
data tlead1;
set tlead;
time = input(compress(_NAME_, "lead"), 1.);
run;


/* Line chart ： lose information when only focusing on week 1 and week 6 */
proc sgplot data = tlead1;
vline time/response = y1 group = group stat = mean markers;
run;

/* spaghetti plot */
proc sgplot data = tlead1;
series x = time y = y1/group =id markers;
where group = "P"/*A*/;
run;

/* excel file */
proc import datafile = "&dirn\bodyfat.xlsx"
out = bodyfat DBMS = excel replace;
getnames = no;
run;

proc print data = bodyfat;
run;

proc sgscatter data = bodyfat;
matrix f4 - f8;
run;
