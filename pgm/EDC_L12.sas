 /*soh**********************************************************************************
CODE NAME                 : <�������ҳ��ȱʧ>
CODE TYPE                 : <dc >
DESCRIPTION               : <��չ�����������ҳ��ȱʧ> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < >
OUTPUT                    : <>
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & yingli
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------

**eoh**********************************************************************************
*****************************************************************************************/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

data out.l9(label='��Ч����'); set derived.rsnl; run;
data out.l10(label='�����¼�'); set derived.ae; run;
data out.l11(label='�ϲ���ҩ'); set derived.cm; run;
data out.l12(label='�ϲ���ҩ������'); set derived.cnd; run;
