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

%include '..\pgm\DC_L1.sas';
%include '..\pgm\DC_L2.sas';
%include '..\pgm\DC_L3.sas';
%include '..\pgm\DC_L4.sas';
%include '..\pgm\DC_L5.sas';
%include '..\pgm\DC_L6.sas';


%m_exportxlsx(title=,creator=);
