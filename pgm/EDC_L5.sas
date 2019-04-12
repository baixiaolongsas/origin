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
%let specialvisit='�ƻ������','�������','��ȫ�����1','��ȫ�����2','������չ���','�����¼';
%let ds1=eot;/*���ƽ���ҳ���ƣ��Ƿ�����Ŀ���ж�����ƽ���ҳ����Ҫȷ�����ĸ�*/
%let novisdat='��ͬҳ','��ֹ/�˳�����','�о����ƽ���'; /*�е���Ŀ��ͳ�Ƽƻ���*/




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
/**/
/**/
/**/
/*�̶����Ӵ�*/
/*data sfzqb;*/
/*	set edc.sfzqb(keep=subjid open close bm);*/
/*	visitid=bm;*/
/*	drop bm;*/
/*run;*/


/*��̬���Ӵ�*/
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




/*��̬���Ӵ�*/
data sfzqb;
  set edc.sfzqb11;
  run;



proc sort data=sfzqb;by subjid visitid;run;



data subject_sfzqb;
	merge subject_visit_crfnum(in=a) sfzqb;
	by subjid visitid;
	if a;
run;
/*�޳�ѭ������*/
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
/*																									*/
data sv_last;
	set sv;
	if compress(&visit.)='��ֹ/�˳�����';

	label &visdat.='�˳�ǰ��������';
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
	label lastdat='��С�˳�/��ҩ����';
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

/*��������ȱʧ*/
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
	label day ='����ȱʧ�������';
run;
proc sort data=edc.visitmiss;by subjid visitnum;run;


proc sql;
create table EDC.qsvisitview as
select qssubjectview.siteid as siteid,
count(*) as qsvisit '����ȱʧ��' from EDC.visitmiss qssubjectview 
group by siteid;

quit;

data out.l2(label='����ȱʧ����'); set edc.visitmiss; run;
