*Small Project for the Telecom company

Customer Distribution and Deactivation Analyses
Objective:Analyzing and performing EDA on a  CRM data of a wireless company for 2 years. 
investigating the customer distribution and business behaviors, and then gaining insightful understanding about the customers, and to forecast the deactivation
trends for the next 6 months.

Data:
Acctno: account number.
Actdt: account activation date
Deactdt: account deactivation date
DeactReason: reason for deactivation.
GoodCredit: customer’s credit is good or not.
RatePlan: rate plan for the customer.
DealerType: dealer type.
Age: customer age.
Province: province.
Sales: the amount of sales to a customer;



LIBNAME TELECOM "C:\DSA\Advanced SAS\Final Project";

*==============================================================================
IMPORTING DATA SET IN TO SAS
==============================================================================;

Title " Importing Data Set in to SAS";


data telecom.Details;
infile "C:\DSA\Advanced SAS\Final Project\New_Wireless_Fixed.txt";
input acctno 1-14
@15 actdt mmddyy10.
@26 Deactdt mmddyy10.
Deactreason $ 41-45
GoodCredit 53
Rateplan  $62-63
DealerType $65-66
Age 74 -75
Province $ 80-81
Sales dollar11.2
;
format acctno 14.0 actdt date9. Deactdt date9. ;
format Sales DOLLAR11.2;
run;

proc print data = telecom.Details(obs=10);
run;

title;
***********************************************************************************************************************
Analyzing the data set and Performing EDA
***********************************************************************************************************************;

*==================================================================================
Browsing Descriptive Portion 
===================================================================================;
proc contents  data = telecom.Details order = varnum;
run;

*===================================================================================
Browsing Head of data set
====================================================================================;
Title "Browsing Head of Data Set";
proc print  data = telecom.Details (obs = 10);
run;

*===================================================================================
Browsing tail of data set
====================================================================================;
Title "Browsing Tail of Data Set";
proc print  data = telecom.Details (obs = 102255 firstobs =102246);
run;

*====================================================================================
*Finding number of unique distinct values
=====================================================================================;

Title "Number of unique distinct values in each variables";
proc freq data =telecom.Details nlevels;
ods exclude onewayfreqs;
run;

proc freq data = telecom.Details;
table deactreason Dealertype province goodcredit/ nopercent nocum;
run;

****************************************************************************************
*EDA AND DATA CLEANING;
****************************************************************************************
*Removing Duplicated Data if any;
proc sort data = telecom.Details out = telecom.Data nodupkey;
by Acctno;
run;
 *No duplicated account numbers were found so zero observations were deleted ;

*=======================================================================================
Checking for missing values
========================================================================================;
Title "Number of missing values";
proc means data = telecom.Data nmiss;
run;

proc sql;
select nmiss(Province) as Province,nmiss (deactreason) as deactreason,
nmiss(rateplan) as rateplan,nmiss(dealertype) as dealertype
from telecom.Data;
quit;

 * Replacing missing values in age with mean age in new column as New_Age ;
PROC SQL;
CREATE TABLE TELECOM.WIRELESS_NOMISS AS
SELECT*,
COALESCE(AGE,MEDIAN(AGE)) as New_age		
	 FROM TELECOM.Details
 ;
 QUIT;

 PROC PRINT DATA = TELECOM.WIRELESS_NOMISS (OBS=50);
 RUN;

*========================================================================================
Descriptive Analysis of continous variables
=========================================================================================;
TITLE"DESCRIPTIVE ANALYSIS OF CONTINUOUS";
PROC MEANS DATA = Telecom.Data N NMISS MIN Q1 MEDIAN Q3 MAX qrange mean std cv clm;
RUN;

PROC UNIVARIATE DATA = Telecom.Data;RUN;
*---------------------------------------------------------------------------------------------------
QUESTION 1 
1.1  Explore and describe the dataset briefly. For example, is the acctno unique? What
is the number of accounts activated and deactivated? When is the earliest and
latest activation/deactivation dates available? 
-------------------------------------------------------------------------------------------------;

*1.1a  Explore and describe the dataset briefly;
TITLE "DESCRIPTION OF DATASET";
PROC CONTENTS DATA = TELECOM.DATA;
RUN;

*Checking if All Account Numbers are Unique ?;
*Removing Duplicated Data if any;
proc sort data = telecom.Details out = telecom.Data nodupkey;
by Acctno;
run;

*Number of unique accounts;
PROC SQL OUTOBS=20;
SELECT COUNT(*) AS TOTAL_COUNT, 
	   COUNT(DISTINCT Acctno) AS UNIQUE_ACCOUNTS
FROM TELECOM.DATA
;
QUIT;
 *No duplicated account numbers were found so zero observations were deleted ;

*what is the number of accounts activated and deactivated ?;
Title "Number of Activated and Deactivated Accounts";
PROC SQL;
SELECT COUNT(Acctno) AS Total_Accounts,
      (COUNT(Actdt) - COUNT(Deactdt)) AS Activted_Accounts,
	   COUNT(Deactdt) AS Deactvated_Accounts 
FROM telecom.Data;
QUIT;

*When is the earliest and latest activation/deactivation dates available?;
*Earliest and Latest Activation Date;

Title "Earliest and Latest Activation Date";
proc sql;
select min(actdt) as Earliest_Activation_Date format = date9.,
max(actdt) as Latest_Activation_Date format = date9. 
from telecom.Data;
quit;

*Earliest and Latest DeActivation Date;

Title "Earliest and Latest DeActivation Date";
proc sql;
select min(deactdt) as Earliest_DeActivation_Date format = date9.,
max(deactdt) as Latest_DeActivation_Date format = date9. 
from telecom.Data;
quit;
title;
*QUESTION 2;
 *1.2 What is the age and province distributions of active customers?;

data telecom.Account_segment ;
set telecom.Data;
length Age_Group $25;
 IF AGE <= 20 THEN AGE_GROUP  = "LESS THAN 20";
 ELSE IF  21<= AGE<=40 THEN AGE_GROUP = "BETWEEN 21 AND 40 ";
 ELSE IF 41<=AGE <=59 THEN AGE_GROUP ="BETWEEN 41 AND 60";
 ELSE IF AGE >= 60 THEN AGE_GROUP = "60 AND ABOVE";
 RUN;

proc print data = telecom.Account_segment (obs=20);
run;

 Title"Age distributions of active customers";

PROC SQL ;
CREATE TABLE AGEDIST AS
SELECT AGE_GROUP,
       (COUNT(Actdt) - COUNT(Deactdt))AS TOTAL_ACTIVE_CUSTOMERS,
	   SUM(SALES) AS TOTAL_SALES
FROM TELECOM.ACCOUNT_SEGMENT
WHERE DEACTDT IS NULL
GROUP BY AGE_GROUP
ORDER BY AGE_GROUP;
QUIT;

PROC PRINT DATA = AGEDIST;
RUN;


PROC GCHART DATA = TELECOM.ACCOUNT_SEGMENT;
PIE3D AGE_GROUP/ PERCENT =INSIDE;
WHERE DEACTDT IS NULL;
RUN;
*=====================================================================================;
PROC SQL ;
CREATE TABLE PROVINDIST AS
SELECT PROVINCE,
       (COUNT(Actdt) - COUNT(Deactdt))AS TOTAL_ACTIVE_CUSTOMERS,
	   SUM(SALES) AS TOTAL_SALES
FROM TELECOM.ACCOUNT_SEGMENT
WHERE DEACTDT IS NULL ,PROVINCE IS NOT NULL
GROUP BY PROVINCE
ORDER BY PROVINCE;
QUIT;

*PROC PRINT DATA = PROVINDIST;
*WHERE PROVINCE IS NOT NULL; 
*RUN;

 Title"Distribution of Active Customers By Province ";
PROC GCHART DATA = TELECOM.ACCOUNT_SEGMENT;
PIE3D PROVINCE/ PERCENT =INSIDE;
WHERE DEACTDT IS NULL;
RUN;

*=======================================================================================;
PROC SQL ;
CREATE TABLE AGEPROVINDIST AS
SELECT PROVINCE,AGE_GROUP,
       (COUNT(Actdt) - COUNT(Deactdt))AS TOTAL_ACTIVE_CUSTOMERS,
	   SUM(SALES) AS TOTAL_SALES
FROM TELECOM.ACCOUNT_SEGMENT
WHERE DEACTDT IS NULL 
GROUP BY PROVINCE,AGE_GROUP
ORDER BY PROVINCE,AGE_GROUP;
QUIT;

 Title"Distribution of Active Customers By Age and Province ";
PROC PRINT DATA = AGEPROVINDIST;
WHERE PROVINCE IS NOT NULL; 
RUN;

*What is the age and province distributions of deactivated customers?;
Title"Distribution of DeActive Customers By Age and Province ";
PROC SQL ;
CREATE TABLE AGEPROVINDIST1 AS
SELECT PROVINCE,AGE_GROUP,
 COUNT(Deactdt)AS TOTAL_DEACTIVATED_CUSTOMERS,
	   SUM(SALES) AS TOTAL_SALES
FROM TELECOM.ACCOUNT_SEGMENT
WHERE DEACTDT IS NOT NULL 
GROUP BY PROVINCE,AGE_GROUP
ORDER BY PROVINCE,AGE_GROUP;
QUIT;

PROC PRINT DATA = AGEPROVINDIST1;
WHERE PROVINCE IS NOT NULL; 
RUN;
*VISUALIZATION;
 Title"Age distributions of Deactive customers";

PROC SQL ;
CREATE TABLE AGEDIST1 AS
SELECT AGE_GROUP,
       COUNT(DEACTDT) AS TOTAL_DEACTIVE_CUSTOMERS,
	   SUM(SALES) AS TOTAL_SALES
FROM TELECOM.ACCOUNT_SEGMENT
WHERE DEACTDT IS NOT NULL
GROUP BY AGE_GROUP
ORDER BY AGE_GROUP;
QUIT;

PROC PRINT DATA = AGEDIST1;
RUN;


PROC GCHART DATA = TELECOM.ACCOUNT_SEGMENT;
PIE3D AGE_GROUP/ PERCENT =INSIDE;
WHERE DEACTDT IS NOT NULL;
RUN;
*=====================================================================================;
 Title" Distributions of Deactive customers by Province";
PROC SQL ;
CREATE TABLE PROVINDIST AS
SELECT PROVINCE,
      COUNT(DEACTDT) AS TOTAL_DEACTIVE_CUSTOMERS,
	   SUM(SALES) AS TOTAL_SALES
FROM TELECOM.ACCOUNT_SEGMENT
WHERE DEACTDT IS NOT NULL
GROUP BY PROVINCE
ORDER BY PROVINCE;
QUIT;

PROC PRINT DATA = PROVINDIST;
WHERE PROVINCE IS NOT NULL; 
RUN;

 Title"Distribution of DeActive Customers By Province ";
PROC GCHART DATA = TELECOM.ACCOUNT_SEGMENT;
PIE3D PROVINCE/ PERCENT =INSIDE;
WHERE DEACTDT IS NOT NULL;
RUN;

*QUESTION- 3;
 *Segment the customers based on age, province and sales amount:;

 *Sales segment: < $100, $100---500, $500-$800, $800 and above.;
TITLE"SEGMENTATION BASED ON AGE , SALES and PROVINCE";
 DATA TELECOM.SEGMENTS;
 SET TELECOM.DATA;
 DROP NEW_AGE;
 LENGTH AGE_GROUP $25;
 LENGTH SALES_GROUP $25;
 LENGTH PROVINCEE $25;


 IF AGE <= 20 THEN AGE_GROUP  = "20 OR LESS";
 ELSE IF  21<= AGE<=40 THEN AGE_GROUP= "BETWEEN 21 & 40 ";
 ELSE IF 41<=AGE<=59 THEN AGE_GROUP =" BETWEEN 41 - 60";
 ELSE IF AGE >= 60 THEN AGE_GROUP = "60 & MORE";


 *Sales segment: < $100, $100---500, $500-$800, $800 and above.;

 IF SALES<100 THEN SALES_GROUP ="$100 & BELOW";
 ELSE IF 100 <SALES<500 THEN SALES_GROUP ="$100 - $500";
 ELSE IF 500 <SALES<800 THEN SALES_GROUP ="$500 - $800";
 ELSE IF SALES >=800 THEN SALES_GROUP="800 & ABOVE";

 *Province Segmentation;

IF PROVINCE = "AB" THEN PROVINCEE = "ALBERTA";
ELSE IF PROVINCE ="BC" THEN PROVINCEE ="BRITISH COLOMBIA";
ELSE IF PROVINCE ="NS" THEN PROVINCEE = "NOVA SCOTIA";
ELSE IF PROVINCE ="ON" THEN PROVINCEE = "ONTARIO";
ELSE IF PROVINCE ="QC" THEN PROVINCEE ="QUEBEC";
RUN;

PROC PRINT DATA = TELECOM.SEGMENTS (OBS = 50);

RUN;

*Create Analysis Report Based on Segmentation;
TITLE "SALES BASED ON DIFFERENT AGE GROUPS";
PROC FREQ DATA = TELECOM.SEGMENTS;
TABLE AGE_GROUP*SALES_GROUP/CHISQ; 
run;

PROC SGPLOT DATA =TELECOM.SEGMENTS;
VBAR AGE_GROUP/ group = SALES_GROUP groupdisplay = CLUSTER;
YAXIS LABEL = "SALES";
RUN;

TITLE "SALES BASED ON DIFFERENT PROVINCE";

PROC FREQ DATA = TELECOM.SEGMENTS;
TABLE PROVINCEE*SALES_GROUP/ chisq;
run;

PROC SGPLOT DATA =TELECOM.SEGMENTS;
VBAR  PROVINCEE/ group =SALES_GROUP groupdisplay = CLUSTER;
YAXIS LABEL = "SALES";
RUN;

TITLE "AGE DISTRIBUTTION BASED ON DIFFERENT PROVINCE";

PROC FREQ DATA = TELECOM.SEGMENTS;
TABLE PROVINCEE*AGE_GROUP/ chisq;
run;

PROC SGPLOT DATA =TELECOM.SEGMENTS;
VBAR  PROVINCEE/ group =AGE_GROUP groupdisplay = CLUSTER;
YAXIS LABEL = "SALES";
RUN;

PROC OPTIONS OPTION = MACRO;
RUN;

*METHOD USING MACRO;

%MACRO BI_ANALYSIS_CAT_CAT (DSN = ,VAR1= , VAR2= );
PROC FREQ DATA =&DSN;
TITLE " RELATION BETWEEN &VAR1. AND &VAR2.";
TABLE &VAR1.*&VAR2/chisq;
PROC SGPLOT DATA = &DSN;
 VBAR &VAR1/GROUP = &VAR2 GROUPDISPLAY = CLUSTER;
 RUN;
%MEND BI_ANALYSIS_CAT_CAT;

%BI_ANALYSIS_CAT_CAT(DSN =TELECOM.SEGMENTS,VAR1= AGE_GROUP, VAR2 = SALES_GROUP);
%BI_ANALYSIS_CAT_CAT(DSN =TELECOM.SEGMENTS ,VAR1 =SALES_GROUP , VAR2 =PROVINCE );
%BI_ANALYSIS_CAT_CAT(DSN =TELECOM.SEGMENTS ,VAR1 AGE_GROUP , VAR2 =PROVINCE );


*1.4.Statistical Analysis:;
*1) Calculate the tenure in days for each account and give its simple statistics;

proc sort data = telecom.segments out=telecom.sort ;
by descending actdt ;
run;

proc print data = telecom.sort (obs=50);
run;

Title "Tenure in days for each account";
data telecom.tenure;
set telecom.segments;
*reference_date = "20JAN2001"d;
if deactdt = '' then tenure_days = intck('day',actdt,"20JAN2001"d);
else
tenure_days = intck('day',actdt,deactdt);
run;

proc print data = telecom.tenure(obs = 50);
run;

proc means data = telecom.tenure  N NMISS MIN Q1 MEDIAN Q3 MAX qrange mean std cv clm;
var tenure_days;
run;


%MACRO UNI_ANALYSIS_NUM(DATA,VAR);
 TITLE "HORIZONTAL BOXPLOT FOR &VAR";
 PROC SGPLOT DATA=&DATA;
  HBOX &VAR;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=LIGHTPINK
     ;
 RUN;
TITLE "UNIVARIATE ANALYSIS FOR &VAR";
proc means data=&DATA  N NMISS MIN Q1 MEDIAN MEAN Q3 MAX qrange cv clm maxdec=2 ;
var &var;
run;
%MEND;

%UNI_ANALYSIS_NUM(telecom.tenure,TENURE_DAYS);

*2) Calculate the number of accounts deactivated for each month;

data telecom.deact_yrmonth;
set telecom.segments;
deact_year = year(deactdt);
deact_month = intnx('month',deactdt,0,'b');
run;

proc print data = telecom.deact_yrmonth (obs=50);
format deact_month monname3.;
run;

*To find monthly deactivation in all the years from 1999 - 2001;
Title "Number of monthly deactivation from 1999 - 2001";
proc freq data = telecom.deact_yrmonth;
table deact_month/NOCUM;
format deact_month monname3.;
run;


*for year 1999;
DATA telecom.deact_1999; 
   SET telecom.deact_yrmonth;
   KEEP acctno deactdt deact_year deact_month;
   where deact_year = 1999;
RUN;
proc print data = telecom.deact_1999 (obs=100);
format deact_month  monname3.;
run;
 proc sort data = telecom.deact_1999 out = telecom.deact1_1999;
 by deact_month;
 run;
proc print data = telecom.deact1_1999 (obs=100);
format deact_month  monname3.;
run;
Title"Number Of Accounts Deactivated For Each Month In 1999";
proc sql;
create table telecom.deactNo_1999 as
select deact_month,
count(*) as Deact_Number
from telecom.deact1_1999
group by deact_month;
quit;

proc print data = telecom.deactNo_1999;
format deact_month  monname3.;
run;

*for year 2000;

 DATA telecom.deact_2000; 
   SET telecom.deact_yrmonth;
   KEEP acctno deactdt deact_year deact_month;
   where deact_year = 2000;
RUN;
proc print data = telecom.deact_2000 (obs=100);
format deact_month  monname3.;
run;
 proc sort data = telecom.deact_2000 out = telecom.deact1_2000;
 by deact_month;
 run;
proc print data = telecom.deact1_2000 (obs=100);
format deact_month  monname3.;
run;
Title"Number Of Accounts Deactivated For Each Month In 2000";
proc sql;
create table telecom.deactNo_2000 as
select deact_month,
count(*) as Deact_Number
from telecom.deact1_2000
group by deact_month;
quit;

proc print data = telecom.deactNo_2000;
format deact_month  monname3.;
run;


*for year 2001;
DATA telecom.deact_2001; 
   SET telecom.deact_yrmonth;
   KEEP acctno deactdt deact_year deact_month;
   where deact_year = 2001;
RUN;
proc print data = telecom.deact_2001 (obs=100);
format deact_month  monname3.;
run;
 proc sort data = telecom.deact_2001 out = telecom.deact1_2001;
 by deact_month;
 run;
proc print data = telecom.deact1_2001 (obs=100);
format deact_month  monname3.;
run;
Title"Number Of Accounts Deactivated For Each Month In 2001";
proc sql;
create table telecom.deactNo_2001 as
select deact_month,
count(*) as Deact_Number
from telecom.deact1_2001
group by deact_month;
quit;

proc print data = telecom.deactNo_2001;
format deact_month  monname3.;
run;
*visualization;
Title"Accounts Deactivated In 1999";
proc sgplot data=telecom.deactno_1999;
series x=deact_month y=deact_number;
xaxis label = "months in 1999";
yaxis label ="Account Deactivation";
format deact_month  monname3.;
run;

Title"Accounts Deactivated In 2000";
proc sgplot data=telecom.deactno_2000;
series x=deact_month y=deact_number;
xaxis label = "months in 2000";
yaxis label ="Account Deactivation";
format deact_month  monname3.;
run;

*3) Segment the account, first by account status “Active” and “Deactivated”, then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.;

Title "Tenure in days for each account";
data telecom.tenure;
set telecom.segments;
*reference_date = "20JAN2001"d;
if deactdt = '' then tenure_days = intck('day',actdt,"20JAN2001"d);
else
tenure_days = intck('day',actdt,deactdt);
run;

proc print data = telecom.tenure(obs = 50);
run;

data telecom.Account_segment ;
set telecom.tenure;
length Account_Status $25;
length Tenure_Segment $30;
if deactdt = '' then Account_Status = "Active";
else Account_Status = "DeActivated";

if tenure_days <30 then Tenure_Segment ="Less than 30 days";
else if tenure_days <60 then Tenure_Segment = "Between 31 and 60 days";
else if tenure_days <365 then Tenure_Segment = "Between 60 days and 1 year";
else if tenure_days > 365 then Tenure_Segment = "Over 1 year";
run;

proc print data = telecom.Account_Segment(obs = 100);
run;

title"Account Status";
proc freq data = telecom.Account_Segment;
table Account_Status;
run;
title"Tenure Segmentation";
proc freq data = telecom.Account_Segment;
table Tenure_Segment;
run;


*4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”;
data telecom.credit ;
set telecom.Account_Segment;
 if goodcredit = 1 then Credit_Type = "Good";
 else Credit_Type = "Bad";
 run;

 proc print data = telecom.credit (obs = 100);
 run;

PROC OPTIONS OPTION = MACRO;
RUN;

%MACRO BI_ANALYSIS_CAT_CAT (DSN = ,CLASS= , VAR= );
PROC FREQ DATA =&DSN;
TITLE " RELATION BETWEEN &VAR. AND &CLASS.";
TABLE &VAR.*&CLASS/chisq;
PROC SGPLOT DATA = &DSN;
 VBAR &VAR/GROUP = &CLASS GROUPDISPLAY = STACK;
 RUN;
%MEND BI_ANALYSIS_CAT_CAT;

%BI_ANALYSIS_CAT_CAT(DSN =telecom.credit ,CLASS = TENURE_SEGMENT, VAR = CREDIT_TYPE);
%BI_ANALYSIS_CAT_CAT(DSN =telecom.credit ,CLASS = TENURE_SEGMENT, VAR = RATEPLAN);
%BI_ANALYSIS_CAT_CAT(DSN =telecom.credit ,CLASS = TENURE_SEGMENT, VAR = DEALERTYPE);


*5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?;

%MACRO BI_ANALYSIS_CAT_CAT (DSN = ,CLASS= , VAR= );
PROC FREQ DATA =&DSN;
TITLE " RELATION BETWEEN &VAR. AND &CLASS.";
TABLE &VAR.*&CLASS/chisq;
PROC SGPLOT DATA = &DSN;
 VBAR &VAR/GROUP = &CLASS GROUPDISPLAY = CLUSTER;
 RUN;
%MEND BI_ANALYSIS_CAT_CAT;

%BI_ANALYSIS_CAT_CAT(DSN =telecom.credit ,CLASS =ACCOUNT_STATUS , VAR = TENURE_SEGMENT);

*better tenure segmentation strategy;
DATA telecom.TENURE_SEGNEW;
SET telecom.credit;
IF TENURE_DAYS < 183 THEN TENURE_SEGMENT ="LESS THAN 6 MONTHS";
ELSE IF TENURE_DAYS <365 then TENURE_SEGMENT ="BETWEEN 6 MONTHS AND 1 YEAR";
ELSE IF TENURE_DAYS <=731 then TENURE_SEGMENT ="BETWEEN 1 AND 2 YEARS";
RUN;

proc print data = telecom.TENURE_SEGNEW (obs=100);
run;

%BI_ANALYSIS_CAT_CAT(DSN =telecom.TENURE_SEGNEW ,CLASS =TENURE_SEGMENT , VAR = ACCOUNT_STATUS);


*6 Does Sales amount differ among different account status, GoodCredit, and
customer age segments?;

*SALES VS ACCOUNT STATUS
*=======================
*summarization using proc univariate and test of normality;
proc univariate data=telecom.TENURE_SEGNEW normal;
class account_status;
var sales;
run;

%MACRO BI_ANALYSIS_NUMs_CAT (DSN = ,CLASS= , VAR=,VAR1= );
%LET N = %SYSFUNC(COUNTW(&VAR));
%DO I = 1 %TO &N;
	%LET X = %SCAN(&VAR,&I);
	PROC MEANS DATA = &DSN. N NMISS MIN Q1 MEDIAN MEAN Q3 MAX qrange cv clm maxdec=2 ;
	TITLE " RELATION BETWEEN &X. AND &CLASS.";
	CLASS &CLASS. ;
	VAR &X.;
	OUTPUT OUT= OUT_&CLASS._&X. MIN =   MEAN=  STD = MAX = /AUTONAME ;
	RUN;
%END;
%MEND BI_ANALYSIS_NUMs_CAT;


%BI_ANALYSIS_NUMs_CAT (DSN = telecom.TENURE_SEGNEW  ,CLASS=ACCOUNT_STATUS , VAR=sales,VAR1=PROVINCEE );
%BI_ANALYSIS_NUMs_CAT (DSN = telecom.TENURE_SEGNEW  ,CLASS=CREDIT_TYPE , VAR=sales );
%BI_ANALYSIS_NUMs_CAT (DSN = telecom.TENURE_SEGNEW  ,CLASS=AGE_GROUP, VAR=sales );

*Visualization using histogram;
Title "Distribution of Sales with Account Status ";
proc sgplot data=telecom.TENURE_SEGNEW;
   histogram sales / group=account_status transparency=0.5 scale=count;
   keylegend / location=inside position=topright across=1;
run;
title;
*for test of equality of variance;
proc glm data=telecom.TENURE_SEGNEW;
class account_status;
model sales = account_status;
means account_status / hovtest=levene(type=abs);
run;
*T test for test of independancy;
%MACRO BI_ANALYSIS_NUMs_CAT_TTEST (DSN = ,CLASS= , VAR= );
TITLE "TTEST for &VAR. grouped by &CLASS. in &DSN.";
proc ttest data=&DSN.;
var &VAR. ;
class &CLASS.;
run;
QUIT;
%MEND BI_ANALYSIS_NUMs_CAT_TTEST;

%BI_ANALYSIS_NUMs_CAT_TTEST (DSN =telecom.TENURE_SEGNEW ,CLASS=account_status , VAR=sales);

*SALES VS GOOD CREDIT 

*summarization using proc univariate and test of normality;
proc univariate data=telecom.TENURE_SEGNEW normal;
class credit_type;
var sales;
run;

%BI_ANALYSIS_NUMs_CAT (DSN = telecom.TENURE_SEGNEW  ,CLASS=CREDIT_TYPE , VAR=sales );

*Visualization using histogram;
Title "Distribution of Sales with credit type ";
proc sgplot data=telecom.TENURE_SEGNEW;
   histogram sales / group=credit_type transparency=0.5 scale=count;
   keylegend / location=inside position=topright across=1;
run;
title;
*for test of equality of variance;
proc glm data=telecom.TENURE_SEGNEW;
class credit_type;
model sales = credit_type;
means credit_type / hovtest=levene(type=abs);
run;

%BI_ANALYSIS_NUMs_CAT_TTEST (DSN =telecom.TENURE_SEGNEW ,CLASS=credit_type , VAR=sales);

*Does Sales amount differ among age group?;

proc univariate data=telecom.TENURE_SEGNEW normal;
class Age_group;
var sales;
run;

%BI_ANALYSIS_NUMs_CAT (DSN = telecom.TENURE_SEGNEW  ,CLASS=CREDIT_TYPE , VAR=sales );

*Visualization using histogram;
Title "Distribution of Sales with Age group ";
proc sgplot data=telecom.TENURE_SEGNEW;
   histogram sales / group=age_group transparency=0.5 scale=count;
   keylegend / location=inside position=topright across=1;
run;
title;

*for test of equality of variance;
proc glm data=telecom.TENURE_SEGNEW;
class age_group;
model sales = age_group;
means age_group / hovtest=levene(type=abs);
run;

*Test of independancy using one way anova ;
PROC ANOVA DATA = TELECOM.TENURE_SEGNEW;
CLASS AGE_GROUP;
MODEL SALES = AGE_GROUP;
RUN;
*==============================================================================================================;
