/*soh**********************************************************************************
CODE NAME                 : <父子表核查>
CODE TYPE                 : <dc >
DESCRIPTION               : <父子表核查> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < >
OUTPUT                    : <父子表核查.xml >
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

PROC IMPORT OUT= WORK.code 
            DATAFILE= "..\doc\batchcodelist_20180607_1407.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="内嵌表编码$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc sql;
	create table code1 as select _COL2 as tid,_COL4 as cat,_COL5 as code from code;
	create table code_final as select distinct tid ,cat ,count(code) as seq '请依据该数核查后面sheet内嵌表数量' from code1 
where tid is not null
group by tid,cat;
quit;


/*父子表问题核查*/

%macro bootstrap(data=,data2=,key=,ID=);

proc sql;
	create table &data. as select pub_tid,subjid,visit,input(visit,best.) as visitnum,&key.,compress(put(pub_rid,best20.)) as &ID.  from Fzpl_i_1.&data.;
	create table &data2. as select subjid,&ID.,input(sn,best.) as sn,count(sn) as count from Fzpl_i_1.&data2. group by &ID.;
quit;
proc sort;by &ID. subjid count sn;run;
data sn;
	set &data2.;
	by &ID. subjid count sn;
	if first.&ID. then sn1=0;
	sn1+1;
	if sn ne sn1 then warning='序号出现混乱';
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
	label count='请核查该数与内嵌表编码总数是否一致';
	if visit='' then warning2='父表缺失';
	warning1=catx(',',warning,warning2);
	label warning1='子表序号混乱或者父表缺失提醒';
	drop visitnum ;
run;
proc sort;by subjid;run;



%mend bootstrap;

%bootstrap(data=fc,data2=fc1,key=%STR(notdone),ID=subject_ref_field);
%bootstrap(data=pmh,data2=pmh1,key=%STR(none),ID=subject_ref_field);
%bootstrap(data=uc,data2=uc1,key=%STR(notdone),ID=subject_ref_field);
%bootstrap(data=ie,data2=ie1,key=%STR(lockstat,ieyn),ID=ie_ref_field);
%bootstrap(data=ie,data2=ie2,key=%STR(lockstat,ieyn),ID=out_ref_field);
%bootstrap(data=vs,data2=vs1,key=%STR(notdone,vsdat),ID=subject_ref_field);
%bootstrap(data=mvs,data2=mvs1,key=%STR(vstim,notdone,vsdat),ID=subject_ref_field);
%bootstrap(data=lb,data2=lb1,key=%STR(lbcat,notdone,lbbdat),ID=lb_ref_field);
%bootstrap(data=pe,data2=pe1,key=%STR(notdone,pedat),ID=pe);
%bootstrap(data=pkb,data2=pkb1,key=%STR(notdone),ID=pkb_ref_field);


ods listing close;
ods RESULTS off;
ods escapechar='^';
ods excel file="..\output\&study._父子表缺失核查.xlsx" options(sheet_name="内嵌表编码汇总"  contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;
ods excel options(embedded_titles='no' embedded_footnotes='no');
%let ps1=800;
%let ls1=256;
Options   nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 

 proc report data=code_final nowd ;
     column _all_;

   run;
ods excel  options(sheet_name="fc")  ;


  proc report data=final_fc1(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;
ods excel  options(sheet_name="ie1")  ;


  proc report data=final_ie1(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;
   ods excel  options(sheet_name="ie2")  ;


  proc report data=final_ie2(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;
   ods excel  options(sheet_name="lb")  ;


  proc report data=final_lb1(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;
   ods excel  options(sheet_name="mvs")  ;


  proc report data=final_mvs1(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;
      ods excel  options(sheet_name="pe")  ;


  proc report data=final_pe1(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;
         ods excel  options(sheet_name="pkb")  ;


  proc report data=final_pkb1(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;
        ods excel  options(sheet_name="pmh")  ;


  proc report data=final_pmh1(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;


            ods excel  options(sheet_name="uc")  ;


  proc report data=final_uc1(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;
        ods excel  options(sheet_name="vs")  ;


  proc report data=final_vs1(drop=_name_) nowd ;
     column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};

   run;


ods excel close;
ods listing;
