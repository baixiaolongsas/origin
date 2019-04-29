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
proc datasets library=out kill; quit;

%include '.\Uncompress.sas' ;
%include '.\GET_DATA.sas' ;


%include '..\pgm\DC_L重复性数据记录核查.sas';

%m_exportxlsx(title=重复性数据记录核查,creator=白小龙,num=1);
