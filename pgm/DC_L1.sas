/*soh**********************************************************************************
CODE NAME                 : <DC_L1.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <数据清理> 
SOFTWARE/VERSION#         : <SAS 9.3>
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
 Author & liying
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Weixin				2016-8-2
--------------------------------------------------------------------------;*/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;


%let pgmname=DC_L1;
proc printto log="&root.\logout\&pgmname..log" new;run;




proc sql;
  create table pre as select
  a.siteid 'SITE_ID',
  a.subjid 'SUBJECT_NUMBER',
  a.brthdat 'YEAR_OF_BIRTH',
  b.visstage 'VISITNAME',
  b.rsmethod 'MODALITY',
  b.rsmecom 'MODALITY_OTHER',
  b.rsdat 'EXAM DATE'
  from derived.dm as a left join derived.rst1 as b on a.subjid=b.subjid;
  quit;


proc sql;
  create table pre1 as select
  a.siteid 'SITE_ID',
  a.subjid 'SUBJECT_NUMBER',
  a.brthdat 'YEAR_OF_BIRTH',
  b.visstage 'VISITNAME',
  b.rsmethod 'MODALITY',
  b.rsmecom 'MODALITY_OTHER',
  b.rsdat 'EXAM DATE'
  from derived.dm as a left join derived.rsnt1 as b on a.subjid=b.subjid;
  quit;

data final;
  set pre pre1;
run;

proc sort data=final; by subjid;run;

proc sort data=final nodupkeys; by _all_;run;

/*骨病灶*/
  proc sql;
  create table pre2 as select
  a.siteid 'SITE_ID',
  a.subjid 'SUBJECT_NUMBER',
  b.visstage 'VISITNAME',
  b.ectdat 'EXAM_DATE',
  a.brthdat 'YEAR_OF_BIRTH'
  from derived.dm as a left join derived.ect as b on a.subjid=b.subjid
order by a.subjid;
  quit;



goptions reset=all;
ods tagsets.ExcelXP file="..\output\&study._影像学拼接表_&sysdate..xml" options(sheet_name="肿瘤影像学拼表" absolute_column_width='15')  style=Minimal;
 proc report data=final;
 column _all_;
 define subjid/style(column)={TAGATTR='format:00000'};
 run;

ods tagsets.ExcelXP  options(sheet_name="放射性骨病灶扫描拼表" absolute_column_width='15')  style=Minimal;
 proc report data=pre2;
 column _all_;
 define subjid/style(column)={TAGATTR='format:00000'};
 run;

ods tagsets.excelxp close;















 ***Save all information inclduing log files;
proc printto log=log; run; 


****To chceck all log files**;
%ut_saslogcheck(logfile=&root.\logout\&pgmname..log, outfile=&root.\logout\&pgmname._logchk.lst,msgdata=dc.msgdata);
