 /*soh**********************************************************************************
CODE NAME                 : <EDC进展报告>
CODE TYPE                 : <dc >
DESCRIPTION               : <进展报告EDC进展报告> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < >
OUTPUT                    : < edc_metrics.sas7dbat>
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & xwei
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01					2017-11-02
**eoh**********************************************************************************
*****************************************************************************************/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;






proc sql;

create table EDC.VisitNum as
select studyid as studyid,
count(distinct visitname) as vinum '访视阶段' from EDC.visittable 
group by studyid ;

create table EDC.piview as
SELECT subject.studyid as studyid,
sv_workflow.siteid as siteid,
subject.subjid as subjid,
sum(case when sv_workflow.lockstat ='40' then 1 else 0 end) as pin '已签名访视数',
sum(case when sv_workflow.lockstat ='40' or sv_workflow.lockstat ='30' then 1 else 0 end) as pis '已冻结+已签名访视数' from EDC.sv_workflow sv_workflow 
inner join derived.subject subject on sv_workflow.jlid=subject.subjid 
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


create table EDC.SAEView as
SELECT studyid as studyid,
siteid as siteid,
count(*) as saecount 'SAE数',
count(distinct subjid) as saesubjcount 'SAE受试者数' FROM derived.ae obj 
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
sum(case when obj.status='已终止' then 1 else 0 end) as dsucount '已终止数' FROM derived.subject obj 
GROUP BY studyid,siteid,sitename ;

/*受试者结束治疗数*/
create table EDC.done as 
SELECT studyid as studyid,
siteid as siteid,
count(distinct subjid) as donecount '受试者结束治疗数'  FROM derived.ds1 obj
GROUP BY studyid,siteid
;



quit;


















proc sql;
create table EDC.EDC_metrics as 
SELECT zxlsb.zxbhzd as zxbhzd '研究中心编号',zxlsb.dw as dw '研究中心名称' ,COALESCE(subjectview.jlcount,0) as jlcount '受试者筛选数',
COALESCE(subjectview.sbcount,0) as sbcount '筛选失败数',COALESCE(subjectview.rzcount+subjectview.dsucount,0) as rzcount '受试者入组数',
COALESCE(SAEView.saesubjcount,0) as saesubject 'SAE受试者数',COALESCE(SAEView.saecount,0) as saecount 'SAE条数',
COALESCE(done.donecount,0) as donecount '受试者结束治疗数',
COALESCE(subjectview.dsucount,0) as dsucount '受试者已终止数',
COALESCE(qsvisitview.qsvisit,0) as qsvisit '受试者访视缺失数',COALESCE(qscrf.qscrf,0) as qscrf '入组受试者缺失页数',COALESCE(zsview.zs,0) as zs '总记录页数',COALESCE(input(zsview.zs1,best.),0) as zs1 '未提交页数',
COALESCE(round(input(zsview.zs1,best.)/zsview.zs*100,0.01),0) as zsq "未提交百分率(%)",COALESCE(sdvnum.sdvnum,0) as sdvnum '未SDV字段数',COALESCE(sdvnum.sdvrate,0) as sdvrate "未SDV字段百分率(%)",
COALESCE(dmnum.dmnum,0) as dmnum 'DM未核查字段数',
COALESCE(dmnum.dmznum,0) as dmznum 'DM需核查字段数',
COALESCE(dmnum.dmrate,0) as dmrate "DM未核查字段百分率(%)",
COALESCE(mednum.mednum,0) as mednum 'MED未核查字段数',
COALESCE(mednum.medznum,0) as medznum 'MED需核查字段数',
COALESCE(mednum.medrate,0) as medrate "MED未核查字段百分率(%)",



COALESCE(zynum.zynum,0) as zynum '总质疑数',COALESCE(zynum.zynum1,0) as zynum1 '未回复质疑数',COALESCE(round(zynum.zynum1/zynum.zynum*100,0.1),0) as zyrate "未回复质疑率(%)",
COALESCE(pisubjview.pin,0) as pi1 '电子签名受试者数',COALESCE(round(pisubjview.pin/pisubjview.pis*100,0.1),0) as pirate "电子签名受试者率(%)" FROM EDC.zxlsb zxlsb 
LEFT JOIN EDC.subjectview subjectview  on zxlsb.zxbhzd=subjectview.siteid 
LEFT JOIN EDC.SAEView SAEView  on zxlsb.zxbhzd=SAEView.siteid 
LEFT JOIN EDC.done done on zxlsb.zxbhzd=done.siteid
LEFT JOIN EDC.qsvisitview qsvisitview on zxlsb.zxbhzd=qsvisitview.siteid 
LEFT JOIN EDC.qscrfview qscrf on zxlsb.zxbhzd=qscrf.siteid 
LEFT JOIN EDC.zsview zsview on zxlsb.zxbhzd=zsview.siteid and zsview.zs>0 
LEFT JOIN EDC.sdvnumview sdvnum on zxlsb.zxbhzd=sdvnum.siteid 
LEFT JOIN EDC.dmnumview dmnum on zxlsb.zxbhzd=dmnum.siteid 
LEFT JOIN EDC.mednumview mednum on zxlsb.zxbhzd=mednum.siteid 
LEFT JOIN EDC.zynumview zynum on zxlsb.zxbhzd=zynum.siteid and zynum.zynum >0 
LEFT JOIN EDC.pisubjview pisubjview on zxlsb.zxbhzd=pisubjview.siteid and pisubjview.pis >0 
 ORDER BY zxlsb.zxbhzd;
quit;

data out.l1(label='EDC进展报告'); set EDC.EDC_metrics; run;
