/*soh**********************************************************************************
CODE NAME                 : <DC_L1_LY.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <LB-AE> 
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
 Author & liying
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------

--------------------------------------------------------------------------;*/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

/*AE*/
proc sql;
create table pre as select
a.pub_rid,
a.lockstat,
a.subjid,
a.svstage,
input(put(b.svstage,$10.),best.) as visitnum1 '访视编号',
a.pub_tname,
a.sn,
a.aeterm as test,
a.aeout as yn1 length=500,
a.aectc as sig length=20,
a.aestdat,
a.aeouttm,
a.lastmodifytime
from derived.ae as a left join raw.ae as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid
where a.yn='是';
quit;

data ae22;
	set pre;
	length dat $10 pub_tname1 $100;
	if aestdat ne '' and aeouttm ne '' then do;
	   dat=aestdat;
	   pub_tname1='不良事件:开始'; 
	   output;
	   dat=aeouttm;
	   pub_tname1='不良事件:转归'; 
	   output;
	end;
	else if aeouttm = '' then do;
		dat=aestdat;
		pub_tname1='不良事件:无转归'; 
		output;
	end;
	drop aeouttm aestdat pub_tname;
run;


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

data tot2;
  set tot1;
  retain cyclenum;
by subjid lbtest visitnum dat;
if first.visitnum then cyclenum=0;
else if ^first.visitnum then cyclenum+0.01;
visitnum1=sum(input(visitnum,best.),cyclenum);
run;

proc sort data=tot2;by subjid lbtest visitnum1;run;

data final1;
  set ae22 tot2(rename=(lbtest=test));
label test="不良事件/检查项" sig="CTCAE分级/lab临床意义判断" dat="lab检查/AE开始(结束)日期" yn1="检查结果/AE的转归" pub_tname1="表名称";
run;

proc sort data=final1;by subjid test dat visitnum1;run;

proc sql;
create table final2 as select
pub_rid,lockstat,subjid,svstage,visitnum1,pub_tname1,sn,test,yn1,sig,dat,lastmodifytime from final1;
quit;

proc sort ;
by  subjid  test dat pub_tname1  visitnum1 ;
run;

data final3;
  set final2;
 retain order;
 by subjid test dat;
 if first.test then order+1;
run;

data final4;
  set final3;
  retain x y;
  by subjid test dat;
  if first.test and index(pub_tname1,'实验室检查') then do;
  x=pub_tname1;
  y=order;
  end;
run;

data final5;
  set final4;
  if index(pub_tname1,'不良事件') and index(x,'实验室检查') then order=y;
  drop x y;
run;

proc sort; by subjid order dat test visitnum1;run;

data labae;
  set final5;
drop order;
run;

data out.L1(label=lab|计划外检查项目表|计划外访视-ae);set labae; run;






 
