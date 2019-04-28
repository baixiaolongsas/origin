/*soh**********************************************************************************
CODE NAME                 : <DC_L2_LY.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <AE-CM> 
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
 Author & liying
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------

--------------------------------------------------------------------------;*/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

/*AE*/
proc sql;
create table pre as select
pub_rid,
lockstat,
subjid,
svstage,
pub_tname,
sn,
aeterm as test length=100,
aeout as yn1,
aectc,
aestdat as dat,
aeouttm as dat1,
aeacncm as cm,
aecom as com
from derived.ae
where yn eq "是";
quit;

/*CM*/
data pre1;
  set derived.cm(rename=(cmstdat=dat cmendat=dat1 cmongo=yn1 cmynae=cm cmcom=com));
length test $100;
test=compress(cmindc||':'||cmtrt);
if yn ne "否";
keep pub_rid lockstat subjid svstage pub_tname test sn dat dat1 yn1 cm com;
run;

data pre2;
  set pre pre1;
label test="不良事件/适应症：合并用药" yn1="AE的转归/是否持续" cm="AE是否采取纠正治疗/CM是否与AE相关" com="备注" dat="开始日期" dat1="结束日期";
run;

proc sort data=pre2;
by subjid dat test pub_tname;run;

data out.l2(label=ae-cm);
  set pre2;
run;
