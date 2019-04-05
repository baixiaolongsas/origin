/*soh**********************************************************************************
CODE NAME                 : <COMPARE.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <比较上次试验数据> 
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
 Author & weix
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Weixin				2016-8-2
--------------------------------------------------------------------------;*/

dm log 'clear';
proc datasets lib=work nolist kill; run;
proc datasets lib=dc nolist kill; run;
%include '..\init\init.sas' ;
proc copy in=derived out=dc;run;
/*请在新数据放入raw，并解压后运行*/
%m_get_raw;
%m_get_derived;
/*上次数据导出日期*/
%let comparetime=20180724122941;
ods listing close;
%macro connect;
proc sql;
	select count(*) into:dnum from DICTIONARY.TABLES
                where libname = "DERIVED" ;
 quit;
 
ods listing close;
ods RESULTS off;
ods escapechar='^';
ods excel file="..\output\&study.Listing_测试.xlsx" options( sheet_name="sheet1" contents="no"   autofilter='all' )  ;
ods excel options(embedded_titles='no' embedded_footnotes='no');

Options   nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 
%do i=1 %to &dnum;
	   proc sql noprint;
	   	  select distinct MEMNAME into:DNAME separated by ' ' from SASHELP.vstable where libname = "DERIVED" and monotonic()=&i;
          select name,catx('=_',name,name),compress(name)||",_"||compress(name)||' label="20180724090941数据" '
			into 
			:varname separated by ' ',
			:rename separated by ' ',
			:seq separated by ',' from DICTIONARY.COLUMNS
          where libname = "DERIVED" and memname="&DNAME";
   
		proc sql noprint;
			create table &DNAME._&DNAME. as select &seq. from derived.&DNAME. as a full join dc.&DNAME.(rename=(&rename)) as b on a.pub_rid=b._pub_rid;
		quit;
		
		proc sql noprint;
			select "if "||compress(name)||"=_"||compress(name)||" then mod_"||compress(name)||"=0;else mod_"||compress(name)||"=1;",
					"define mod_"||compress(name)||" / order noprint ;",
					'compute mod_'||compress(name)||';
						if mod_'||compress(name)||'=0 then do;
						    call define("'||compress(name)||'", "style", "style=[background=white]");

						    call define("_'||compress(name)||'", "style", "style=[background=white]");
						end;
						else if mod_'||compress(name)||'=1 then do;
						 call define("'||compress(name)||'", "style", "style=[background=cx00FFE6]");

						 call define("_'||compress(name)||'", "style", "style=[background=cx00FFE6]");
						 end;
						endcomp;'
		into
			:mod separated by ' ', 
			:order separated by ' ',
			:draw separated by ' ' from DICTIONARY.COLUMNS
          where libname = "DERIVED" and memname="&DNAME";
		data final_&DNAME._&DNAME.;
			length  PUB_RID_all $12;
			set &DNAME._&DNAME.;
			&mod.;
			if sum(of mod_:)>1;
		run;

		proc sql;
			create table final_&DNAME._&DNAME. as select coalesce(PUB_RID,_PUB_RID) as PUB_RID_all,* from final_&DNAME._&DNAME.;
		quit;


		proc sql noprint;
			select "define "||compress(name)||" / STYLE(column)={TAGATTR='type:text'};" 
		into
			:define separated by ';' 
		from DICTIONARY.COLUMNS
		 where libname='WORK' and memname="FINAL_&DNAME._&DNAME." and ^index(upcase(name),'MOD_') and upcase(name) not in('PUB_RID_all') ;
		quit;
ods excel options(sheet_name="&DNAME."  );
		proc report data=final_&DNAME._&DNAME. NOWD;
		COLUMN _all_;
		DEFINE PUB_RID_all /order noprint;		
		&define.;
		&order.;
		&draw.;
		run;
%end;
%mend;
%connect;

ods excel close;
