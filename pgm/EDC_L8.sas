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

/*value $f1_fmt '1'='未处理' '2'='已处理' '3'='已关闭';*/
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


data out.L6(label='未回复质疑');
set EDC.zyb_un;
run;

data out.L7(label='已回复未确认质疑');
set EDC.zyb_rep;
run;




