 /*soh**********************************************************************************
CODE NAME                 : <ҳ��ȱʧ>
CODE TYPE                 : <dc >
DESCRIPTION               : <��չ����ҳ��ȱʧ> 
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

%let visit=visit;/*���ӽ׶εı��������Ƿ��е���Ŀ�ĸñ�����Ϊsvstage��*/
%let visitnum=visitnum; /*������ŵı��������Ƿ��е���Ŀ�ĸñ�����Ϊ�����ģ�*/
%let visdat=visdat;/*�������ڵı��������Ƿ��е���Ŀ��svstdat��*/
%let specialvisit='�ƻ������';
%let ds1=eot;/*���ƽ���ҳ���ƣ��Ƿ�����Ŀ���ж�����ƽ���ҳ����Ҫȷ�����ĸ�*/
%let novisdat='��ͬҳ'; /*�е���Ŀ��ͳ�Ƽƻ���*/








/*ɸѡ����ɸѡʧ�ܲ���*/
proc sort data=derived.subject out=subject(keep=studyid siteid subjid pub_rid status where=(status ne "ɸѡʧ��"));by studyid pub_rid subjid;run;
proc sort data=edc.visittable out=visittable(keep=studyid visitname visitid domain dmname svnum);by studyid;run;

proc sql;
	/*������������Ϣ������ӱ�����빹�� �����ܱ�*/
	create table subject_visittable as select compress(pub_rid) as pub_rid ,a.studyid,a.siteid,subjid,status,b.visitname,visitid,domain,dmname,svnum from subject as a full join visittable as b on a.studyid=b.studyid
	where visitname not in(&specialvisit.); /*ȥ������Ҫ����ҳ��ȱʧ*/
	alter table work.subject_visittable
 	 modify pub_rid char(20) format=$20.;
	/*�������������еķ�������*/
	create table subject_v_sv as select a.*,b.&visdat. from subject_visittable as a left join derived.sv as b on a.subjid=b.subjid and a.visitname=b.&visit.;
	
quit;
/*�����˲���ܱ����и��������ӵ��ܱ�*/
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
/*ȥ����ѡ��δ�ɼ���crf*/
data uncollect;
	length svnum $20;
	set derived.uncollect(keep=recordid svnum visitnum visitnum tableid status where=(status='��ȷ��') rename=(svnum=svnum1));
	rename recordid=pub_rid visitnum=visitid tableid=domain;
	svnum=svnum1;
	drop status svnum1;
run;


proc sort data=uncollect nodupkeys dupout=a;by pub_rid visitid domain svnum;run;

data sub_uncollect;
	merge sub_v_sv_hc uncollect(in=b);
	by pub_rid visitid domain svnum;
	if ^b;

run;

/*���������������ƽ���ҳ�����ж��Ƿ��������*/
data ds1;
	set derived.&ds1.(keep=subjid  pub_tid);
	rename pub_tid=ds1;
run;
proc sort data=ds1;by subjid;run;


proc sql;
	create table sub_ds1 as select a.*,b.ds1 from sub_uncollect as a left join ds1 as b on a.subjid=b.subjid;
quit;

/*�����з������ڵģ����޷������ڵķ���*/
data prefinal1 prefinal_1;
/*	set sub_ds1;*/
	set sub_ds1;
	if visitname in (&novisdat.) then output prefinal1;
	else if visitname not in (&novisdat.) and &visdat. ne '' then  output prefinal_1;
run;

/*�������ƽ���ҳ�ж��Ƿ�ҳ��ȱʧ���ҷǷ���ȱʧ*/
proc sql;
	create table prefinal2 as select *,count(*) as crfnum,count(jl) as crfnum1 from prefinal1 group by subjid,visitid;
quit;

data prefinal3;
	set prefinal2;
	if ds1 ne '' and jl='' and crfnum1 ne 0;
run;
/*�з������ڵ�ҳ�棬������һ�η��ӵķ�������*/
proc sort data=prefinal_1;by subjid  &visdat. visitid svnum;run; 

data sv_1;
	set prefinal_1(rename=(&visdat.=visdat_));
	keep subjid visdat_ visitid;

proc sort data=sv_1 nodupkeys;by _all_;run;

proc sql;
	create table prefinal_2 as select a.*,b.visdat_ from prefinal_1 as a left join sv_1 as b on a.subjid=b.subjid and input(a.visitid,best.)+1=input(b.visitid,best.);

	create table prefinal_3 as select *,count(*) as crfnum,count(jl) as crfnum1 from prefinal_2 group by subjid,visitid;
quit;
/*�������ھ�����15�죬�����¸���������д�������û����ҷǷ���ȱʧ*/
data prefinal_4;
	set prefinal_3;
	if crfnum1 ne crfnum and jl='' and crfnum1 ne 0;
	if today()-input(&visdat.,yymmdd10.)>15 or visdat_ ne '';
run;

/*�������״θ�ҩ����-��ҩ��¼ҳ��ȱʧ*/
data exd;
  set derived.ex(where=(exstdat ne ''));
keep subjid extrt;
run;

proc sort data=exd nodupkeys;by subjid extrt;run;

proc transpose data=exd out=exd1(drop=_LABEL_ _NAME_) prefix=sn;
by subjid;
var extrt;
run;


proc sql;
create table fdd1 as select
a.subjid,a.visit as visitname,c.status,a.studyid,a.siteid,input(a.visitnum,best.) as visitnum,a.fdat,b.sn1,b.sn2
from derived.fdd as a left join exd1 as b on a.subjid=b.subjid
   left join derived.subject as c on a.subjid=c.subjid;
quit;

data fdd2;
  set fdd1;
  length dmname $500;
  if sn1 eq '' then dmname='fdd����д-��ҩ��¼HS-10234/HS-10234ģ���ȱʧ';
  if sn2 eq '' then dmname='fdd����д-��ҩ��¼TDFƬ/TDFģ���ȱʧ';
  if sn1 eq '' and sn2 eq '' then dmname='fdd����д-��ҩ��¼����ҩ�ﶼȱʧ';
  keep studyid siteid subjid status visitname visitnum dmname; 
run;

data fdd2;
  set fdd2;
  if dmname ne '';
run;

data edc.crfmiss1;
	retain studyid siteid subjid status visitname visitnum dmname &visdat. day;
	set prefinal3 prefinal_4;
	if ^missing(&visdat.)  then 
	day=today()-input(&visdat.,yymmdd10.)-15;
	visitnum=input(visitid,best.);
	keep studyid siteid subjid status visitname visitnum dmname &visdat. day;
	label day ='ҳ��ȱʧ�������';
run;
proc sort data=edc.crfmiss1;by subjid visitnum;run;

data edc.crfmiss;
  set edc.crfmiss1 fdd2;
run;

proc sort data=edc.crfmiss;by subjid visitnum;run;

proc sql;
create table edc.qscrfview as
select qscrfview.siteid as siteid,
count(*) as qscrf 'ҳ��ȱʧ��' from edc.crfmiss1 qscrfview group by qscrfview.siteid
;
quit;



data out.l3(label='ҳ��ȱʧ����'); set edc.crfmiss; run;
