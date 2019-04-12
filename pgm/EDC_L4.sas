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
%let specialvisit='�������'/*,'C4�����'*/;
%let ds1=ds;
/*���ƽ���ҳ���ƣ��Ƿ�����Ŀ���ж�����ƽ���ҳ����Ҫȷ�����ĸ�*/
%let novisdat='��ͬҳ'; /*�е���Ŀ��ͳ�Ƽƻ���*/


data visittablepre;
set edc.visittable;
if visitname="C4�����"  and domain ne "sv";
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

/*C4����ӣ����ӱ������         ��Щ���ڲ���ҪĳЩҳ�棬ȥ��*/
data visittable1;
set visittable0;
if domain="lb" then do;if find(viscycle,"D15") ;end;
if dmname="������������" then do;if  mod(input(scan(viscycle,1,"CD"),best.),3)=0 and  find(viscycle,"D15") ;end;
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
if visitname="���ƽ���/�˳�" then cyclenum=35;
run;


/*ɸѡ����ɸѡʧ�ܲ���*/
proc sort data=derived.subject out=subject(keep=studyid siteid subjid pub_rid status where=(status ne "ɸѡʧ��"));by studyid pub_rid subjid;run;
/*proc sort data=edc.visittable out=visittable(keep=studyid visitname visitid domain dmname svnum);by studyid;run;*/
proc sort data=visittable2 out=visittable(keep=studyid visitname visitid domain dmname svnum viscycle cyclenum);by studyid;run;
proc sql;
	/*������������Ϣ������ӱ�����빹�� �����ܱ�*/
	create table subject_visittable as select compress(pub_rid) as pub_rid ,a.studyid,a.siteid,subjid,status,b.visitname,visitid,domain,dmname,svnum,viscycle,cyclenum from subject as a full join visittable as b on a.studyid=b.studyid
	where visitname not in(&specialvisit.); /*ȥ������Ҫ����ҳ��ȱʧ*/
	alter table work.subject_visittable
 	 modify pub_rid char(20) format=$20.;
	/*�������������еķ�������*/
	create table subject_v_sv as select a.*,b.&visdat. from subject_visittable as a left join derived.sv as b on a.subjid=b.subjid and a.visitname=b.&visit. and a.viscycle=b.viscycle;
	
quit;
/*�����˲���ܱ����и��������ӵ��ܱ�*/
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
/*ȥ����ѡ��δ�ɼ���crf*/
/*data uncollect;*/
/*	length svnum $20;*/
/*	set derived.uncollect(keep=recordid svnum visitnum visitnum tableid status where=(status='��ȷ��') rename=(svnum=svnum1));*/
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
/*���������������ƽ���ҳ�����ж��Ƿ��������*/
data ds1;
	set derived.&ds1.(keep=subjid  pub_tid);
	rename pub_tid=ds1;
run;
proc sort data=ds1;by subjid;run;


proc sql;
	create table sub_v_sv_hc as select a.*,b.ds1 from sub_uncollect as a left join ds1 as b on a.subjid=b.subjid;
quit;

/*�����з������ڵģ����޷������ڵķ���*/
data prefinal1 prefinal_1;
	set sub_v_sv_hc;
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
	keep subjid visdat_ visitid cyclenum;

proc sort data=sv_1 nodupkeys;by _all_;run;

proc sql;
	create table prefinal_2 as select a.*,b.visdat_ from prefinal_1 as a left join sv_1 as b on a.subjid=b.subjid 
	and ( (compress(a.visitid) ^in ("7","8") and  input(a.visitid,best.)+1=input(b.visitid,best.) ) or (a.cyclenum ne . and a.cyclenum+1=b.cyclenum)) ;

	create table prefinal_3 as select *,count(*) as crfnum,count(jl) as crfnum1 from prefinal_2 group by subjid,visitid;
quit;
/*�������ھ�����15�죬�����¸���������д�������û����ҷǷ���ȱʧ*/
data prefinal_4;
	set prefinal_3;
	if (crfnum1 ne crfnum and jl='' and crfnum1 ne 0) or (visitname="C4�����" ) ;
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
left join   derived.lb as e on a.subjid=e.subjid  and a.domain=e.pub_tid  and a.viscycle=e.viscycle and compress(e.lbcat)=compress(tranwrd(tranwrd(a.dmname,"ʵ���Ҽ��("," "),")","")) and e.visitnum="8"
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
	if visitname="C4�����" then do;if pub_ridcyc = "" ;end;
	if ^missing(&visdat.)  then 
	day=today()-input(&visdat.,yymmdd10.)-15;
	visitnum=input(visitid,best.);
	keep studyid siteid subjid status visitname visitnum  viscycle dmname &visdat. day;
	label day ='ҳ��ȱʧ�ݽ�����' visitnum="�������" viscycle="��������";
run;
proc sort data=edc.crfmiss;by subjid visitnum viscycle ;run;




proc sql;
create table edc.qscrfview as
select qscrfview.siteid as siteid,
count(*) as qscrf 'ҳ��ȱʧ��' from edc.crfmiss qscrfview group by qscrfview.siteid
;
quit;

data out.l3(label="ҳ��ȱʧ����") ;set edc.crfmiss;run;
