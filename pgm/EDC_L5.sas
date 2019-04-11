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
%let specialvisit='计划外访视','妊娠记录';
%let ds1=ds1;/*治疗结束页名称，是否有项目会有多个治疗结束页，需要确定用哪个*/
%let novisdat='共同页','安全性随访','交叉入组筛选','生存随访','研究总结页','治疗结束页','治疗完成_退出'; /*有的项目不统计计划外*/



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
/*固定访视窗*/
data sfzqb;
	set edc.sfzqb(keep=subjid open close bm);
	visitid=bm;
	drop bm;
run;

proc sort data=sfzqb;by subjid visitid;run;


/*************************    将双盲期和开放期是分开计算访视缺失    *******************************/
proc freq data=subject_visit_crfnum; table visitname; run;

data subject_sfzqb;
	merge subject_visit_crfnum(in=a) sfzqb;
	by subjid visitid;
	if a;
run;
/*剔除特殊访视*/
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
	if compress(&visit.) in ('治疗完成_退出' '研究总结页');

	label &visdat.='退出前访视日期';
	keep subjid &visdat.;
run;
proc sort;by subjid;run;

/************************************无dth数据集*****************************************************/
/*双盲期治疗结束日期*/
data ds1;
	set derived.Eot_otoz;
	keep subjid eotdat;
	where eotcat='SHR1210/安慰剂';
run;
proc sort;by subjid;run;
/*C1SD1 SHR1210给药日期*/
data ex;
  set derived.Exi_otoz;
  keep subjid exstdat;
  if visit='C1SD1';
run;
proc sort;by subjid;run;
/*开放期治疗结束日期*/
data ds2;
	set derived.Eot_otoz;
	keep subjid eotdat;
	where eotcat='SHR1210';
run;
proc sort;by subjid;run;
/*安全性随访*/
data sv_safe;
	set sv;
	if compress(&visit.) ='安全性随访';
	label &visdat.='安全性随访日期';
	keep subjid &visdat.;
run;
proc sort;by subjid;run;

data ds;
	set derived.ds;
	keep subjid dthdat dsterm;
run;
proc sort;by subjid;run;

/**/
/*data dth;*/
/*	set derived.dth;*/
/*	keep subjid dthdat;*/
/*proc sort;by subjid;run;*/

/*data sv_last_ds1_ds;*/
/*	merge sv_last ds1 ds dth;*/
/*	by subjid;*/
/*run;*/

data sv_last_ds1_ds1;
	merge sv_last  ds ds1;
	by subjid;
run;
data sv_last_ds1_ds2;
	merge sv_last ex ds ds2 ;
	by subjid;
run;

/*data lastdat;*/
/*	set sv_last_ds1_ds;*/
/*	lastdat=min(input(lasexdat,yymmdd10.),input(&visdat.,yymmdd10.),input(dsdat,yymmdd10.),input(dthdat,yymmdd10.));*/
/*	format lastdat yymmdd10.;*/
/*	label lastdat='最小退出/给药日期';*/
/*	keep subjid lastdat;*/
/*run;*/
data lastdat1;
	set sv_last_ds1_ds1;
	lastdat1=min(input(&visdat.,yymmdd10.),input(dthdat,yymmdd10.),input(eotdat,yymmdd10.));
	format lastdat1 yymmdd10.;
	label lastdat1='双盲期最小退出/给药日期';
	keep subjid lastdat1 dsterm;
run;
data lastdat2;
	set sv_last_ds1_ds2;
	lastdat=min(input(&visdat.,yymmdd10.),input(dthdat,yymmdd10.),input(eotdat,yymmdd10.));
	if exstdat='' then lastdat2=.;
	else if exstdat ne '' and lastdat < input(exstdat,yymmdd10.) then lastdat2=.;
	else if exstdat ne '' and lastdat > input(exstdat,yymmdd10.) then lastdat2=lastdat;
	format lastdat2 yymmdd10.;
	label lastdat2='开放期最小退出/给药日期';
	keep subjid lastdat2 eotdat dsterm;
run;
/************************************无dth数据集*****************************************************/

/*判断访视缺失*/
proc sort data=subject_sv_svworkflow;by subjid;run;
data prefinal;
	merge subject_sv_svworkflow lastdat1 lastdat2 sv_safe;
	by subjid;
	if visitname not in (&novisdat.) then do;
	  if find(visitname,'S') ne 0 or visitname='开放期肿瘤影像学' then lastdat=lastdat2;
	  else if find(visitname,'S')=0 or visitname='双盲期肿瘤影像学' or  visitname= '筛选期' then lastdat=lastdat1;      
	end;
	if eotdat ne '' or visdat ne '' or dsterm ne '' then finish='治疗完成_退出访视缺失'; else finish='';
	label lastdat='最小退出/给药日期';
	drop lastdat1 lastdat2;
run;


data prefinal_1 prefinal_2;
	set prefinal;
	if visitname in (&novisdat.) then output prefinal_1;
	else output prefinal_2;
run;

data prefinal_1_1;
	set prefinal_1;
	if visitname in ('共同页','安全性随访','生存随访','治疗结束页') and dsterm ne '' and crfnum1=. then output;
    if visitname='治疗完成_退出' and finish ne '' and crfnum1=. then output;
run;

/*prefinal_2_1双盲期   prefinal_2_2开放期*/
data prefinal_2_1 prefinal_2_2;
   set prefinal_2;
   if find(visitname,'S') ne 0 or visitname='开放期肿瘤影像学' then output prefinal_2_2;
   else output prefinal_2_1;
run;

/*双盲期判断*/
data prefinal_2_1;
	set prefinal_2_1;
	visitnum=input(visitid,best.);
run;
proc sort data=prefinal_2_1 ;by subjid descending visitnum;run;
data prefinal1;
	set prefinal_2_1(where=(lastdat>close or lastdat=.));
	visdat_=lag(&visdat.);
	by subjid descending visitnum;
	if first.subjid then visdat_='';
	if (visdat_ ne '' or (close ne . and  today()-close >=15)) and crfnum1 = .;
run;
proc sort ;by subjid visitnum;run;

/*开放期判断*/
data prefinal_2_2;
	set prefinal_2_2;
	visitnum=input(visitid,best.);
run;
proc sort data=prefinal_2_2 ;by subjid descending visitnum;run;
data prefinal2;
	set prefinal_2_2;
	visdat_=lag(&visdat.);
	by subjid descending visitnum;
	if first.subjid then visdat_='';
	if (visdat_ ne '') and crfnum1 = .;
/*	if (visdat_ ne '' or (close ne . and  today()-close >=15)) and crfnum1 = .;*/
run;
proc sort ;by subjid visitnum;run;
  





data edc.visitmiss;
	retain studyid siteid subjid status visitname visitnum visitid open close day;
	set prefinal1 prefinal2 prefinal_1_1;
	if ^missing(open)  then 
	day=today()-open;
	else day=.;
	visitnum=input(visitid,best.);
	keep studyid siteid subjid status visitname visitnum visitid open close day;
	label day ='访视缺失据今天数';
run;
proc sort data=edc.visitmiss;by subjid visitnum;run;


proc sql;
create table EDC.qsvisitview as
select qssubjectview.siteid as siteid,
count(*) as qsvisit '访视缺失数' from EDC.visitmiss qssubjectview 
group by siteid;

quit;

data out.l2(label='访视缺失汇总'); set edc.visitmiss; run;

/*ods listing close; /*不在output和graph窗口显示结果*/*/
/*ods RESULTS off;  /*不弹出结果*/*/
/*ods html close;  /*不生成html文件*/*/
/*ods escapechar='^';*/
/*ods excel file="&root.\output\&study._访视缺失.xlsx" options(sheet_name="访视缺失"  contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;*/
/*ods excel options(embedded_titles='no' embedded_footnotes='no');*/
/*Options   nodate nonumber nocenter;*/
/*options nonotes;*/
/*OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; */
/*proc report data=edc.visitmiss nowd ;*/
/*     column _all_;*/
/*	 define siteid / style( column )={tagattr='type:text'};*/
/*	 define subjid / style( column )={tagattr='type:text'};*/
/* run;*/
/*ods excel close;*/
/*ods listing;*/
