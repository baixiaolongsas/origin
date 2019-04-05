/*soh**********************************************************************************
CODE NAME                 : <数据库定义报告>
CODE TYPE                 : <dc >
DESCRIPTION               : <数据库定义报告> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < >
OUTPUT                    : < 数据库定义报告.xml >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & shis
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Shishuo					2018-06-07
**eoh**********************************************************************************
*****************************************************************************************/






dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

PROC IMPORT OUT= WORK.define_pre 
            DATAFILE= "..\doc\项目数据库定义报告_fzpl_i_102_food_1528351476025.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="数据库定义报告$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;



proc sql;
	create table crf_id as
			select
				_COL0 as tid,
				_COL1 as crfname  
			from define_pre;

	create table var_type as 
			select 
				_COL0 as tid,
				_COL5 as var,
				_COL6 as type 
			from define_pre;
quit;

proc sort data=crf_id nodupkeys;by _all_;run;
proc sort data=var_type nodupkeys;by _all_;run;




Proc Format  Lib=Fzpl_i_1.Formats        cntlout=Work.Fmtport1; 
quit;



data Fmtport1;
	set Fmtport1(keep=FMTNAME START LABEL);
	code=compress(START||':'||LABEL||',');
	FMTNAME1=compress('$'||FMTNAME);
	if START not in ('F','M') then
	SN=input(START,best.);
	IF START='F' then SN=0; IF START='M' then SN=1;
run;
proc sort ;by FMTNAME START;
data Fmtport1;
	set Fmtport1;
	retain sn1 0;
	by FMTNAME START;
	sn1+1;
	if first.FMTNAME then sn1=1;
	if sn = . then sn = sn1;
run;

proc sort;by FMTNAME1 SN;run;

proc transpose data=Fmtport1 out=code1 PREFIX=SN ;var code;by FMTNAME1 SN;run;

proc transpose data=code1 out=code2 PREFIX=code ;var SN1;by FMTNAME1 ;run;






data Vstable;
	set sashelp.Vstable(where=(libname='FZPL_I_1'));
	memname1=compress(memname);
	x+1;
run;                   


%macro PORPERTY;
	%do i=1 %to 37;
	proc sql;
		select compress(memname,' ') into:data from Vstable where x=&i;
	quit; 
	proc contents data=FZPL_I_1.&data out=porpert_&data(keep=MEMNAME NAME LABEL FORMAT);quit;

	%end;
%mend PORPERTY;



%PORPERTY;

data all;
	set porpert_:(where=(NAME not in ('userid','unitid','createtime','modifyuserid','lastmodifytime')));
run;

proc sql;
	create table all_crf as select a.MEMNAME,b.crfname 'CRF名称',a.NAME,a.LABEL,c.type,a.FORMAT from all as a 
    left join crf_id as b on a.MEMNAME=upcase(b.tid)
	left join var_type as c on a.NAME=c.var and a.MEMNAME=upcase(c.tid);
quit;



proc sql;
	create table all_final(drop= FMTNAME1  _NAME_) as select a.*,b.* from all_crf as a 
	left join code2 as b on a.FORMAT=b.FMTNAME1;
quit;




proc sort;by _all_;run;




ods listing close;
ods RESULTS off;

ods excel file="..\output\&study._数据库定义报告.xlsx" options(sheet_name="数据库定义报告" contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;
ods excel options(embedded_titles='no' embedded_footnotes='no');
%let ps1=800;
%let ls1=256;
Options   nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-<>*"; 

 proc report data=all_final;
 column _all_;

run;


ods excel close;
ods  listing;


