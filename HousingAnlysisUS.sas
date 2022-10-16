*Real Estate Market;

libname Plogit '/home/u62375561/sasuser.v94/HousingData';
proc import 
datafile = "/home/u62375561/sasuser.v94/HousingData/realtorDataNew (1).xlsx"
out = Plogit.Houses	dbms = XLSX	replace;
getnames = yes;
run;

data plogit.Houses;
set plogit.Houses;
if bed =. then delete;
if bath =. then delete;
if house_size =. then delete;
if acre_lot = . then delete;
row  = _n_;
run;

proc means data = plogit.Houses nmiss;
run;

*Adding a row column to our data.;
data plogit.Houses;
set plogit.Houses;
nrow = n;
run;


*Find out outliners by creating a macro;

%macro housing(var);
proc sgscatter data = plogit.Houses;
plot &var.*nrow;
run;

PROC SGPLOT  DATA = plogit.Houses;
   VBOX &var;
   title '&var. - Box Plot';
RUN; 

proc univariate data=plogit.Houses  ;
   var &var;
   histogram;
   output out= &var.Ptile pctlpts  = 0 0.1 0.2 30 40 50 70 80 90 95 97.5 99 99.5 99.6 99.7 99.8 99.9 100 pctlpre  = P;
run;

proc sgscatter data = PLOGIT.HOUSES; 
compare y = &var  x = row / ellipse =(alpha = 0.01 type = predicted); 
title 'Losses - Scatter Plot'; 
title2 '-- with 99% prediction ellipse --'; 
run;

%mend;

*Running our macro to get outliers on numeric variables.;
%housing(price);
%housing(bath);
%housing(bed);
%housing(acre_lot);
%housing(house_size);


proc univariate data=plogit.Houses  ;
   var price;
   histogram;
   output out= PricePtile pctlpts  = 0 20 40 60 80 100 pctlpre  = P;
run;

data present;
set plogit.houses;
if price > 0 and price < 200000 then G1 = 
run;

*Taking out outliers bases on our findings with the macros.;
data plogit.Houses;
set plogit.Houses;
if bed>13 then delete;
if bath>13 then delete;
if house_size>4932 then delete;
if acre_lot>6.15 then delete;
if price>10000000 then delete;
run;


*Bivariate Analysis for categorical;

%macro bivariate(var);

proc sql;
create table &var._table as
select &var,avg(price) as Avg_priceBy&var
from plogit.Houses group by &var;
quit;
run;

proc sgplot data = &var._table;
vbar  &var/ response = Avg_priceBy&var stat = mean;
title &var._barchart;
run;

%mend;

%bivariate(state);
%bivariate(city); *Too much data to be show.;

/* bivariate for continuous variable */
/* cut the price into 5 groups to create var chart */
proc univariate data = plogit.Houses;
var price;
output out = price_ptile pctlpts= 0 20  40 60 80 100 pctlpre=P_
run;

/* 15000 1264896	1624100	2076816	2916032	5904942 */

data plogit.Houses;
set plogit.Houses;
if price<1264896 then PriceSeg = '1_VeryCheap';
if price>=1264896 & price<1624100 then PriceSeg = '2_Cheap';
if price >=1624100 & price<2076816 then PriceSeg = '3_Middle';
if price >=2076816 & price<2916032 then PriceSeg = '4_Expensive';
if price >=2916032 & price<5904942 then PriceSeg = '5_VeryExpensive';
run;



%macro bivariateforcon(var);

proc sql;
create table &var._table as
select PriceSeg,avg(&var) as Avg_&var.ByPriceSeg
from plogit.Houses group by PriceSeg order by PriceSeg;
quit;
run;

proc sgplot data = &var._table;
vbar  PriceSeg/ response = Avg_&var.ByPriceSeg stat = mean;
title &var._barchart;
run;

%mend;

%bivariateforcon(bath);
%bivariateforcon(bed);
%bivariateforcon(acre_lot);
%bivariateforcon(house_size);



proc corr data = plogit.Houses plots = matrix;
var price bed bath acre_lot house_size ;
run;



proc reg data = plogit.Houses outest=pred1;
model price = bed bath acre_lot house_size/ vif tol collin;
run;



****************************************************************************************************************;

%macro avg(var);

proc sql;
create table &var._table as
select &var,avg(price) as Avg_priceBy&var
from plogit.Houses group by &var;
quit;
run;
%mend;


%avg(City);
%avg(Year);
%avg(State);
%avg(Zip_code);

%macro jointables(var);
proc sort data = plogit.Houses out =plogit.Houses;
by &var;
RUN;

proc sort data = &var._table out = &var._table ;
by &var;
RUN;

DATA plogit.Houses;
MERGE plogit.Houses(IN = a) &var._table(IN = b);
BY &var;
IF a = 1 and b=1;
RUN;
%mend;

%jointables(City);
%jointables(Year);
%jointables(State);
%jointables(Zip_code);


/* bivariate for categorical */

%macro bivariate(var);

proc sql;
create table &var._table as
select &var,avg(price) as Avg_priceBy&var
from plogit.Houses group by &var;
quit;
run;

proc sgplot data = &var._table;
vbar  &var/ response = Avg_priceBy&var stat = mean;
title &var._barchart;
run;

%mend;

%bivariate(state);
/* %bivariate(city); so much variables */

/* we change the categoical variables into numeric which is avg of each value. */


%macro ChangeToNumeric(var);

proc sql;
create table &var._table as
select &var,avg(price) as Avg_priceBy&var
from plogit.Houses group by &var;
quit;
run;


proc sort data = plogit.Houses out =plogit.Houses;
by &var;
RUN;

proc sort data = &var._table out = &var._table ;
by &var;
RUN;

data plogit.Houses;
merge plogit.Houses(IN=a) &var._table(IN=b);
by &var;
if a = 1 and b = 1;
run;

%mend;

%ChangeToNumeric(city);
%ChangeToNumeric(state);
%ChangeToNumeric(zip_code);
%ChangeToNumeric(soldyear);




proc corr data = plogit.Houses plots = matrix;
var price bed bath  house_size Avg_priceBycity Avg_priceBystate Avg_priceByzip_code Avg_priceByyear;
run;

/* price and house_size have strong corretion */


/* vif test */

proc reg data = plogit.Houses outest=pred1;
model price = bed bath house_size 
Avg_PriceByZip_code Avg_PriceByYear Avg_PriceByCity Avg_PriceBySate/ vif tol collin;
run;


/* no variable whose vif is more than 3 */
*****************************************************************************************************************************;


data plogit.Houses;
Set Plogit.houses;
nn = _n_;
run;

proc means data=plogit.houses max ;
var nn;
output out=noobs;
run;


proc reg data=train outest=pred; 
model Price = Bed Bath House_Size Avg_PriceByZip_code;
Output Out= TrainOut P= predicted R = residual; 
store out = ModelOut;

%macro BootStrap(TestP,Seed);

proc sql outobs = %eval(&TestP*30581/100);
create table test as
select * from plogit.Houses
order by ranuni(&Seed);
quit;

proc sql;
create table train as 
select * from plogit.Houses
except
select * from test;
quit;

proc reg data=train outest=pred; 
model Price = Bath House_Size;
Output Out= TrainOut P= predicted R = residual; 
store out = ModelOut; 
run;

/* D. Run the model on test data */
proc plm source = ModelOut;
score data=test out=TestOut pred=predicted residual = residual;
run;

/* E. check residual metrics on test data */
proc sql;
create table residual_metrics_test as
select round(mean(abs(residual/Price))*100,1) as mape, round(sqrt(mean(residual**2)),1) as rmse
from TestOut;
quit;

%mend;



%BootStrap(30,100);
%BootStrap(30,200);
%BootStrap(25,100); *This is the best model for us, with a 38 MAPE and 391920 RMSE;
%BootStrap(20,100);
%BootStrap(15,100);

*Confirming the model is accurate with other data in the dataset.;
%BootStrap(25,200); *MAPE 43 RMSE 412246;
%BootStrap(25,300); *MAPE 41 RMSE 402208;


/* F. Finalize the best model selected from bootstrapping exercise */
%let TestP = 25;
%let seed = 100;

proc sql outobs = %eval(&TestP*30581/100);
create table test as
select * from lin_reg_sample
order by ranuni(&seed);
quit;

proc sql;
create table train as 
select * from lin_reg_sample
except
select * from test;
quit;



