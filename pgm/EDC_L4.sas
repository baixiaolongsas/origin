 /*soh**********************************************************************************
CODE NAME                 : <页面缺失>
CODE TYPE                 : <dc >
DESCRIPTION               : <进展报告页面缺失> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < >
OUTPUT                    : < crfmiss.sas7dbat>
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
%let specialvisit='生存随访'/*,'C4后访视'*/;
%let ds1=ds;
/*治疗结束页名称，是否有项目会有多个治疗结束页，需要确定用哪个*/
%let novisdat='共同页'; /*有的项目不统计计划外*/


data visittablepre;
set edc.visittable;
if visitname="C4后访视"  and domain ne "sv";
run;
data cycle;
input cyclenum viscycle$ @@;
cards;
1 C4D1 2 C4D15 3 C5D1 4 C5D15 5 C6D1 6 C6D15  7 C7D1 8  C7D15 9 C8D1 10 C8D15 11 C9D1 12 C9D15
13 C10D1 14 C10D15 15 C11D1 16  C11D15 17 C12D1 18  C12D15 19 C13D1 20 C13D15  21 C14D1 22 C14D15  23 C15D1 24  C15D15 
25 C16D1  26 C16D15 27   C17D1 28  C17D15 29 C18D1  30 C18D15 31  C19D1 32  C19D15 33  C20D1 34 C20D15 
;
RUN;


proc sql;
create table visittable0 as 
select a.*,b.* from visittablepre as a left join cycle as b on 1=1;quit;

/*C4后访视，访视报告编码         有些周期不需要某些页面，去除*/
data visittable1;
set visittable0;
if domain="lb" then do;if find(viscycle,"D15") ;end;
if dmname="生活质量评分" then do;if  mod(input(scan(viscycle,1,"CD"),best.),3)=0 and  find(viscycle,"D15") ;end;
if domain="ex" then do;if ^find(viscycle,"D15") ;end;
run;


proc sql;
create table visittable2 as 
select a.*,b.viscycle ,b.cyclenum
from edc.visittable as a 
left join visittable1 as b on a.visitname=b.visitname and a.domain=b.domain;
quit;
data visittable2;
set visittable2;
if visitname="C3D15" then cyclenum=0;
if visitname="治疗结束/退出" then cyclenum=35;
run;


/*筛选出费筛选失败病例*/
proc sort data=derived.subject out=subject(keep=studyid siteid subjid pub_rid status where=(status ne "筛选失败"));by studyid pub_rid subjid;run;
/*proc sort data=edc.visittable out=visittable(keep=studyid visitname visitid domain dmname svnum);by studyid;run;*/
proc sort data=visittable2 out=visittable(keep=studyid visitname visitid domain dmname svnum viscycle cyclenum);by studyid;run;
proc sql;
	/*利用受试者信息表与访视报告编码构建 构建总表*/
	create table subject_visittable as select compress(pub_rid) as pub_rid ,a.studyid,a.siteid,subjid,status,b.visitname,visitid,domain,dmname,svnum,viscycle,cyclenum from subject as a full join visittable as b on a.studyid=b.studyid
	where visitname not in(&specialvisit.); /*去除不需要进行页面缺失*/
	alter table work.subject_visittable
 	 modify pub_rid char(20) format=$20.;
	/*连接试验数据中的访视日期*/
	create table subject_v_sv as select a.*,b.&visdat. from subject_visittable as a left join derived.sv as b on a.subjid=b.subjid and a.visitname=b.&visit. and a.viscycle=b.viscycle;
	
quit;
/*保留核查汇总表所有父表并且链接到总表*/
data hchzb;
	set edc.hchzb(where=(ejzbfjl='' and fs ne '') rename=(fzbdrkbjl=pub_rid1) drop=pub_rid);
	visitid=fs;domain=tid;pub_rid=pub_rid1;
	keep pub_rid jl visitid domain svnum;
run;
proc sort nodupkeys;by  pub_rid  visitid domain svnum;run;
proc sort data=subject_v_sv;by pub_rid  visitid domain svnum;run;


data sub_v_sv_hc;
	merge subject_v_sv(in=a) hchzb;
	by  pub_rid visitid domain svnum;
	if a;
run;
/*去除已选择未采集的crf*/
/*data uncollect;*/
/*	length svnum $20;*/
/*	set derived.uncollect(keep=recordid svnum visitnum visitnum tableid status where=(status='已确认') rename=(svnum=svnum1));*/
/*	rename recordid=pub_rid visitnum=visitid tableid=domain;*/
/*	svnum=svnum1;*/
/*	drop status svnum1;*/
/*run;*/
/**/
/**/
/*proc sort data=uncollect nodupkeys dupout=a;by pub_rid visitid domain svnum;run;*/
/**/
/*data sub_uncollect;*/
/*	merge sub_v_sv_hc uncollect(in=b);*/
/*	by pub_rid visitid domain svnum;*/
/*	if ^b;*/
/**/
/*run;*/

data sub_uncollect;
	set sub_v_sv_hc;
	by pub_rid visitid domain svnum;
	if ^b;

run;
/*连接试验数据治疗结束页，已判断是否治疗完成*/
data ds1;
	set derived.&ds1.(keep=subjid  pub_tid);
	rename pub_tid=ds1;
run;
proc sort data=ds1;by subjid;run;


proc sql;
	create table sub_v_sv_hc as select a.*,b.ds1 from sub_uncollect as a left join ds1 as b on a.subjid=b.subjid;
quit;

/*区分有访视日期的，与无访视日期的访视*/
data prefinal1 prefinal_1;
	set sub_v_sv_hc;
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
/*有访视日期的页面，连接下一次访视的访视日期*/
proc sort data=prefinal_1;by subjid  &visdat. visitid svnum;run; 

data sv_1;
	set prefinal_1(rename=(&visdat.=visdat_));
	keep subjid visdat_ visitid cyclenum;

proc sort data=sv_1 nodupkeys;by _all_;run;

proc sql;
	create table prefinal_2 as select a.*,b.visdat_ from prefinal_1 as a left join sv_1 as b on a.subjid=b.subjid 
	and ( (compress(a.visitid) ^in ("7","8") and  input(a.visitid,best.)+1=input(b.visitid,best.) ) or (a.cyclenum ne . and a.cyclenum+1=b.cyclenum)) ;

	create table prefinal_3 as select *,count(*) as crfnum,count(jl) as crfnum1 from prefinal_2 group by subjid,visitid;
quit;
/*访视日期距今大于15天，并且下个访视已填写这个访视没填，并且非访视缺失*/
data prefinal_4;
	set prefinal_3;
	if (crfnum1 ne crfnum and jl='' and crfnum1 ne 0) or (visitname="C4后访视" ) ;
	if today()-input(&visdat.,yymmdd10.)>15 or visdat_ ne '';
run;

proc sql;
create table prefinal_4 as 
select 
a.*,
coalescec(c.pub_rid,d.pub_rid,e.pub_rid,h.pub_rid,i.pub_rid,j.pub_rid,k.pub_rid) as pub_ridcyc

from prefinal_4 as a 

left join   derived.vs as c on a.subjid=c.subjid and a.domain=c.pub_tid  and a.viscycle=c.viscycle and c.visitnum="8"
left join   derived.pe as d on a.subjid=d.subjid and a.domain=d.pub_tid   and a.viscycle=d.viscycle and d.visitnum="8"
left join   derived.lb as e on a.subjid=e.subjid  and a.domain=e.pub_tid  and a.viscycle=e.viscycle and compress(e.lbcat)=compress(tranwrd(tranwrd(a.dmname,"实验室检查("," "),")","")) and e.visitnum="8"
left join   derived.ecog as h on a.subjid=h.subjid and a.domain=h.pub_tid  and a.viscycle=h.viscycle and h.visitnum="8"
left join   derived.vas as i on a.subjid=i.subjid  and a.domain=i.pub_tid and a.viscycle=i.viscycle and i.visitnum="8" 
left join   derived.qs as j on a.subjid=j.subjid and a.domain=j.pub_tid  and a.viscycle=j.viscycle and j.visitnum="8"
left join   derived.ex as k on a.subjid=k.subjid and a.domain=k.pub_tid  and a.viscycle=k.viscycle and k.visitnum="8"
;
quit;

proc sort nodupkey ;by _all_;run;

data edc.crfmiss;
	retain studyid siteid subjid status visitname visitnum  viscycle dmname &visdat. day;
	set prefinal3 prefinal_4;
	if visitname="C4后访视" then do;if pub_ridcyc = "" ;end;
	if ^missing(&visdat.)  then 
	day=today()-input(&visdat.,yymmdd10.)-15;
	visitnum=input(visitid,best.);
	keep studyid siteid subjid status visitname visitnum  viscycle dmname &visdat. day;
	label day ='页面缺失据今天数' visitnum="访视序号" viscycle="访视周期";
run;
proc sort data=edc.crfmiss;by subjid visitnum viscycle ;run;




proc sql;
create table edc.qscrfview as
select qscrfview.siteid as siteid,
count(*) as qscrf '页面缺失数' from edc.crfmiss qscrfview group by qscrfview.siteid
;
quit;

data out.l3(label="页面缺失汇总") ;set edc.crfmiss;run;
