 /*soh**********************************************************************************
CODE NAME                 : <未提交页面>
CODE TYPE                 : <dc >
DESCRIPTION               : <进展报告未提交crf> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < >
OUTPUT                    : < 进展报告未提交crf.xml >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & shis
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Shishuo	   			2018-06-20
**eoh**********************************************************************************
*****************************************************************************************/





/**/
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/
%let pgmname=unsub;
/*proc printto log="&root.\logout\&pgmname..log" new;run;*/


/*只体现父表*/
/**/
/*proc sql;*/
/*create table dp.unsub as */
/*select  hchzbsubject.studyid as studyid,*/
/*hchzbsubject.siteid as siteid,*/
/*hchzbsubject.subjid as subjid,*/
/*hchzbsubject.mc as visit,*/
/*put(sv.visdat,yymmdd10.) as visdat '访视日期',*/
/*hchzbsubject.bmc as bmc,*/
/*hchzbsubject.tid as tid,*/
/*spjlb.f13 as createtime,*/
/*today()-spjlb.f13 as time '未提交距今天数' from dp.spjlb spjlb */
/*left join dp.hchzbsubject hchzbsubject on COALESCE(hchzbsubject.jl,hchzbsubject.ejzbfjl)=spjlb.jl */
/*left join dc.sv sv on sv.subjid=hchzbsubject.subjid and input(sv.visit,best.) = hchzbsubject.bm*/
/*left join dp.visittable visittable on input(visittable.visitid,best.)=hchzbsubject.bm and visittable.domain=hchzbsubject.mc*/
/*where spjlb.dqzt = '00' and spjlb.sjb ^= 'sv_workflow' and hchzbsubject.subjid ^=''*/
/*order by subjid,hchzbsubject.bm;*/
/*quit;*/


/*父子表都有*/
/**/
/*proc sql;*/
/*create table dp.unsub as */
/**/
/*select  subject.studyid as studyid,*/
/*subject.siteid as siteid,*/
/*subject.subjid as subjid,*/
/*visittable.f1 as visitname,*/
/*hchzb.tid as tid,*/
/*'' as sn '序号',*/
/*hchzb.bmc as bmc,*/
/*visittable.dmname as dmname,*/
/*spjlb.f13 as createtime  FORMAT=YYMMDD10.,*/
/*today()-spjlb.f13 as time '未提交距今天数' from dp.hchzb hchzb */
/*left join dc.subject subject on subject.pub_rid=hchzb.f3 */
/*left join dp.hchzb hchzb1 on hchzb.ejzbfjl=hchzb1.jl and hchzb1.fs=hchzb.fs and subject.pub_rid=hchzb1.f3 and hchzb1.ejzbfjl is null */
/*left join dp.visittable visittable on subject.studyid=visittable.studyid and input(visittable.visitid,best.)=hchzb1.fs and visittable.domain=hchzb1.tid  and visittable.svnum=hchzb1.svnum */
/*left join dp.spjlb spjlb on spjlb.jl=hchzb1.jl  where spjlb.dqzt = '00' */
/**/
/**/
/*union all*/
/**/
/**/
/*select  subject.studyid as studyid,*/
/*subject.siteid as siteid,*/
/*subject.subjid as subjid,*/
/*visittable.f1 as visitname,*/
/*hchzb.tid as tid,*/
/*COALESCE(ae.sn,cm.sn,pcmr.sn,pcms.sn,rst.sn,rst1.lesionno,rsnt.sn,rsnt1.lesionno,mh.sn,*/
/*pcm.sn,ecog.sn,hcg.sn,ucg.sn,exia.sn,pcmc.sn,ad.sn) as sn,*/
/*visittable.dmname as bmc,*/
/*'' as dmname,*/
/*spjlb.f13 as createtime  FORMAT=YYMMDD10.,*/
/*today()-spjlb.f13 as time '未提交距今天数' from dc.subject subject */
/*left join dp.visittable visittable on subject.studyid=visittable.studyid */
/*left join dp.hchzb hchzb on subject.pub_rid=hchzb.f3 and input(visittable.visitid,best.)=hchzb.fs and visittable.domain=hchzb.tid  and visittable.svnum=hchzb.svnum */
/*left join dp.spjlb spjlb on spjlb.jl=hchzb.jl */
/*left join dc.ae ae on ae.pub_rid=hchzb.jl */
/*left join dc.cm cm on cm.pub_rid=hchzb.jl */
/*left join dc.pcmr pcmr on pcmr.pub_rid=hchzb.jl */
/*left join dc.rand rand1 on rand1.subjid=subject.subjid */
/*left join dc.pcms pcms on pcms.pub_rid=hchzb.jl */
/*left join dc.rst rst on rst.pub_rid=hchzb.jl */
/*left join dc.rst1 rst1 on rst1.pub_rid=hchzb.jl */
/*left join dc.rsnt rsnt on rsnt.pub_rid=hchzb.jl */
/*left join dc.rsnt1 rsnt1 on rsnt1.pub_rid=hchzb.jl */
/*left join dc.mh mh on mh.pub_rid=hchzb.jl */
/*left join dc.pcm pcm on pcm.pub_rid=hchzb.jl */
/*left join dc.pcmc pcmc on pcmc.pub_rid=hchzb.jl */
/*left join dc.ecog ecog on ecog.pub_rid=hchzb.jl */
/*left join dc.hcg hcg on hcg.pub_rid=hchzb.jl */
/*left join dc.ucg ucg on ucg.pub_rid=hchzb.jl */
/*left join dc.exia exia on exia.pub_rid=hchzb.jl */
/*left join dc.add ad on add.pub_rid=hchzb.jl*/
/*where spjlb.dqzt = '00' */
/*order by subjid,tid,sn*/
/*;*/
/*quit;*/




proc sql;
create table dp.unsub as 
select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
/*put(subject.status,$SUBJECT8.) as status '入组状态',*/
/*subject.icfdat as icfdat FORMAT=YYMMDD10.,*/
COALESCE(visittable.f1,visittable1.f1) as f1 '访视阶段',
hchzb.fs as fs,
hchzb.tid as tid,
COALESCE(ae.sn,cm.sn,pcmr.sn,pcms.sn,rst.sn,rst1.lesionno,rsnt.sn,rsnt1.lesionno,mh.sn,
pcm.sn,ecog.sn,hcg.sn,ucg.sn,exia.sn,pcmc.sn,ad.sn) as sn '序号',
COALESCE(visittable.dmname,hchzb.bmc)  as dmname '表名称', 
visittable1.dmname as dmname1 '父表名称', 
spjlb.f13 as time FORMAT=YYMMDD10.,
today()-spjlb.f13 as time1 '距今天数'
/*hchzb.svnum as svnum,*/
/*hchzb.jl as jl,*/
/*hchzb.ejzbfjl as ejzbfjl,*/
/*spjlb.dqzt as dqzt,*/
from dp.hchzb_total hchzb
left join  dc.subject subject on subject.pub_rid=COALESCE(hchzb.f3,hchzb.jl) 
left join dp.visittable visittable on hchzb.fs=input(visittable.visitid,best.) and  visittable.svnum=hchzb.svnum and hchzb.ejzbfjl is null 
left join dp.visittable visittable1 on hchzb.fs=input(visittable1.visitid,best.) and  visittable1.svnum=hchzb.svnum and hchzb.ejzbfjl is not null 
left join dp.spjlb spjlb on spjlb.jl=COALESCE(hchzb.jl,hchzb.ejzbfjl) and spjlb.dqzt ='00'
left join dc.sv sv on sv.subjid=subject.subjid and sv.visit = visittable.visitid
left join dc.ae ae on ae.pub_rid=hchzb.jl 
left join dc.cm cm on cm.pub_rid=hchzb.jl 
left join dc.pcmr pcmr on pcmr.pub_rid=hchzb.jl 
left join dc.rand rand1 on rand1.subjid=subject.subjid 
left join dc.pcms pcms on pcms.pub_rid=hchzb.jl 
left join dc.rst rst on rst.pub_rid=hchzb.jl 
left join dc.rst1 rst1 on rst1.pub_rid=hchzb.jl 
left join dc.rsnt rsnt on rsnt.pub_rid=hchzb.jl 
left join dc.rsnt1 rsnt1 on rsnt1.pub_rid=hchzb.jl 
left join dc.mh mh on mh.pub_rid=hchzb.jl 
left join dc.pcm pcm on pcm.pub_rid=hchzb.jl 
left join dc.pcmc pcmc on pcmc.pub_rid=hchzb.jl 
left join dc.ecog ecog on ecog.pub_rid=hchzb.jl 
left join dc.hcg hcg on hcg.pub_rid=hchzb.jl 
left join dc.ucg ucg on ucg.pub_rid=hchzb.jl 
left join dc.exia exia on exia.pub_rid=hchzb.jl 
left join dc.add ad on add.pub_rid=hchzb.jl
where spjlb.dqzt = '00' 
order by subject.subjid,hchzb.fs,hchzb.tid
;
quit;
