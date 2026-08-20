*1.4.Statistical Analysis:;
*1) Calculate the tenure in days for each account and give its simple statistics;

data work.segments;
input acctno actdt : mmddyy10. deactdt : mmddyy10.;
format actdt deactdt date9.;
datalines;
10001 01/15/1999 06/20/2000
10002 02/10/1999 .
10003 03/05/1999 12/01/1999
10004 04/22/1999 .
10005 05/18/1999 09/10/2000
10006 06/01/1999 .
10007 07/14/1999 01/22/2000
10008 08/09/1999 .
10009 09/25/1999 03/14/2000
10010 10/30/1999 .
;
run;

proc sort data = work.segments out=work.sort ;
by descending actdt ;
run;

proc print data = work.sort (obs=50);
run;

Title "Tenure in days for each account";
data work.tenure;
set work.segments;
*reference_date = "20JAN2001"d;
if deactdt = '' then tenure_days = intck('day',actdt,"20JAN2001"d);
else
tenure_days = intck('day',actdt,deactdt);
run;

proc print data = work.tenure(obs = 50);
run;

proc means data = work.tenure  N NMISS MIN Q1 MEDIAN Q3 MAX qrange mean std cv clm;
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

%UNI_ANALYSIS_NUM(work.tenure,TENURE_DAYS);
title;
