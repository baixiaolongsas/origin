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
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/

/*value $f1_fmt '1'='δ����' '2'='�Ѵ���' '3'='�ѹر�';*/
/*dm log 'clear';*/


proc sql;
create table EDC.zyb_un as
select * from EDC.zyb where zt ='1' ;
;


create table EDC.zyb_rep as
select * from EDC.zyb
where zt ='2' 
;



quit;




data out.L6(label='δ�ظ�����');
set EDC.zyb_un;
run;

data out.L7(label='�ѻظ�δȷ������');
set EDC.zyb_rep;
run;










