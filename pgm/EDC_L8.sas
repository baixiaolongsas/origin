/*soh**********************************************************************************
CODE NAME                 : < >
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
01		Weixin				2018-12-21
**eoh**********************************************************************************/;
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/

/*value $f1_fmt '1'='未处理' '2'='已处理' '3'='已关闭';*/
/*dm log 'clear';*/


proc sql;
create table EDC.zyb_un(drop=cjsj createtime lastmodifytime) as
select * ,put(cjsj,is8601DT.) as cjsj_ '数据创建时间',
put(createtime,is8601DT.) as createtime_ '创建时间',put(lastmodifytime,is8601DT.) as lastmodifytime_ '修改时间' from EDC.zyb where zt ='1' ;
;


create table EDC.zyb_rep(drop=cjsj createtime lastmodifytime) as
select * ,put(cjsj,is8601DT.) as cjsj_ '数据创建时间',
put(createtime,is8601DT.) as createtime_ '创建时间',put(lastmodifytime,is8601DT.) as lastmodifytime_ '修改时间' from EDC.zyb
where zt ='2' 
;



quit;











data out.L8(label='未回复质疑');
set EDC.zyb_un;
run;

data out.L9(label='已回复未确认质疑');
set EDC.zyb_rep;
run;

