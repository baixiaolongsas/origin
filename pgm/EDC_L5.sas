 /*soh**********************************************************************************
CODE NAME                 : <访视缺失>
CODE TYPE                 : <dc >
DESCRIPTION               : <进展报告访视缺失> 
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
01		 Shishuo			 2018-12-21
**eoh**********************************************************************************
*****************************************************************************************/

/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/
/**//**//**/

%let visit=visit;/*访视阶段的变量名，是否有的项目的该变量名为svstage？*/
%let visitnum=visitnum; /*访视序号的变量名，是否有的项目的该变量名为其他的？*/
%let visdat=visdat;/*访视日期的变量名，是否有的项目叫svstdat？*/
%let specialvisit='生存随访  末次治疗后30天 末次治疗后60天  末次治疗后90天  计划外访视  妊娠报告/随访';
%let ds1=ds;/*治疗结束页名称，是否有项目会有多个治疗结束页，需要确定用哪个*/
%let novisdat='共同页'; /*有的项目不统计计划外*/



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
proc sql;
	create table sv_sfzqb(drop=bm rename=(bm_1=bm)) as select b.exdat,a.*,input(bm,best.) as bm_1 from edc.sfzqb as a left join derived.ex as b on a.subjid=b.subjid and a.bm=b.&visitnum.;
quit;


proc sort;by subjid bm;run;
data sfzqb2;
	length dat 8.;
	set sv_sfzqb;
	if bm=>3 and bm le 36 then 
	dat=lag(input(exdat,yymmdd10.));
	
	if bm=3 then dat = .;


	format dat  yymmdd10.;
run;

proc sql;
	create table sfzqb2_1 as select distinct subjid,max(dat) as dat2,max(bm) as bm2 from sfzqb2 where dat ne . group by subjid;
	create table sfzqb3 as select a.*,dat2 format yymmdd10.,bm2 from sfzqb2 as a left join sfzqb2_1 as b on a.subjid =b.subjid;
quit;
proc sort;by subjid bm;run;

data sfzqb4;
	length dat3 8.;
	set sfzqb3;
	if bm=>3 and bm le 36  then dat3=dat2+21*abs(bm-bm2);
	format dat3 yymmdd10.;
run;



data sfzqb5;

	set sfzqb4;
	if exdat in ( '' '.' ) and dat =. then
	dat=dat3;
	if dat ne . then do;
	open1=dat+18;
	close1=dat+24;
	end;

	if bm=>3 and bm le 36 then  open =open1 ;
	if bm=>3 and bm le 36 then  close =close1 ;
	format open1 close1 dat  yymmdd10.;
run;



data sfzqb;
	set sfzqb5(keep=subjid bm open close);
	visitid=left(put(bm,best.));
	drop bm;
	if open ne . and close ne .;
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
																									
data sv_last;
	set sv;
	if compress(&visit.)='退出研究治疗';

	label &visdat.='退出研究治疗日期';
	keep subjid &visdat.;
run;
proc sort;by subjid;run;

/*data ds1;*/
/*	set derived.ds1;*/
/*	keep subjid lasexdat;*/
/*run;*/
/*proc sort;by subjid;run;*/

data ds;
	set derived.ds;
	keep subjid cwdat losdat dthdat;
run;
proc sort;by subjid;run;


data sv_last_ds1_ds;
	merge sv_last ds ;
	
	by subjid;
run;

data lastdat;
	set sv_last_ds1_ds;
	lastdat=min(input(&visdat.,yymmdd10.),input(cwdat,yymmdd10.),input(losdat,yymmdd10.) ,input(dthdat,yymmdd10.));
/*	if &visdat. ne '' and statdat ne '' then lastdat=min(input(&visdat.,yymmdd10.),input(statdat,yymmdd10.));*/
/*	else if  &visdat. ne '' and statdat eq '' then lastdat=input(&visdat.,yymmdd10.);*/
/*	else if  &visdat. eq '' and statdat ne '' then lastdat=input(statdat,yymmdd10.);*/
/*	else lastdat=.;*/
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


/*治疗结束页，最晚治疗结束日期-最后一次访视日期>24*/

data eot;
set raw.eot;
keep subjid eotdat;
proc sort;
by subjid;
run;

data eot1;
set raw.eot1;
keep subjid eotdat;
rename eotdat=eotdat1;
proc sort;
by subjid;
run;

data eot2;
set raw.eot2;
keep subjid eotdat;
rename eotdat=eotdat2;
proc sort;
by subjid;
run;

data ds1;
merge eot eot1 eot2;
by subjid;
format ds1dat YYMMDD10.;
if eotdat ne . and eotdat1 ne . and eotdat2 ne .;
ds1dat=max(eotdat,eotdat1,eotdat2);
keep subjid ds1dat;
label ds1dat='最晚治疗结束日期';
run;

data sv_;
set raw.sv;
keep subjid visdat;
proc sort;
by subjid visdat;
run;

data last_sv;
set sv_;
by subjid;
if last.subjid;
run;

data ds_sv;
merge ds1 (in=a) last_sv;
by subjid;
if a;
dif=ds1dat-visdat;
if dif gt 24 then flag='退出治疗日期距末次访视日期超过24天';
if flag ne '';
rename visdat=visdat_last;
label dif='退出日期与末次访视日期差' visdat='末次访视日期' flag='提醒1';
run;



data prefinal_1_1;
	set prefinal_1;
	if lastdat ne . and crfnum1=.;
run;

data prefinal_2_1;
	merge prefinal_2 ds_sv;
	by subjid;
	visitnum=input(visitid,best.);
run;
proc sort data=prefinal_2_1 ;by subjid descending visitnum;run;


data prefinal_2_2;
	set prefinal_2_1(where=(lastdat>close or lastdat=.));
	if &visdat. ne '' then visdat_=lag(&visdat.);
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
	if ds1dat ne . and close ne . then do;
		dif2=ds1dat-close;
	end;
	keep studyid siteid subjid status visitname visitnum visitid open close day ds1dat visdat_last flag dif dif2;
	label day ='访视缺失距今天数' dif2='退出日期与close日期差';
run;
proc sort data=edc.visitmiss;by subjid visitname;run;


proc sql;
create table EDC.qsvisitview as
select qssubjectview.siteid as siteid,
count(*) as qsvisit '访视缺失数' from EDC.visitmiss qssubjectview 
group by siteid;


create table EDC.qsvisitview_sub as
select qssubjectview.subjid as subjid,
count(*) as qsvisit '访视缺失数' from EDC.visitmiss qssubjectview 
group by subjid;

quit;


data out.L3(label='访视缺失汇总');
set edc.visitmiss;
run;
