/*soh**********************************************************************************
CODE NAME                 : <质疑明细>
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
 Author & shis
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Shishuo				2018-04-18
**eoh**********************************************************************************/;


/*value $f1_fmt '1'='未处理' '2'='已处理' '3'='已关闭';*/
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/

proc sql;
create table EDC.zyb_un as
select a.zybh as zybh,
a.zt as zt ,
a.querytype as f2 ,
a.subjid as subjid,
b.sitename as sitename,
b.siteid as siteid,
a.vnum as vnum,
a.bmc as bmc,
a.zdmc as zdmc,
a.zyr as zyr,
a.zyrq as zyrq,
a.zdz as zdz,
a.zylx as zylx,
a.zynr as zynr,
a.clzyjszd as clzyjszd,
a.hfr as hfr,
a.hfsj as hfsj,
a.hfzdz as hfzdz,
a.hfnr as hfnr,
a.gbr as gbr,
a.gbsj as gbsj,
a.gbyy as gbyy,
a.pvzd as pvzd,
a.userid as userid,
a.unitid as unitid,
a.createtime as f23 from EDC.zyb a
left join derived.subject b on a.subjid=b.subjid
where zt ='1' 
;


create table EDC.zyb_rep as
select a.zybh as zybh,
a.zt as zt ,
a.querytype as f2 ,
a.subjid as subjid,
b.sitename as sitename,
b.siteid as siteid,
a.vnum as vnum,
a.bmc as bmc,
a.zdmc as zdmc,
a.zyr as zyr,
a.zyrq as zyrq,
a.zdz as zdz,
a.zylx as zylx,
a.zynr as zynr,
a.clzyjszd as clzyjszd,
a.hfr as hfr,
a.hfsj as hfsj,
a.hfzdz as hfzdz,
a.hfnr as hfnr,
a.gbr as gbr,
a.gbsj as gbsj,
a.gbyy as gbyy,
a.pvzd as pvzd,
a.userid as userid,
a.unitid as unitid,
a.createtime as f23 from EDC.zyb a
left join derived.subject b on a.subjid=b.subjid
where zt ='2' 
;



quit;

data out.L6(label='未回复质疑');
set EDC.zyb_un;
run;

data out.L7(label='已回复未确认质疑');
set EDC.zyb_rep;
run;








