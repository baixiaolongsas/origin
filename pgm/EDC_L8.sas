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

/*value $f1_fmt '1'='未处理' '2'='已处理' '3'='已关闭';*/
/*dm log 'clear';*/


proc sql;
create table EDC.zyb_un(drop=lockstat) as
select * from EDC.zyb where zt ='1' ;
;


create table EDC.zyb_rep(drop=lockstat) as
select * from EDC.zyb
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



data out.l6(label="未回复质疑");set edc.zyb_un;run;

data out.l7(label="已回复未确认质疑");set edc.zyb_rep;run;

