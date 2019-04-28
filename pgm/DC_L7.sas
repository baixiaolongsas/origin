/*soh**********************************************************************************
CODE NAME                 : <DC_L17_BXL.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <死亡记录表> 
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




***********************************************主程序******************************************************;
proc sql;
  create table pre1 as
  select a.subjid, a.aeterm, a.aeout, a.aeouttm, b.dthdat, c.dsreas 
  from derived.ae a left join derived.dth b on a.subjid=b.subjid
       left join derived.ds c on a.subjid=c.subjid
  where a.aeout='死亡';
quit;

data final;
  set pre1;
  if aeouttm ne dthdat then warning1='转归日期≠死亡日期，请核实';
  if index(dsreas,'死亡')=0 then warning2='试验完成状况≠死亡，请核实';
  label warning1='质疑1' warning2='质疑2';
run;

data out.l17(label=死亡记录表);
  set final;
run;
 





