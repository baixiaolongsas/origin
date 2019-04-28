/*soh**********************************************************************************
CODE NAME                 : <DC_L18_bxl.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <�ظ������ݼ�¼�˲�AE CM lbtest> 
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

/**********AEҳ������һ�£������ص�************/
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
             a.sn1 "���",
	    	 a.aeterm,
			 a.aestdat,
			 a.aeouttm as aeendat,
             b.sn1 as sn2 "���",
			 b.aestdat as aestdat1 "��ʼ����II",
			 b.aeouttm as aeendat1 "ת������II"
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
		else warning="�ص�";
	end;
	if aeendat ='' and aeendat1^='' then do;
	   if aestdat >= aeendat1 then warning=''; 
	   else warning="�ص�";
	end;
	if aeendat ^='' and aeendat1 ='' then do;
	   if aestdat1 >= aeendat then warning=''; 
	   else warning="�ص�";
	end;
	if aeendat ='' and aeendat1 ='' then warning="�ص�";
	label warning="����";
run;

data out.L18(label=AE�ظ������ݺ˲�); set final1; run;

/**********CMҳ������һ�£������ص�************/
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
             a.sn1 "���",
	    	 a.cmtrt,
			 a.cmstdat ,
			 a.cmendat   ,
             b.sn1 as sn2 "�ϲ���ҩ���",
			 b.cmstdat as cmstdat1 "�ϲ���ҩ��ʼ����" ,
			 b.cmendat as cmendat1 "�ϲ���ҩ��������"  
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
		else warning="�ص�";
	end;
	if cmendat ='' and cmendat1^='' then do;
	   if cmstdat >= cmendat1 then warning=''; 
	   else warning="�ص�";
	end;
	if cmendat ^='' and cmendat1 ='' then do;
	   if cmstdat1 >= cmendat then warning=''; 
	   else warning="�ص�";
	end;
	if cmendat ='' and cmendat1 ='' then warning="�ص�";
	label warning="����";
run;

data out.L19(label=CM�ظ������ݺ˲�); set final2; run;

/******************ʵ���Ҽ�飨�����ƻ�������Ŀ���������Ŀ��������ڡ�������ظ��Ժ˲�*********************/

/*LBB*/
data prelbb;
  set raw.lbb;
visitnum=put(svstage,$10.);
label visitnum="���ӱ��";
run;

proc sql;
  create table lbb as select
a.*,b.visitnum
from derived.lbb as a left join prelbb as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;


data lbb1;
  set lbb(rename=(lbbdat=dat) where=(yn="��"));
  length lbtest $100 unit $10 sig $20;
lbtest="Ѫ�쵰�ף�Hb��";res=hbores;unit=hboresu;sig=hbclsig;output;
lbtest="��ϸ����RBC��";res=rbcores;unit=rbcoresu;sig=rbcclsig;output;
lbtest="��ϸ����WBC��";res=wbcores;unit=wbcoresu;sig=wbcclsig;output;
lbtest="������ϸ����ANC��";res=neuores;unit=neuoresu;sig=neuclsig;output;
lbtest="ѪС�������PLT��";res=pltores;unit=pltoresu;sig=pltclsig;output;
keep pub_rid lockstat subjid svstage visitnum pub_tname lbtest res unit sig dat lastmodifytime; 
run;

/*LBC*/
data prelbc;
  set raw.lbc;
visitnum=put(svstage,$10.);
label visitnum="���ӱ��";
run;

proc sql;
  create table lbc as select
a.*,b.visitnum
from derived.lbc as a left join prelbc as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;

data lbc1;
  set lbc(rename=(lbcdat=dat) where=(yn="��"));
    length lbtest $100 unit $10 sig $20;
lbtest="�ܵ�����(TBIL)";res=tbilores;unit=tbilorsu;sig=tbilclsg;output;
lbtest="ֱ�ӵ����أ�DBIL��";res=dbilores;unit=dbilorsu;sig=dbilclsg;output;
lbtest="�ȱ�ת��ø��ALT��";res=altores;unit=altoresu;sig=altclsig;output;
lbtest="�Ȳ�ת��ø��AST��";res=astores;unit=astoresu;sig=astclsig;output;
lbtest="�Ȱ���ת��ø(GGT)";res=ggtores;unit=ggtoresu;sig=ggtclsig;output;
lbtest="�ܵ��ף�TP��";res=tporres;unit=tporresu;sig=tpclsig;output;
lbtest="�׵��ף�ALB��";res=albores;unit=alboresu;sig=albclsig;output;
lbtest="���ص���BUN��";res=bunores;unit=bunoresu;sig=bunclsig;output;
lbtest="������Cr��";res=crorres;unit=crorresu;sig=crclsig;output;
lbtest="���ᣨUA��";res=uaorres;unit=uaorresu;sig=uaclsig;output;
lbtest="Ѫ��K";res=korres;unit=korresu;sig=kclsig;output;
lbtest="Ѫ��Na";res=naorres;unit=naorreu;sig=naclsig;output;
lbtest="Ѫ��Cl";res=clorres;unit=clorresu;sig=clclsig;output;
lbtest="Ѫ��Ca";res=caorres;unit=caorresu;sig=caclsig;output;
lbtest="Ѫ��P";res=porres;unit=porresu;sig=pclsig;output;
lbtest="Ѫ������ø��AKP��";res=akporres;unit=akporesu;sig=akpclsig;output;
lbtest="Ѫ�ǣ�CLU��";res=gluorres;unit=gluoresu;sig=gluclsig;output;
lbtest="Ѫ�ܵ��̴���TC��";res=tcorres;unit=tcoresu;sig=tcclsig;output;
lbtest="��������(TG)";res=tgorres;unit=tgoresu;sig=tgclsig;output;
keep pub_rid lockstat subjid svstage visitnum pub_tname lbtest res unit sig dat lastmodifytime ; 
run;

/*LBF*/
data prelbf;
  set raw.lbf;
visitnum=put(svstage,$10.);
label visitnum="���ӱ��";
run;

proc sql;
  create table lbf as select
a.*,b.visitnum
from derived.lbf as a left join prelbf as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;



data lbf1;
  set lbf(rename=(lbfdat=dat) where=(yn="��"));
    length lbtest $100 res $500 sig $20;
lbtest="��㳣��";
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
label visitnum="���ӱ��";
run;

proc sql;
  create table lbp as select
a.*,b.visitnum
from derived.lbp as a left join prelbp as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;


data lbp1;
  set lbp(rename=(lbpdat=dat) where=(yn="��"));
    length lbtest $100 unit $10 sig $20;
lbtest="��Ѫøԭʱ�䣨PT��";res=ptorres;unit=ptorresu;sig=ptclsig;output;
lbtest="�������Ѫ��øʱ�䣨APTT��";res=apttores;unit=apttorsu;sig=apttclsg;output;
lbtest="��Ѫøʱ�䣨TT��";res=ttorres;unit=ttorresu;sig=ttclsig;output;
lbtest="Ѫ����ά����ԭ��Fbg��";res=fbgores;unit=fbgoresu;sig=fbgclsig;output;
lbtest="���ʱ�׼�����ʣ�INR��";res=inrores;unit=inroresu;sig=inrclsig;output;
keep pub_rid lockstat subjid svstage visitnum pub_tname lbtest res unit sig dat lastmodifytime; 
run;

/*LBU*/
data prelbu;
  set raw.lbu;
visitnum=put(svstage,$10.);
label visitnum="���ӱ��";
run;

proc sql;
  create table lbu as select
a.*,b.visitnum
from derived.lbu as a left join prelbu as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;
data lbu1;
  set lbu(rename=(lbudat=dat) where=(yn="��"));
    length lbtest $100 unit $10 sig $20;
lbtest="�򵰰��ʣ�PRO��";res=uproores;unit=uprosu;sig=uproclsg;output;
lbtest="���ϸ����RBC��";res=urbcores;unit=urbcsu;sig=urbcclsg;output;
lbtest="���ϸ����WBC��";res=uwbcores;unit=uwbcsu;sig=uwbcclsg;output;
keep pub_rid lockstat subjid svstage visitnum pub_tname lbtest res unit sig dat lastmodifytime; 
run;

data lbu2;
  set lbu(where=(yn="��"));
    length lbtest $100 pub_tname1 $100 yn1 $500 sig $20;
lbtest="���򵰰ס�++���򵰰�24Сʱ�������";
if qproores ne '' then yn1=compress(qproores||'('||qprosu||')');
else if qproores eq '' then yn='';
sig=qproclsg;
dat=qprodat;
pub_tname1=compress('ʵ���Ҽ��:'||pub_tname);
keep pub_rid lockstat subjid svstage visitnum pub_tname1 lbtest yn1 sig dat lastmodifytime ; 
run;

/*ADD*/
data preadd;
   set raw.add;
visitnum=put(svstage,$10.);
label visitnum="���ӱ��";
run; 

proc sql;
  create table add as select
a.*,b.visitnum
from derived.add as a left join preadd as b on a.subjid=b.subjid and input(a.pub_rid,best.)=b.pub_rid;
quit;

data add1;
  set add(rename=(adddat=dat) where=(yn='��'));
   length lbtest $100 pub_tname1 $100 yn1 $500 sig $20;
lbtest=additem;
yn1=addorres;
sig=addclsig;
pub_tname1=compress('�ƻ�������Ŀ��:'||additem);
keep pub_rid lockstat subjid svstage visitnum pub_tname1 lbtest yn1 sig dat lastmodifytime ; 
run;


data tot;
  set lbb1 lbc1 lbf1 lbp1 lbu1;
  length pub_tname1 $100 yn1 $500;
if res ne '' then yn1=compress(res||'('||unit||')');
else if res eq '' then yn1='';
pub_tname1=compress('ʵ���Ҽ��:'||pub_tname);
drop res unit pub_tname;
run;

data tot1;
  set tot lbu2 add1;
run;

proc sort data=tot1; by subjid lbtest visitnum dat;run;

proc sql;
  create table tot2 as 
  select a.subjid,a.svstage '�ƻ�����ӽ׶�', a.lbtest '�ƻ�������', a.dat '�ƻ���������',a.yn1 '�ƻ�������',a.sig '�ƻ������ٴ�����',
         b.svstage as svstage1 '������ӽ׶�', b.lbtest as lbtest1 '��������', b.dat as dat1 '����������',b.yn1 as yn2'��������',b.sig as sig1 '�������ٴ�����'
  from tot1(where=(svstage='V401_�ƻ������' or  svstage='V100_��ͬҳ')) as a 
       inner join tot1(where=(svstage ne 'V401_�ƻ������' and svstage ne 'V100_��ͬҳ')) as b on a.subjid=b.subjid and a.lbtest=b.lbtest and a.dat=b.dat and a.yn1=b.yn1
  order by subjid,lbtest;
quit;

data final;
  set tot2;
  if sig ne sig1 then warning='�ƻ������볣�����ٴ����岻һ�£����ʵ';
  label warning='����';
run;

data out.L20(label=LB�ظ������ݺ˲�); set final; run;
 



	 
