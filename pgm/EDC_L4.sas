 /*soh**********************************************************************************
CODE NAME                 : <页面缺失>
CODE TYPE                 : <dc >
DESCRIPTION               : <进展报告页面缺失> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : <  >
OUTPUT                    : <  >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & shis
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		 Shishuo			2018-12-21
**eoh**********************************************************************************
*****************************************************************************************/

/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/
/**//**//**/

%let visit=visit;/*访视阶段的变量名，是否有的项目的该变量名为svstage？*/
%let visitnum=visitnum; /*访视序号的变量名，是否有的项目的该变量名为其他的？*/
%let visdat=visdat;/*访视日期的变量名，是否有的项目叫svstdat？*/
%let specialvisit='计划外访视';
%let ds1=ds;/*治疗结束页名称，是否有项目会有多个治疗结束页，需要确定用哪个*/
%let novisdat='共同页'; /*有的项目不统计计划外*/

/**/
/*data a;*/
/*set edc.visittable;*/
/*b=input(visitid,best.);*/
/*keep visitname visitid b;*/
/*proc sort nodupkey;*/
/*by b;*/
/*run;*/

/*筛选出非筛选失败病例*/
proc sort data=derived.subject out=subject(keep=studyid siteid subjid pub_rid status where=(status ne "筛选失败"));by studyid pub_rid subjid;run;
proc sort data=edc.visittable out=visittable(keep=studyid visitname visitid domain dmname svnum);by studyid;run;

proc sql;
	/*利用受试者信息表与访视报告编码构建 构建总表*/
	create table subject_visittable as select compress(pub_rid) as pub_rid ,a.studyid,a.siteid,subjid,status,b.visitname,visitid,domain,dmname,svnum from subject as a full join visittable as b on a.studyid=b.studyid
	where visitname not in(&specialvisit.); /*去除不需要进行页面缺失*/
	alter table work.subject_visittable
 	modify pub_rid char(20) format=$20.;
	/*联接试验数据中的访视日期*/
	create table subject_v_sv as select a.*,b.&visdat. from subject_visittable as a left join derived.sv as b on a.subjid=b.subjid and a.visitname=b.&visit.;
	
quit;
/*保留核查汇总表所有父表并且联接到总表*/
data hchzb;
	set edc.hchzb(where=(ejzbfjl='' and fs ne '') rename=(fzbdrkbjl=pub_rid1) drop=pub_rid);
	visitid=fs;domain=tid;pub_rid=pub_rid1;
	keep pub_rid jl visitid domain svnum;
run;
proc sort nodupkeys;by pub_rid visitid domain svnum;run;
proc sort data=subject_v_sv;by pub_rid visitid domain svnum;run;



data sub_v_sv_hc;
	merge subject_v_sv(in=a) hchzb;
	by pub_rid visitid domain svnum;
	if a;
run;
/*去除已选择未采集的crf*/
data uncollect;
	length svnum $20;
	set derived.uncollect(keep=recordid svnum visitnum visitnum tableid status where=(status='已确认') rename=(svnum=svnum1));
	rename recordid=pub_rid visitnum=visitid tableid=domain;
	svnum=svnum1;
	drop status svnum1;
run;


proc sort data=uncollect nodupkeys dupout=a;by pub_rid visitid domain svnum;run;

data sub_uncollect;
	merge sub_v_sv_hc uncollect(in=b);
/*	set sub_v_sv_hc;*/
	by pub_rid visitid domain svnum;
	if ^b;
run;
/*联接试验数据治疗结束页，已判断是否治疗完成*/
data ds1;
	set derived.&ds1.(keep=subjid  pub_tid);
	rename pub_tid=ds1;
run;
proc sort data=ds1;by subjid;run;


proc sql;
	create table sub_ds1 as select a.*,b.ds1 from sub_uncollect as a left join ds1 as b on a.subjid=b.subjid;
quit;

/*区分有访视日期的，与无访视日期的访视*/
data prefinal1 prefinal_1;
	set sub_ds1;
	if visitname in (&novisdat.) then output prefinal1;
	else if visitname not in (&novisdat.) and &visdat. ne '' then  output prefinal_1;
run;

/*利用治疗结束页判断是否页面缺失并且非访视缺失*/
proc sql;
	create table prefinal2 as select *,count(*) as crfnum,count(jl) as crfnum1 from prefinal1 group by subjid,visitid;
quit;

data prefinal3;
	set prefinal2;
	if ds1 ne '' and jl='' and crfnum1 ne 0;
run;
/*有访视日期的页面，联接下一次访视的访视日期*/
proc sort data=prefinal_1;by subjid  &visdat. visitid svnum;run; 

data sv_1;
	set prefinal_1(rename=(&visdat.=visdat_));
	keep subjid visdat_ visitid;

proc sort data=sv_1 nodupkeys;by _all_;run;

proc sql;
	create table prefinal_2 as select a.*,b.visdat_ from prefinal_1 as a left join sv_1 as b on a.subjid=b.subjid and input(a.visitid,best.)+1=input(b.visitid,best.);

	create table prefinal_3 as select *,count(*) as crfnum,count(jl) as crfnum1 from prefinal_2 group by subjid,visitid;
quit;
/*访视日期距今大于15天，并且下个访视已填写这个访视没填，并且非访视缺失*/
data prefinal_4;
	set prefinal_3;
	if crfnum1 ne crfnum and jl='' and crfnum1 ne 0;
	if today()-input(&visdat.,yymmdd10.)>15 or visdat_ ne '';
run;

data edc.crfmiss;
	retain studyid siteid subjid status visitname visitnum dmname &visdat. day;
	set prefinal3 prefinal_4;
	if ^missing(&visdat.)  then 
	day=today()-input(&visdat.,yymmdd10.);
	visitnum=input(visitid,best.);
	keep studyid siteid subjid status visitname visitnum dmname &visdat. day;
	label day ='页面缺失距今天数';
run;
proc sort data=edc.crfmiss;by subjid visitnum;run;


proc sql;
create table edc.qscrfview as
select qscrfview.siteid as siteid,
count(*) as qscrf '页面缺失数' from edc.crfmiss qscrfview group by qscrfview.siteid
;
quit;

data out.L3(label='页面缺失汇总');
set edc.crfmiss;
run;
