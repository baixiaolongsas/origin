
/*soh**********************************************************************************
CODE NAME                 : <随机生成受试者>
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
01		Shishuo				2018-08-23
**eoh**********************************************************************************/;
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

/*设定种子*/
%let myseed=1;

/*得到随机选取的受试者*/
%macro random;

proc sql;
create table subject as 
select * ,count(subjid) as num from derived.subject
where status ^= '筛选失败'
;
quit;

proc sql noprint;
select max(num) into: total from subject;
quit;

/*随机数总数为全部筛选成功受试者总数开平方；其中男女数相等；*/

%let filtnum=%sysfunc(ceil(%sysfunc(divide((%sysfunc(floor((%sysfunc(sqrt(&total)))))), 2))));


data man;
  set subject(where=(sex='男'));
  ran=ranuni(&myseed);
run;
proc sort ; by ran ;run;


data woman;
  set subject(where=(sex='女'));
  ran=ranuni(&myseed);
run;
proc sort ; by ran ;run;


data select_subject;
  set man(firstobs=1 obs=&filtnum) woman(firstobs=1 obs=&filtnum);
run;


%mend;
%random;





data vtable;
	set sashelp.vtable( where=(libname=("DERIVED"))) ;
	n+1;
	keep libname memname n;
run;

%macro filt;

	proc sql noprint;
	select max(n) into: num from vtable;
	quit;


	%do i=1 %to &num;
		proc sql noprint;
			select compress(memname,' ') into:data from vtable where n=&i;
			select subjid into: id separated by ' ' from select_subject;

		quit; 

		data L_&data.;
		set DERIVED.&data ;
		if  input(subjid,best.) in  (&id);
		run;


	%end;
%mend filt;

%filt;




%macro export;
			
		proc sql noprint;
		select max(n) into: num from vtable;
		quit;

		ods listing close;
		ods RESULTS off;
		ods excel file="..\output\&study._随机受试者_&sysdate..xlsx" options( contents="no"   FROZEN_HEADERS="Yes" autofilter='all' )  ;
		ods excel options(embedded_titles='no' embedded_footnotes='no');
		Options   nodate nonumber nocenter;
		options nonotes;
		OPTIONS FORMCHAR="|----|+|---+=|-<>*"; 		 

        %do i=1 %to &num;
			    proc sql noprint;
				select compress(memname,' ') into:data from vtable where n=&i;
			    quit; 

				ods excel  options(sheet_name="&data") ;
                proc report data=L_&data. ;
                column _all_;
			    run;

        %end;
		ods excel close;
		ods  listing;
%mend export;
%export;


