%let dirn = C:\Users\NTPU Computer Center\Downloads\;

data lead;
infile "&dirn\tlc.txt" firstobs = 32;
/*firstobs*/
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

/*視窗向右 CTRL + TAB 視窗向左 CTRL + TAB + SHIFT*/

/* 直方圖 */
proc sort data = lead;
by group;
proc sgplot data  = lead;
by group;
histogram lead0; 
run;

/* 兩種藥有沒有差異 */
proc ttest data = lead;
class group;
var lead0;
run;

/*baseline 減去 第六周 進行 two independent sample t test*/
proc ttest data = lead;
paired lead0*lead6;
where group = "P";
run;

proc corr data = lead;
var lead0 lead6;
run;

/*設定新檔案觀察下降的值有沒有顯著*/
data newlead;
set lead;
diff = lead0 - lead6;
run;

proc ttest data = newlead;
class group;
var diff;
run;

/* 變數散佈圖 - 看到最右邊的點有點奇怪 */
proc sgscatter data = newlead;
matrix lead0 lead1 lead4 lead6;
run;

/* 分組變數散佈圖 分兩張圖 */
proc sgscatter data = newlead;
by group;
matrix lead0 lead1 lead4 lead6;
run;

/*  分組變數散佈圖 一張圖不同顏色 */
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

/*substr(var, start, num)*/
data tlead1;
set tlead;
time = input(compress(_NAME_, "lead"), 1.);
run;
proc print data = tlead1;
run;

/* 畫時間變化 */
/* 折線圖 如果只看第一周和第六周損失許多資訊 藍線為口服 紅線為注射 */
proc sgplot data = tlead1;
vline time/response = y1 group = group stat = mean markers;
run;
/* 每個人的趨勢圖(spaghetti plot) 看變動大不大 */
proc sgplot data = tlead1;
series x = time y = y1/group =id markers;
where group = "P"/*A*/;
run;

/* excel 檔案 */
proc import datafile = "&dirn\bodyfat.xlsx"
out = bodyfat DBMS = excel replace;
getnames = no;
run;

proc print data = bodyfat;
run;

proc sgscatter data = bodyfat;
matrix f4 - f8;
run;
