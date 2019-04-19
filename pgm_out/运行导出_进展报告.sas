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
/*%include '.\Uncompress.sas' ;*/
%include '.\GET_DATA.sas';

%include '..\pgm\EDC_L1.sas';

%include '..\pgm\EDC_L4.sas';
%include '..\pgm\EDC_L5.sas';
%include '..\pgm\EDC_L6.sas';
%include '..\pgm\EDC_L7.sas';
%include '..\pgm\EDC_L8.sas';


options fmtsearch=(work raw derived edc) nofmterr;
%m_exportxlsx(title=进展报告,creator=史硕);
