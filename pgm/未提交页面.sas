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




proc sql;
create table EDC.unsub as 
select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
/*put(subject.status,$SUBJECT8.) as status '入组状态',*/
/*subject.icfdat as icfdat FORMAT=YYMMDD10.,*/
COALESCE(visittable.visitname,visittable1.visitname) as f1 '访视阶段',
hchzb.fs as fs,
hchzb.tid as tid,
COALESCE(ae.sn,cm.sn,mh.sn,mha.sn) as sn '序号',
COALESCE(visittable.dmname,hchzb.bmc)  as dmname '表名称', 
visittable1.dmname as dmname1 '父表名称', 
datepart(spjlb.lastmodifytime) as time FORMAT=YYMMDD10.,
today()-datepart(spjlb.lastmodifytime) as time1 '距今天数'
/*,*/
/*hchzb.svnum as svnum,*/
/*hchzb.jl as jl,*/
/*hchzb.ejzbfjl as ejzbfjl,*/
/*spjlb.dqzt as dqzt*/
from EDC.hchzb_total hchzb
left join  derived.subject subject on input(subject.pub_rid,best.)=COALESCE(input(hchzb.f3,best.),hchzb.jl) 
left join EDC.visittable visittable on hchzb.fs=visittable.visitid and  visittable.svnum=hchzb.svnum and hchzb.ejzbfjl is null 
left join EDC.visittable visittable1 on hchzb.fs=visittable1.visitid  and  visittable1.svnum=hchzb.svnum and hchzb.ejzbfjl is not null 
left join EDC.spjlb spjlb on input(spjlb.jl,best.)=COALESCE(hchzb.jl,input(hchzb.ejzbfjl,best.)) and spjlb.dqzt ='00'
left join derived.sv sv on sv.subjid=subject.subjid and sv.visit = visittable.visitid
left join derived.ae ae on input(ae.pub_rid,best.)=hchzb.jl 
left join derived.cm cm on input(cm.pub_rid,best.)=hchzb.jl 
left join derived.rand rand1 on rand1.subjid=subject.subjid 
left join derived.mh mh on  input(mh.pub_rid,best.)=hchzb.jl 
left join Derived.mha mha on input(mha.pub_rid,best.)=hchzb.jl 

where spjlb.dqzt = '00' 
order by subject.subjid,hchzb.fs,hchzb.tid
;
quit;

data out.L5(label='未提交页面汇总');
set EDC.unsub;
run;
