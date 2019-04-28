/*soh**********************************************************************************
CODE NAME                 : <DC_L18_bxl.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <重复性数据记录核查AE CM lbtest> 
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

/**********AE页中名称一致，日期重叠************/
data ae;
   set derived.ae;
   if aeterm^="";
   sn1=input(sn,best.);
run;
proc sort data=ae;
	by subjid sn1;
run;


 proc sql ;
   create table aecf as
      select a.subjid, 
             a.sn1 "序号",
	    	 a.aeterm,
			 a.aestdat,
			 a.aeouttm as aeendat,
             b.sn1 as sn2 "序号",
			 b.aestdat as aestdat1 "开始日期II",
			 b.aeouttm as aeendat1 "转归日期II"
      from ae as a 
	  left join ae as b
	  on a.subjid=b.subjid and a.aeterm=b.aeterm 
      where a.sn1<b.sn1
      order by subjid,aeterm,sn1;
quit;

data final1;
	 set aecf;
     length  warning $10;
	 if aeendat^='' and aeendat1^='' then do;
	    if aestdat1 >= aeendat then warning='';
		else if aestdat >= aeendat1 then warning='';
		else warning="重叠";
	end;
	if aeendat ='' and aeendat1^='' then do;
	   if aestdat >= aeendat1 then warning=''; 
	   else warning="重叠";
	end;
	if aeendat ^='' and aeendat1 ='' then do;
	   if aestdat1 >= aeendat then warning=''; 
	   else warning="重叠";
	end;
	if aeendat ='' and aeendat1 ='' then warning="重叠";
	label warning="提醒";
run;

data out.L18(label=AE重复性数据核查); set final1; run;

/**********CM页中名称一致，日期重叠************/
data cm;
   set derived.cm;
   if cmtrt^="";
   sn1=input(sn,best.);
run;
proc sort data=cm;
	by subjid sn1;
run;


 proc sql ;
   create table cmcf as
      select a.subjid, 
             a.sn1 "序号",
	    	 a.cmtrt,
			 a.cmstdat ,
			 a.cmendat   ,
             b.sn1 as sn2 "合并用药序号",
			 b.cmstdat as cmstdat1 "合并用药开始日期" ,
			 b.cmendat as cmendat1 "合并用药结束日期"  
      from cm as a 
	  left join cm as b
	  on a.subjid=b.subjid and a.cmtrt=b.cmtrt where  a.sn1<b.sn1;
quit;

data final2;
	 set cmcf;
     length  warning $10;	
	 if cmendat^='' and cmendat1^='' then do;
	    if cmstdat1 >= cmendat then warning='';
		else if cmstdat >= cmendat1 then warning='';
		else warning="重叠";
	end;
	if cmendat ='' and cmendat1^='' then do;
	   if cmstdat >= cmendat1 then warning=''; 
	   else warning="重叠";
	end;
	if cmendat ^='' and cmendat1 ='' then do;
	   if cmstdat1 >= cmendat then warning=''; 
	   else warning="重叠";
	end;
	if cmendat ='' and cmendat1 ='' then warning="重叠";
	label warning="提醒";
run;

data out.L19(label=CM重复性数据核查); set final2; run;

/******************实验室检查（包括计划外检查项目表），检查项目、检查日期、检查结果重复性核查*********************/

/*LBB*/
data prelbb;
  set raw.lbb;
visitnum=put(svstage,$10.);
label visitnum="访视编号";
run;

proc sql;
  create table lbb as select
a.*,b.visitnum
from derived.lbb as a left join prelbb as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;


data lbb1;
  set lbb(rename=(lbbdat=dat) where=(yn="是"));
  length lbtest $100 unit $10 sig $20;
lbtest="血红蛋白（Hb）";res=hbores;unit=hboresu;sig=hbclsig;output;
lbtest="红细胞（RBC）";res=rbcores;unit=rbcoresu;sig=rbcclsig;output;
lbtest="白细胞（WBC）";res=wbcores;unit=wbcoresu;sig=wbcclsig;output;
lbtest="中性粒细胞（ANC）";res=neuores;unit=neuoresu;sig=neuclsig;output;
lbtest="血小板计数（PLT）";res=pltores;unit=pltoresu;sig=pltclsig;output;
keep pub_rid lockstat subjid svstage visitnum pub_tname lbtest res unit sig dat lastmodifytime; 
run;

/*LBC*/
data prelbc;
  set raw.lbc;
visitnum=put(svstage,$10.);
label visitnum="访视编号";
run;

proc sql;
  create table lbc as select
a.*,b.visitnum
from derived.lbc as a left join prelbc as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;

data lbc1;
  set lbc(rename=(lbcdat=dat) where=(yn="是"));
    length lbtest $100 unit $10 sig $20;
lbtest="总胆红素(TBIL)";res=tbilores;unit=tbilorsu;sig=tbilclsg;output;
lbtest="直接胆红素（DBIL）";res=dbilores;unit=dbilorsu;sig=dbilclsg;output;
lbtest="谷丙转氨酶（ALT）";res=altores;unit=altoresu;sig=altclsig;output;
lbtest="谷草转氨酶（AST）";res=astores;unit=astoresu;sig=astclsig;output;
lbtest="谷氨酰转移酶(GGT)";res=ggtores;unit=ggtoresu;sig=ggtclsig;output;
lbtest="总蛋白（TP）";res=tporres;unit=tporresu;sig=tpclsig;output;
lbtest="白蛋白（ALB）";res=albores;unit=alboresu;sig=albclsig;output;
lbtest="尿素氮（BUN）";res=bunores;unit=bunoresu;sig=bunclsig;output;
lbtest="肌酐（Cr）";res=crorres;unit=crorresu;sig=crclsig;output;
lbtest="尿酸（UA）";res=uaorres;unit=uaorresu;sig=uaclsig;output;
lbtest="血钾K";res=korres;unit=korresu;sig=kclsig;output;
lbtest="血钠Na";res=naorres;unit=naorreu;sig=naclsig;output;
lbtest="血氯Cl";res=clorres;unit=clorresu;sig=clclsig;output;
lbtest="血钙Ca";res=caorres;unit=caorresu;sig=caclsig;output;
lbtest="血磷P";res=porres;unit=porresu;sig=pclsig;output;
lbtest="血清磷酸酶（AKP）";res=akporres;unit=akporesu;sig=akpclsig;output;
lbtest="血糖（CLU）";res=gluorres;unit=gluoresu;sig=gluclsig;output;
lbtest="血总胆固醇（TC）";res=tcorres;unit=tcoresu;sig=tcclsig;output;
lbtest="甘油三酯(TG)";res=tgorres;unit=tgoresu;sig=tgclsig;output;
keep pub_rid lockstat subjid svstage visitnum pub_tname lbtest res unit sig dat lastmodifytime ; 
run;

/*LBF*/
data prelbf;
  set raw.lbf;
visitnum=put(svstage,$10.);
label visitnum="访视编号";
run;

proc sql;
  create table lbf as select
a.*,b.visitnum
from derived.lbf as a left join prelbf as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;



data lbf1;
  set lbf(rename=(lbfdat=dat) where=(yn="是"));
    length lbtest $100 res $500 sig $20;
lbtest="大便常规";
if lbfresot eq '' then res=lbforres;
else if lbfresot ne '' then res=compress(lbforres||':'||lbfresot);
sig=lbfclsig;
output;
keep pub_rid lockstat subjid svstage visitnum pub_tname lbtest res  sig dat lastmodifytime ; 
run;

/*LBP*/

data prelbp;
  set raw.lbp;
visitnum=put(svstage,$10.);
label visitnum="访视编号";
run;

proc sql;
  create table lbp as select
a.*,b.visitnum
from derived.lbp as a left join prelbp as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;


data lbp1;
  set lbp(rename=(lbpdat=dat) where=(yn="是"));
    length lbtest $100 unit $10 sig $20;
lbtest="凝血酶原时间（PT）";res=ptorres;unit=ptorresu;sig=ptclsig;output;
lbtest="活化部分凝血活酶时间（APTT）";res=apttores;unit=apttorsu;sig=apttclsg;output;
lbtest="凝血酶时间（TT）";res=ttorres;unit=ttorresu;sig=ttclsig;output;
lbtest="血浆纤维蛋白原（Fbg）";res=fbgores;unit=fbgoresu;sig=fbgclsig;output;
lbtest="国际标准化比率（INR）";res=inrores;unit=inroresu;sig=inrclsig;output;
keep pub_rid lockstat subjid svstage visitnum pub_tname lbtest res unit sig dat lastmodifytime; 
run;

/*LBU*/
data prelbu;
  set raw.lbu;
visitnum=put(svstage,$10.);
label visitnum="访视编号";
run;

proc sql;
  create table lbu as select
a.*,b.visitnum
from derived.lbu as a left join prelbu as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;
data lbu1;
  set lbu(rename=(lbudat=dat) where=(yn="是"));
    length lbtest $100 unit $10 sig $20;
lbtest="尿蛋白质（PRO）";res=uproores;unit=uprosu;sig=uproclsg;output;
lbtest="尿红细胞（RBC）";res=urbcores;unit=urbcsu;sig=urbcclsg;output;
lbtest="尿白细胞（WBC）";res=uwbcores;unit=uwbcsu;sig=uwbcclsg;output;
keep pub_rid lockstat subjid svstage visitnum pub_tname lbtest res unit sig dat lastmodifytime; 
run;

data lbu2;
  set lbu(where=(yn="是"));
    length lbtest $100 pub_tname1 $100 yn1 $500 sig $20;
lbtest="若尿蛋白≥++，尿蛋白24小时定量检测";
if qproores ne '' then yn1=compress(qproores||'('||qprosu||')');
else if qproores eq '' then yn='';
sig=qproclsg;
dat=qprodat;
pub_tname1=compress('实验室检查:'||pub_tname);
keep pub_rid lockstat subjid svstage visitnum pub_tname1 lbtest yn1 sig dat lastmodifytime ; 
run;

/*ADD*/
data preadd;
   set raw.add;
visitnum=put(svstage,$10.);
label visitnum="访视编号";
run; 

proc sql;
  create table add as select
a.*,b.visitnum
from derived.add as a left join preadd as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;

data add1;
  set add(rename=(adddat=dat) where=(yn='是'));
   length lbtest $100 pub_tname1 $100 yn1 $500 sig $20;
lbtest=additem;
yn1=addorres;
sig=addclsig;
pub_tname1=compress('计划外检查项目表:'||additem);
keep pub_rid lockstat subjid svstage visitnum pub_tname1 lbtest yn1 sig dat lastmodifytime ; 
run;


data tot;
  set lbb1 lbc1 lbf1 lbp1 lbu1;
  length pub_tname1 $100 yn1 $500;
if res ne '' then yn1=compress(res||'('||unit||')');
else if res eq '' then yn1='';
pub_tname1=compress('实验室检查:'||pub_tname);
drop res unit pub_tname;
run;

data tot1;
  set tot lbu2 add1;
run;

proc sort data=tot1; by subjid lbtest visitnum dat;run;

proc sql;
  create table tot2 as 
  select a.subjid,a.svstage '计划外访视阶段', a.lbtest '计划外检查项', a.dat '计划外检查日期',a.yn1 '计划外检查结果',a.sig '计划外检查临床意义',
         b.svstage as svstage1 '常规访视阶段', b.lbtest as lbtest1 '常规检查项', b.dat as dat1 '常规检查日期',b.yn1 as yn2'常规检查结果',b.sig as sig1 '常规检查临床意义'
  from tot1(where=(svstage='V401_计划外访视' or  svstage='V100_共同页')) as a 
       inner join tot1(where=(svstage ne 'V401_计划外访视' and svstage ne 'V100_共同页')) as b on a.subjid=b.subjid and a.lbtest=b.lbtest and a.dat=b.dat and a.yn1=b.yn1
  order by subjid,lbtest;
quit;

data final;
  set tot2;
  if sig ne sig1 then warning='计划外检查与常规检查临床意义不一致，请核实';
  label warning='提醒';
run;

data out.L20(label=LB重复性数据核查); set final; run;
 



	 
