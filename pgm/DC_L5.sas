/*soh**********************************************************************************
CODE NAME                 : <DC_L5_ZQ.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <��������> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < da dad dar exd exi>
OUTPUT                    : < final >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & Zouq
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Zouqing				2018-11-6
--------------------------------------------------------------------------;*/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;





/**************************************������******************************************************/

/* ���ҩ�﷢�Ż��ձ� */
data da1(keep= subjid svstage ywgl dardat darores1 darores2 darores3 darcom 
		 rename=(dardat=dat darores1=ores1 darores2=ores2 darores3=ores3 darcom=com)) 
	  da2(keep=subjid svstage ywgl daddat dadores1 dadores2 dadores3 dadcom 
		 rename=(daddat=dat dadores1=ores1 dadores2=ores2 dadores3=ores3 dadcom=com));
	set derived.da;
	ywgl='ҩ�﷢��';
	if dadperf='��' then output da2;
	ywgl='ҩ�����';
	if darperf='��' then output da1;
run;

/* V99 ���ձ� */
data dar;
	set derived.dar;
	ywgl='ҩ�����';
	if darperf='��';
	keep  subjid svstage  dardat darores1 darores2 darores3 darcom ywgl;
	rename dardat=dat darores1=ores1 darores2=ores2 darores3=ores3 darcom=com;
run;

/* V1���ű� */
data dad;
	set derived.dad;
	ywgl='ҩ�﷢��';
	if dadperf='��';
	keep subjid svstage   daddat dadores1 dadores2 dadores3 dadcom ywgl;
	rename daddat=dat dadores1=ores1 dadores2=ores2 dadores3=ores3 dadcom=com;
	label dadores1='����(25mg/Ƭ)����'  dadores2='����(20mg/Ƭ)����' dadores3='����(15mg/Ƭ)����' dadcom='��ע/ԭ��' ywgl='ҩ�����' daddat='����';
run;

/* ���ҩ������µ��� */
data exd1(keep=subjid ywgl exdstdat extdose extreas
		   rename=(exdstdat=dat extdose=dose extreas=com))
	  exd2(keep=subjid ywgl extendat
		   rename=(extendat=dat));
	set derived.exd;
	label exdstdat='����' extdose='�䶯�����';
	ywgl='�����µ�����ʼ';
	if yn='��' then output exd1;
	ywgl='�����µ�������';
	if yn='��' then output exd2;
run;

/* �����ͣ��ҩ�� */
data exi1(keep=subjid ywgl existdat exipdos exireas
		  rename=(existdat=dat exipdos=dose exireas=com))
	  exi2(keep=subjid ywgl exiendat
		  rename=(exiendat=dat));
	set derived.exi;
	ywgl='��ͣ��ҩ����ʼ';
	if yn='��' then output exi1;
	ywgl='��ͣ��ҩ������';
	if yn='��' then output exi2;
run;

/* �ϲ������ɾ��ĳЩ�����µ�����ͣ�����ڵĹ۲� */
data DC.L5;
	retain subjid svstage ywgl dat dose ores1-ores3 com;
	length ywgl $50.;
	set dad da1 da2 dar exd1 exd2 exi1 exi2;
	if dat~='';
run;

proc sort;by subjid dat;run;

data out.L5(label=�����������뷢�Ż���);
set DC.L5;
run;






