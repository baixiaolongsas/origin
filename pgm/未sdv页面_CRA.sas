/**/
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/


/*sql ���;*/

proc sql;
create table EDC.unsdv_CRA as 
select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
put(subject.status,$SUBJECT8.) as status '����״̬',
/*subject.icfdat as icfdat FORMAT=YYMMDD10.,*/
COALESCE(visittable.visitname,visittable1.visitname) as f1 '���ӽ׶�',
/*put(COALESCE(sv.visdat,input(ae.aestdat,yymmdd10.),input(cm.cmstdat,yymmdd10.)),yymmdd10.) as visdat '��������/��ʼ����',*/
hchzb.fs as fs,
hchzb.tid as tid,
COALESCE(ae.sn,cm.sn,mh.sn,mha.sn
/*,ad.sn*/
) as sn '���',
COALESCE(visittable.dmname,hchzb.bmc)  as dmname '������', 
visittable1.dmname as dmname1 '��������', 
hchzb.yhczdsly as yhczdsly '�Ѻ˲��ֶ���',
hchzb.xhczdzsl as xhczdzsl '��˲��ֶ���',
cats(put(round((hchzb.yhczdsly)/(hchzb.xhczdzsl)*100,1),best.),'%') as hcl1 '�˲���',
'CRA' as loginid,
datepart(spjlb.lastmodifytime) as time FORMAT=YYMMDD10.,
today()-datepart(spjlb.lastmodifytime) as time1 '�������'
/*hchzb.svnum as svnum,*/
/*hchzb.jl as jl,*/
/*hchzb.ejzbfjl as ejzbfjl,*/
/*spjlb.dqzt as dqzt,*/
from EDC.hchzb_total hchzb
left join Derived.subject subject on input(subject.pub_rid,best.)=COALESCE(input(hchzb.f3,best.),hchzb.jl) 
left join EDC.visittable visittable on hchzb.fs=visittable.visitid and  visittable.svnum=hchzb.svnum and hchzb.ejzbfjl is null 
left join EDC.visittable visittable1 on hchzb.fs=visittable1.visitid and  visittable1.svnum=hchzb.svnum and hchzb.ejzbfjl is not null 
left join EDC.spjlb spjlb on input(spjlb.jl,best.)=COALESCE(hchzb.jl,input(hchzb.ejzbfjl,best.)) and spjlb.dqzt ^='00'
left join Derived.sv sv on sv.subjid=subject.subjid and sv.visit = visittable.visitid
left join Derived.ae ae on input(ae.pub_rid,best.)=hchzb.jl 
left join Derived.cm cm on input(cm.pub_rid,best.)=hchzb.jl
left join Derived.rand rand1 on rand1.subjid=subject.subjid 
left join Derived.mh mh on input(mh.pub_rid,best.)=hchzb.jl 
left join Derived.mha mha on input(mha.pub_rid,best.)=hchzb.jl 
/*left join Derived.add ad on add.pub_rid=hchzb.jl*/ 
where   hchzb.xhczdzsl > hchzb.yhczdsly
and (spjlb.lastmodifytime is not null or  (hchzb.tid='subject' and (subject.lockstat ^='00' or subject.lockstat is not null)) )
order by subject.subjid,hchzb.fs,hchzb.tid,sn
;
quit;

data out.L4(label='CRAδ�˲�ҳ��ϸ');
set EDC.unsdv_CRA;
run;
