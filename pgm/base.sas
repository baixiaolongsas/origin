

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
��ID��,����,��¼ID,���ӱ���ڱ��¼ID,�������,���������,δ�����������,δ�ر���������,�ѹر���������,�Ѻ˲��ֶ�����һ,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�����ֶ���������һ,�����ֶ�����������,�����ֶ�����������,�����ֶ�����������,�����ֶ�����������,�����ӱ���¼ID�ֶ�,������,����ʱ��
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
��ID��,����,��¼ID,���ӱ���ڱ��¼ID,�������,���������,δ�����������,δ�ر���������,�ѹر���������,�Ѻ˲��ֶ�����һ,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�Ѻ˲��ֶ�������,�����ֶ���������һ,�����ֶ�����������,�����ֶ�����������,�����ֶ�����������,�����ֶ�����������,�����ӱ���¼ID�ֶ�,������,����ʱ��
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
��Ŀ����,�о����ı��,�����ߴ���,������״̬,���ӽ׶�,���ӽ׶α��,������,��ID,�ֶ���,��¼ID,�����ֱ����¼ID,���ӱ���ڱ�ID,������,����ʱ��
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

/*����ȱʧ*/

/*visit_sum
��Ŀ����,���ӽ׶�,���ӽ׶����,������crf����
*/

create table EDC.visit_sum as
select visittable.studyid as studyid,
visittable.visitname as f1,
visittable.visitid as visitid,
count(*) as sv_crf '������crf����' from EDC.visittable visittable 
group by visittable.studyid,visittable.visitname,visittable.visitid
;

/*
VisitWCCrfView
�о�����,�����ߴ���,���ӽ׶�,���ӽ׶α���,��¼��
*/

create table EDC.VisitWCCrfView as
select hchzbsubject.siteid as siteid,
hchzbsubject.subjid as subjid,
hchzbsubject.mc as mc,
hchzbsubject.bm as bm,
count(*) as crfnum '��¼��' from EDC.spjlb spjlb 
left join EDC.hchzbsubject hchzbsubject on input(spjlb.jl,best.)=hchzbsubject.jl 
where hchzbsubject.ejzbfjl is null or hchzbsubject.ejzbfjl eq ''
group by siteid,subjid,mc,bm
;

/*��չ����*/

/*VisitNum
��Ŀ����,���ӽ׶�
*/

create table EDC.VisitNum as
select studyid as studyid,
count(distinct visitname) as vinum '���ӽ׶�' from EDC.visittable 
group by studyid 
;

/*piview
��Ŀ����,�о����ı��,�����ߴ���,��ǩ��������,�Ѷ���+��ǩ��������
*/

create table EDC.piview as
SELECT subject.studyid as studyid,
sv_workflow.siteid as siteid,
subject.subjid as subjid,
sum(case when sv_workflow.lockstat ='40' then 1 else 0 end) as pin '��ǩ��������',
sum(case when sv_workflow.lockstat ='40' or sv_workflow.lockstat ='30' then 1 else 0 end) as pis '�Ѷ���+��ǩ��������' from EDC.sv_workflow sv_workflow 
inner join Derived.subject subject on sv_workflow.jlid=subject.subjid 
group by subject.studyid,sv_workflow.siteid,subject.subjid
;

/*pisubjview
�о����ı��,��ǩ����������,�Ѷ���+��ǩ����������
*/

create table EDC.pisubjview as
select piview.siteid as siteid,
sum(case when piview.pin = VisitNum.vinum then 1 else 0 end) as pin '��ǩ����������',
sum(case when piview.pis = VisitNum.vinum then 1 else 0 end) as pis '�Ѷ���+��ǩ����������' from EDC.piview piview 
left join EDC.VisitNum VisitNum on VisitNum.studyid=piview.studyid 
group by piview.siteid
;

/*zynumview
�о����ı��,������,δ�ر�������
*/

create table EDC.zynumview as
select zyb.siteid as siteid,
count(*) as zynum '������',
sum(case when zyb.zt= '1' then 1 else 0 end) as zynum1 'δ�ر�������' from EDC.zyb zyb 
group by zyb.siteid 
;

/*sdvnumview
�о����ı��,δSDV��,��SDV��,δSDV�ٷ���(%)
*/



create table EDC.sdvnumview as
select subject.siteid as siteid,
sum(case when hchzb.xhczdzsl-hchzb.yhczdsly > 0 then 1 else 0 end) as sdvnum 'δSDV��',
sum(case when hchzb.xhczdzsl > 0 then 1 else 0 end) as sdvznum '��SDV��',
round(sum(case when hchzb.xhczdzsl-hchzb.yhczdsly > 0 then 1 else 0 end)/sum(case when hchzb.xhczdzsl > 0 then 1 else 0 end)*100,2) as sdvrate 'δSDV�ٷ���(%)' from EDC.hchzb_total hchzb 
left join Derived.subject subject on input(subject.pub_rid,best.)=COALESCE(input(hchzb.f3,best.),hchzb.jl) 
left join EDC.spjlb spjlb on input(spjlb.jl,best.)=COALESCE(hchzb.jl,input(hchzb.ejzbfjl,best.)) and spjlb.dqzt ^= '00' 
where   hchzb.xhczdzsl is not null and (spjlb.lastmodifytime is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) 
group by subject.siteid 

;


/*sdvnumview(MED) yhczdsls  f16
�о����ı��,δSDV��,��SDV��,δSDV�ٷ���(%)
*/

create table EDC.sdvnumviewMED as
select subject.siteid as siteid,
sum(case when hchzb.f16-hchzb.yhczdsls > 0 then 1 else 0 end) as sdvnum 'δSDV��',
sum(case when hchzb.f16 > 0 then 1 else 0 end) as sdvznum '��SDV��',
round(sum(case when hchzb.f16-hchzb.yhczdsls > 0 then 1 else 0 end)/sum(case when hchzb.f16 > 0 then 1 else 0 end)*100,2) as sdvrate 'δSDV�ٷ���(%)' from EDC.hchzb_total hchzb 
left join Derived.subject subject on input(subject.pub_rid,best.)=COALESCE(input(hchzb.f3,best.),hchzb.jl)  
left join EDC.spjlb spjlb on input(spjlb.jl,best.)=COALESCE(hchzb.jl,input(hchzb.ejzbfjl,best.)) and spjlb.dqzt ^= '00' 
where   hchzb.f16 is not null and (spjlb.lastmodifytime is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) 
group by subject.siteid 
 ;

/*sdvnumview(DM) yhczdsle  f15
�о����ı��,δSDV��,��SDV��,δSDV�ٷ���(%)
*/

 create table EDC.sdvnumviewDM as
select subject.siteid as siteid,
sum(case when hchzb.f15-hchzb.yhczdsle > 0 then 1 else 0 end) as sdvnum 'δSDV��',
sum(case when hchzb.f15 > 0 then 1 else 0 end) as sdvznum '��SDV��',
round(sum(case when hchzb.f15-hchzb.yhczdsle > 0 then 1 else 0 end)/sum(case when hchzb.f15 > 0 then 1 else 0 end)*100,2) as sdvrate 'δSDV�ٷ���(%)' from EDC.hchzb_total hchzb 
left join Derived.subject subject on input(subject.pub_rid,best.)=COALESCE(input(hchzb.f3,best.),hchzb.jl) 
left join EDC.spjlb spjlb on input(spjlb.jl,best.)=COALESCE(hchzb.jl,input(hchzb.ejzbfjl,best.)) and spjlb.dqzt ^= '00' 
where   hchzb.f15 is not null and (spjlb.lastmodifytime is not null) or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) 
group by subject.siteid 
;




/*zsview
�о����ı��,�ܼ�¼��,δ�ύҳ��
*/

create table EDC.zsview as
select hchzbsubject.siteid as siteid,
count(*) as zs '�ܼ�¼��',
count(spjlb1.jl) as zs1 'δ�ύҳ��' from EDC.hchzbsubject hchzbsubject  
left join EDC.spjlb spjlb on COALESCE(hchzbsubject.jl,input(hchzbsubject.ejzbfjl,best.))=input(spjlb.jl,best.)
left join EDC.spjlb spjlb1 on spjlb.jl=spjlb1.jl and spjlb1.dqzt='00' 
where  hchzbsubject.tid ^='sfzqb'  
group by hchzbsubject.siteid

;




/*SAEView
��Ŀ����,�о����ı��,SAE��,SAE��������
*/

create table EDC.SAEView as
SELECT studyid as studyid,
siteid as siteid,
count(*) as saecount 'SAE��',
count(distinct subjid) as saesubjcount 'SAE��������' FROM Derived.ae obj 
where obj.saeyn='��' and lockstat ^= 'δ�ύ' 
GROUP BY studyid,siteid
;

/*subjectview
��Ŀ����,�о����ı��,�о���������,����,ɸѡ��,������,ɸѡʧ����,�������,����ֹ��
*/

create table EDC.subjectview as
SELECT studyid as studyid,
siteid as siteid,
sitename as sitename,
count(*) as jlcount '����',
sum(case when status='ɸѡ��' then 1 else 0 end) as djcount 'ɸѡ��',
sum(case when status='������' then 1 else 0 end) as rzcount '������',
sum(case when status='ɸѡʧ��' then 1 else 0 end) as sbcount 'ɸѡʧ����',
sum(case when obj.status='�����' then 1 else 0 end) as dscount '�������',
sum(case when obj.status='����ֹ' then 1 else 0 end) as dsucount '����ֹ��' FROM Derived.subject obj 
GROUP BY studyid,siteid,sitename ;

quit;



