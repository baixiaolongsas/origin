/*soh**********************************************************************************
CODE NAME                 : <���е���>
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
%include '..\pgm\������ϸ.sas';
%include '..\pgm\����ȱʧ.sas';
%include '..\pgm\ҳ��ȱʧ.sas';
%include '..\pgm\δsdvҳ��_CRA.sas';
%include '..\pgm\δ�ύҳ��.sas';
%include '..\pgm\EDC��չ����.sas';

options fmtsearch=(work raw derived edc) nofmterr;

%m_exportxlsx(title=��չ����,creator=ʷ˶);
