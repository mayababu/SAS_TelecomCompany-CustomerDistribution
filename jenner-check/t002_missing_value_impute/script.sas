*=======================================================================================
Checking for missing values
========================================================================================;

data work.Details;
input acctno 1-14 Deactreason $ 41-45 Rateplan $ 62-63 DealerType $ 65-66 Age 74-75 Province $ 80-81;
datalines;
10001                                   VOL                  A1 DL       34    ON
10002                                   CRD                  B2 DL             BC
10003                                   FRD                  A1 RT       52    QC
10004                                   A1                   C3 DL       18    AB
10005                                   VOL                  B2 RT       67    NS
10006                                   CRD                  A1 DL       45
10007                                   FRD                  C3 RT       23    BC
10008                                   VOL                  B2 DL       38    QC
10009                                   A1                   A1 RT             AB
10010                                   CRD                  C3 DL       27    NS
;
run;

Title "Number of missing values";
proc means data = work.Details nmiss;
run;

proc sql;
select nmiss(Province) as Province,nmiss (deactreason) as deactreason,
nmiss(rateplan) as rateplan,nmiss(dealertype) as dealertype
from work.Details;
quit;

 * Replacing missing values in age with mean age in new column as New_Age ;
PROC SQL;
CREATE TABLE WORK.WIRELESS_NOMISS AS
SELECT*,
COALESCE(AGE,MEDIAN(AGE)) as New_age
	 FROM WORK.Details
 ;
 QUIT;

 PROC PRINT DATA = WORK.WIRELESS_NOMISS (OBS=50);
 RUN;
title;
