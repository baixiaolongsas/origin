/*soh**********************************************************************************
CODE NAME                 : <L_>
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
 Author & weix
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Weixin				2017-4-27
**eoh**********************************************************************************/;
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

/*value $f1_fmt '1'='δ����' '2'='�Ѵ���' '3'='�ѹر�';*/
/*dm log 'clear';*/


proc sql;
create table EDC.zyb_un(drop=lockstat) as
select * ,
(today()-datepart(createtime)) as time1 '�������' from EDC.zyb where zt ='1' ;
;


create table EDC.zyb_rep(drop=lockstat) as
select *,
(today()-datepart(hfsj)) as time1 '�������' 
from EDC.zyb
where zt ='2' 
;

quit;

data edc.zyb_un;
retain pub_tid pub_tname pub_rid subject xmmc zybh zt subjid;
set edc.zyb_un;
drop pub_tid pub_tname pub_rid subject;
run;
proc sort;by subjid vnum;run;

data edc.zyb_rep;
retain pub_tid pub_tname pub_rid subject xmmc zybh zt subjid;
set edc.zyb_rep;
drop pub_tid pub_tname pub_rid subject;
run;
proc sort;by subjid vnum;run;



/*ǰ10�ֳ�������*/

/*data aa;*/
/*set edc.zyb;*/
/*keep bmc zdmc zynr;*/
/*run;*/
/*proc sort nodupkey;by bmc zdmc zynr;*/
/*run;*/

proc sql;
create table edc.zybnor1 as 
select 
pub_tid ,pub_tname,bmc,zdmc,
zynr,count(*) as num '���ɸ���'
from edc.zyb group by bmc,zdmc,zynr   ;
quit;

proc sort nodupkey;by   bmc zdmc zynr  descending num;run;
proc sort;by descending num;run;


data edc.zybnor;
set edc.zybnor1(firstobs=1 obs=20);
run;

/*�����¼�*/
data ae;
set derived.ae(where =(aeyn ne '��'));
sn1=input(sn,best.);
run ;
proc sort data=ae out=edc.ae(drop=sn1);by subjid sn1;run;
 
data out.l8(label='ǰ10�ֵ�ǰ������������'); set edc.zybnor; run;
  
data out.l6(label='δ�ظ�����'); set edc.zyb_un; run;
data out.l7(label='�ѻظ�δȷ������'); set edc.zyb_rep; run;
data out.l9(label='�����¼�'); set edc.ae; run;
