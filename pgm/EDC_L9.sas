/*soh**********************************************************************************
CODE NAME                 : <EDC_L9>
CODE TYPE                 : <listing >
DESCRIPTION               : <> 
SOFTWARE/VERSION#         : <SAS 9.3>
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
 Author & liying
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------

**eoh**********************************************************************************/;
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

data edc.ae;
  set derived.ae;
if lockstat ne 'δ�ύ';
run;

data edc.cm;
  set derived.cm;
  if lockstat ne 'δ�ύ';
  run;

data out.l10(label='�����¼�'); set EDC.ae; run;
data out.l11(label='�������ϲ���ҩ'); set EDC.cm; run;
