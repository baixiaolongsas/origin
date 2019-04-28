/*soh**********************************************************************************
CODE NAME                 : <DC_L6_BXL.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <肿瘤核查> 
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



***********************************************主程序******************************************************;
/*找出最大病灶数*/
proc sql noprint; select max(input(lesionno,best.)) into :num from derived.rst1;quit;
proc sql noprint; select compress(put(max(input(lesionno,best.)),3.)) into :num1 from derived.rst1;quit;

proc sql noprint; select max(input(lesionno,best.)) into :nnum from derived.rsnt1;quit;
proc sql noprint; select compress(put(max(input(lesionno,best.)),3.)) into :nnum1 from derived.rsnt1;quit;

/*****************************靶病灶直径总和核查*************************************/

/*挑选变量受试者代码、状态、性别、年龄、方式阶段、EDC直径总和*/
proc sql;
  create table pre1 as 
  select a.subjid,b.status,c.sex,c.age,a.visstage,a.rsdiatot'本评估期靶病灶直径总和（EDC)'
  from derived.rsnl as a 
      left join derived.subject as b on a.subjid=b.subjid
	      left join derived.dm as c on a.subjid=c.subjid
  order by subjid,visstage;
quit;

/*提取每个病灶及直径，转置后合并*/
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
  
/*将把病灶序号与直径按照模板进行变量排序，并给予标签*/
%macro rsporres;
%do i=1 %to 8; 
data rsporres&i.;
  set pre2;
  label bz&i.="病灶&i." rs&i.="径直&i";
  if rs&i. ne '' then rsporres_&i.=input(rs&i.,best.);
  keep subjid status sex age visstage bz&i. rs&i. rsporres_&i.;
run;
%end;
data pre3;
  merge rsporres:;
  by subjid  visstage;
  rsporres_sum=round(sum(of rsporres_1-rsporres_8),0.01);
  label rsporres_sum="本评估期靶病灶直径总和（SAS)";
  drop rsporres_1-rsporres_8;
run;
%mend;
%rsporres;

/*合并EDC直径与SAS直径*/
proc sql;
  create table pre as 
  select b.*,a.rsdiatot
  from pre1 as a right join pre3 as b on a.subjid=b.subjid and a.visstage=b.visstage;
quit;
/*给warning*/
data final_rsdiatot;
  set pre;
  length warning $500;
  if rsdiatot='' or rsdiatot='uk' or rsdiatot='无法测量' or rsdiatot='NA' or rsdiatot='UK' or rsdiatot='未评价' then warning='rsnl表靶病灶直径和有缺失';
  else if rsporres_sum ne round(input(rsdiatot,best.),0.01) then warning="EDC填写的目标病灶径值总和与计算出来的径值总和不一致，请核实";
  label warning ="提醒";
run;
data out.L6(label=目标病灶径直总和);
  set final_rsdiatot;
run;


/********************************************目标病灶疗效评估*****************************************/
/*挑选目标靶病灶疗效评估所需变量*/
proc sql;
  create table target1 as
  select pub_tid,
       visstage,
	   trsdat,
	   input(compress(rsdiatot,'0123456789.','k'),best.) as rsdiatot "本评估期靶病灶直径总和(mm)",
	   rsevltl,
	   subjid
  from derived.rsnl;
quit;
proc sort data=target1;
by subjid trsdat;
run;

/*建立靶病灶疗效评价所需变量*/
data target2;
  set target1;
  retain baseline;
  by subjid;
  if first.subjid and index(visstage,"筛选期") ne 0 then baseline=rsdiatot;
  if first.subjid and index(visstage,"筛选期") = 0  then baseline=.;
  label baseline="基线期靶病灶直径总和(mm)";
run;

data target3;
  set target2;
  by subjid;
  if baseline ne . then do;
    absolute=dif(rsdiatot);  
    if first.subjid then absolute=.;
    if rsdiatot ne . then relative=round((rsdiatot-baseline)/baseline*100,0.01);
  end; 
  label relative="（当前-基线）/基线(%)" absolute="直径总和的绝对值增加（mm）";
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
  label increase="（当前-最小直径）/最小直径(%)";
run;

/*判定疗效*/
data target5;
set target4;
length efficacy $500;
if index(visstage,"筛选期") ne 0 then efficacy="不适用";
if index(visstage,"筛选期") = 0 then do;
   if rsdiatot = . or baseline=. then efficacy='缺少基线期/本评估期靶病灶直径总和';
   if rsdiatot ne . and baseline ne .  then do;
       if rsdiatot=0 or rsdiatot<10 then efficacy="完全缓解";
       if relative <=-30 then  efficacy="部分缓解";
       else if increase>=20 and absolute>=5 then efficacy="疾病进展";     
       else efficacy="疾病稳定";
   end;
end;
label efficacy="靶病灶疗效评估（SAS结果）";
run;
data pre_efficacy;
  set target5;  
  if rsevltl ne '' and efficacy ne rsevltl then warning="EDC与SAS结果不一致";
  label warning="提醒";
run;
proc sql;
  create table final_efficacy as
  select subjid,
       pub_tid,
       visstage, 
       trsdat,
       put(baseline,best.) as baseline "基线期靶病灶直径总和(mm)",
       put(rsdiatot,best.) as rsdiatot "本评估期靶病灶直径总和(mm)",
       rsevltl,
       put(relative,best.) as relative "（当前-基线）/基线(%)",
       put(increase,best.) as increase "（当前-最小直径）/最小直径(%)",
       put(absolute,best.) as absolute "直径总和的绝对值增加（mm）",  
       efficacy, 
       warning
  from pre_efficacy;
quit;

data out.L7(label=目标病灶疗效评估);
  set final_efficacy ;
run;


/************************************肿瘤疗效总评估***************************************/
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


/*根据疗效标准，判定疗效*/
/*data sumef2;*/
/*  set sumef1;*/
/*  length sumef $20;*/
/*  if index(visstage,"筛选期") = 0 then do;*/
/*     if rsevltl="CR" and rsevlnt="CR" and nlyn="否" then sumef="CR";*/
/*     else if (rsevltl="CR" and (rsevlnt="非CR/非PD" or rsevlnt="不能评估(NE)") and nlyn="否")*/
/*             or (rsevltl="PR" and (rsevlnt ne "PD" or rsevlnt="不能评估(NE)")and nlyn="否") then sumef="PR";*/
/*     else if rsevltl="SD" and (rsevlnt ne "PD" or rsevlnt="不能评估(NE)") and nlyn="否" then sumef="SD";*/
/*     else if rsevltl="不能评估(NE)" and rsevlnt ne "疾病进展(PD)" and nlyn="否" then sumef="不能评估(NE)";*/
/*     else if (rsevltl="PD" and (nlyn="否" or nlyn="是")) or (rsevlnt="PD" and (nlyn="否" or nlyn="是")) or nlyn="是" then sumef="PD";*/
/*  end;*/
/*label sumef="本评估期肿瘤疗效总评估(SAS)";*/
/*run;*/
data sumef2;
  set sumef1;
  length sumef $20;
  if index(visstage,"筛选期") ne 0 then sumef="不适用";
  if index(visstage,"筛选期") = 0 then do;
     if rsevltl="完全缓解" and rsevlnt="完全缓解" and nlyn="否" then sumef="完全缓解";
     else if (rsevltl="完全缓解" and rsevlnt="非完全缓解/非疾病进展" and nlyn="否")
             or (rsevltl="部分缓解" and rsevlnt ne "疾病进展" and nlyn="否") then sumef="部分缓解";
     else if rsevltl="疾病稳定" and (rsevlnt ne "疾病进展" ) and nlyn="否" then sumef="疾病稳定";
     else if (rsevltl="疾病进展" and (nlyn="否" or nlyn="是")) or (rsevlnt="疾病进展" and (nlyn="否" or nlyn="是")) or nlyn="是" then sumef="疾病进展";
  end;
  if rsevltl="未评价" or rsevlnt="未评价" then sumef="未评价";
label sumef="本评估期肿瘤疗效总评估(SAS)";
run;


data final_sumef;
  set sumef2;
  if rsevltot ne sumef then warning="EDC总评估结果与SAS不一致"; 
  label warning="提醒";
run; 

data out.L8(label=肿瘤疗效总评估);
  set final_sumef ;
run;



/****************************************************目标病灶评估日期核查***************************************************/
/*挑选所需变量*/
proc sql;
  create table rsdat1 as 
  select a.subjid,b.status,a.visstage,input(a.rsdat,yymmdd10.) as rsdat,a.lesionno, compress('mb'||a.lesionno) as mb 
  from derived.rst1 as a left join derived.subject as b on a.subjid=b.subjid   
  order by subjid,a.visstage,a.lesionno;
quit;
proc sort data=rsdat1 nodupkeys; by subjid visstage lesionno;run;
/*转置检查日期,计算最小评估日期*/
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
  label mb&i.="目标病灶&i.检查日期";
  keep subjid status  visstage mb&i.; 
run;
%end;
data rsdat3;
  merge rsdatn:;
  format mindat yymmdd10.;
  by subjid status visstage;
  mindat=min(of mb1-mb&num1.);
  label mindat='目标病灶最早日期(SAS)';
run;
%mend;
%trsdate;

/*合并评估日期至检查日期*/
proc sql;
  create table rsdat4 as 
  select a.*,b.trsdat '目标病灶评估日期（EDC）'
  from rsdat3 as a left join derived.rsnl as b on a.subjid=b.subjid and a.visstage=b.visstage
  order by subjid,trsdat;
quit;

/*判断后给出warning*/
data final_rsdat;
  set rsdat4;
  length warning $500;
  if trsdat='' then warning='EDC评估日期为空';
  else if  mindat ne input(trsdat,yymmdd10.) then do; 
       warning='评估日期与最早检查日期不一致'; 
       d=input(trsdat,yymmdd10.)-mindat;
  end;
  label warning="提醒"
        d='差值';
run;

data out.L9(label=目标病灶评估日期);
  set  final_rsdat;
run;

     





/****************************************************非目标病灶评估日期核查***************************************************/
/*挑选所需变量*/
proc sql;
  create table nrsdat1 as 
  select a.subjid,b.status,a.visstage,input(a.rsdat,yymmdd10.) as rsdat,a.lesionno, compress('mb'||a.lesionno) as mb 
  from derived.rsnt1 as a left join derived.subject as b on a.subjid=b.subjid   
  order by subjid,a.visstage,a.lesionno;
quit;

proc sort data=nrsdat1 nodupkeys; by subjid visstage lesionno;run;
/*转置检查日期,计算最小评估日期*/
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
  label mb&i.="非目标病灶&i.检查日期";
  keep subjid status  visstage mb&i.; 
run;
%end;
data nrsdat3;
  merge nrsdatn:;
  format mindat yymmdd10.;
  by subjid status visstage;
  mindat=min(of mb1-mb&num1.);
  label mindat='非目标病灶最早日期(SAS)';
run;
%mend;
%ntrsdate;

/*合并评估日期至检查日期*/
proc sql;
  create table nrsdat4 as 
  select a.*,b.ntrsdat '非目标病灶评估日期（EDC）'
  from nrsdat3 as a left join derived.rsnl as b on a.subjid=b.subjid and a.visstage=b.visstage
  order by subjid,ntrsdat;
quit;

/*判断后给出warning*/
data final_nrsdat;
  set nrsdat4;
  length warning $500;
  if ntrsdat='' then warning='EDC评估日期为空';
  else if  mindat ne input(ntrsdat,yymmdd10.) then do; 
       warning='评估日期与最早检查日期不一致'; 
       d=input(ntrsdat,yymmdd10.)-mindat;
  end;
  label warning="提醒"
        d='差值';
run;

data out.L10(label=非目标病灶评估日期);
set final_nrsdat;
run;
     



/**********************************************靶病灶测量方法核查***********************************************/
/*挑选核查所需变量*/
proc sql;
create table rsmethod1 as
select coalesce(a.subjid,b.subjid) as subjid "受试者编号",
       coalesce(a.lesionno,b.sn) as sn "靶病灶序号",
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
if rsmethod ne "其他" and first.sn then x=rsmethod;
else if rsmethod="其他" and first.sn then x=rsmethdo;
run;

data final_rsmethod;
set rsmethod2;
if (rsmethod ne "其他" and rsmethod=x) or (rsmethod="其他" and rsmethdo=x) then warning="是";
else warning="否";
label warning="测量方法是否一致";
drop x;
run;

data out.L11(label=靶病灶测量不一致);
set final_rsmethod;
run;


/**********************************************非靶病灶测量方法核查***********************************************/
/*挑选核查所需变量*/
proc sql;
create table nrsmethod1 as
select coalesce(a.subjid,b.subjid) as subjid "受试者编号",
       coalesce(a.lesionno,b.sn) as sn "非靶病灶序号",
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
if rsmethod ne "其他" and first.sn then x=rsmethod;
else if rsmethod="其他" and first.sn then x=rsmethdo;
run;

data final_nrsmethod;
set nrsmethod2;
if (rsmethod ne "其他" and rsmethod=x) or (rsmethod="其他" and rsmethdo=x) then warning="是";
else warning="否";
label warning="测量方法是否一致";
drop x;
run;

data out.L12(label=靶病灶测量不一致);
set final_nrsmethod;
run;


/*********************************************靶病灶测量与评估缺失*************************************************/
/*挑选核查所需变量*/
proc sql;
create table tcheck1 as
select coalesce(a.subjid,c.subjid) as subjid '受试者代码',
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
	   c.visstage as rsnvis "rsnl访视阶段",
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
if missing(rsdat) and missing(trsdat)=0 then warning="测量缺失";
else if missing(rsdat)=0 and missing(trsdat) then warning="评估缺失";
label warning="提醒";
run;

data out.L13(label=靶病灶测量评估缺失);
set final_tcheck;
run;


/*********************************************非靶病灶测量与评估缺失*************************************************/
/*挑选核查所需变量*/
proc sql;
create table ntcheck1 as
select coalesce(a.subjid,c.subjid) as subjid '受试者代码',
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
	   c.visstage as rsnvis "rsnl访视阶段",
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
if missing(rsdat) and missing(ntrsdat)=0 then warning="测量缺失";
else if missing(rsdat)=0 and missing(ntrsdat) then warning="评估缺失";
label warning="提醒";
run;

data out.L14(label=非靶病灶测量评估缺失);
set final_ntcheck;
run;


/*********************************************靶病灶测量与访视缺失*************************************************/
/*挑选核查所需变量*/
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
  select coalesce(a.subjid,b.subjid) as subjid "受试者编号",
       coalesce(a.status,b.status) as status '受试者状态',
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
  where b.svstage in ('V0_筛选期(-14D)','V11_(C4:D42)','V13_(C5:D42)','V15_(C6:D42)','V17_(C7:D42)','V19_(C8:D42)','V21_(C9:D42)','V23_(C10:D42)','V25_(C11:D42)','V29_(C13:D42)','V31_(C14:D42)','V33_(C15:D42)','V4_(C1:D42)','V7_(C2:D42)','V99_退出前检查','V9_(C3:D42)');
quit;

data final_visit;
set pre1;
length warning $500;
if missing(visstage) and missing(svstage)=0 then warning="测量缺失";
else if missing(visstage)=0 and missing(svstage) then warning="访视缺失";
label warning="提醒";
drop lesionno;
run;
data out.L15(label=靶病灶测量访视缺失);
set final_visit;
run;



/*********************************************非靶病灶测量与访视缺失*************************************************/
/*挑选核查所需变量*/
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
  select coalesce(a.subjid,b.subjid) as subjid "受试者编号",
       coalesce(a.status,b.status) as status '受试者状态',
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
  where b.svstage in ('V0_筛选期(-14D)','V11_(C4:D42)','V13_(C5:D42)','V15_(C6:D42)','V17_(C7:D42)','V19_(C8:D42)','V21_(C9:D42)','V23_(C10:D42)','V25_(C11:D42)','V29_(C13:D42)','V31_(C14:D42)','V33_(C15:D42)','V4_(C1:D42)','V7_(C2:D42)','V99_退出前检查','V9_(C3:D42)');
quit;

data final_nvisit;
set pre1;
length warning $500;
if missing(visstage) and missing(svstage)=0 then warning="测量缺失";
else if missing(visstage)=0 and missing(svstage) then warning="访视缺失";
label warning="提醒";
drop lesionno;
run;

data out.L16(label=非靶病灶测量访视缺失);
set final_nvisit;
run;







