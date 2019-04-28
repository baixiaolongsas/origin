/*soh**********************************************************************************
CODE NAME                 : <DC_L3_LY.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <AE-exd与AE-exi> 
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

/*AE和剂量下调*/
proc sql;
create table exd as select
a.pub_rid,
a.lockstat,
a.subjid,
a.svstage,
a.pub_tname,
input(a.sn,best.) as sn1 '序号',
a.aeterm as test,
a.aestdat as dat,
a.aeout,
a.aeouttm as dat1,
a.aectc,
a.aeacn as cn,
b.exdstdat,
b.extendat,
b.extdose,
b.sn,
b.extreas
from derived.ae as a left join derived.exd as b on a.subjid=b.subjid
where a.yn eq "是"
order by subjid,sn1,sn;
quit;

/*AE与剂量暂停*/
proc sql;
create table exi as select
a.pub_rid,
a.lockstat,
a.subjid,
a.svstage,
a.pub_tname,
input(a.sn,best.) as sn1 '序号',
a.aeterm as test,
a.aestdat as dat,
a.aeout,
a.aeouttm as dat1,
a.aectc,
a.aeacn as cn,
b.existdat,
b.exiendat,
b.exipdos,
b.sn,
b.exireas
from derived.ae as a left join derived.exi as b on a.subjid=b.subjid
where a.yn eq "是"
order by subjid,sn1,sn;
quit;


data out.L3_1(label=ae-药物剂量下调表);
  set exd;
run;

data out.l3_2(label=ae-药物剂量暂停表);
  set exi;
run;
