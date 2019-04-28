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
where yn eq "��";
quit;

/*CM*/
data pre1;
  set derived.cm(rename=(cmstdat=dat cmendat=dat1 cmongo=yn1 cmynae=cm cmcom=com));
length test $100;
test=compress(cmindc||':'||cmtrt);
if yn ne "��";
keep pub_rid lockstat subjid svstage pub_tname test sn dat dat1 yn1 cm com;
run;

data pre2;
  set pre pre1;
label test="�����¼�/��Ӧ֢���ϲ���ҩ" yn1="AE��ת��/�Ƿ����" cm="AE�Ƿ��ȡ��������/CM�Ƿ���AE���" com="��ע" dat="��ʼ����" dat1="��������";
run;

proc sort data=pre2;
by subjid dat test pub_tname;run;

data out.l2(label=ae-cm);
  set pre2;
run;
