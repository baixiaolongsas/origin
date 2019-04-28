/*soh**********************************************************************************
CODE NAME                 : <DC_L5_ZQ.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <数据清理> 
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





/**************************************主程序******************************************************/

/* 拆分药物发放回收表 */
data da1(keep= subjid svstage ywgl dardat darores1 darores2 darores3 darcom 
		 rename=(dardat=dat darores1=ores1 darores2=ores2 darores3=ores3 darcom=com)) 
	  da2(keep=subjid svstage ywgl daddat dadores1 dadores2 dadores3 dadcom 
		 rename=(daddat=dat dadores1=ores1 dadores2=ores2 dadores3=ores3 dadcom=com));
	set derived.da;
	ywgl='药物发放';
	if dadperf='是' then output da2;
	ywgl='药物回收';
	if darperf='是' then output da1;
run;

/* V99 回收表 */
data dar;
	set derived.dar;
	ywgl='药物回收';
	if darperf='是';
	keep  subjid svstage  dardat darores1 darores2 darores3 darcom ywgl;
	rename dardat=dat darores1=ores1 darores2=ores2 darores3=ores3 darcom=com;
run;

/* V1发放表 */
data dad;
	set derived.dad;
	ywgl='药物发放';
	if dadperf='是';
	keep subjid svstage   daddat dadores1 dadores2 dadores3 dadcom ywgl;
	rename daddat=dat dadores1=ores1 dadores2=ores2 dadores3=ores3 dadcom=com;
	label dadores1='剂型(25mg/片)数量'  dadores2='剂型(20mg/片)数量' dadores3='剂型(15mg/片)数量' dadcom='备注/原因' ywgl='药物管理' daddat='日期';
run;

/* 拆分药物剂量下调表 */
data exd1(keep=subjid ywgl exdstdat extdose extreas
		   rename=(exdstdat=dat extdose=dose extreas=com))
	  exd2(keep=subjid ywgl extendat
		   rename=(extendat=dat));
	set derived.exd;
	label exdstdat='日期' extdose='变动后剂量';
	ywgl='剂量下调：开始';
	if yn='是' then output exd1;
	ywgl='剂量下调：结束';
	if yn='是' then output exd2;
run;

/* 拆分暂停用药表 */
data exi1(keep=subjid ywgl existdat exipdos exireas
		  rename=(existdat=dat exipdos=dose exireas=com))
	  exi2(keep=subjid ywgl exiendat
		  rename=(exiendat=dat));
	set derived.exi;
	ywgl='暂停用药：开始';
	if yn='是' then output exi1;
	ywgl='暂停用药：结束';
	if yn='是' then output exi2;
run;

/* 合并多表，并删除某些结束下调与暂停无日期的观测 */
data DC.L5;
	retain subjid svstage ywgl dat dose ores1-ores3 com;
	length ywgl $50.;
	set dad da1 da2 dar exd1 exd2 exi1 exi2;
	if dat~='';
run;

proc sort;by subjid dat;run;

data out.L5(label=剂量调整表与发放回收);
set DC.L5;
run;






