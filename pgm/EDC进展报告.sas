/*soh**********************************************************************************
CODE NAME                 : <EDC进展报告>
CODE TYPE                 : <listing >
DESCRIPTION               : <> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : <   >
OUTPUT                    : <   >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & shis
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Shishuo				2018-04-18
**eoh**********************************************************************************/;


/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/



proc sql;
create table EDC.EDC_metrics as 
SELECT subjectview.studyid as studyid '项目代码',
zxlsb.zxbhzd as zxbhzd '研究中心编号',
zxlsb.dw as dw '研究中心名称' ,
COALESCE(subjectview.jlcount,0) as jlcount '受试者筛选数',
COALESCE(subjectview.sbcount,0) as sbcount '筛选失败数',
COALESCE(subjectview.rzcount+subjectview.dsucount+subjectview.dscount,0) as rzcount '受试者入组数',
COALESCE(subjectview.dsucount,0) as dsucount '受试者已终止数',
/*COALESCE(subjectview.dscount,0) as dscount '受试者已完成数',*/
COALESCE(SAEView.saesubjcount,0) as saesubject 'SAE受试者数',
COALESCE(SAEView.saecount,0) as saecount 'SAE条数',
COALESCE(qsvisitview.qsvisit,0) as qsvisit '入组受试者访视缺失数',
COALESCE(qscrf.qscrf,0) as qscrf '入组受试者缺失页数',
COALESCE(zsview.zs,0) as zs '总记录页数',
COALESCE(zsview.zs1,0) as zs1 '未提交页数',
COALESCE(round(zsview.zs1/zsview.zs*100,0.01),0) as zsq "未提交百分率(%)",
COALESCE(sdvnum.sdvnum,0) as sdvnum '未SDV页数',
COALESCE(sdvnum.sdvrate,0) as sdvrate "未SDV页百分率(%)",
COALESCE(zynum.zynum,0) as zynum '总质疑数',
COALESCE(zynum.zynum1,0) as zynum1 '未回复质疑数',
COALESCE(round(zynum.zynum1/zynum.zynum*100,0.1),0) as zyrate "未回复质疑率(%)",
COALESCE(pisubjview.pin,0) as pi1 '电子签名受试者数',
COALESCE(round(pisubjview.pin/pisubjview.pis*100,0.1),0) as pirate "电子签名受试者率(%)" FROM EDC.zxlsb zxlsb 
LEFT JOIN EDC.subjectview subjectview  on zxlsb.zxbhzd=subjectview.siteid 
LEFT JOIN EDC.SAEView SAEView  on zxlsb.zxbhzd=SAEView.siteid 
LEFT JOIN EDC.qsvisitview qsvisitview on zxlsb.zxbhzd=qsvisitview.siteid 
LEFT JOIN EDC.qscrfview qscrf on zxlsb.zxbhzd=qscrf.siteid 
LEFT JOIN EDC.zsview zsview on zxlsb.zxbhzd=zsview.siteid and zsview.zs>0 
LEFT JOIN EDC.sdvnumview sdvnum on zxlsb.zxbhzd=sdvnum.siteid 
LEFT JOIN EDC.zynumview zynum on zxlsb.zxbhzd=zynum.siteid and zynum.zynum >0 
LEFT JOIN EDC.pisubjview pisubjview on zxlsb.zxbhzd=pisubjview.siteid and pisubjview.pis >0 

WHERE zxlsb.effective = '1' ORDER BY zxlsb.zxbhzd;
quit;


data out.L1(label='EDC进展报告');
set EDC.EDC_metrics;
run;

data out.L8(label='不良事件');
set derived.ae;
run;


data out.L9(label='合并用药');
set derived.cm;
run;
