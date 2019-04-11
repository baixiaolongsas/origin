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
%let specialvisit='�ƻ������','�����¼';
%let ds1=ds1;/*���ƽ���ҳ���ƣ��Ƿ�����Ŀ���ж�����ƽ���ҳ����Ҫȷ�����ĸ�*/
%let novisdat='��ͬҳ','��ȫ�����','��������ɸѡ','�������','�о��ܽ�ҳ','���ƽ���ҳ','�������_�˳�'; /*�е���Ŀ��ͳ�Ƽƻ���*/



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
/*�̶����Ӵ�*/
data sfzqb;
	set edc.sfzqb(keep=subjid open close bm);
	visitid=bm;
	drop bm;
run;

proc sort data=sfzqb;by subjid visitid;run;


/*************************    ��˫ä�ںͿ������Ƿֿ��������ȱʧ    *******************************/
proc freq data=subject_visit_crfnum; table visitname; run;

data subject_sfzqb;
	merge subject_visit_crfnum(in=a) sfzqb;
	by subjid visitid;
	if a;
run;
/*�޳��������*/
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
	if compress(&visit.) in ('�������_�˳�' '�о��ܽ�ҳ');

	label &visdat.='�˳�ǰ��������';
	keep subjid &visdat.;
run;
proc sort;by subjid;run;

/************************************��dth���ݼ�*****************************************************/
/*˫ä�����ƽ�������*/
data ds1;
	set derived.Eot_otoz;
	keep subjid eotdat;
	where eotcat='SHR1210/��ο��';
run;
proc sort;by subjid;run;
/*C1SD1 SHR1210��ҩ����*/
data ex;
  set derived.Exi_otoz;
  keep subjid exstdat;
  if visit='C1SD1';
run;
proc sort;by subjid;run;
/*���������ƽ�������*/
data ds2;
	set derived.Eot_otoz;
	keep subjid eotdat;
	where eotcat='SHR1210';
run;
proc sort;by subjid;run;
/*��ȫ�����*/
data sv_safe;
	set sv;
	if compress(&visit.) ='��ȫ�����';
	label &visdat.='��ȫ���������';
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
/*	label lastdat='��С�˳�/��ҩ����';*/
/*	keep subjid lastdat;*/
/*run;*/
data lastdat1;
	set sv_last_ds1_ds1;
	lastdat1=min(input(&visdat.,yymmdd10.),input(dthdat,yymmdd10.),input(eotdat,yymmdd10.));
	format lastdat1 yymmdd10.;
	label lastdat1='˫ä����С�˳�/��ҩ����';
	keep subjid lastdat1 dsterm;
run;
data lastdat2;
	set sv_last_ds1_ds2;
	lastdat=min(input(&visdat.,yymmdd10.),input(dthdat,yymmdd10.),input(eotdat,yymmdd10.));
	if exstdat='' then lastdat2=.;
	else if exstdat ne '' and lastdat < input(exstdat,yymmdd10.) then lastdat2=.;
	else if exstdat ne '' and lastdat > input(exstdat,yymmdd10.) then lastdat2=lastdat;
	format lastdat2 yymmdd10.;
	label lastdat2='��������С�˳�/��ҩ����';
	keep subjid lastdat2 eotdat dsterm;
run;
/************************************��dth���ݼ�*****************************************************/

/*�жϷ���ȱʧ*/
proc sort data=subject_sv_svworkflow;by subjid;run;
data prefinal;
	merge subject_sv_svworkflow lastdat1 lastdat2 sv_safe;
	by subjid;
	if visitname not in (&novisdat.) then do;
	  if find(visitname,'S') ne 0 or visitname='����������Ӱ��ѧ' then lastdat=lastdat2;
	  else if find(visitname,'S')=0 or visitname='˫ä������Ӱ��ѧ' or  visitname= 'ɸѡ��' then lastdat=lastdat1;      
	end;
	if eotdat ne '' or visdat ne '' or dsterm ne '' then finish='�������_�˳�����ȱʧ'; else finish='';
	label lastdat='��С�˳�/��ҩ����';
	drop lastdat1 lastdat2;
run;


data prefinal_1 prefinal_2;
	set prefinal;
	if visitname in (&novisdat.) then output prefinal_1;
	else output prefinal_2;
run;

data prefinal_1_1;
	set prefinal_1;
	if visitname in ('��ͬҳ','��ȫ�����','�������','���ƽ���ҳ') and dsterm ne '' and crfnum1=. then output;
    if visitname='�������_�˳�' and finish ne '' and crfnum1=. then output;
run;

/*prefinal_2_1˫ä��   prefinal_2_2������*/
data prefinal_2_1 prefinal_2_2;
   set prefinal_2;
   if find(visitname,'S') ne 0 or visitname='����������Ӱ��ѧ' then output prefinal_2_2;
   else output prefinal_2_1;
run;

/*˫ä���ж�*/
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

/*�������ж�*/
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
	label day ='����ȱʧ�ݽ�����';
run;
proc sort data=edc.visitmiss;by subjid visitnum;run;


proc sql;
create table EDC.qsvisitview as
select qssubjectview.siteid as siteid,
count(*) as qsvisit '����ȱʧ��' from EDC.visitmiss qssubjectview 
group by siteid;

quit;

data out.l2(label='����ȱʧ����'); set edc.visitmiss; run;

/*ods listing close; /*����output��graph������ʾ���*/*/
/*ods RESULTS off;  /*���������*/*/
/*ods html close;  /*������html�ļ�*/*/
/*ods escapechar='^';*/
/*ods excel file="&root.\output\&study._����ȱʧ.xlsx" options(sheet_name="����ȱʧ"  contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;*/
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
