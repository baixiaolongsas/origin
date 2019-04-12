/*soh**********************************************************************************
CODE NAME                 : <访视缺失>
CODE TYPE                 : <listing >
DESCRIPTION               : <> 
SOFTWARE/VERSION#         : <SAS 9.4>
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
 Author & shis
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Shishuo				2018-07-09
**eoh**********************************************************************************/;

/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/

data uncollect;
set derived.Uncollect(keep =recordid_subjid visitnum svnum tableid status lastmodifytime);
proc sort data=uncollect;
by recordid_subjid visitnum svnum lastmodifytime;
run;

data uncollect1;
set uncollect;
by recordid_subjid visitnum svnum lastmodifytime;
if last.svnum then output;
run;

data uncollect2;
set uncollect1;
if status eq '已确认';
run;

proc sql;
create table EDC.uncol_sum as
select Uncollect.recordid_subjid as subjid,
Uncollect.visitnum as visitnum,
count(*) as unnum '未采集记录数' from uncollect2 Uncollect 
group by Uncollect.recordid_subjid,Uncollect.visitnum
;

create table EDC.uncol_vit as
select uncol_sum.subjid as subjid,
uncol_sum.visitnum as visitnum,
uncol_sum.unnum as unnum,
Visit_sum.sv_crf  as crfnum from EDC.uncol_sum uncol_sum 
left join EDC.Visit_sum Visit_sum on  Visit_sum.visitid=uncol_sum.visitnum
where uncol_sum.unnum=Visit_sum.sv_crf
order by subjid,visitnum
;
quit;

proc sql;
create table EDC.visitmiss as 


select subject.studyid as studyid ,
subject.siteid as siteid,
subject.subjid as subjid,
visit_sum.f1 as svstage,
. as open format=yymmdd10.,
. as close format=yymmdd10.,
. as time from derived.subject subject 
left join EDC.visit_sum visit_sum on subject.studyid=visit_sum.studyid 
left join EDC.VisitWCCrfView VisitWCCrfView2 on VisitWCCrfView2.subjid=subject.subjid and VisitWCCrfView2.bm=visit_sum.visitid 
left join EDC.VisitWCCrfView VisitWCCrfView11 on VisitWCCrfView11.subjid=subject.subjid and VisitWCCrfView11.bm='16'
/*left join EDC.sv_workflow sv_workflow on sv_workflow.jlid = sfzqb.subjid and sv_workflow.fsxh = sfzqb.bm */
left join EDC.Uncol_vit Uncol_vit on Uncol_vit.subjid = subject.subjid and Uncol_vit.visitnum = visit_sum.visitid  

where VisitWCCrfView11.crfnum is not null and Uncol_vit.subjid is null and 
( visit_sum.visitid='10' and VisitWCCrfView2.crfnum is null
or visit_sum.visitid='11' and VisitWCCrfView2.crfnum is null
or visit_sum.visitid='14' and VisitWCCrfView2.crfnum is null
or visit_sum.visitid='15' and VisitWCCrfView2.crfnum is null) 

union 

select sfzqb.studyid  as studyid ,
sfzqb.siteid as siteid,
sfzqb.subjid as subjid,
sfzqb.mc as svstage,
sfzqb.open as open format=yymmdd10.,
sfzqb.close as close format=yymmdd10.,
today()-sfzqb.close-15 as time '访视缺失距今天天数' from EDC.sfzqb sfzqb 
/*left join derived.rand rand on sfzqb.subjid=rand.subjid */
left join derived.subject subject on sfzqb.subjid=subject.subjid 
left join derived.ds ds on sfzqb.subjid=ds.subjid 
left join derived.dth dth on sfzqb.subjid=dth.subjid 
left join derived.ds1 ds1 on sfzqb.subjid=ds1.subjid 
left join EDC.VisitWCCrfView VisitWCCrfView on sfzqb.siteid = VisitWCCrfView.siteid and sfzqb.subjid = VisitWCCrfView.subjid and sfzqb.mc = VisitWCCrfView.mc 
left join EDC.VisitWCCrfView VisitWCCrfView1 on sfzqb.siteid = VisitWCCrfView1.siteid and sfzqb.subjid = VisitWCCrfView1.subjid and input(sfzqb.bm,best.) = input(VisitWCCrfView1.bm,best.)-1 
left join EDC.sv_workflow sv_workflow on sv_workflow.jlid = sfzqb.subject and sv_workflow.fsxh = sfzqb.mc 
left join derived.sv sv on sv.subjid=sfzqb.subjid and sv.visitnum='10'
left join EDC.Uncol_vit Uncol_vit on Uncol_vit.subjid = subject.subjid and Uncol_vit.visitnum = sfzqb.bm  


where subject.status ne '筛选失败'   and  Uncol_vit.subjid is null and
sv_workflow.lockstat ne '未提交' and
(
((sfzqb.close<input(ds1.lasexdat,YYMMDD10.) or ds1.lasexdat is null or sfzqb.close is null) and  
(sfzqb.close<input(ds.statdat,YYMMDD10.) or ds.statdat is null or sfzqb.close is null) and  
(sv.visdat is null or sfzqb.close is null or sfzqb.close<input(sv.visdat,YYMMDD10.))) and 

(today()-sfzqb.close-15>0 and VisitWCCrfView.crfnum is null 
	or (VisitWCCrfView1.crfnum is not null and VisitWCCrfView.crfnum is null and sfzqb.close is not null )) 

or (sfzqb.bm='10' and VisitWCCrfView.crfnum is null and ds1.lasexdat is not null) 
or (sfzqb.bm='14' and VisitWCCrfView.crfnum is null and ds.status is not null)
or (sfzqb.bm='16' and VisitWCCrfView.crfnum is null and dth.dthdat is not null) 
or (sfzqb.bm='11' and VisitWCCrfView.crfnum is null and sv.visdat is not null) 
or (sfzqb.bm='15' and VisitWCCrfView.crfnum is null and ds.status is not null) 

)
order by subjid,open,svstage;
quit;




proc sql;
create table EDC.qsvisitview as
select qssubjectview.siteid as siteid,
count(qssubjectview.svstage) as qsvisit from EDC.visitmiss qssubjectview 
group by siteid;

quit;


data out.L2(label='访视缺失汇总');
set EDC.visitmiss;
run;
