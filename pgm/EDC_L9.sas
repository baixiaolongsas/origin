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



proc sql;
create table edc.zqb as 
select distinct visitname ,input(visitid,best.) as visitid '访视阶段序号'
from edc.visittable order by visitid;
quit;



proc sql;
/*fbhchzb
表ID表,名称,记录ID,复杂表单入口表记录ID,访视序号,访视内序号,未解决质疑数量,未关闭质疑数量,已关闭质疑数量,已核查字段数量一,已核查字段数量二,已核查字段数量三,已核查字段数量四,已核查字段数量五,需解决字段数总数量一,需解决字段数总数量二,需解决字段数总数量三,需解决字段数总数量四,需解决字段数总数量五,二级子表父记录ID字段,创建人,创建时间
*/

create table fbhchzb as 
select tid as tid,
bmc as bmc,
jl as jl,
fzbdrkbjl as f3,
fs as fs,
svnum as svnum,
wjjzysl as wjjzysl,
wgbzysl as wgbzysl,
ygbzysl as ygbzysl,
yhczdsly as yhczdsly,
yhczdsle as yhczdsle,
yhczdsls as yhczdsls,
yhczdslss as f12,
yhczdslw as yhczdslw,
xhczdzsl as xhczdzsl, 
xhczdzsle as f15, 
xhczdzsls as f16, 
xhczdzslsi as f17, 
xhczdzslw as f18,
ejzbfjl as ejzbfjl,
userid as userid,
createtime as f22 from edc.hchzb where ejzbfjl is null ;
;

/*hchzb_total
表ID表,名称,记录ID,复杂表单入口表记录ID,访视序号,访视内序号,未解决质疑数量,未关闭质疑数量,已关闭质疑数量,已核查字段数量一,已核查字段数量二,已核查字段数量三,已核查字段数量四,已核查字段数量五,需解决字段数总数量一,需解决字段数总数量二,需解决字段数总数量三,需解决字段数总数量四,需解决字段数总数量五,二级子表父记录ID字段,创建人,创建时间
*/
create table hchzb_total as
select tid as tid,
bmc as bmc,
jl as jl,
fzbdrkbjl as f3,
fs as fs,
svnum as svnum,
input(wjjzysl,best.) as wjjzysl,
input(wgbzysl,best.) as wgbzysl,
input(ygbzysl,best.) as ygbzysl,
input(yhczdsly,best.) as yhczdsly,
input(yhczdsle,best.) as yhczdsle,
input(yhczdsls,best.) as yhczdsls,
input(yhczdslss,best.) as f12,
input(yhczdslw,best.) as yhczdslw,
input(xhczdzsl,best.) as xhczdzsl, 
input(xhczdzsle,best.) as f15, 
input(xhczdzsls,best.) as f16, 
input(xhczdzslsi,best.) as f17, 
input(xhczdzslw,best.) as f18,
ejzbfjl as ejzbfjl,
userid as userid,
createtime as f22  from edc.hchzb where ejzbfjl is null 

union 

select zb.tid as tid,
zb.bmc as bmc,
'' as jl,
zb.fzbdrkbjl as f3,
zb.fs as fs,
zb.svnum as svnum,
sum(input(zb.wjjzysl,best.)) as wjjzysl,
sum(input(zb.wgbzysl,best.)) as wgbzysl,
sum(input(zb.ygbzysl,best.)) as ygbzysl,
sum(input(zb.yhczdsly,best.)) as yhczdsly,
sum(input(zb.yhczdsle,best.)) as yhczdsle,
sum(input(zb.yhczdsls,best.)) as yhczdsls,
sum(input(zb.yhczdslss,best.)) as f12,
sum(input(zb.yhczdslw,best.)) as yhczdslw,
sum(input(zb.xhczdzsl,best.)) as xhczdzsl, 
sum(input(zb.xhczdzsle,best.)) as f15, 
sum(input(zb.xhczdzsls,best.)) as f16, 
sum(input(zb.xhczdzslsi,best.)) as f17, 
sum(input(zb.xhczdzslw,best.)) as f18,
zb.ejzbfjl as ejzbfjl,
zb.userid as userid,
max(zb.createtime) as f22  from edc.hchzb zb 
left join fbhchzb fb on fb.jl=zb.ejzbfjl 
where zb.ejzbfjl is not null 
group by zb.fzbdrkbjl,zb.fs,zb.svnum,zb.tid,zb.bmc,zb.ejzbfjl,zb.userid
;


create table hchzbsubject as
select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
subject.status as status,
zqb.visitname as mc,
hchzb.fs as bm,
hchzb.bmc as bmc,
hchzb.tid as tid,
hchzb.yhczdsly as zds,
hchzb.jl as jl,
hchzb.ejzbfjl as ejzbfjl,
hchzb.f3 as f3,
hchzb.userid as users,
hchzb.f22 as ctime from hchzb_total hchzb 
left join raw.subject subject on input(COALESCEc(hchzb.f3,hchzb.jl),best.)=subject.pub_rid 
left join edc.zqb zqb on input(hchzb.fs,best.)=zqb.visitid 
;
quit;

proc sql;
create table unsub_visit1 as 
select a.studyid,a.siteid,a.subjid,mc,b.sjb,b.wjzt,   input(put(b.LASTMODIFYTIME,is8601dt.),is8601dt.) as lastmodify  from hchzbsubject as a right join edc.spjlb b on a.jl=b.jl where subjid ne '';
quit; 

proc sql;
	create table unsub_visit2
		as select distinct studyid,siteid,subjid,mc,wjzt,max(lastmodify) as lastmodify format=is8601dt. from unsub_visit1 group by subjid,mc;
quit;

proc sql;
	create table edc.unsub_visit as 
		select 
			a.*,
		    c.visdat,
		    '否' as yn '是否提交'
/*			b.lockstat as lockstat  'CRF状态'*/  	 
		from unsub_visit2 as a 
		left join derived.subject as x on a.subjid=x.subjid
		left join edc.sv_workflow as b on x.pub_rid=b.jlid and compress(a.mc)=put(b.fsxh,$FSXH16.)
		left join raw.sv c on a.subjid=c.subjid and a.mc =put(c.visit,$VISIT19.) 
		where b.lockstat='00'
		;
quit;


data out.l10(label='访视未提交'); set EDC.unsub_visit; run;
