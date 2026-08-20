*3) Segment the account, first by account status "Active" and "Deactivated", then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.;

data work.tenure;
input acctno deactdt : mmddyy10. tenure_days sales;
format deactdt date9. sales dollar11.2;
datalines;
10001 06/20/2000 522 120.50
10002 . 710 450.00
10003 12/01/1999 271 800.25
10004 . 20 45.00
10005 09/10/2000 45 999.99
10006 . 300 300.00
10007 01/22/2000 400 150.75
10008 . 600 700.00
10009 03/14/2000 15 500.50
10010 . 90 88.00
10011 04/18/2000 730 650.00
10012 . 200 210.00
;
run;

data work.Account_segment ;
set work.tenure;
length Account_Status $25;
length Tenure_Segment $30;
if deactdt = '' then Account_Status = "Active";
else Account_Status = "DeActivated";

if tenure_days <30 then Tenure_Segment ="Less than 30 days";
else if tenure_days <60 then Tenure_Segment = "Between 31 and 60 days";
else if tenure_days <365 then Tenure_Segment = "Between 60 days and 1 year";
else if tenure_days > 365 then Tenure_Segment = "Over 1 year";
run;

proc print data = work.Account_Segment(obs = 100);
run;

title"Account Status";
proc freq data = work.Account_Segment;
table Account_Status;
run;
title"Tenure Segmentation";
proc freq data = work.Account_Segment;
table Tenure_Segment;
run;

%MACRO BI_ANALYSIS_CAT_CAT (DSN = ,CLASS= , VAR= );
PROC FREQ DATA =&DSN;
TITLE " RELATION BETWEEN &VAR. AND &CLASS.";
TABLE &VAR.*&CLASS/chisq;
PROC SGPLOT DATA = &DSN;
 VBAR &VAR/GROUP = &CLASS GROUPDISPLAY = CLUSTER;
 RUN;
%MEND BI_ANALYSIS_CAT_CAT;

%BI_ANALYSIS_CAT_CAT(DSN =work.Account_segment ,CLASS =ACCOUNT_STATUS , VAR = TENURE_SEGMENT);

*T test for test of independancy;
%MACRO BI_ANALYSIS_NUMs_CAT_TTEST (DSN = ,CLASS= , VAR= );
TITLE "TTEST for &VAR. grouped by &CLASS. in &DSN.";
proc ttest data=&DSN.;
var &VAR. ;
class &CLASS.;
run;
QUIT;
%MEND BI_ANALYSIS_NUMs_CAT_TTEST;

%BI_ANALYSIS_NUMs_CAT_TTEST (DSN =work.Account_segment ,CLASS=account_status , VAR=sales);
title;
