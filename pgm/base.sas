
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/


/**/
/*PROC IMPORT OUT= DP.sysuser */
/*            DATAFILE= "&root.\doc\sysuser.xlsx" */
/*            DBMS=EXCEL REPLACE;*/
/*     RANGE="sysuser$"; */
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/


PROC IMPORT OUT= DP.zqb 
            DATAFILE= "&root.\doc\zqb.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="zqb$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


proc sql;

/*fbhchzb
表ID表,名称,记录ID,复杂表单入口表记录ID,访视序号,访视内序号,未解决质疑数量,未关闭质疑数量,已关闭质疑数量,已核查字段数量一,已核查字段数量二,已核查字段数量三,已核查字段数量四,已核查字段数量五,需解决字段数总数量一,需解决字段数总数量二,需解决字段数总数量三,需解决字段数总数量四,需解决字段数总数量五,二级子表父记录ID字段,创建人,创建时间
*/

create table dp.fbhchzb as 
select tid as tid,
bmc as bmc,
jl as jl,
f3 as f3,
fs as fs,
svnum as svnum,
wjjzysl as wjjzysl,
wgbzysl as wgbzysl,
ygbzysl as ygbzysl,
yhczdsly as yhczdsly,
yhczdsle as yhczdsle,
yhczdsls as yhczdsls,
f12 as f12,
yhczdslw as yhczdslw,
xhczdzsl as xhczdzsl, 
f15 as f15, 
f16 as f16, 
f17 as f17, 
f18 as f18,
ejzbfjl as ejzbfjl,
userid as userid,
f22 as f22 from dp.hchzb where ejzbfjl is null ;
;


/*hchzb_total
表ID表,名称,记录ID,复杂表单入口表记录ID,访视序号,访视内序号,未解决质疑数量,未关闭质疑数量,已关闭质疑数量,已核查字段数量一,已核查字段数量二,已核查字段数量三,已核查字段数量四,已核查字段数量五,需解决字段数总数量一,需解决字段数总数量二,需解决字段数总数量三,需解决字段数总数量四,需解决字段数总数量五,二级子表父记录ID字段,创建人,创建时间
*/
create table dp.hchzb_total as
select tid as tid,
bmc as bmc,
jl as jl,
f3 as f3,
fs as fs,
svnum as svnum,
wjjzysl as wjjzysl,
wgbzysl as wgbzysl,
ygbzysl as ygbzysl,
yhczdsly as yhczdsly,
yhczdsle as yhczdsle,
yhczdsls as yhczdsls,
f12 as f12,
yhczdslw as yhczdslw,
xhczdzsl as xhczdzsl, 
f15 as f15, 
f16 as f16, 
f17 as f17, 
f18 as f18,
ejzbfjl as ejzbfjl,
userid as userid,
f22 as f22 format YYMMDD10. from dp.hchzb where ejzbfjl is null 


union 

select zb.tid as tid,
zb.bmc as bmc,
input('',best.) as jl,
zb.f3 as f3,
zb.fs as fs,
zb.svnum as svnum,
sum(zb.wjjzysl) as wjjzysl,
sum(zb.wgbzysl) as wgbzysl,
sum(zb.ygbzysl) as ygbzysl,
sum(zb.yhczdsly) as yhczdsly,
sum(zb.yhczdsle) as yhczdsle,
sum(zb.yhczdsls) as yhczdsls,
sum(zb.f12) as f12,
sum(zb.yhczdslw) as yhczdslw,
sum(zb.xhczdzsl) as xhczdzsl, 
sum(zb.f15) as f15, 
sum(zb.f16) as f16, 
sum(zb.f17) as f17, 
sum(zb.f18) as f18,
zb.ejzbfjl as ejzbfjl,
zb.userid as userid,
max(zb.f22) as f22 format YYMMDD10. from dp.hchzb zb 
left join dp.fbhchzb fb on fb.jl=zb.ejzbfjl 
where zb.ejzbfjl is not null 
group by zb.f3,zb.fs,zb.svnum,zb.tid,zb.bmc,zb.ejzbfjl,zb.userid
;

/*
hchzbsubject
项目代码,研究中心编号,受试者代码,受试者状态,访视阶段,访视阶段编号,表名称,表ID,字段数,记录ID,二级字表父表记录ID,复杂表单入口表ID,创建人,创建时间
*/

create table dp.hchzbsubject as
select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
subject.status as status,
zqb._COL0 as mc,
hchzb.fs as bm,
hchzb.bmc as bmc,
hchzb.tid as tid,
hchzb.yhczdsly as zds,
hchzb.jl as jl,
hchzb.ejzbfjl as ejzbfjl,
hchzb.f3 as f3,
/*users._COL1 as users,*/
hchzb.userid as users,
hchzb.f22 as ctime from dp.hchzb_total hchzb 
left join dc.subject subject on COALESCE(hchzb.f3,hchzb.jl)=subject.pub_rid 
left join dp.zqb zqb on hchzb.fs=zqb._COL1 
/*left join dp.sysuser users on users._COL1 = hchzb.userid*/
;

/*访视缺失*/

/*visit_sum
项目代码,访视阶段,访视阶段序号,访视内crf数量
*/

create table dp.visit_sum as
select visittable.studyid as studyid,
visittable.f1 as f1,
visittable.visitid as visitid,
count(*) as sv_crf '访视内crf数量' from dp.visittable visittable 
group by visittable.studyid,visittable.f1,visittable.visitid
;

/*
VisitWCCrfView
研究中心,受试者代码,访视阶段,访视阶段编码,记录数
*/

create table dp.VisitWCCrfView as
select hchzbsubject.siteid as siteid,
hchzbsubject.subjid as subjid,
hchzbsubject.mc as mc,
hchzbsubject.bm as bm,
count(*) as crfnum '记录数' from dp.spjlb spjlb 
left join dp.hchzbsubject hchzbsubject on spjlb.jl=hchzbsubject.jl 
where hchzbsubject.ejzbfjl is null or hchzbsubject.ejzbfjl =. 
group by siteid,subjid,mc,bm
;

/*进展报告*/

/*VisitNum
项目代码,访视阶段
*/

create table dp.VisitNum as
select studyid as studyid,
count(distinct f1) as vinum '访视阶段' from dp.visittable 
group by studyid 
;

/*piview
项目代码,研究中心编号,受试者代码,已签名访视数,已冻结+已签名访视数
*/

create table dp.piview as
SELECT subject.studyid as studyid,
sv_workflow.siteid as siteid,
subject.subjid as subjid,
sum(case when sv_workflow.lockstat ='40' then 1 else 0 end) as pin '已签名访视数',
sum(case when sv_workflow.lockstat ='40' or sv_workflow.lockstat ='30' then 1 else 0 end) as pis '已冻结+已签名访视数' from dp.sv_workflow sv_workflow 
inner join dc.subject subject on sv_workflow.jlid=subject.subjid 
group by subject.studyid,sv_workflow.siteid,subject.subjid
;

/*pisubjview
研究中心编号,已签名受试者数,已冻结+已签名受试者数
*/

create table dp.pisubjview as
select piview.siteid as siteid,
sum(case when piview.pin = VisitNum.vinum then 1 else 0 end) as pin '已签名受试者数',
sum(case when piview.pis = VisitNum.vinum then 1 else 0 end) as pis '已冻结+已签名受试者数' from dp.piview piview 
left join dp.VisitNum VisitNum on VisitNum.studyid=piview.studyid 
group by piview.siteid
;

/*zynumview
研究中心编号,质疑数,未关闭质疑数
*/

create table dp.zynumview as
select zyb.siteid as siteid,
count(*) as zynum '质疑数',
sum(case when zyb.zt= '1' then 1 else 0 end) as zynum1 '未关闭质疑数' from dp.zyb zyb 
group by zyb.siteid 
;

/*sdvnumview
研究中心编号,未SDV数,需SDV数,未SDV百分率(%)
*/


/**/
/*create table dp.sdvnumview as*/
/*select subject.siteid as siteid,*/
/*sum(case when hchzb.xhczdzsl-hchzb.yhczdsly > 0 then 1 else 0 end) as sdvnum '未SDV数',*/
/*sum(case when hchzb.xhczdzsl > 0 then 1 else 0 end) as sdvznum '需SDV数',*/
/*round(sum(case when hchzb.xhczdzsl-hchzb.yhczdsly > 0 then 1 else 0 end)/sum(case when hchzb.xhczdzsl > 0 then 1 else 0 end)*100,2) as sdvrate '未SDV百分率(%)' from dp.hchzb_total hchzb */
/*left join dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) */
/*left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.jl,hchzb.ejzbfjl) and spjlb.dqzt ^= '00' */
/*where   hchzb.xhczdzsl is not null and (spjlb.f13 is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) */
/*group by subject.siteid */
/**/
/*;*/



create table dp.sdvnumview as
select subject.siteid as siteid,
sum(hchzb.xhczdzsl-hchzb.yhczdsly ) as sdvnum '去除未提交的未SDV数',
sum(hchzb.xhczdzsl ) as sdvznum '未SDV页面的需SDV字段数',
round(sum(hchzb.xhczdzsl-hchzb.yhczdsly )/sum(hchzb.xhczdzsl )*100,0.01) as sdvrate '未SDV百分率(%)' 

from  dp.hchzb hchzb 
left join dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) 
/*left join dp.spjlb spjlb on (spjlb.jl=hchzb.jl or spjlb.jl=hchzb.ejzbfjl) */
left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.ejzbfjl,hchzb.jl) 
where   
(hchzb.xhczdzsl is not null and (spjlb.f13 is not null) 
/*or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) */
) and
spjlb.dqzt ^= '00'
group by subject.siteid
;



/*sdvnumview(MED) yhczdsls  f16
研究中心编号,未SDV数,需SDV数,未SDV百分率(%)
*/
/**/
/*create table dp.sdvnumviewMED as*/
/*select subject.siteid as siteid,*/
/*sum(case when hchzb.f16-hchzb.yhczdsls > 0 then 1 else 0 end) as sdvnum '未SDV数',*/
/*sum(case when hchzb.f16 > 0 then 1 else 0 end) as sdvznum '需SDV数',*/
/*round(sum(case when hchzb.f16-hchzb.yhczdsls > 0 then 1 else 0 end)/sum(case when hchzb.f16 > 0 then 1 else 0 end)*100,2) as sdvrate '未SDV百分率(%)' from dp.hchzb_total hchzb */
/*left join dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) */
/*left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.jl,hchzb.ejzbfjl) and spjlb.dqzt ^= '00' */
/*where   hchzb.f16 is not null and (spjlb.f13 is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) */
/*group by subject.siteid */
/* ;*/

 

create table dp.sdvnumviewMED as
select subject.siteid as siteid,
sum(hchzb.f16-hchzb.yhczdsls ) as sdvnum '去除未提交的未SDV数',
sum(hchzb.f16 ) as sdvznum '未SDV页面的需SDV字段数',
round(sum(hchzb.f16-hchzb.yhczdsls )/sum(hchzb.f16 )*100,0.01) as sdvrate '未SDV百分率(%)' 
from  dp.hchzb hchzb 
left join dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) 
left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.ejzbfjl,hchzb.jl) 
where   
(hchzb.f16 is not null and (spjlb.f13 is not null) 
) and
spjlb.dqzt ^= '00'
group by subject.siteid
;

/*sdvnumview(DM) yhczdsle  f15
研究中心编号,未SDV数,需SDV数,未SDV百分率(%)
*/
/**/
/* create table dp.sdvnumviewDM as*/
/*select subject.siteid as siteid,*/
/*sum(case when hchzb.f15-hchzb.yhczdsle > 0 then 1 else 0 end) as sdvnum '未SDV数',*/
/*sum(case when hchzb.f15 > 0 then 1 else 0 end) as sdvznum '需SDV数',*/
/*round(sum(case when hchzb.f15-hchzb.yhczdsle > 0 then 1 else 0 end)/sum(case when hchzb.f15 > 0 then 1 else 0 end)*100,2) as sdvrate '未SDV百分率(%)' from dp.hchzb_total hchzb */
/*left join dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) */
/*left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.jl,hchzb.ejzbfjl) and spjlb.dqzt ^= '00' */
/*where   hchzb.f15 is not null and (spjlb.f13 is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) */
/*group by subject.siteid */
/*;*/




create table dp.sdvnumviewDM as
select subject.siteid as siteid,
sum(hchzb.f15-hchzb.yhczdsle ) as sdvnum '去除未提交的未SDV数',
sum(hchzb.f15 ) as sdvznum '未SDV页面的需SDV字段数',
round(sum(hchzb.f15-hchzb.yhczdsle )/sum(hchzb.f15 )*100,0.01) as sdvrate '未SDV百分率(%)' 
from  dp.hchzb hchzb 
left join dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) 
left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.ejzbfjl,hchzb.jl) 
where   
(hchzb.f15 is not null and (spjlb.f13 is not null) 
) and
spjlb.dqzt ^= '00'
group by subject.siteid
;




/*zsview
研究中心编号,总记录数,未提交页数
*/

create table dp.zsview as
select hchzbsubject.siteid as siteid,
count(*) as zs '总记录数',
count(spjlb1.jl) as zs1 '未提交页数' from dp.hchzbsubject hchzbsubject  
left join dp.spjlb spjlb on COALESCE(hchzbsubject.jl,hchzbsubject.ejzbfjl)=spjlb.jl 
left join dp.spjlb spjlb1 on spjlb.jl=spjlb1.jl and spjlb1.dqzt='00' 
where  hchzbsubject.tid ^='sfzqb'  
group by hchzbsubject.siteid

;


;

/*SAEView
项目代码,研究中心编号,SAE数,SAE受试者数
*/

create table dp.SAEView as
SELECT studyid as studyid,
siteid as siteid,
count(*) as saecount 'SAE数',
count(distinct subjid) as saesubjcount 'SAE受试者数' FROM dc.ae obj 
where obj.saeyn='1' and lockstat ^= '00' 
GROUP BY studyid,siteid
;
/*subjectview
项目代码,研究中心编号,研究中心名称,总数,筛选数,入组数,筛选失败数,已完成数,已中止数
*/

create table dp.subjectview as
SELECT studyid as studyid,
siteid as siteid,
sitename as sitename,
count(*) as jlcount '总数',
sum(case when status='0' then 1 else 0 end) as djcount '筛选数',
sum(case when status='2' then 1 else 0 end) as rzcount '入组数',
sum(case when status='5' then 1 else 0 end) as sbcount '筛选失败数',
sum(case when obj.status='4' then 1 else 0 end) as dscount '已完成数',
sum(case when obj.status='3' then 1 else 0 end) as dsucount '已中止数' FROM dc.subject obj 
GROUP BY studyid,siteid,sitename ;

quit;



