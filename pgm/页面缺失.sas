/*soh**********************************************************************************
CODE NAME                 : <L_>
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


proc sql;

create table EDC.crfmiss as 

select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
visittable.visitname as f1,
visittable.dmname as dmname,
'' as svstdat '访视日期',
'' as time,
'否' as ynt '是否填写' from derived.subject subject 
left join EDC.visittable visittable on subject.studyid=visittable.studyid and visittable.visitid = '14' 
left join EDC.hchzb hchzb on input(subject.pub_rid,best.)=input(hchzb.fzbdrkbjl,best.) and visittable.visitid=hchzb.fs and visittable.domain=hchzb.tid  and visittable.svnum=hchzb.svnum 
left join derived.ds ds on input(subject.pub_rid,best.)=input(ds.subject_ref_field,best.) 
left join derived.uncollect uncollect on input(uncollect.recordid,best.) = input(subject.pub_rid,best.) and uncollect.visitnum=visittable.visitid and uncollect.tableid= visittable.domain 
and visittable.svnum=uncollect.svnum
left join EDC.VisitWCCrfView VisitWCCrfView on VisitWCCrfView.subjid=subject.subjid and VisitWCCrfView.bm='14'
where hchzb.tid is null 
and uncollect.tableid is null 
and ds.subjid is not null  
and VisitWCCrfView.crfnum >0


union all

select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
visittable.visitname as f1,
visittable.dmname as dmname,
'' as svstdat '访视日期',
'' as time,
'否' as ynt '是否填写' from derived.subject subject 
left join EDC.visittable visittable on subject.studyid=visittable.studyid and visittable.visitid = '15' 
left join EDC.hchzb hchzb on input(subject.pub_rid,best.)=input(hchzb.fzbdrkbjl,best.) and visittable.visitid=hchzb.fs and visittable.domain=hchzb.tid  and visittable.svnum=hchzb.svnum 
left join derived.ds ds on input(subject.pub_rid,best.)=input(ds.subject_ref_field,best.) 
left join derived.uncollect uncollect on input(uncollect.recordid,best.) = input(subject.pub_rid,best.) and uncollect.visitnum=visittable.visitid and uncollect.tableid= visittable.domain 
and visittable.svnum=uncollect.svnum
left join EDC.VisitWCCrfView VisitWCCrfView on VisitWCCrfView.subjid=subject.subjid and VisitWCCrfView.bm='15'
where hchzb.tid is null 
and uncollect.tableid is null 
and ds.subjid is not null  
and VisitWCCrfView.crfnum >0


union 



select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
visittable.visitname as f1,
visittable.dmname as dmname,
sv.visdat as svstdat '访视日期',
put((today()-input(sv.visdat,YYMMDD10.)-15),best.) as time '页面缺失距今天天数',
'否' as ynt '是否填写' from derived.subject subject
left join EDC.visittable visittable on visittable.studyid=subject.studyid and visittable.visitid ^='13'
left join derived.sv sv on sv.subjid=subject.subjid and sv.visitnum=visittable.visitid 
left join derived.sv sv1 on input(subject.pub_rid,best.)=input(sv1.subject_ref_field,best.) and input(sv1.visitnum,best.)-1=input(visittable.visitid,best.)
left join EDC.hchzb hchzb on input(hchzb.fzbdrkbjl,best.)=input(subject.pub_rid,best.) and hchzb.tid=visittable.domain and hchzb.fs=visittable.visitid and hchzb.svnum=visittable.svnum
left join derived.uncollect uncollect on  input(uncollect.recordid,best.) = input(subject.pub_rid,best.) and uncollect.tableid=visittable.domain and uncollect.visitnum=visittable.visitid and visittable.svnum=uncollect.svnum
left join EDC.VisitWCCrfView VisitWCCrfView on VisitWCCrfView.subjid=subject.subjid and VisitWCCrfView.bm=visittable.visitid


where (subject.status ^= '5' ) and VisitWCCrfView.crfnum > 0 
and uncollect.tableid is null
and 
(( (today()-input(sv.visdat,YYMMDD10.)) > 15 and hchzb.tid is null )
   or(sv1.visitnum is not null and sv.visitnum is not null and hchzb.tid is null ))

order by subjid,f1,dmname
;
quit;


proc sql;
create table EDC.qscrfview as
select qscrfview.siteid as siteid,
count(*) as qscrf from EDC.crfmiss qscrfview group by qscrfview.siteid
;
quit;


data out.L3(label='页面缺失汇总');
set EDC.crfmiss;
run;
