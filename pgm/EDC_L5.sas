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
%let specialvisit='生存随访','C8后访视';
%let ds1=ds1;/*治疗结束页名称，是否有项目会有多个治疗结束页，需要确定用哪个*/
%let novisdat='共同页','计划外访视','研究治疗结束/退出研究'; /*有的项目不统计计划外*/



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
/**/

/*动态访视窗*/
PROC IMPORT OUT= WORK.sfzqb 
            DATAFILE= "D:\hr_projects\SHR-1210-III-311\doc\SHR-1210-III-311-访视编码_20190402.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="访视编码$"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


proc sql;
	create table sv_sfzqb as 
    select a.subjid, a.visit, input(a.visitnum,best.) as bm, a.&visdat.,
           b._COL3, b._COL4 
    from derived.sv as a left join sfzqb as b on input(a.visitnum,best.)+1=input(b._COL3,best.)
    where substr(visit,1,6) ne '筛选期';
quit;

proc sort;by subjid bm;run;


data sfzqb5;
	set sv_sfzqb;
	if &visdat. ne  ''  then do;
	open=input(&visdat.,yymmdd10.)+18;
	close=input(&visdat.,yymmdd10.)+24;
	end;
	format open close  yymmdd10.;
run;

data sfzqb;
	set sfzqb5(keep=subjid _COL3 open close);
	visitid=_COL3;
	drop _COL3;
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

/************************************ 无退出前访视日期、最后用药时间、死亡日期 up  ********************************************/
/*data sv_last;*/
/*	set sv;*/
/*	if compress(&visit.)='研究治疗结束/退出研究';*/
/**/
/*	label &visdat.='退出前访视日期';*/
/*	keep subjid &visdat.;*/
/*run;*/
/*proc sort;by subjid;run;*/
/**/
/*data ds1;*/
/*	set derived.ds1;*/
/*	keep subjid lasexdat;*/
/*run;*/
/*proc sort;by subjid;run;*/
/**/
/*data ds;*/
/*	set derived.ds;*/
/*	keep subjid dsdat;*/
/*run;*/
/*proc sort;by subjid;run;*/
/**/
/*data dth;*/
/*	set derived.dth;*/
/*	keep subjid dthdat;*/
/*proc sort;by subjid;run;*/
/**/
/*data sv_last_ds1_ds;*/
/*	merge sv_last ds1 ds dth;*/
/*	by subjid;*/
/*run;*/
/**/
/*data lastdat;*/
/*	set sv_last_ds1_ds;*/
/*	lastdat=min(input(lasexdat,yymmdd10.),input(&visdat.,yymmdd10.),input(dsdat,yymmdd10.),input(dthdat,yymmdd10.));*/
/*	format lastdat yymmdd10.;*/
/*	label lastdat='最小退出/给药日期';*/
/*	keep subjid lastdat;*/
/*run;*/

data lastdat; set derived.subject; lastdat=.; keep subjid lastdat; where status='已入组'; run;
proc sort; by subjid;run;
/************************************ 无退出前访视日期、最后用药时间、死亡日期 down  ********************************************/

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
/*	if &visdat. ne '' then visdat_=lag(&visdat.);*/
	visdat_=lag(&visdat.);
	by subjid descending visitnum;
	if first.subjid then visdat_='';
	if (visdat_ ne '' or (close ne . and  today()-close >=15)) and crfnum1 = .;
run;

proc sort ;by subjid visitnum;run;






data edc.visitmiss;
	retain studyid siteid subjid status visitname visitnum visitid open close day;
	set prefinal_2_2 prefinal_1_1;
	if ^missing(open)  then 
	day=today()-open;
	else day=.;
	visitnum=input(visitid,best.);
	keep studyid siteid subjid status visitname visitnum visitid open close day;
	label day ='访视缺失据今天数';
run;
proc sort data=edc.visitmiss;by subjid visitname;run;


proc sql;
create table EDC.qsvisitview as
select qssubjectview.siteid as siteid,
count(*) as qsvisit '访视缺失数' from EDC.visitmiss qssubjectview 
group by siteid;

quit;

data out.l2(label='访视缺失汇总'); set edc.visitmiss; run;
