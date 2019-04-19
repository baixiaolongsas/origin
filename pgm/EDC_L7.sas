 /*soh**********************************************************************************
CODE NAME                 : <EDC��չ����>
CODE TYPE                 : <dc >
DESCRIPTION               : <��չ����EDC��չ����> 
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
count(distinct visitname) as vinum '���ӽ׶�' from EDC.visittable 
group by studyid ;

create table EDC.piview as
SELECT subject.studyid as studyid,
sv_workflow.siteid as siteid,
subject.subjid as subjid,
sum(case when sv_workflow.lockstat ='40' then 1 else 0 end) as pin '��ǩ��������',
sum(case when sv_workflow.lockstat ='40' or sv_workflow.lockstat ='30' then 1 else 0 end) as pis '�Ѷ���+��ǩ��������' from EDC.sv_workflow sv_workflow 
inner join derived.subject subject on sv_workflow.jlid=subject.subjid 
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


create table EDC.SAEView as
SELECT studyid as studyid,
siteid as siteid,
count(*) as saecount 'SAE��',
count(distinct subjid) as saesubjcount 'SAE��������' FROM derived.ae obj 
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
sum(case when obj.status='����ֹ' then 1 else 0 end) as dsucount '����ֹ��' FROM derived.subject obj 
GROUP BY studyid,siteid,sitename ;

/*�����߽���������*/
create table EDC.done as 
SELECT studyid as studyid,
siteid as siteid,
count(distinct subjid) as donecount '�����߽���������'  FROM derived.ds1 obj
GROUP BY studyid,siteid
;



quit;


















proc sql;
create table EDC.EDC_metrics as 
SELECT zxlsb.zxbhzd as zxbhzd '�о����ı��',zxlsb.dw as dw '�о���������' ,COALESCE(subjectview.jlcount,0) as jlcount '������ɸѡ��',
COALESCE(subjectview.sbcount,0) as sbcount 'ɸѡʧ����',COALESCE(subjectview.rzcount+subjectview.dsucount,0) as rzcount '������������',
COALESCE(SAEView.saesubjcount,0) as saesubject 'SAE��������',COALESCE(SAEView.saecount,0) as saecount 'SAE����',
COALESCE(done.donecount,0) as donecount '�����߽���������',
COALESCE(subjectview.dsucount,0) as dsucount '����������ֹ��',
COALESCE(qsvisitview.qsvisit,0) as qsvisit '�����߷���ȱʧ��',COALESCE(qscrf.qscrf,0) as qscrf '����������ȱʧҳ��',COALESCE(zsview.zs,0) as zs '�ܼ�¼ҳ��',COALESCE(input(zsview.zs1,best.),0) as zs1 'δ�ύҳ��',
COALESCE(round(input(zsview.zs1,best.)/zsview.zs*100,0.01),0) as zsq "δ�ύ�ٷ���(%)",COALESCE(sdvnum.sdvnum,0) as sdvnum 'δSDV�ֶ���',COALESCE(sdvnum.sdvrate,0) as sdvrate "δSDV�ֶΰٷ���(%)",
COALESCE(dmnum.dmnum,0) as dmnum 'DMδ�˲��ֶ���',
COALESCE(dmnum.dmznum,0) as dmznum 'DM��˲��ֶ���',
COALESCE(dmnum.dmrate,0) as dmrate "DMδ�˲��ֶΰٷ���(%)",
COALESCE(mednum.mednum,0) as mednum 'MEDδ�˲��ֶ���',
COALESCE(mednum.medznum,0) as medznum 'MED��˲��ֶ���',
COALESCE(mednum.medrate,0) as medrate "MEDδ�˲��ֶΰٷ���(%)",



COALESCE(zynum.zynum,0) as zynum '��������',COALESCE(zynum.zynum1,0) as zynum1 'δ�ظ�������',COALESCE(round(zynum.zynum1/zynum.zynum*100,0.1),0) as zyrate "δ�ظ�������(%)",
COALESCE(pisubjview.pin,0) as pi1 '����ǩ����������',COALESCE(round(pisubjview.pin/pisubjview.pis*100,0.1),0) as pirate "����ǩ����������(%)" FROM EDC.zxlsb zxlsb 
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

data out.l1(label='EDC��չ����'); set EDC.EDC_metrics; run;
