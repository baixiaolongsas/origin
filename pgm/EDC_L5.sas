 /*soh**********************************************************************************
CODE NAME                 : <����ȱʧ>
CODE TYPE                 : <dc >
DESCRIPTION               : <��չ�������ȱʧ> 
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

%let visit=visit;/*���ӽ׶εı��������Ƿ��е���Ŀ�ĸñ�����Ϊsvstage��*/
%let visitnum=visitnum; /*������ŵı��������Ƿ��е���Ŀ�ĸñ�����Ϊ�����ģ�*/
%let visdat=visdat;/*�������ڵı��������Ƿ��е���Ŀ��svstdat��*/
%let specialvisit='�������','C4�����';
%let ds1=ds;
/*���ƽ���ҳ���ƣ��Ƿ�����Ŀ���ж�����ƽ���ҳ����Ҫȷ�����ĸ�*/
%let novisdat='��ͬҳ','���ƽ���/�˳�','���ƽ���ҳ',''; /*�е���Ŀ��ͳ�Ƽƻ���*/


data subject;
	set derived.subject(keep=pub_rid subjid status studyid siteid);
run;

proc sql;
	/*ÿ��������Ҫ���ж��ٸ�ģ��*/
	create table visitsum as select distinct visitname,visitid,count(*) as crfnum '������crf������' from edc.visittable  group by visitname;
	/*ÿ�������Ѿ������˶��ģ��*/
	create table VisitWCCrfView as select distinct fzbdrkbjl as pub_rid,fs as visitid,count(*) as crfnum1 '�������ѽ���crf����' from edc.hchzb(where=(ejzbfjl='')) group by fzbdrkbjl,fs;
	/*������������Ϣ������ӱ�����빹�� �����ܱ�*/
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

/*���ڶ�̬�������¼���ʱ�䴰�����ڷǶ�̬����ֱ����sfzqb*/
/*��Ҫ�޸Ĵ˴�*/

/*����Ŀʹ�ò�����sfzqb*/





/*�޳�ѭ������*/
data subject_sfzqb_select;
/*	set subject_sfzqb;*/
	set subject_visit_crfnum;
	if visitname not in (&specialvisit.);
run;
data sv;
	set derived.sv;
	keep subjid &visit. &visdat.;
run;

proc sql;
	create table subject_sv as select a.*,b.&visdat. from subject_sfzqb_select as a left join sv as b on a.subjid=b.subjid and a.visitname=b.&visit.;
quit;
/*�ҵ�δ�ɼ����Ӳ��޳�*/
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
/*�ҵ����ߵ����ƽ��������Լ������ҩʱ��,�������û����ҩ�����о��������ڣ������������ڣ�֮��ѡһ����С��  */
/*																									*/
/*					�˴�Ӧ����Ŀ�޸�																	*/
/**/

data sv_last;
	set sv;
	if compress(&visit.)='���ƽ���/�˳�';

	label &visdat.='�˳�ǰ��������';
	keep subjid &visdat.;
run;
proc sort;by subjid;run;

data ds1;
	set derived.ds1;
	keep subjid lasexdat;
run;
proc sort;by subjid;run;

data ds;
	set derived.ds;
	keep subjid dsdat;
run;
proc sort;by subjid;run;

data dth;
	set derived.dth;
	keep subjid dthdat;
proc sort;by subjid;run;

data sv_last_ds1_ds;
	merge sv_last ds1 dth
/*ds */
;
	by subjid;
	
run;

data lastdat;
	set sv_last_ds1_ds;
/*	lastdat=min(input(lasexdat,yymmdd10.),input(&visdat.,yymmdd10.),input(dsdat,yymmdd10.),input(dthdat,yymmdd10.));*/
	lastdat=min(input(dsdat,yymmdd10.),input(dthdat,yymmdd10.));
	format lastdat yymmdd10.;
	label lastdat='�о���������';
/*	keep subjid lastdat;*/
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
	if dsdat ne . and crfnum1=.;

	open=.;close=.;day=.;
	keep  studyid siteid subjid status visitname  visitid open close day;;
run;



data prefinal_2_1;
	set prefinal_2;
	visitnum=input(visitid,best.);
run;
proc sort data=prefinal_2_1 ;by subjid descending visitnum;run;

/*jin yanhong ��ӷ��Ӵ�Ҫ��*/
proc sql;
create table presfzqb as 
select 
a.*, input(b.visdat,yymmdd10.) as visdat2 "C1D1��������" format yymmdd10.,input(c.visdat,yymmdd10.)  as visdat9 "���ƽ���/�˳���������" format yymmdd10.,
input(d.visdat,yymmdd10.) as visdat4 "C2D1��������" format yymmdd10.,input(e.visdat,yymmdd10.) as visdat6 "C3D1��������" format yymmdd10.,
input(f.visdat,yymmdd10.) as visdatl "��һ��������" format yymmdd10.,
g.crfnum1 as crfnumn "��һ����CRF����"
from prefinal_2_1 as a
left join derived.sv as b on a.subjid=b.subjid and b.visitnum="2"
left join derived.sv as c on a.subjid=c.subjid and c.visitnum="9"
left join derived.sv as d on a.subjid=d.subjid and d.visitnum="4"
left join derived.sv as e on a.subjid=e.subjid and e.visitnum="6"
left join derived.sv as f on a.subjid=f.subjid and input(f.visitnum,best.)=a.visitnum-1
left join prefinal_2_1  as g on a.subjid=g.subjid and g.visitnum=a.visitnum+1
;
quit;

data prefinal_sfzqb;
set presfzqb;
format open yymmdd10.  close yymmdd10.;
if visitnum=1 then do;open=visdat2-14;close=visdat2;end;
if visitnum=11 then do;open=visdat9+23;close=visdat9+37;end;
if visitnum=4 then do;open=visdat2+12;close=visdat2+37;end;
if visitnum=6 then do;open=visdat4+12;close=visdat4+37;end;
if visitnum in(3,5,7)  then do;open=visdatl+12;close=visdatl+16;end;
/*if visitnum in(2,4,6)  then do;open2=visdatl;close2=visdatl;end;*/
/*if visitnum in (4,6) then do;close=min(close1,close2);end;*/
run;

data edc.visitmiss;
	set prefinal_sfzqb ;
	if crfnum1=. and ((close ^=. and today()>close ) /*OR  crfnumn ne .*/);
    day=today()-close;
	label day="�������";
	keep studyid siteid subjid status visitname  visitid open close day;;
run;

data edc.visitmiss;
	set edc.visitmiss prefinal_1_1;
run;

/*proc sort data=prefinal_sfzqb ;by subjid descending visitnum;run;*/
/**/
/*data prefinal_2_2;*/
/*	set prefinal_sfzqb(where=( lastdat>close  or lastdat=.));*/
/*	 visdat_=lag(&visdat.); */
/*	by subjid descending visitnum;*/
/*	if first.subjid then visdat_='';*/
/*	if (visdat_ ne '' or (close ne . and  today()-close >=15)) and crfnum1 = .;*/
/*run;*/
/**/
/*proc sort ;by subjid visitnum;run;*/
/**/
/**/
/**/
/**/
/**/
/*data edc.visitmiss;*/
/*	retain studyid siteid subjid status visitname visitnum visitid open close day;*/
/*	set prefinal_2_2 prefinal_1_1;*/
/*	if ^missing(open)  then */
/*	day=today()-open;*/
/*	else day=.;*/
/*	visitnum=input(visitid,best.);*/
/*	keep studyid siteid subjid status visitname visitnum visitid open close day;*/
/*	label day ='����ȱʧ�ݽ�����';*/
/*run;*/
/*proc sort data=edc.visitmiss;by subjid visitname;run;*/

/*data a;*/
/*subjid="��������";*/
/*run;*/
/*data edc.visitmiss;*/
/*merge a edc.visitmiss ;*/
/*run;*/
/**/


proc sql;
create table EDC.qsvisitview as
select qssubjectview.siteid as siteid,
count(*) as qsvisit '����ȱʧ��' from EDC.visitmiss qssubjectview 
group by siteid;

quit;


data out.l2(label="����ȱʧ����") ;set edc.visitmiss;run;


