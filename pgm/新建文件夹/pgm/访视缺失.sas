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
01		Shishuo				2018-04-18
**eoh**********************************************************************************/;

/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/



proc sql;
create table dp.visitmiss as 

/**/
/*select subject.studyid as studyid ,*/
/*subject.siteid as siteid,*/
/*subject.subjid as subjid,*/
/*visit_sum.f1 as svstage,*/
/*. as open format=yymmdd10.,*/
/*. as close format=yymmdd10.,*/
/*. as time from dc.subject subject */
/*left join dp.visit_sum visit_sum on subject.studyid=visit_sum.studyid */
/*left join dp.VisitWCCrfView VisitWCCrfView2 on VisitWCCrfView2.subjid=subject.subjid and VisitWCCrfView2.bm=input(visit_sum.visitid,best.) */
/*left join dp.VisitWCCrfView VisitWCCrfView11 on VisitWCCrfView11.subjid=subject.subjid and VisitWCCrfView11.bm=17 where VisitWCCrfView11.crfnum is not null and */
/*(visit_sum.visitid='9' and VisitWCCrfView2.crfnum is null  ) */
/**/
/*union */

select sfzqb.studyid  as studyid ,
sfzqb.siteid as siteid,
sfzqb.subjid as subjid,
sfzqb.mc as svstage,
sfzqb.open as open format=yymmdd10.,
sfzqb.close as close format=yymmdd10.,
today()-sfzqb.close-15 as time '访视缺失距今天天数' from dp.sfzqb sfzqb 
left join dc.rand rand on sfzqb.subjid=rand.subjid 
left join dc.ds ds on sfzqb.subjid=ds.subjid 
left join dc.ds1 ds1 on sfzqb.subjid=ds1.subjid 
left join dp.VisitWCCrfView VisitWCCrfView on sfzqb.siteid = VisitWCCrfView.siteid and sfzqb.subjid = VisitWCCrfView.subjid and sfzqb.mc = VisitWCCrfView.mc 
left join dp.VisitWCCrfView VisitWCCrfView1 on sfzqb.siteid = VisitWCCrfView1.siteid and sfzqb.subjid = VisitWCCrfView1.subjid and sfzqb.bm = VisitWCCrfView1.bm-1 
left join dp.sv_workflow sv_workflow on sv_workflow.jlid = sfzqb.subjid and input(sv_workflow.fsxh,best.) = sfzqb.bm 
left join dc.sv sv on sv.subjid=sfzqb.subjid and sv.visitnum='13'


where (rand.status ne '5'  and   rand.status is not  null) and
sv_workflow.lockstat ne '50' and
((sfzqb.close<ds.exendat or ds.exendat is null or sfzqb.close is null) and 
(sv.visdat is null or sfzqb.close is null or sfzqb.close<sv.visdat) and 

(today()-sfzqb.close-15>0 and VisitWCCrfView.crfnum is null 
	or (VisitWCCrfView1.crfnum is not null and VisitWCCrfView.crfnum is null and sfzqb.close is not null)) 


)
order by subjid,open,svstage;
quit;





proc sql;
create table dp.qsvisitview as
select qssubjectview.siteid as siteid,
count(qssubjectview.svstage) as qsvisit from dp.visitmiss qssubjectview 
group by siteid;

quit;




