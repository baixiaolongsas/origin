 /*soh**********************************************************************************
CODE NAME                 : <访视缺失>
CODE TYPE                 : <dc >
DESCRIPTION               : <进展报告访视缺失> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < >
OUTPUT                    : <visitfmiss.sas7dbat>
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
/**//**//**/

%let visit=visit;/*访视阶段的变量名，是否有的项目的该变量名为svstage？*/
%let visitnum=visitnum; /*访视序号的变量名，是否有的项目的该变量名为其他的？*/
%let visdat=visdat;/*访视日期的变量名，是否有的项目叫svstdat？*/
%let specialvisit='计划外访视','生存随访','安全性随访1','安全性随访2','肿瘤进展随访','妊娠记录';
%let ds1=eot;/*治疗结束页名称，是否有项目会有多个治疗结束页，需要确定用哪个*/
%let novisdat='共同页','终止/退出治疗','研究治疗结束'; /*有的项目不统计计划外*/




data subject;
	set derived.subject(keep=pub_rid subjid status studyid siteid);
run;

proc sql;
	/*每个访视需要进行多少个模块*/
	create table visitsum as select distinct visitname,visitid,count(*) as crfnum '访视内crf总数量' from edc.visittable  group by visitname;
	/*每个访视已经进行了多个模块*/
	create table VisitWCCrfView as select distinct fzbdrkbjl as pub_rid,fs as visitid,count(*) as crfnum1 '访视内已进行crf数量' from edc.hchzb(where=(ejzbfjl='')) group by fzbdrkbjl,fs;
	/*利用受试者信息表与访视报告编码构建 构建总表*/
	create table subject_visitsum as select a.*,b.* from subject as a full join visitsum as b on 1=1;
	alter table work.subject_visitsum
 	 modify pub_rid char(20) format=$20.;
quit;
proc sort data=subject_visitsum;by pub_rid visitid;run;
proc sort data=VisitWCCrfView;by pub_rid visitid;run;

data subject_visit_crfnum;
	merge subject_visitsum(in=a) VisitWCCrfView;
	by pub_rid visitid;
	if a ;
run;
proc sort data=subject_visit_crfnum;by subjid visitid;run;

/*对于动态访视重新计算时间窗，对于非动态访视直接用sfzqb*/
/*主要修改此处*/
/**/
/**/
/**/
/*固定访视窗*/
/*data sfzqb;*/
/*	set edc.sfzqb(keep=subjid open close bm);*/
/*	visitid=bm;*/
/*	drop bm;*/
/*run;*/


/*动态访视窗*/
/*proc sql;*/
/*	create table sv_sfzqb(drop=bm rename=(bm_1=bm)) as select b.&visdat.,a.*,input(bm,best.) as bm_1 from edc.sfzqb as a left join derived.sv as b on a.subjid=b.subjid and a.bm=b.&visitnum.;*/
/*quit;*/
/**/
/**/
/*proc sort;by subjid bm;run;*/
/*data sfzqb2;*/
/*	length dat 8.;*/
/*	set sv_sfzqb;*/
/*	if bm=>3 and open ne . then */
/*	dat=lag(input(&visdat.,yymmdd10.));*/
/*	*/
/*	if bm=3 then dat = .;*/
/**/
/**/
/*	format dat  yymmdd10.;*/
/*run;*/
/**/
/*proc sql;*/
/*	create table sfzqb2_1 as select distinct subjid,max(dat) as dat2,max(bm) as bm2 from sfzqb2 where dat ne . group by subjid;*/
/*	create table sfzqb3 as select a.*,dat2 format yymmdd10.,bm2 from sfzqb2 as a left join sfzqb2_1 as b on a.subjid =b.subjid;*/
/*quit;*/
/*proc sort;by subjid bm;run;*/
/**/
/*data sfzqb4;*/
/*	length dat3 8.;*/
/**/
/*	set sfzqb3;*/
/*	*/
/*	if open ne .  then dat3=dat2+14*abs(bm-bm2);*/
/*	format dat3 yymmdd10.;*/
/*run;*/
/**/
/**/
/**/
/*data sfzqb5;*/
/**/
/*	set sfzqb4;*/
/*	if &visdat. = '' and dat =. then*/
/*	dat=dat3;*/
/*	if dat ne . then do;*/
/*	open1=dat+11;*/
/*	close1=dat+17;*/
/*	end;*/
/**/
/*	if open ne . and open1 ne . then  open =open1 ;*/
/*	if open ne . and open1 ne . then  close =close1 ;*/
/*	format open1 close1 dat  yymmdd10.;*/
/*run;*/
/**/
/**/
/**/
/*data sfzqb;*/
/*	set sfzqb5(keep=subjid bm open close);*/
/*	visitid=left(put(bm,best.));*/
/*	drop bm;*/
/*	if open ne . and close ne .;*/
/*run;*/




/*动态访视窗*/
data sfzqb;
  set edc.sfzqb11;
  run;



proc sort data=sfzqb;by subjid visitid;run;



data subject_sfzqb;
	merge subject_visit_crfnum(in=a) sfzqb;
	by subjid visitid;
	if a;
run;
/*剔除循环访视*/
data subject_sfzqb_select;
	set subject_sfzqb;
	if visitname not in (&specialvisit.);
run;
data sv;
	set derived.sv;
	keep subjid &visit. &visdat.;
run;

proc sql;
	create table subject_sv as select a.*,b.&visdat. from subject_sfzqb_select as a left join sv as b on a.subjid=b.subjid and a.visitname=b.&visit.;
quit;
/*找到未采集访视并剔除*/
data sv_workflow;
	set edc.sv_workflow(keep=jlid fsxh lockstat);
	pub_rid=jlid;
	visitid=fsxh;
	if lockstat='50';
	keep pub_rid visitid lockstat;
run;
proc sort data=sv_workflow nodupkeys;by pub_rid visitid;run;
proc sort data=subject_sv;by pub_rid visitid;run;
data subject_sv_svworkflow;
	merge subject_sv(in=a) sv_workflow(in=b);
	by pub_rid visitid;
	if a and ^b;
run;
/*找到患者的治疗结束访视以及最后用药时间,如果有人没有用药就用研究结束日期，或者死亡日期，之中选一个最小的  */
/*																									*/
/*					此处应按项目修改																	*/
/*																									*/
data sv_last;
	set sv;
	if compress(&visit.)='终止/退出治疗';

	label &visdat.='退出前访视日期';
	keep subjid &visdat.;
run;
proc sort;by subjid;run;

data ds1;
	set derived.eot;
	keep subjid eotdat;
run;
proc sort;by subjid;run;

data ds;
	set derived.ds;
	keep subjid dsstdat dthdat;
run;
proc sort;by subjid;run;

/*data dth;*/
/*	set derived.dth;*/
/*	keep subjid dthdat;*/
/*proc sort;by subjid;run;*/

data sv_last_ds1_ds;
	merge sv_last ds1 ds;
	by subjid;
run;

data lastdat;
	set sv_last_ds1_ds;
	lastdat=min(input(eotdat,yymmdd10.),input(&visdat.,yymmdd10.),input(dsstdat,yymmdd10.),input(dthdat,yymmdd10.));

	format lastdat yymmdd10.;
	label lastdat='最小退出/给药日期';
	keep subjid lastdat;
run;
proc sort data=subject_sv_svworkflow;by subjid;run;
data prefinal;
	merge subject_sv_svworkflow lastdat;
	by subjid;
run;


data prefinal_1 prefinal_2;
	set prefinal;
	
	if visitname in (&novisdat.) then output prefinal_1;
	else output prefinal_2;
run;



data prefinal_1_1;
	set prefinal_1;
	if lastdat ne . and crfnum1=.;
run;

data prefinal_2_1;
	set prefinal_2;
	visitnum=input(visitid,best.);
run;
proc sort data=prefinal_2_1 ;by subjid descending visitnum;run;



data prefinal_2_2;
	set prefinal_2_1(where=(lastdat>close or lastdat=.));
	visdat_=lag(&visdat.);
	by subjid descending visitnum;
	if first.subjid then visdat_='';
	if (visdat_ ne '' or (close ne . and  today()-close >=15)) and crfnum1 = .;
  
run;

proc sort ;by subjid visitnum;run;

/*访视连续缺失*/
/*data test;*/
/*	set prefinal_2_1(where=(lastdat>close or lastdat=.));*/
/*	visdat_=lag(&visdat.);*/
/*	by subjid descending visitnum;*/
/*	if first.subjid then visdat_='';*/
/*  */
/*run;*/
/**/
/*data test1;*/
/*  set test;*/
/*  retain bigdat;*/
/*  if visit='' then bigdat=visdat_;*/
/*  else bigdat=min(visdat_,bigdat);*/
/*  run;*/

/*proc sort ;by subjid visitnum;run;*/

data edc.visitmiss;
	retain studyid siteid subjid status visitname visitnum visitid open close day;
	set prefinal_2_2 prefinal_1_1;
	if ^missing(open)  then 
	day=today()-open;
	else day=.;
	visitnum=input(visitid,best.);
	keep studyid siteid subjid status visitname visitnum visitid open close day;
	label day ='访视缺失距今天数';
run;
proc sort data=edc.visitmiss;by subjid visitnum;run;


proc sql;
create table EDC.qsvisitview as
select qssubjectview.siteid as siteid,
count(*) as qsvisit '访视缺失数' from EDC.visitmiss qssubjectview 
group by siteid;

quit;

data out.l2(label='访视缺失汇总'); set edc.visitmiss; run;
