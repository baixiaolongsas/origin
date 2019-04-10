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
if lockstat ne '未提交';
run;

data edc.cm;
  set derived.cm;
  if lockstat ne '未提交';
  run;

data out.l10(label='不良事件'); set EDC.ae; run;
data out.l11(label='既往及合并用药'); set EDC.cm; run;
