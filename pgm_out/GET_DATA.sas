/*soh**********************************************************************************
CODE NAME                 : <GET_DATA.sas>
CODE TYPE                 : <macro >
DESCRIPTION               : <初始化数据> 
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
01		Weixin				2018-07-24
--------------------------------------------------------------------------;*/
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;
%m_get_raw;

options fmtsearch=(work raw derived edc) nofmterr;
%m_get_derived;
/*%m_get_edc;*/

libname out "&root\data\out";


%include "..\data\edc\sfzqb\adife_hd_extract.sas";

data edc.sfzqb;
	set adife_hd.sfzqb;

run;
/*proc delete data=mydata;run;*/



%include "&root\data\edc\hchzb\adife_hd_extract.sas";

data edc.hchzb;
	set adife_hd.hchzb;

run;
/*proc delete data=mydata;run;*/


%include "&root\data\edc\spjlb\adife_hd_extract.sas";

data edc.spjlb;
	set adife_hd.spjlb;

run;
/*proc delete data=mydata;run;*/


%include "&root\data\edc\sv_workflow\adife_hd_extract.sas";

data edc.sv_workflow;
	set adife_hd.sv_workflow;

run;
/*proc delete data=mydata;run;*/


%include "&root\data\edc\visittable\adife_hd_extract.sas";

data edc.visittable;
	set adife_hd.visittable;
run;
/*proc delete data=mydata;run;*/


%include "&root\data\edc\zxlsb\adife_hd_extract.sas";

data edc.zxlsb;
	set adife_hd.zxlsb;
run;
/*proc delete data=mydata;run;*/

%include "&root\data\edc\zyb\adife_hd_extract.sas";

data edc.zyb;
	set adife_hd.zyb;

run;
/*proc delete data=mydata;run;*/

