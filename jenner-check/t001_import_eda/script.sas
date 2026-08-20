*==============================================================================
IMPORTING DATA SET IN TO SAS
==============================================================================;

Title " Importing Data Set in to SAS";

data work.Details;
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
datalines;
         1000101/15/1999 06/20/2000     VOL         1        A1 DL       34    ON$120.50
         1000202/10/1999                CRD         1        B2 DL       29    BC$450.00
         1000303/05/1999 12/01/1999     FRD         0        A1 RT       52    QC$800.25
         1000404/22/1999                A1          1        C3 DL       18    AB$45.00
         1000505/18/1999 09/10/2000     VOL         1        B2 RT       67    NS$999.99
         1000606/01/1999                CRD         0        A1 DL       45    ON$300.00
         1000707/14/1999 01/22/2000     FRD         1        C3 RT       23    BC$150.75
         1000808/09/1999                VOL         1        B2 DL       38    QC$700.00
         1000909/25/1999 03/14/2000     A1          0        A1 RT       60    AB$500.50
         1001010/30/1999                CRD         1        C3 DL       27    NS$88.00
         1001111/11/1999 04/18/2000     VOL         1        A1 RT       41    ON$650.00
         1001212/05/1999                FRD         0        B2 DL       55    BC$210.00
         1001301/20/2000 07/30/2000     CRD         1        C3 RT       19    QC$999.00
         1001402/14/2000                A1          1        A1 DL       63    AB$333.33
         1001503/08/2000 10/12/2000     VOL         0        B2 RT       30    NS$120.00
         1001604/19/2000                CRD         1        C3 DL       48    ON$405.00
         1001705/23/2000 11/29/2000     FRD         1        A1 RT       22    BC$780.00
         1001806/17/2000                VOL         0        B2 DL       58    QC$95.00
         1001907/02/2000 12/15/2000     A1          1        C3 RT       36    AB$540.00
         1002008/28/2000                CRD         1        A1 DL       44    NS$610.00
;
run;

proc print data = work.Details(obs=10);
run;

title;
*==================================================================================
Browsing Descriptive Portion
===================================================================================;
proc contents  data = work.Details order = varnum;
run;

*====================================================================================
Finding number of unique distinct values
=====================================================================================;

Title "Number of unique distinct values in each variables";
proc freq data = work.Details nlevels;
ods exclude onewayfreqs;
run;

proc freq data = work.Details;
table deactreason Dealertype province goodcredit/ nopercent nocum;
run;
title;
