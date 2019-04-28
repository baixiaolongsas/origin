/*soh**********************************************************************************
CODE NAME                 : <DC_L6_BXL.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <�����˲�> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < all>
OUTPUT                    : < none >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & baixiaolong	
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		
--------------------------------------------------------------------------;*/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;



***********************************************������******************************************************;
/*�ҳ��������*/
proc sql noprint; select max(input(lesionno,best.)) into :num from derived.rst1;quit;
proc sql noprint; select compress(put(max(input(lesionno,best.)),3.)) into :num1 from derived.rst1;quit;

proc sql noprint; select max(input(lesionno,best.)) into :nnum from derived.rsnt1;quit;
proc sql noprint; select compress(put(max(input(lesionno,best.)),3.)) into :nnum1 from derived.rsnt1;quit;

/*****************************�в���ֱ���ܺͺ˲�*************************************/

/*��ѡ���������ߴ��롢״̬���Ա����䡢��ʽ�׶Ρ�EDCֱ���ܺ�*/
proc sql;
  create table pre1 as 
  select a.subjid,b.status,c.sex,c.age,a.visstage,a.rsdiatot'�������ڰв���ֱ���ܺͣ�EDC)'
  from derived.rsnl as a 
      left join derived.subject as b on a.subjid=b.subjid
	      left join derived.dm as c on a.subjid=c.subjid
  order by subjid,visstage;
quit;

/*��ȡÿ�����ֱ����ת�ú�ϲ�*/
proc sql;
  create table rst1 as 
  select a.subjid,c.status,d.sex,d.age,a.visstage,input(a.lesionno,best.) as lesionno,b.rsloc,compress(a.rsporres,'0123456789.','k') as rsporres
  from derived.rst1 as a left join derived.rst as b on a.subjid=b.subjid and a.lesionno=b.sn
      left join derived.subject as c on a.subjid=c.subjid
	      left join derived.dm as d on a.subjid=d.subjid
  order by subjid, visstage, lesionno;
quit;
proc sort; by subjid visstage lesionno;run;


proc transpose data=rst1 out=rst1_1(drop=_NAME_ _LABEL_) prefix=bz ;
  var rsloc;
  by subjid status sex age visstage;
run;
proc transpose data=rst1 out=rst1_2 (drop=_NAME_ ) prefix=rs;
  var rsporres;
  by subjid status sex age visstage;
  
run;
data pre2;
  merge rst1_1 rst1_2;
  by subjid visstage ;
run;
  
/*���Ѳ��������ֱ������ģ����б������򣬲������ǩ*/
%macro rsporres;
%do i=1 %to 8; 
data rsporres&i.;
  set pre2;
  label bz&i.="����&i." rs&i.="��ֱ&i";
  if rs&i. ne '' then rsporres_&i.=input(rs&i.,best.);
  keep subjid status sex age visstage bz&i. rs&i. rsporres_&i.;
run;
%end;
data pre3;
  merge rsporres:;
  by subjid  visstage;
  rsporres_sum=round(sum(of rsporres_1-rsporres_8),0.01);
  label rsporres_sum="�������ڰв���ֱ���ܺͣ�SAS)";
  drop rsporres_1-rsporres_8;
run;
%mend;
%rsporres;

/*�ϲ�EDCֱ����SASֱ��*/
proc sql;
  create table pre as 
  select b.*,a.rsdiatot
  from pre1 as a right join pre3 as b on a.subjid=b.subjid and a.visstage=b.visstage;
quit;
/*��warning*/
data final_rsdiatot;
  set pre;
  length warning $500;
  if rsdiatot='' or rsdiatot='uk' or rsdiatot='�޷�����' or rsdiatot='NA' or rsdiatot='UK' or rsdiatot='δ����' then warning='rsnl��в���ֱ������ȱʧ';
  else if rsporres_sum ne round(input(rsdiatot,best.),0.01) then warning="EDC��д��Ŀ�겡�ֵ�ܺ����������ľ�ֵ�ܺͲ�һ�£����ʵ";
  label warning ="����";
run;
data out.L6(label=Ŀ�겡�ֱ�ܺ�);
  set final_rsdiatot;
run;


/********************************************Ŀ�겡����Ч����*****************************************/
/*��ѡĿ��в�����Ч�����������*/
proc sql;
  create table target1 as
  select pub_tid,
       visstage,
	   trsdat,
	   input(compress(rsdiatot,'0123456789.','k'),best.) as rsdiatot "�������ڰв���ֱ���ܺ�(mm)",
	   rsevltl,
	   subjid
  from derived.rsnl;
quit;
proc sort data=target1;
by subjid trsdat;
run;

/*�����в�����Ч�����������*/
data target2;
  set target1;
  retain baseline;
  by subjid;
  if first.subjid and index(visstage,"ɸѡ��") ne 0 then baseline=rsdiatot;
  if first.subjid and index(visstage,"ɸѡ��") = 0  then baseline=.;
  label baseline="�����ڰв���ֱ���ܺ�(mm)";
run;

data target3;
  set target2;
  by subjid;
  if baseline ne . then do;
    absolute=dif(rsdiatot);  
    if first.subjid then absolute=.;
    if rsdiatot ne . then relative=round((rsdiatot-baseline)/baseline*100,0.01);
  end; 
  label relative="����ǰ-���ߣ�/����(%)" absolute="ֱ���ܺ͵ľ���ֵ���ӣ�mm��";
run;
data target4(drop=min);
  set target3;
  by subjid;
  retain min;
  if baseline ne . and rsdiatot ne . then do;
     if first.subjid then min=rsdiatot;
     min=min(min,rsdiatot);
     if rsdiatot=min then increase=0;
     else  increase=(rsdiatot-min)/min*100;
  end;
  label increase="����ǰ-��Сֱ����/��Сֱ��(%)";
run;

/*�ж���Ч*/
data target5;
set target4;
length efficacy $500;
if index(visstage,"ɸѡ��") ne 0 then efficacy="������";
if index(visstage,"ɸѡ��") = 0 then do;
   if rsdiatot = . or baseline=. then efficacy='ȱ�ٻ�����/�������ڰв���ֱ���ܺ�';
   if rsdiatot ne . and baseline ne .  then do;
       if rsdiatot=0 or rsdiatot<10 then efficacy="��ȫ����";
       if relative <=-30 then  efficacy="���ֻ���";
       else if increase>=20 and absolute>=5 then efficacy="������չ";     
       else efficacy="�����ȶ�";
   end;
end;
label efficacy="�в�����Ч������SAS�����";
run;
data pre_efficacy;
  set target5;  
  if rsevltl ne '' and efficacy ne rsevltl then warning="EDC��SAS�����һ��";
  label warning="����";
run;
proc sql;
  create table final_efficacy as
  select subjid,
       pub_tid,
       visstage, 
       trsdat,
       put(baseline,best.) as baseline "�����ڰв���ֱ���ܺ�(mm)",
       put(rsdiatot,best.) as rsdiatot "�������ڰв���ֱ���ܺ�(mm)",
       rsevltl,
       put(relative,best.) as relative "����ǰ-���ߣ�/����(%)",
       put(increase,best.) as increase "����ǰ-��Сֱ����/��Сֱ��(%)",
       put(absolute,best.) as absolute "ֱ���ܺ͵ľ���ֵ���ӣ�mm��",  
       efficacy, 
       warning
  from pre_efficacy;
quit;

data out.L7(label=Ŀ�겡����Ч����);
  set final_efficacy ;
run;


/************************************������Ч������***************************************/
proc sql;
create table sumef1 as 
select subjid,
       visstage,
	   trsdat,
	   rsdiatot,
	   rsevltl,
	   rsevltc,
	   ntrsdat,
	   rsevlnt,
	   rsevlntc,
	   nlyn,
	   rsevltot
from derived.rsnl
order by subjid,visstage ;
quit;


/*������Ч��׼���ж���Ч*/
/*data sumef2;*/
/*  set sumef1;*/
/*  length sumef $20;*/
/*  if index(visstage,"ɸѡ��") = 0 then do;*/
/*     if rsevltl="CR" and rsevlnt="CR" and nlyn="��" then sumef="CR";*/
/*     else if (rsevltl="CR" and (rsevlnt="��CR/��PD" or rsevlnt="��������(NE)") and nlyn="��")*/
/*             or (rsevltl="PR" and (rsevlnt ne "PD" or rsevlnt="��������(NE)")and nlyn="��") then sumef="PR";*/
/*     else if rsevltl="SD" and (rsevlnt ne "PD" or rsevlnt="��������(NE)") and nlyn="��" then sumef="SD";*/
/*     else if rsevltl="��������(NE)" and rsevlnt ne "������չ(PD)" and nlyn="��" then sumef="��������(NE)";*/
/*     else if (rsevltl="PD" and (nlyn="��" or nlyn="��")) or (rsevlnt="PD" and (nlyn="��" or nlyn="��")) or nlyn="��" then sumef="PD";*/
/*  end;*/
/*label sumef="��������������Ч������(SAS)";*/
/*run;*/
data sumef2;
  set sumef1;
  length sumef $20;
  if index(visstage,"ɸѡ��") ne 0 then sumef="������";
  if index(visstage,"ɸѡ��") = 0 then do;
     if rsevltl="��ȫ����" and rsevlnt="��ȫ����" and nlyn="��" then sumef="��ȫ����";
     else if (rsevltl="��ȫ����" and rsevlnt="����ȫ����/�Ǽ�����չ" and nlyn="��")
             or (rsevltl="���ֻ���" and rsevlnt ne "������չ" and nlyn="��") then sumef="���ֻ���";
     else if rsevltl="�����ȶ�" and (rsevlnt ne "������չ" ) and nlyn="��" then sumef="�����ȶ�";
     else if (rsevltl="������չ" and (nlyn="��" or nlyn="��")) or (rsevlnt="������չ" and (nlyn="��" or nlyn="��")) or nlyn="��" then sumef="������չ";
  end;
  if rsevltl="δ����" or rsevlnt="δ����" then sumef="δ����";
label sumef="��������������Ч������(SAS)";
run;


data final_sumef;
  set sumef2;
  if rsevltot ne sumef then warning="EDC�����������SAS��һ��"; 
  label warning="����";
run; 

data out.L8(label=������Ч������);
  set final_sumef ;
run;



/****************************************************Ŀ�겡���������ں˲�***************************************************/
/*��ѡ�������*/
proc sql;
  create table rsdat1 as 
  select a.subjid,b.status,a.visstage,input(a.rsdat,yymmdd10.) as rsdat,a.lesionno, compress('mb'||a.lesionno) as mb 
  from derived.rst1 as a left join derived.subject as b on a.subjid=b.subjid   
  order by subjid,a.visstage,a.lesionno;
quit;
proc sort data=rsdat1 nodupkeys; by subjid visstage lesionno;run;
/*ת�ü������,������С��������*/
proc transpose data=rsdat1 out=rsdat2(drop=_NAME_);
var rsdat;
by subjid status visstage;
id mb;
run;
%macro trsdate;
%do i=1 %to &num.;
data rsdatn&i.;
  set rsdat2; 
  format mb&i. yymmdd10.;
  label mb&i.="Ŀ�겡��&i.�������";
  keep subjid status  visstage mb&i.; 
run;
%end;
data rsdat3;
  merge rsdatn:;
  format mindat yymmdd10.;
  by subjid status visstage;
  mindat=min(of mb1-mb&num1.);
  label mindat='Ŀ�겡����������(SAS)';
run;
%mend;
%trsdate;

/*�ϲ������������������*/
proc sql;
  create table rsdat4 as 
  select a.*,b.trsdat 'Ŀ�겡���������ڣ�EDC��'
  from rsdat3 as a left join derived.rsnl as b on a.subjid=b.subjid and a.visstage=b.visstage
  order by subjid,trsdat;
quit;

/*�жϺ����warning*/
data final_rsdat;
  set rsdat4;
  length warning $500;
  if trsdat='' then warning='EDC��������Ϊ��';
  else if  mindat ne input(trsdat,yymmdd10.) then do; 
       warning='�������������������ڲ�һ��'; 
       d=input(trsdat,yymmdd10.)-mindat;
  end;
  label warning="����"
        d='��ֵ';
run;

data out.L9(label=Ŀ�겡����������);
  set  final_rsdat;
run;

     





/****************************************************��Ŀ�겡���������ں˲�***************************************************/
/*��ѡ�������*/
proc sql;
  create table nrsdat1 as 
  select a.subjid,b.status,a.visstage,input(a.rsdat,yymmdd10.) as rsdat,a.lesionno, compress('mb'||a.lesionno) as mb 
  from derived.rsnt1 as a left join derived.subject as b on a.subjid=b.subjid   
  order by subjid,a.visstage,a.lesionno;
quit;

proc sort data=nrsdat1 nodupkeys; by subjid visstage lesionno;run;
/*ת�ü������,������С��������*/
proc transpose data=nrsdat1 out=nrsdat2(drop=_NAME_) ;
var rsdat;
by subjid status visstage;
id mb;
run;
%macro ntrsdate;
%do i=1 %to &num.;
data nrsdatn&i.;
  set nrsdat2; 
  format mb&i. yymmdd10.;
  label mb&i.="��Ŀ�겡��&i.�������";
  keep subjid status  visstage mb&i.; 
run;
%end;
data nrsdat3;
  merge nrsdatn:;
  format mindat yymmdd10.;
  by subjid status visstage;
  mindat=min(of mb1-mb&num1.);
  label mindat='��Ŀ�겡����������(SAS)';
run;
%mend;
%ntrsdate;

/*�ϲ������������������*/
proc sql;
  create table nrsdat4 as 
  select a.*,b.ntrsdat '��Ŀ�겡���������ڣ�EDC��'
  from nrsdat3 as a left join derived.rsnl as b on a.subjid=b.subjid and a.visstage=b.visstage
  order by subjid,ntrsdat;
quit;

/*�жϺ����warning*/
data final_nrsdat;
  set nrsdat4;
  length warning $500;
  if ntrsdat='' then warning='EDC��������Ϊ��';
  else if  mindat ne input(ntrsdat,yymmdd10.) then do; 
       warning='�������������������ڲ�һ��'; 
       d=input(ntrsdat,yymmdd10.)-mindat;
  end;
  label warning="����"
        d='��ֵ';
run;

data out.L10(label=��Ŀ�겡����������);
set final_nrsdat;
run;
     



/**********************************************�в�����������˲�***********************************************/
/*��ѡ�˲��������*/
proc sql;
create table rsmethod1 as
select coalesce(a.subjid,b.subjid) as subjid "�����߱��",
       coalesce(a.lesionno,b.sn) as sn "�в������",
       visstage,
	   rsmethod,
	   rsmethdo,
       rsdat,
	   rsloc,
       rslocoth
from derived.rst1 as a 
left join derived.rst as b
on a.subjid=b.subjid and a.lesionno=b.sn;
quit;
proc sort data=rsmethod1;
by subjid sn rsdat;
run;

data rsmethod2;
set rsmethod1;
length x $500;
by subjid sn;
retain x;
if rsmethod ne "����" and first.sn then x=rsmethod;
else if rsmethod="����" and first.sn then x=rsmethdo;
run;

data final_rsmethod;
set rsmethod2;
if (rsmethod ne "����" and rsmethod=x) or (rsmethod="����" and rsmethdo=x) then warning="��";
else warning="��";
label warning="���������Ƿ�һ��";
drop x;
run;

data out.L11(label=�в��������һ��);
set final_rsmethod;
run;


/**********************************************�ǰв�����������˲�***********************************************/
/*��ѡ�˲��������*/
proc sql;
create table nrsmethod1 as
select coalesce(a.subjid,b.subjid) as subjid "�����߱��",
       coalesce(a.lesionno,b.sn) as sn "�ǰв������",
       visstage,
	   rsmethod,
	   rsmethdo,
       rsdat,
	   rsloc,
       rslocoth
from derived.rsnt1 as a 
left join derived.rsnt as b
on a.subjid=b.subjid and a.lesionno=b.sn;
quit;
proc sort data=nrsmethod1;
by subjid sn rsdat;
run;

data nrsmethod2;
set nrsmethod1;
length x $500;
by subjid sn;
retain x;
if rsmethod ne "����" and first.sn then x=rsmethod;
else if rsmethod="����" and first.sn then x=rsmethdo;
run;

data final_nrsmethod;
set nrsmethod2;
if (rsmethod ne "����" and rsmethod=x) or (rsmethod="����" and rsmethdo=x) then warning="��";
else warning="��";
label warning="���������Ƿ�һ��";
drop x;
run;

data out.L12(label=�в��������һ��);
set final_nrsmethod;
run;


/*********************************************�в������������ȱʧ*************************************************/
/*��ѡ�˲��������*/
proc sql;
create table tcheck1 as
select coalesce(a.subjid,c.subjid) as subjid '�����ߴ���',
       d.status,
	   a.lockstat,
	   a.pgxh,
       a.visstage,
	   a.lesionno,
	   a.rsdat,
	   a.rsmethod,
	   a.rsmethdo,       
	   b.rsloc,
       b.rslocoth,
	   c.visstage as rsnvis "rsnl���ӽ׶�",
	   c.trsdat,
	   c.rsevltl,
	   c.rsevltc	  
from derived.rst1 as a left join derived.rst as b on a.subjid=b.subjid and a.lesionno=b.sn
	 full join derived.rsnl as c on a.subjid=c.subjid and  a.visstage=c.visstage
	      left join derived.subject as d on a.subjid=d.subjid
order by subjid,a.pgxh;
quit;

data final_tcheck;
set tcheck1;
if missing(rsdat) and missing(trsdat)=0 then warning="����ȱʧ";
else if missing(rsdat)=0 and missing(trsdat) then warning="����ȱʧ";
label warning="����";
run;

data out.L13(label=�в����������ȱʧ);
set final_tcheck;
run;


/*********************************************�ǰв������������ȱʧ*************************************************/
/*��ѡ�˲��������*/
proc sql;
create table ntcheck1 as
select coalesce(a.subjid,c.subjid) as subjid '�����ߴ���',
       d.status,
	   a.lockstat,
	   a.pgxh,
       a.visstage,
	   a.lesionno,
	   a.rsdat,
	   a.rsmethod,
	   a.rsmethdo,       
	   b.rsloc,
       b.rslocoth,
	   c.visstage as rsnvis "rsnl���ӽ׶�",
	   c.ntrsdat,
	   c.rsevlnt,
	   c.rsevlntc	   
from derived.rsnt1 as a left join derived.rsnt as b on a.subjid=b.subjid and a.lesionno=b.sn
	 full join derived.rsnl as c on a.subjid=c.subjid and  a.visstage=c.visstage
	      left join derived.subject as d on a.subjid=d.subjid
order by subjid,a.pgxh;
quit;

data final_ntcheck;
set ntcheck1;
if missing(rsdat) and missing(ntrsdat)=0 then warning="����ȱʧ";
else if missing(rsdat)=0 and missing(ntrsdat) then warning="����ȱʧ";
label warning="����";
run;

data out.L14(label=�ǰв����������ȱʧ);
set final_ntcheck;
run;


/*********************************************�в�����������ȱʧ*************************************************/
/*��ѡ�˲��������*/
proc sql;
  create table visit1 as
  select a.subjid,c.status,a.lesionno, a.visstage, a.rsmethod, a.rsmethdo,a.rsdat, b.rsloc, b.rslocoth	   
  from derived.rst1 as a left join derived.subject as c on a.subjid=c.subjid
       left join derived.rst as b	on a.subjid=b.subjid and a.lesionno=b.sn
  order by subjid ,rsdat;
quit;
proc sql;
  create table visit2 as
  select a.subjid , b.status,  a.svstage,	a.svstdat        
  from derived.sv as a left join derived.subject as b on a.subjid=b.subjid
  order by subjid, svstdat ;
quit;

/*
proc freq data=visit1; 
 table visstage;
 run;
proc freq data=visit2; 
 table svstage;
 run;
*/
 
proc sql;
  create table pre1 as 
  select coalesce(a.subjid,b.subjid) as subjid "�����߱��",
       coalesce(a.status,b.status) as status '������״̬',
       lesionno,
       visstage,
	   rsmethod,
	   rsmethdo,
       rsdat,
	   rsloc,
       rslocoth,
	   svstage,
       svstdat	  
  from visit1 as a
  full join visit2 as b
  on a.subjid=b.subjid and a.visstage=b.svstage
  where b.svstage in ('V0_ɸѡ��(-14D)','V11_(C4:D42)','V13_(C5:D42)','V15_(C6:D42)','V17_(C7:D42)','V19_(C8:D42)','V21_(C9:D42)','V23_(C10:D42)','V25_(C11:D42)','V29_(C13:D42)','V31_(C14:D42)','V33_(C15:D42)','V4_(C1:D42)','V7_(C2:D42)','V99_�˳�ǰ���','V9_(C3:D42)');
quit;

data final_visit;
set pre1;
length warning $500;
if missing(visstage) and missing(svstage)=0 then warning="����ȱʧ";
else if missing(visstage)=0 and missing(svstage) then warning="����ȱʧ";
label warning="����";
drop lesionno;
run;
data out.L15(label=�в����������ȱʧ);
set final_visit;
run;



/*********************************************�ǰв�����������ȱʧ*************************************************/
/*��ѡ�˲��������*/
proc sql;
  create table nvisit1 as
  select a.subjid,c.status,a.lesionno, a.visstage, a.rsmethod, a.rsmethdo,a.rsdat, b.rsloc, b.rslocoth	   
  from derived.rsnt1 as a left join derived.subject as c on a.subjid=c.subjid
       left join derived.rsnt as b	on a.subjid=b.subjid and a.lesionno=b.sn
  order by subjid ,rsdat;
quit;
proc sql;
  create table nvisit2 as
  select a.subjid , b.status,  a.svstage,	a.svstdat              
  from derived.sv as a left join derived.subject as b on a.subjid=b.subjid
  order by subjid, svstdat ;
quit;

/*
proc freq data=nvisit1; 
 table visstage;
 run;
proc freq data=nvisit2; 
 table svstage;
 run;
*/

 
proc sql;
  create table pre1 as 
  select coalesce(a.subjid,b.subjid) as subjid "�����߱��",
       coalesce(a.status,b.status) as status '������״̬',
       lesionno,
       visstage,
	   rsmethod,
	   rsmethdo,
       rsdat,
	   rsloc,
       rslocoth,
	   svstage,
       svstdat	
  from nvisit1 as a
  full join nvisit2 as b
  on a.subjid=b.subjid and a.visstage=b.svstage
  where b.svstage in ('V0_ɸѡ��(-14D)','V11_(C4:D42)','V13_(C5:D42)','V15_(C6:D42)','V17_(C7:D42)','V19_(C8:D42)','V21_(C9:D42)','V23_(C10:D42)','V25_(C11:D42)','V29_(C13:D42)','V31_(C14:D42)','V33_(C15:D42)','V4_(C1:D42)','V7_(C2:D42)','V99_�˳�ǰ���','V9_(C3:D42)');
quit;

data final_nvisit;
set pre1;
length warning $500;
if missing(visstage) and missing(svstage)=0 then warning="����ȱʧ";
else if missing(visstage)=0 and missing(svstage) then warning="����ȱʧ";
label warning="����";
drop lesionno;
run;

data out.L16(label=�ǰв����������ȱʧ);
set final_nvisit;
run;







