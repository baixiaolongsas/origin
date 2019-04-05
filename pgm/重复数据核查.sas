
/*soh**********************************************************************************
CODE NAME                 : <重复数据核查>
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
 Author & shis
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Shishuo				2018-08-17
**eoh**********************************************************************************/;
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;


proc copy in=fzpl_i_1 out=dc;
run;

PROC IMPORT OUT= WORK.dup 
            DATAFILE= "&root\dc\doc\重复变量.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


data vtable;
	set sashelp.vtable( where=(libname=("DC"))) ;
	n+1;
	keep libname memname n;
run;

data dup1;
set dup;
data=upcase(data);
var=strip(catx(' ',key_variable_1,key_variable_2,key_variable_3,key_variable_4,key_variable_5,key_variable_6,key_variable_7));
run;

proc sql;
create table dup2 as
select a.*,b.n from dup1 a
left join vtable b on a.data=b.memname
;
quit;

%macro dup;
	%do i=1 %to 37;
		proc sql noprint;
			select compress(memname,' ') into:data from vtable where n=&i;
			select var,n into:var_sort,
							 :num from dup2 where n=&i;
			
		quit; 

		%if &num eq &i %then %do;
			proc sort data=dc.&data nodupkey dupout=L_&data.;
			by &var_sort;
			run;
		%end;

	%end;
%mend dup;


%dup;

data dup_final;
	set L_: ;
run;

proc sort ;by pub_tname subjid ;run;



ods listing close;
ods RESULTS off;
ods escapechar='^';
ods excel file="&root\dc\output\&study._重复记录核查.xlsx" options( sheet_name="sv" contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;
ods excel options(embedded_titles='no' embedded_footnotes='no');
%let ps1=800;
%let ls1=256;
Options   nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 


proc report data=L_sv NOWD;
COLUMN _all_;
		
DEFINE siteid / STYLE( column )={TAGATTR='type:text'};
DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
run;



ods excel options( sheet_name="hcg" contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;

proc report data=L_hcg NOWD;
COLUMN _all_;
		
DEFINE siteid / STYLE( column )={TAGATTR='type:text'};
DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
run;


ods excel options( sheet_name="vs1" contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;

proc report data=L_vs1 NOWD;
COLUMN _all_;
		
DEFINE siteid / STYLE( column )={TAGATTR='type:text'};
DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
run;

ods excel close;
ods  listing;

