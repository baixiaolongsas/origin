 /*soh**********************************************************************************
CODE NAME                 : <ҳ��ȱʧ>
CODE TYPE                 : <dc >
DESCRIPTION               : <��չ����ҳ��ȱʧ> 
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

%let visit=visit;/*���ӽ׶εı��������Ƿ��е���Ŀ�ĸñ�����Ϊsvstage��*/
%let visitnum=visitnum; /*������ŵı��������Ƿ��е���Ŀ�ĸñ�����Ϊ�����ģ�*/
%let visdat=visdat;/*�������ڵı��������Ƿ��е���Ŀ��svstdat��*/
%let specialvisit='�ƻ������';
%let ds1=ds;/*���ƽ���ҳ���ƣ��Ƿ�����Ŀ���ж�����ƽ���ҳ����Ҫȷ�����ĸ�*/
%let novisdat='��ͬҳ'; /*�е���Ŀ��ͳ�Ƽƻ���*/

/**/
/*data a;*/
/*set edc.visittable;*/
/*b=input(visitid,best.);*/
/*keep visitname visitid b;*/
/*proc sort nodupkey;*/
/*by b;*/
/*run;*/

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
/*	set sub_v_sv_hc;*/
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

data edc.crfmiss;
	retain studyid siteid subjid status visitname visitnum dmname &visdat. day;
	set prefinal3 prefinal_4;
	if ^missing(&visdat.)  then 
	day=today()-input(&visdat.,yymmdd10.);
	visitnum=input(visitid,best.);
	keep studyid siteid subjid status visitname visitnum dmname &visdat. day;
	label day ='ҳ��ȱʧ�������';
run;
proc sort data=edc.crfmiss;by subjid visitnum;run;


proc sql;
create table edc.qscrfview as
select qscrfview.siteid as siteid,
count(*) as qscrf 'ҳ��ȱʧ��' from edc.crfmiss qscrfview group by qscrfview.siteid
;
quit;

data out.L3(label='ҳ��ȱʧ����');
set edc.crfmiss;
run;
