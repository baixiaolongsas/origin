

/**/
/*PROC IMPORT OUT= EDC.sysuser */
/*            DATAFILE= "&root.\doc\sysuser.xlsx" */
/*            DBMS=EXCEL REPLACE;*/
/*     RANGE="sysuser$"; */
/*     GETNAMES=YES;*/
/*     MIXED=NO;*/
/*     SCANTEXT=YES;*/
/*     USEDATE=YES;*/
/*     SCANTIME=YES;*/
/*RUN;*/


PROC IMPORT OUT= EDC.zqb 
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

create table EDC.fbhchzb as 
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
lastmodifytime as f22 from EDC.hchzb where ejzbfjl is null ;
;


/*hchzb_total
表ID表,名称,记录ID,复杂表单入口表记录ID,访视序号,访视内序号,未解决质疑数量,未关闭质疑数量,已关闭质疑数量,已核查字段数量一,已核查字段数量二,已核查字段数量三,已核查字段数量四,已核查字段数量五,需解决字段数总数量一,需解决字段数总数量二,需解决字段数总数量三,需解决字段数总数量四,需解决字段数总数量五,二级子表父记录ID字段,创建人,创建时间
*/
create table EDC.hchzb_total as
select tid as tid,
bmc as bmc,
input(jl,best.) as jl,
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
lastmodifytime as f22 format E8601DT19. from EDC.hchzb where ejzbfjl is null 


union 

select zb.tid as tid,
zb.bmc as bmc,
input('',best.) as jl,
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
max(zb.lastmodifytime) as f22 format E8601DT19. from EDC.hchzb zb 
left join EDC.fbhchzb fb on fb.jl=zb.ejzbfjl 
where zb.ejzbfjl is not null 
group by zb.fzbdrkbjl,zb.fs,zb.svnum,zb.tid,zb.bmc,zb.ejzbfjl,zb.userid
;

/*
hchzbsubject
项目代码,研究中心编号,受试者代码,受试者状态,访视阶段,访视阶段编号,表名称,表ID,字段数,记录ID,二级字表父表记录ID,复杂表单入口表ID,创建人,创建时间
*/


create table EDC.hchzbsubject as
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
hchzb.f22 as ctime from EDC.hchzb_total hchzb 
left join Derived.subject subject on COALESCE(input(hchzb.f3,best.),hchzb.jl)=input(subject.pub_rid,best.) 
left join EDC.zqb zqb on input(hchzb.fs,best.)=zqb._COL1 
/*left join EDC.sysuser users on users._COL1 = hchzb.userid*/
;

/*访视缺失*/

/*visit_sum
项目代码,访视阶段,访视阶段序号,访视内crf数量
*/

create table EDC.visit_sum as
select visittable.studyid as studyid,
visittable.visitname as f1,
visittable.visitid as visitid,
count(*) as sv_crf '访视内crf数量' from EDC.visittable visittable 
group by visittable.studyid,visittable.visitname,visittable.visitid
;

/*
VisitWCCrfView
研究中心,受试者代码,访视阶段,访视阶段编码,记录数
*/

create table EDC.VisitWCCrfView as
select hchzbsubject.siteid as siteid,
hchzbsubject.subjid as subjid,
hchzbsubject.mc as mc,
hchzbsubject.bm as bm,
count(*) as crfnum '记录数' from EDC.spjlb spjlb 
left join EDC.hchzbsubject hchzbsubject on input(spjlb.jl,best.)=hchzbsubject.jl 
where hchzbsubject.ejzbfjl is null or hchzbsubject.ejzbfjl eq ''
group by siteid,subjid,mc,bm
;

/*进展报告*/

/*VisitNum
项目代码,访视阶段
*/

create table EDC.VisitNum as
select studyid as studyid,
count(distinct visitname) as vinum '访视阶段' from EDC.visittable 
group by studyid 
;

/*piview
项目代码,研究中心编号,受试者代码,已签名访视数,已冻结+已签名访视数
*/

create table EDC.piview as
SELECT subject.studyid as studyid,
sv_workflow.siteid as siteid,
subject.subjid as subjid,
sum(case when sv_workflow.lockstat ='40' then 1 else 0 end) as pin '已签名访视数',
sum(case when sv_workflow.lockstat ='40' or sv_workflow.lockstat ='30' then 1 else 0 end) as pis '已冻结+已签名访视数' from EDC.sv_workflow sv_workflow 
inner join Derived.subject subject on sv_workflow.jlid=subject.subjid 
group by subject.studyid,sv_workflow.siteid,subject.subjid
;

/*pisubjview
研究中心编号,已签名受试者数,已冻结+已签名受试者数
*/

create table EDC.pisubjview as
select piview.siteid as siteid,
sum(case when piview.pin = VisitNum.vinum then 1 else 0 end) as pin '已签名受试者数',
sum(case when piview.pis = VisitNum.vinum then 1 else 0 end) as pis '已冻结+已签名受试者数' from EDC.piview piview 
left join EDC.VisitNum VisitNum on VisitNum.studyid=piview.studyid 
group by piview.siteid
;

/*zynumview
研究中心编号,质疑数,未关闭质疑数
*/

create table EDC.zynumview as
select zyb.siteid as siteid,
count(*) as zynum '质疑数',
sum(case when zyb.zt= '1' then 1 else 0 end) as zynum1 '未关闭质疑数' from EDC.zyb zyb 
group by zyb.siteid 
;

/*sdvnumview
研究中心编号,未SDV数,需SDV数,未SDV百分率(%)
*/



create table EDC.sdvnumview as
select subject.siteid as siteid,
sum(case when hchzb.xhczdzsl-hchzb.yhczdsly > 0 then 1 else 0 end) as sdvnum '未SDV数',
sum(case when hchzb.xhczdzsl > 0 then 1 else 0 end) as sdvznum '需SDV数',
round(sum(case when hchzb.xhczdzsl-hchzb.yhczdsly > 0 then 1 else 0 end)/sum(case when hchzb.xhczdzsl > 0 then 1 else 0 end)*100,2) as sdvrate '未SDV百分率(%)' from EDC.hchzb_total hchzb 
left join Derived.subject subject on input(subject.pub_rid,best.)=COALESCE(input(hchzb.f3,best.),hchzb.jl) 
left join EDC.spjlb spjlb on input(spjlb.jl,best.)=COALESCE(hchzb.jl,input(hchzb.ejzbfjl,best.)) and spjlb.dqzt ^= '00' 
where   hchzb.xhczdzsl is not null and (spjlb.lastmodifytime is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) 
group by subject.siteid 

;


/*sdvnumview(MED) yhczdsls  f16
研究中心编号,未SDV数,需SDV数,未SDV百分率(%)
*/

create table EDC.sdvnumviewMED as
select subject.siteid as siteid,
sum(case when hchzb.f16-hchzb.yhczdsls > 0 then 1 else 0 end) as sdvnum '未SDV数',
sum(case when hchzb.f16 > 0 then 1 else 0 end) as sdvznum '需SDV数',
round(sum(case when hchzb.f16-hchzb.yhczdsls > 0 then 1 else 0 end)/sum(case when hchzb.f16 > 0 then 1 else 0 end)*100,2) as sdvrate '未SDV百分率(%)' from EDC.hchzb_total hchzb 
left join Derived.subject subject on input(subject.pub_rid,best.)=COALESCE(input(hchzb.f3,best.),hchzb.jl)  
left join EDC.spjlb spjlb on input(spjlb.jl,best.)=COALESCE(hchzb.jl,input(hchzb.ejzbfjl,best.)) and spjlb.dqzt ^= '00' 
where   hchzb.f16 is not null and (spjlb.lastmodifytime is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) 
group by subject.siteid 
 ;

/*sdvnumview(DM) yhczdsle  f15
研究中心编号,未SDV数,需SDV数,未SDV百分率(%)
*/

 create table EDC.sdvnumviewDM as
select subject.siteid as siteid,
sum(case when hchzb.f15-hchzb.yhczdsle > 0 then 1 else 0 end) as sdvnum '未SDV数',
sum(case when hchzb.f15 > 0 then 1 else 0 end) as sdvznum '需SDV数',
round(sum(case when hchzb.f15-hchzb.yhczdsle > 0 then 1 else 0 end)/sum(case when hchzb.f15 > 0 then 1 else 0 end)*100,2) as sdvrate '未SDV百分率(%)' from EDC.hchzb_total hchzb 
left join Derived.subject subject on input(subject.pub_rid,best.)=COALESCE(input(hchzb.f3,best.),hchzb.jl) 
left join EDC.spjlb spjlb on input(spjlb.jl,best.)=COALESCE(hchzb.jl,input(hchzb.ejzbfjl,best.)) and spjlb.dqzt ^= '00' 
where   hchzb.f15 is not null and (spjlb.lastmodifytime is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) 
group by subject.siteid 
;




/*zsview
研究中心编号,总记录数,未提交页数
*/

create table EDC.zsview as
select hchzbsubject.siteid as siteid,
count(*) as zs '总记录数',
count(spjlb1.jl) as zs1 '未提交页数' from EDC.hchzbsubject hchzbsubject  
left join EDC.spjlb spjlb on COALESCE(hchzbsubject.jl,input(hchzbsubject.ejzbfjl,best.))=input(spjlb.jl,best.)
left join EDC.spjlb spjlb1 on spjlb.jl=spjlb1.jl and spjlb1.dqzt='00' 
where  hchzbsubject.tid ^='sfzqb'  
group by hchzbsubject.siteid

;




/*SAEView
项目代码,研究中心编号,SAE数,SAE受试者数
*/

create table EDC.SAEView as
SELECT studyid as studyid,
siteid as siteid,
count(*) as saecount 'SAE数',
count(distinct subjid) as saesubjcount 'SAE受试者数' FROM Derived.ae obj 
where obj.saeyn='是' and lockstat ^= '未提交' 
GROUP BY studyid,siteid
;

/*subjectview
项目代码,研究中心编号,研究中心名称,总数,筛选数,入组数,筛选失败数,已完成数,已中止数
*/

create table EDC.subjectview as
SELECT studyid as studyid,
siteid as siteid,
sitename as sitename,
count(*) as jlcount '总数',
sum(case when status='筛选中' then 1 else 0 end) as djcount '筛选数',
sum(case when status='已入组' then 1 else 0 end) as rzcount '入组数',
sum(case when status='筛选失败' then 1 else 0 end) as sbcount '筛选失败数',
sum(case when obj.status='已完成' then 1 else 0 end) as dscount '已完成数',
sum(case when obj.status='已终止' then 1 else 0 end) as dsucount '已终止数' FROM Derived.subject obj 
GROUP BY studyid,siteid,sitename ;

quit;



