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
%let specialvisit='�������';
%let ds1=ds1;/*���ƽ���ҳ���ƣ��Ƿ�����Ŀ���ж�����ƽ���ҳ����Ҫȷ�����ĸ�*/
%let novisdat='��ͬҳ','���ﱨ��','���ƽ���/�˳��о�'; /*�е���Ŀ��ͳ�Ƽƻ���*/













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
/*�������ھ�����15�죬�����¸���������д�������û����ҷǷ���ȱʧ�������Ŀ��5��ģ�*/

/*ɸѡ�ڵİ�28+5��ҳ��ȱʧ�������ڵİ���5����*/
data prefinal_4;
	set prefinal_3;
	if visitname ne 'ɸѡ��';
	if crfnum1 ne crfnum and jl='' and crfnum1 ne 0;
	if today()-input(&visdat.,yymmdd10.)>5 or visdat_ ne '';
run;

data prefinal_5;
  set prefinal_3;
if visitname eq 'ɸѡ��';
if crfnum1 ne crfnum and jl='' and crfnum1 ne 0;
if today()-input(&visdat.,yymmdd10.)>33 or visdat_ ne '';
run;


data edc.crfmiss1;
	retain studyid siteid subjid status visitname visitnum dmname &visdat. day;
	set  prefinal_4 prefinal_5;
	if ^missing(&visdat.)  then 
	day=today()-input(&visdat.,yymmdd10.);
	visitnum=input(visitid,best.);
	keep studyid siteid subjid status visitname visitnum dmname &visdat. day;
	label day ='ҳ��ȱʧ�������';
run;


data sv1;
  set derived.sv;
if visit not in ('ɸѡ��','���ƽ���/�˳��о�') then visit1=scan(visit,2,'_');
if visit in ('ɸѡ��','���ƽ���/�˳��о�') then visit1=visit;
run;

proc sql;
  create table pre_zl as select
a.studyid,a.siteid,a.subjid,e.status,a.visit as visitname '���ӽ׶�', input(a.visitnum,best.) as visitnum ,a.visdat,b.visstage as visstage1 '������Ч�������ӽ׶�',
c.visstage as visstage2 '�ǰв������������ӽ׶�',d.visstage as visstage3 '�в������������ӽ׶�'

from sv1 as a left join derived.rsnl as b on a.subjid=b.subjid and a.visit1=b.visstage
left join derived.rsnt1 as c on a.subjid=c.subjid and a.visdat=c.visstage
left join derived.rst1 as d on a.subjid=d.subjid and a.visdat=d.visstage
left join derived.subject as e on a.subjid=e.subjid
where a.visit in ('ɸѡ��','���ƽ���/�˳��о�','������_C3D1','������_C5D1','������_C7D1','������_C9D1','������_C11D1','������_C13D1','������_C15D1','������_C19D1','������_C21D1','������_C23D1')
and e.status ne 'ɸѡʧ��';
quit;
proc sort data=pre_zl nodupkeys; by _all_;run;


data bbz;
  set pre_zl;
  length dmname $ 500;
if visstage1 eq '' and visstage3 ne '' then dmname='������Ч����';
if visstage1 ne '' and visstage3 eq '' then dmname='�в����������';
if visstage1 eq '' and visstage3 eq '' then dmname='������Ч�����Ͱв����������';
if visstage1 ne '' and visstage3 ne '' then dmname='';
label dmname='�ӱ�����';
drop visstage1 visstage2 visstage3;
run;

data EDC.bbz;
  set bbz;
if dmname ne '';run;

/*RST1,ADA,RSNL*/
/*proc sql;*/
/*create table pre_rsnltot as select*/
/*a.studyid,a.siteid,a.subjid,b.status,a.visit as visitname '���ӽ׶�',input(a.visitnum,best.) as visitnum ,a.visdat,c.visstage as visstage1 '������Ч�������ӽ׶�',*/
/*d.visstage as visstage2 '�в������������ӽ׶�'*/
/*from derived.sv as a left join derived.subject as b on a.subjid=b.subjid*/
/*left join derived.rsnl as c on a.subjid=c.subjid and a.visit=c.visstage*/
/*left join derived.rst1 as d on a.subjid=d.subjid and a.visit=d.visstage*/
/*where a.visit in ('ɸѡ��','������_C3D1','������_C5D1','������_C7D1','������_C9D1','������_C11D1','������_C13D1','������_C15D1','������_C19D1','������_C21D1','������_C23D1','���ƽ���/�˳��о�');*/
/*quit;*/



proc sql;
create table pre_ada as select
a.studyid,a.siteid,a.subjid,b.status,a.visit1 as visitname '���ӽ׶�', input(a.visitnum,best.) as visitnum ,a.visdat,c.vsc as visstage4 '����ԭ��Ѫ���ɼ����ӽ׶�'
from sv1 as a left join derived.subject as b on a.subjid=b.subjid
left join derived.ada as c on a.subjid=c.subjid and a.visdat=c.vsc
where a.visit in ('������_C1D1','������_C2D1','������_C3D1','������_C4D1','������_C7D1','������_C10D1','������_C13D1','������_C16D1','������_C19D1','������_C22D1','������_C25D1','���ƽ���/�˳��о�')
and b.status ne 'ɸѡʧ��';
quit;

data edc.finalada;
  set pre_ada(where=(visstage4=''));
if visitname ne visstage4 then dmname='����ԭ��Ѫ���ɼ�';
drop visstage4;
run;

data edc.crfmiss;
  set edc.crfmiss1 edc.bbz edc.finalada;
proc sort data=edc.crfmiss;by subjid visitnum;run;



proc sql;
create table edc.qscrfview as
select qscrfview.siteid as siteid,
count(*) as qscrf 'ҳ��ȱʧ��' from edc.crfmiss qscrfview group by qscrfview.siteid
;
quit;


data out.l4(label='ҳ��ȱʧ����'); set edc.crfmiss; run;
