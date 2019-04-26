/*soh**********************************************************************************
CODE NAME                 : <init.sas>
CODE TYPE                 : < >
DESCRIPTION               : <初始化试验数据> 
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
	lookfor='未初始化';output;
	lookfor='缺失值的生成';output;
	lookfor='无法执行算术运算';output;
	lookfor='检测到 0 为除数';output;
	lookfor='SAS 已转到新的一行';output;
	lookfor='格式对于要打印的数字过小';output;
	lookfor='可用“BEST”格式转换小数位';output;
	lookfor='SAS 系统停止处理该步';output;
	lookfor='多个数据集带有重复的 BY 值';output;
	lookfor='参数无效';output;
	lookfor='值已转换为';output;
	
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
