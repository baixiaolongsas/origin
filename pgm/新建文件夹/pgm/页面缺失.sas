/*soh**********************************************************************************
CODE NAME                 : <页面缺失>
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
01		Shishuo				2018-04-11
**eoh**********************************************************************************/;

/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/


proc sql;

create table dp.crfmiss as 

select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
visittable.f1 as f1,
visittable.dmname as dmname,
'' as svstdat '访视日期','' as time,
'否' as ynt '是否填写' from dc.subject subject 
left join dp.visittable visittable on subject.studyid=visittable.studyid and visittable.visitid = '27' 
left join dp.hchzb hchzb on subject.pub_rid=hchzb.f3 and input(visittable.visitid,best.)=hchzb.fs and visittable.domain=hchzb.tid  and visittable.svnum=hchzb.svnum 
left join dc.ds ds on subject.pub_rid=input(ds.subject_ref_field,best.) 
left join dc.uncollect uncollect on input(uncollect.recordid,best.) = subject.pub_rid and uncollect.visitnum=visittable.visitid and uncollect.tableid= visittable.domain 
and visittable.svnum=input(uncollect.svnum,best.)
left join dp.VisitWCCrfView VisitWCCrfView on VisitWCCrfView.subjid=subject.subjid and VisitWCCrfView.bm=27
where hchzb.tid is null and (uncollect.status is null or  uncollect.status ='2')  and ds.subjid is not null  
and VisitWCCrfView.crfnum >0



union 



select subject.studyid as studyid,
subject.siteid as siteid,
subject.subjid as subjid,
visittable.f1 as f1,
visittable.dmname as dmname,
put(sv.visdat,yymmdd10.) as svstdat '访视日期',
put((today()-sv.visdat-15),best.) as time '页面缺失距今天天数',
'否' as ynt '是否填写' from dc.subject subject
left join dp.visittable visittable on visittable.studyid=subject.studyid 
left join dc.sv sv on input(sv.subject_ref_field,best.)=subject.pub_rid and sv.visit=visittable.visitid 
left join dc.sv sv1 on subject.pub_rid=input(sv1.subject_ref_field,best.) and input(sv1.visit,best.)-1=input(visittable.visitid,best.)
left join dp.hchzb hchzb on hchzb.f3=subject.pub_rid and hchzb.tid=visittable.domain and hchzb.fs=input(visittable.visitid,best.) and hchzb.svnum=visittable.svnum
left join dc.uncollect uncollect on  input(uncollect.recordid,best.) = subject.pub_rid and uncollect.tableid=visittable.domain and uncollect.visitnum=visittable.visitid 
and visittable.svnum=input(uncollect.svnum,best.)
left join dp.VisitWCCrfView VisitWCCrfView on VisitWCCrfView.subjid=subject.subjid and VisitWCCrfView.bm=input(visittable.visitid,best.)


where subject.status ^= '5' and VisitWCCrfView.crfnum > 0 and  

(( (today()-sv.visdat) > 15 and hchzb.tid is null and (uncollect.status is null or  uncollect.status ='2') )
   or(sv1.visitnum is not null and sv.visitnum is not null and hchzb.tid is null and (uncollect.status is null or  uncollect.status ='2')  ))

;

quit;


proc sql;
create table dp.qscrfview as
select qscrfview.siteid as siteid,
count(*) as qscrf from dp.crfmiss qscrfview group by qscrfview.siteid
;
quit;


