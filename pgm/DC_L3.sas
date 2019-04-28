/*soh**********************************************************************************
CODE NAME                 : <DC_L3_LY.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <AE-exd��AE-exi> 
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

/*AE�ͼ����µ�*/
proc sql;
create table exd as select
a.pub_rid,
a.lockstat,
a.subjid,
a.svstage,
a.pub_tname,
input(a.sn,best.) as sn1 '���',
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
where a.yn eq "��"
order by subjid,sn1,sn;
quit;

/*AE�������ͣ*/
proc sql;
create table exi as select
a.pub_rid,
a.lockstat,
a.subjid,
a.svstage,
a.pub_tname,
input(a.sn,best.) as sn1 '���',
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
where a.yn eq "��"
order by subjid,sn1,sn;
quit;


data out.L3_1(label=ae-ҩ������µ���);
  set exd;
run;

data out.l3_2(label=ae-ҩ�������ͣ��);
  set exi;
run;
