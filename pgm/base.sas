
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
��ID��,����,��¼ID,���ӱ���ڱ��¼ID,�������,���������,δ�����������,δ�ر���������,�ѹر���������,�Ѻ˲��ֶ�����һ,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�����ֶ���������һ,�����ֶ�����������,�����ֶ�����������,�����ֶ�����������,�����ֶ�����������,�����ӱ���¼ID�ֶ�,������,����ʱ��
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
��ID��,����,��¼ID,���ӱ���ڱ��¼ID,�������,���������,δ�����������,δ�ر���������,�ѹر���������,�Ѻ˲��ֶ�����һ,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�����ֶ���������һ,�����ֶ�����������,�����ֶ�����������,�����ֶ�����������,�����ֶ�����������,�����ӱ���¼ID�ֶ�,������,����ʱ��
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
��Ŀ����,�о����ı��,�����ߴ���,������״̬,���ӽ׶�,���ӽ׶α��,������,��ID,�ֶ���,��¼ID,�����ֱ����¼ID,���ӱ���ڱ�ID,������,����ʱ��
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

/*����ȱʧ*/

/*visit_sum
��Ŀ����,���ӽ׶�,���ӽ׶����,������crf����
*/

create table dp.visit_sum as
select visittable.studyid as studyid,
visittable.f1 as f1,
visittable.visitid as visitid,
count(*) as sv_crf '������crf����' from dp.visittable visittable 
group by visittable.studyid,visittable.f1,visittable.visitid
;

/*
VisitWCCrfView
�о�����,�����ߴ���,���ӽ׶�,���ӽ׶α���,��¼��
*/

create table dp.VisitWCCrfView as
select hchzbsubject.siteid as siteid,
hchzbsubject.subjid as subjid,
hchzbsubject.mc as mc,
hchzbsubject.bm as bm,
count(*) as crfnum '��¼��' from dp.spjlb spjlb 
left join dp.hchzbsubject hchzbsubject on spjlb.jl=hchzbsubject.jl 
where hchzbsubject.ejzbfjl is null or hchzbsubject.ejzbfjl =. 
group by siteid,subjid,mc,bm
;

/*��չ����*/

/*VisitNum
��Ŀ����,���ӽ׶�
*/

create table dp.VisitNum as
select studyid as studyid,
count(distinct f1) as vinum '���ӽ׶�' from dp.visittable 
group by studyid 
;

/*piview
��Ŀ����,�о����ı��,�����ߴ���,��ǩ��������,�Ѷ���+��ǩ��������
*/

create table dp.piview as
SELECT subject.studyid as studyid,
sv_workflow.siteid as siteid,
subject.subjid as subjid,
sum(case when sv_workflow.lockstat ='40' then 1 else 0 end) as pin '��ǩ��������',
sum(case when sv_workflow.lockstat ='40' or sv_workflow.lockstat ='30' then 1 else 0 end) as pis '�Ѷ���+��ǩ��������' from dp.sv_workflow sv_workflow 
inner join dc.subject subject on sv_workflow.jlid=subject.subjid 
group by subject.studyid,sv_workflow.siteid,subject.subjid
;

/*pisubjview
�о����ı��,��ǩ����������,�Ѷ���+��ǩ����������
*/

create table dp.pisubjview as
select piview.siteid as siteid,
sum(case when piview.pin = VisitNum.vinum then 1 else 0 end) as pin '��ǩ����������',
sum(case when piview.pis = VisitNum.vinum then 1 else 0 end) as pis '�Ѷ���+��ǩ����������' from dp.piview piview 
left join dp.VisitNum VisitNum on VisitNum.studyid=piview.studyid 
group by piview.siteid
;

/*zynumview
�о����ı��,������,δ�ر�������
*/

create table dp.zynumview as
select zyb.siteid as siteid,
count(*) as zynum '������',
sum(case when zyb.zt= '1' then 1 else 0 end) as zynum1 'δ�ر�������' from dp.zyb zyb 
group by zyb.siteid 
;

/*sdvnumview
�о����ı��,δSDV��,��SDV��,δSDV�ٷ���(%)
*/


/**/
/*create table dp.sdvnumview as*/
/*select subject.siteid as siteid,*/
/*sum(case when hchzb.xhczdzsl-hchzb.yhczdsly > 0 then 1 else 0 end) as sdvnum 'δSDV��',*/
/*sum(case when hchzb.xhczdzsl > 0 then 1 else 0 end) as sdvznum '��SDV��',*/
/*round(sum(case when hchzb.xhczdzsl-hchzb.yhczdsly > 0 then 1 else 0 end)/sum(case when hchzb.xhczdzsl > 0 then 1 else 0 end)*100,2) as sdvrate 'δSDV�ٷ���(%)' from dp.hchzb_total hchzb */
/*left join dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) */
/*left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.jl,hchzb.ejzbfjl) and spjlb.dqzt ^= '00' */
/*where   hchzb.xhczdzsl is not null and (spjlb.f13 is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) */
/*group by subject.siteid */
/**/
/*;*/



create table dp.sdvnumview as
select subject.siteid as siteid,
sum(hchzb.xhczdzsl-hchzb.yhczdsly ) as sdvnum 'ȥ��δ�ύ��δSDV��',
sum(hchzb.xhczdzsl ) as sdvznum 'δSDVҳ�����SDV�ֶ���',
round(sum(hchzb.xhczdzsl-hchzb.yhczdsly )/sum(hchzb.xhczdzsl )*100,0.01) as sdvrate 'δSDV�ٷ���(%)' 

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
�о����ı��,δSDV��,��SDV��,δSDV�ٷ���(%)
*/
/**/
/*create table dp.sdvnumviewMED as*/
/*select subject.siteid as siteid,*/
/*sum(case when hchzb.f16-hchzb.yhczdsls > 0 then 1 else 0 end) as sdvnum 'δSDV��',*/
/*sum(case when hchzb.f16 > 0 then 1 else 0 end) as sdvznum '��SDV��',*/
/*round(sum(case when hchzb.f16-hchzb.yhczdsls > 0 then 1 else 0 end)/sum(case when hchzb.f16 > 0 then 1 else 0 end)*100,2) as sdvrate 'δSDV�ٷ���(%)' from dp.hchzb_total hchzb */
/*left join dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) */
/*left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.jl,hchzb.ejzbfjl) and spjlb.dqzt ^= '00' */
/*where   hchzb.f16 is not null and (spjlb.f13 is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) */
/*group by subject.siteid */
/* ;*/

 

create table dp.sdvnumviewMED as
select subject.siteid as siteid,
sum(hchzb.f16-hchzb.yhczdsls ) as sdvnum 'ȥ��δ�ύ��δSDV��',
sum(hchzb.f16 ) as sdvznum 'δSDVҳ�����SDV�ֶ���',
round(sum(hchzb.f16-hchzb.yhczdsls )/sum(hchzb.f16 )*100,0.01) as sdvrate 'δSDV�ٷ���(%)' 
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
�о����ı��,δSDV��,��SDV��,δSDV�ٷ���(%)
*/
/**/
/* create table dp.sdvnumviewDM as*/
/*select subject.siteid as siteid,*/
/*sum(case when hchzb.f15-hchzb.yhczdsle > 0 then 1 else 0 end) as sdvnum 'δSDV��',*/
/*sum(case when hchzb.f15 > 0 then 1 else 0 end) as sdvznum '��SDV��',*/
/*round(sum(case when hchzb.f15-hchzb.yhczdsle > 0 then 1 else 0 end)/sum(case when hchzb.f15 > 0 then 1 else 0 end)*100,2) as sdvrate 'δSDV�ٷ���(%)' from dp.hchzb_total hchzb */
/*left join dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) */
/*left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.jl,hchzb.ejzbfjl) and spjlb.dqzt ^= '00' */
/*where   hchzb.f15 is not null and (spjlb.f13 is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) */
/*group by subject.siteid */
/*;*/




create table dp.sdvnumviewDM as
select subject.siteid as siteid,
sum(hchzb.f15-hchzb.yhczdsle ) as sdvnum 'ȥ��δ�ύ��δSDV��',
sum(hchzb.f15 ) as sdvznum 'δSDVҳ�����SDV�ֶ���',
round(sum(hchzb.f15-hchzb.yhczdsle )/sum(hchzb.f15 )*100,0.01) as sdvrate 'δSDV�ٷ���(%)' 
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
�о����ı��,�ܼ�¼��,δ�ύҳ��
*/

create table dp.zsview as
select hchzbsubject.siteid as siteid,
count(*) as zs '�ܼ�¼��',
count(spjlb1.jl) as zs1 'δ�ύҳ��' from dp.hchzbsubject hchzbsubject  
left join dp.spjlb spjlb on COALESCE(hchzbsubject.jl,hchzbsubject.ejzbfjl)=spjlb.jl 
left join dp.spjlb spjlb1 on spjlb.jl=spjlb1.jl and spjlb1.dqzt='00' 
where  hchzbsubject.tid ^='sfzqb'  
group by hchzbsubject.siteid

;


;

/*SAEView
��Ŀ����,�о����ı��,SAE��,SAE��������
*/

create table dp.SAEView as
SELECT studyid as studyid,
siteid as siteid,
count(*) as saecount 'SAE��',
count(distinct subjid) as saesubjcount 'SAE��������' FROM dc.ae obj 
where obj.saeyn='1' and lockstat ^= '00' 
GROUP BY studyid,siteid
;
/*subjectview
��Ŀ����,�о����ı��,�о���������,����,ɸѡ��,������,ɸѡʧ����,�������,����ֹ��
*/

create table dp.subjectview as
SELECT studyid as studyid,
siteid as siteid,
sitename as sitename,
count(*) as jlcount '����',
sum(case when status='0' then 1 else 0 end) as djcount 'ɸѡ��',
sum(case when status='2' then 1 else 0 end) as rzcount '������',
sum(case when status='5' then 1 else 0 end) as sbcount 'ɸѡʧ����',
sum(case when obj.status='4' then 1 else 0 end) as dscount '�������',
sum(case when obj.status='3' then 1 else 0 end) as dsucount '����ֹ��' FROM dc.subject obj 
GROUP BY studyid,siteid,sitename ;

quit;



