/*soh**********************************************************************************
CODE NAME                 : <���ӱ�˲�>
CODE TYPE                 : <dc >
DESCRIPTION               : <���ӱ�˲�> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < >
OUTPUT                    : <���ӱ�˲�.xml >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & shis
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Shishuo		          2018-06-07
**eoh**********************************************************************************
*****************************************************************************************/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

/*PROC IMPORT OUT= WORK.code */
/*            DATAFILE= "..\doc\batchcodelist_20180607_1407.xls" */
/*            DBMS=EXCEL REPLACE;*/
/*     RANGE="��Ƕ�����$"; */
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/
/**/
/*proc sql;*/
/*	create table code1 as select _COL2 as tid,_COL4 as cat,_COL5 as code from code;*/
/*	create table code_final as select distinct tid ,cat ,count(code) as seq '�����ݸ����˲����sheet��Ƕ������' from code1 */
/*where tid is not null*/
/*group by tid,cat;*/
/*quit;*/


/*���ӱ�����˲�*/

%macro bootstrap(data=,data2=,key=,ID=);
proc sql;
	create table &data. as select pub_tid,subjid,svstage,&key.,compress(pub_rid) as &ID. length=20  from derived.&data.;
	create table &data2. as select subjid,&ID. length=20,input(sn,best.) as sn,count(sn) as count from derived.&data2. group by &ID.;
quit;
proc sort;by &ID. subjid count sn;run;
data sn;
	set &data2.;
	by &ID. subjid count sn;
	if first.&ID. then sn1=0;
	sn1+1;
	if sn ne sn1 then warning='��ų��ֻ���';
	keep &ID. warning;
run;
proc sort data=sn(where=(warning ne '')) out=sn1 nodupkeys;by &ID. ;run;
proc transpose data=&data2. out=&data2._sn prefix=sn;by &ID. subjid count;var sn;run;
proc sort;by &ID.  ;run;
proc sort data=&data.;by &ID.;run;

data final_&data2.(drop=warning2 warning);
	length warning1 $100;
	merge &data. sn1 &data2._sn;
	by  &ID.;
	label count='��˲��������Ƕ����������Ƿ�һ��';
/*	if visit='' then warning2='����ȱʧ';*/
	if svstage='' then warning2='����ȱʧ';
	warning1=catx(',',warning,warning2);
	label warning1='�ӱ���Ż��һ��߸���ȱʧ����';
/*	drop visitnum ;*/
run;
proc sort;by subjid;run;
%mend bootstrap;

%macro bootstrap2(data=,data2=,key=,ID=);
proc sql;
	create table &data. as select pub_tid,subjid,svstage,&key.,compress(pub_rid) as &ID. length=20 from derived.&data.;
	create table &data2. as select subjid,&ID. length=20,input(sn,best.) as sn,count(sn) as count from derived.&data2. group by &ID.;
quit;
proc sort;by &ID. subjid count sn;run;
data sn;
	set &data2.;
	by &ID. subjid count sn;
	if first.&ID. then sn1=0;
	sn1+1;
	if sn ne sn1 then warning='��ų��ֻ���';
	keep &ID. warning;
run;
proc sort data=sn(where=(warning ne '')) out=sn1 nodupkeys;by &ID. ;run;
proc transpose data=&data2. out=&data2._sn prefix=sn;by &ID. subjid count;var sn;run;
proc sort;by &ID.  ;run;
proc sort data=&data.;by &ID.;run;

data final_&data2.(drop=warning2 warning);
	length warning1 $100;
	merge &data. sn1 &data2._sn;
	by  &ID.;
	label count='��˲��������Ƕ����������Ƿ�һ��';
/*	if visit='' then warning2='����ȱʧ';*/
	if svstage='' then warning2='����ȱʧ';
	warning1=catx(',',warning,warning2);
	label warning1='�ӱ���Ż��һ��߸���ȱʧ����';
/*	drop visitnum ;*/
run;
proc sort;by subjid;run;
%mend bootstrap2;

%bootstrap(data=pe,data2=pe1,key=%STR(yn,pedat),ID=pe);
%bootstrap(data=rsnl,data2=rsnl1,key=%STR(nlyn),ID=rsnl_ref_field);
%bootstrap2(data=fup,data2=fup1,key=%STR(tcmyn,fudat),ID=fup_ref_field);
%bootstrap2(data=fpd,data2=fpd1,key=%STR(tcmyn,fudat),ID=fpd_ref_field);


data out.l1(label=���ӱ�˲�pe);set final_pe1;run;
data out.l2(label=���ӱ�˲�rsnl);set final_rsnl1;run;
data out.l3(label=���ӱ�˲�fup);set final_fup1;run;
data out.l4(label=���ӱ�˲�fpd);set final_fpd1;run;


