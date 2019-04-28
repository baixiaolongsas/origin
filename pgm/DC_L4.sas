/*soh**********************************************************************************
CODE NAME                 : <DC_L4_ZQ.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <数据清理> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < dad dar da>
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

/**************************************主程序******************************************************/

/* 药物发放与回收 */



/* 读取药物发放回收表 */
data da;
	set derived.da;
	keep siteid subjid svstage  darperf dardat darores1 darores2 darores3 exorres1 exorres2 exorres3 darcom
		 dadperf daddat dadores1 dadores2 dadores3 dadcom;
run;

/* V1 发放表 */
data dar;
	set derived.dar;
	keep siteid subjid svstage  darperf dardat darores1 darores2 darores3 exorres1 exorres2 exorres3 darcom;
run;

/* V99回收表 */
data dad;
	set derived.dad;
	keep siteid subjid svstage  dadperf daddat dadores1 dadores2 dadores3 dadcom;
run;

/* 合并三表 并提取周期数以便排序 */
data da1;
	retain num;
	set da dad dar;
	num=input(compress(scan(svstage,1,'_'),,'kd'),best.);
run;

proc sort;by subjid  num;run;


/* 获取发放周期数及发放药物的变量 */
data da2;
	set da1;
	by subjid notsorted;
	svstage1=lag(svstage);
	daddat1=lag(daddat);
	dadores11=lag(dadores1);
	dadores22=lag(dadores2);
	dadores33=lag(dadores3);
	dadcom1=lag(dadcom);
	dadperf1=lag(dadperf);
	if first.subjid then do;  
	svstage1=''; daddat1=''; dadores11=''; dadores22=''; dadores33='';dadcom1='';
	end;
run;

/* 数据清理NA ND 字符 */
data da3;
	set da2;
	if svstage1 ne '' then do;
		daddat=daddat1;
		dadores1=dadores11;
		dadores2=dadores22;
		dadores3=dadores33;
		dadcom=dadcom1;
		dadperf=dadperf1;
	end;
	if svstage1='' then svstage1=svstage;
	array x{*} exorres1 exorres2 exorres3 dadores1 dadores2 dadores3  darores1 darores2 darores3;
	do i=1 to dim(x);
	if x(i)='NA' then x(i)='0';
	if x(i)='ND' then x(i)='0';
	end;
	if svstage='V1_基线期(-1D)' then svstage='';
	label svstage1='发放周期数' svstage='回收周期数';
	drop daddat1--dadperf1 num i;
run;

/* 计算warning，由于数据中实际服用药物 有些计算了备注中的丢失与漏服药物数，有些没有，所以warning需要DM查看备注并核查 */
data DC.L4;
	retain siteid subjid dadperf svstage1 daddat dadores1-dadores3 dadcom darperf svstage dardat darores1-darores3 exorres1-exorres3 darcom;
	set da3;
	if dardat ne '' then 
	sasores1=25*exorres1+20*exorres2+15*exorres3;
	sasores2=25*(dadores1-darores1)+20*(dadores2-darores2)+15*(dadores3-darores3);
	if sasores1 ~= sasores2 and sasores2 ne '' then warning='请核查或查看备注';
	label sasores1='（SAS计算）根据实际服用数量计算实际服用总剂量（mg）' sasores2='（SAS计算）根据发放回收计算应服用总剂量（mg）';
run;

data out.L4(label=药物发放与回收);
set DC.L4;
run;








