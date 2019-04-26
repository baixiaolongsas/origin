/*soh**********************************************************************************
CODE NAME                 : <init.sas>
CODE TYPE                 : < >
DESCRIPTION               : <��ʼ����������> 
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
 Author & weixin
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		baixiaolong		  2019-4-6
--------------------------------------------------------------------------;*/

%global study root ;


%let study=%str(FZPL-III-301-OC);
%let root=D:\HR_PROJECTS\FZPL-III-301-OC;




libname raw  "&root.\data\raw" ;
libname derived  "&root.\data\derived" ;
libname edc "&root\data\edc";
libname dc "&root\data\dc";
libname out "&root\data\out";


%let output=&root.\output\;



** define general path or library for macro sas;
*options mrecall MAUTOSOURCE symbolgen;/* mprint;*/

options noxwait SASAUTOS = (SASAUTOS,"&root.\macro");

options fmtsearch=(work raw derived edc) nofmterr;

options missing=' ';

data dc.msgdata;
	length lookfor $ 80;
	lookfor='δ��ʼ��';output;
	lookfor='ȱʧֵ������';output;
	lookfor='�޷�ִ����������';output;
	lookfor='��⵽ 0 Ϊ����';output;
	lookfor='SAS ��ת���µ�һ��';output;
	lookfor='��ʽ����Ҫ��ӡ�����ֹ�С';output;
	lookfor='���á�BEST����ʽת��С��λ';output;
	lookfor='SAS ϵͳֹͣ����ò�';output;
	lookfor='������ݼ������ظ��� BY ֵ';output;
	lookfor='������Ч';output;
	lookfor='ֵ��ת��Ϊ';output;
	
run;

filename zip pipe "dir &root\data\raw\*.zip /b";
data vname;
        length fname $200.;
        infile zip truncover;
        input fname $200.;
        call symput ('nvars',_n_);
run;
proc sort;by fname;run;

data _null_;
  set vname;
/*  pattern=prxparse("/_(\d{8})\B/o");*/
  pattern=prxparse("/SAS_\S(\S{10})\b/o");
  position=prxmatch(pattern,fname);
  if position ne 0 then date1=prxposn(pattern,1,fname);
/*  date2=input(date1,yymmdd8.);*/
  date2=input(date1,yymmdd10.);
  date3=put(date2,yymmdd10.);
  if _n_=1 then call symputx ("rawdate",date3,global);
run;
