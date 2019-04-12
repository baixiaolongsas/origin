/*soh**********************************************************************************
CODE NAME                 : <运行导出>
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
 Author & baixiaolong
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		
**eoh**********************************************************************************/;
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

%include '.\Uncompress.sas' ;
%include '.\GET_DATA.sas';

%include '..\pgm\BASE.sas';
%include '..\pgm\质疑明细.sas';
%include '..\pgm\访视缺失.sas';
%include '..\pgm\页面缺失.sas';
%include '..\pgm\未sdv页面_CRA.sas';
%include '..\pgm\未提交页面.sas';
%include '..\pgm\EDC进展报告.sas';

options fmtsearch=(work raw derived edc) nofmterr;

%m_exportxlsx(title=进展报告,creator=史硕);
