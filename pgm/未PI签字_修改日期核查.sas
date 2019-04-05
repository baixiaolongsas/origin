
/*soh**********************************************************************************
CODE NAME                 : <UNPI>
CODE TYPE                 : <listing >
DESCRIPTION               : <> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : <   >
OUTPUT                    : <   >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & weix
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Weixin				2018-08-16
**eoh**********************************************************************************/;
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

proc copy in=fzpl_i_1 out=dc;
run;

data vtable;
	set sashelp.vtable( where=(libname=("DC"))) ;
	n+1;
	keep libname memname n;
run;


%macro PORPERTY;
	%do i=1 %to 37;
	proc sql;
		select compress(memname,' ') into:data from vtable where n=&i;
	quit; 
	proc sql;
		create table L_&data. as select a.siteid,a.subjid,a.pub_tname,a.visit,b.visdat,a.lockstat,a.lastmodifytime from dc.&data a
		left join dc.sv b on a.subjid=b.subjid and  a.visit=b.visit
	where a.lockstat^='40' or (a.lastmodifytime >input('2018-06-06',YYMMDD10.)) ;
	quit;


	%end;
%mend PORPERTY;


%PORPERTY;

data subject;
set dc.subject(keep=siteid subjid pub_tname lockstat lastmodifytime);
if lockstat^='40' or (lastmodifytime >input('2018-06-06',YYMMDD10.));
run;


data sfzqb;
set dc.sfzqb(keep=siteid subjid pub_tname rand_lockstat lastmodifytime);
if rand_lockstat^='40' or (lastmodifytime >input('2018-06-06',YYMMDD10.));
run;

data unPI;
	set L_: subject sfzqb;
run;

proc sort nodupkeys;by subjid pub_tname;run;





ods listing close;
ods RESULTS off;
ods escapechar='^';
ods excel file="&root\dc\output\&study._未PI签字_修改日期核查.xlsx" options( sheet_name="sheet1" contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;
ods excel options(embedded_titles='no' embedded_footnotes='no');
%let ps1=800;
%let ls1=256;
Options   nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 


proc report data=unPI NOWD;
COLUMN _all_;
		
DEFINE siteid / STYLE( column )={TAGATTR='type:text'};
DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
run;

ods excel close;
ods  listing;
