/*soh**********************************************************************************
CODE NAME                 : <DC_L17_BXL.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <������¼��> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < all>
OUTPUT                    : < none >
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
--------------------------------------------------------------------------;*/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;




***********************************************������******************************************************;
proc sql;
  create table pre1 as
  select a.subjid, a.aeterm, a.aeout, a.aeouttm, b.dthdat, c.dsreas 
  from derived.ae a left join derived.dth b on a.subjid=b.subjid
       left join derived.ds c on a.subjid=c.subjid
  where a.aeout='����';
quit;

data final;
  set pre1;
  if aeouttm ne dthdat then warning1='ת�����ڡ��������ڣ����ʵ';
  if index(dsreas,'����')=0 then warning2='�������״�������������ʵ';
  label warning1='����1' warning2='����2';
run;

data out.l17(label=������¼��);
  set final;
run;
 





