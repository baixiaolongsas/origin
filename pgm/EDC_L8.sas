/*soh**********************************************************************************
CODE NAME                 : <L_>
CODE TYPE                 : <listing >
DESCRIPTION               : <> 
SOFTWARE/VERSION#         : <SAS 9.4>
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
01		Weixin				2018-07-24
**eoh**********************************************************************************/;
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/

/*value $f1_fmt '1'='δ����' '2'='�Ѵ���' '3'='�ѹر�';*/
/*dm log 'clear';*/

/**/
/*proc sql;*/
/*create table EDC.zyb_un(drop =subjinit) as*/
/*select * from EDC.zyb where zt ='1' ;*/
/*;*/
/**/
/**/
/*create table EDC.zyb_rep (drop =subjinit) as*/
/*select * from EDC.zyb*/
/*where zt ='2' */
/*;*/
/**/
/**/
/*quit;*/

data EDC.zyb_un;
set EDC.zyb;
if zt ='1';
drop pub_rid subject xmmc lockstat subjinit;
run;


data EDC.zyb_rep;
set EDC.zyb;
if zt ='2';
drop pub_rid subject xmmc lockstat subjinit;
run;


data out.L6(label='δ�ظ�����');
set EDC.zyb_un;
run;

data out.L7(label='�ѻظ�δȷ������');
set EDC.zyb_rep;
run;




