/*soh**********************************************************************************
CODE NAME                 : <m_exportxlsx.sas>
CODE TYPE                 : <macro >
DESCRIPTION               : <生成excel列表> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < all>
OUTPUT                    : < none >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & weix
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Weixin				2018-6-22
--------------------------------------------------------------------------;*/

/*对导出的次数进行计数*/

%macro m_count(title=,creator=,num=) ;
data temp1; 
  length projects title creator creatime $50 ;
  projects="&study.";
  title="&title.";
  creator="&creator.";
  creatime=put(input("&sysdate.",date7.),yymmdd10.);
  num="&num.";
run;

PROC IMPORT OUT= WORK.temp
            DATAFILE= "D:\hr_projects\summary.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data temp2; 
  length projects title creator creatime num $50 ;
  set temp; 
  format projects title creator creatime num $50. ;
run;

data summary;
  length projects title creator creatime num $50 ;
  set temp2 temp1; 
run;
proc sort nodupkeys; by title creator creatime projects num; run;

ods listing close; 
ods RESULTS off; 
ods html close; 
ods escapechar='^';
ods excel file="D:\hr_projects\summary.xlsx" options(sheet_name="Sheet1"  contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;
ods excel options(embedded_titles='no' embedded_footnotes='no');
Options   nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 
proc report data=summary nowd ;
     column _all_;	
 run;
ods excel close;
ods listing;

%mend;



