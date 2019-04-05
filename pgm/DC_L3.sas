/*soh**********************************************************************************
CODE NAME                     : <DC_L5.sas>
CODE TYPE                     : <��������>
DESCRIPTION                   : <����> 
SOFTWARE/VERSION#   	      : <SAS 9.4>
INFRASTRUCTURE          	  : <System>
LIMITED-USE MODULES       	  : <   >
BROAD-USE MODULES             : <	>
INPUT                         : < all>
OUTPUT                        : < none >
VALIDATION LEVEL              : <	>
REQUIREMENTS                  : <	>
ASSUMPTIONS                   : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01						     
--------------------------------------------------------------------------;*/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;
%let pgmname=L5;
proc printto log="&root.\logout\&pgmname..log" new;run;


/*MH*/
proc sql;
create table pre1 as select
pub_rid,
lockstat,
subjid,
pub_tname,
sn,
mhterm as test,
mhstdat as dat,
mhongo as yn,
mhendt as dat1
from derived.mh where mhterm ne ''
order by subjid,pub_rid;quit;

/*AE*/
proc sql;
create table pre2 as select
pub_rid,
lockstat,
subjid,
pub_tname,
sn,
aeterm as test,
aestdat as dat,
aeout as yn,
aeendat as dat1,
aectc,
aeacncm as cm,
aecom as com
from derived.ae
order by subjid,pub_rid;quit;

/*CM*/
data pre3;
keep pub_rid lockstat subjid pub_tname sn  cmos drugs cmstdat cmongo cmendat  cmcom test;
 set derived.cm;
 if drugs='����' then drugs='';
test=compress(cmos||drugs||':'||cmtrt);
rename cmstdat=dat cmendat=dat1 cmcom=com cmongo=yn;
drop  cmtrt;
run;

data final;
length yn $ 30 test $ 100;
set pre1 pre2 pre3;
label test=������ʷ/�����¼�/��Ӧ֢:�ϲ���ҩ yn=Ŀǰ�Ƿ����/AE��ת��/�Ƿ����  dat=��ʼ���� dat1=�������� cm=AE�Ƿ��ȡ��������/CM�Ƿ���AE���
      com=��ע;
run;

proc sql;
create table dc.L7_8 as select 
pub_rid, subjid, lockstat, pub_tname, test, dat, yn, dat1, aectc, cm, com
from final order by subjid;quit;
/*proc sort;by subjid dat test pub_tname;run;*/
/*ods listing close;*/
/*ods RESULTS off;*/
/*ods excel file="..\output\&study._listing_2_&sysdate..xlsx" options( sheet_name="mh-ae-cm" contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;*/
/*ods excel options(embedded_titles='no' embedded_footnotes='no');*/
/*Options   nodate nonumber nocenter;*/
/*options nonotes;*/
/*OPTIONS FORMCHAR="|----|+|---+=|-<>*"; */
/**/
/* proc report data=final1;*/
/* column _all_;*/
/*DEFINE subjid / STYLE( column )={TAGATTR='type:text'};*/
/* run;*/
/**/
/**/
/**/
/*ods excel close;*/
/*ods  listing;*/
/**/
/**/
/* ***Save all information inclduing log files;*/
/*proc printto log=log; run; */
/**/
/**/
/*****To chceck all log files**;*/
/*%ut_saslogcheck(logfile=&root.\dc\log\&pgmname..log, outfile=&root.\dc\log\&pgmname._logchk.lst,msgdata=msgdata);*/
/**/
/**/
/**/
/**/
/**/
