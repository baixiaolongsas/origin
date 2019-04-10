 /*soh**********************************************************************************
CODE NAME                 : <肿瘤相关页面缺失>
CODE TYPE                 : <dc >
DESCRIPTION               : <进展报告肿瘤相关页面缺失> 
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

data out.l9(label='疗效评估'); set derived.rsnl; run;
data out.l10(label='不良事件'); set derived.ae; run;
data out.l11(label='合并用药'); set derived.cm; run;
data out.l12(label='合并非药物治疗'); set derived.cnd; run;
