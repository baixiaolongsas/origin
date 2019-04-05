/*soh**********************************************************************************
CODE NAME                 : <EDC��չ����>
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
01		Shishuo				2018-06-22
**eoh**********************************************************************************/;


/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/



proc sql;
create table dp.EDC_metrics as 
SELECT subjectview.studyid as studyid '��Ŀ����',
zxlsb.zxbhzd as zxbhzd '�о����ı��',
zxlsb.dw as dw '�о���������' ,
COALESCE(subjectview.jlcount,0) as jlcount '������ɸѡ��',
COALESCE(subjectview.sbcount,0) as sbcount 'ɸѡʧ����',
COALESCE(subjectview.rzcount+subjectview.dsucount+subjectview.dscount,0) as rzcount '������������',
COALESCE(subjectview.dsucount,0) as dsucount '����������ֹ��',
COALESCE(SAEView.saesubjcount,0) as saesubject 'SAE��������',
COALESCE(SAEView.saecount,0) as saecount 'SAE����',
COALESCE(qsvisitview.qsvisit,0) as qsvisit '���������߷���ȱʧ��',
COALESCE(qscrf.qscrf,0) as qscrf '����������ȱʧҳ��',
COALESCE(zsview.zs,0) as zs '�ܼ�¼ҳ��',
COALESCE(zsview.zs1,0) as zs1 'δ�ύҳ��',
COALESCE(round(zsview.zs1/zsview.zs*100,0.01),0) as zsq "δ�ύ�ٷ���(%)",
COALESCE(sdvnum.sdvnum,0) as sdvnum 'δSDV�ֶ���',
COALESCE(sdvnum.sdvrate,0) as sdvrate "δSDV�ֶΰٷ���(%)",
COALESCE(zynum.zynum,0) as zynum '��������',
COALESCE(zynum.zynum1,0) as zynum1 'δ�ظ�������',
COALESCE(round(zynum.zynum1/zynum.zynum*100,0.1),0) as zyrate "δ�ظ�������(%)",
COALESCE(pisubjview.pin,0) as pi1 '����ǩ����������',
COALESCE(round(pisubjview.pin/pisubjview.pis*100,0.1),0) as pirate "����ǩ����������(%)" FROM dp.zxlsb zxlsb 
LEFT JOIN dp.subjectview subjectview  on zxlsb.zxbhzd=subjectview.siteid 
LEFT JOIN dp.SAEView SAEView  on zxlsb.zxbhzd=SAEView.siteid 
LEFT JOIN dp.qsvisitview qsvisitview on zxlsb.zxbhzd=qsvisitview.siteid 
LEFT JOIN dp.qscrfview qscrf on zxlsb.zxbhzd=qscrf.siteid 
LEFT JOIN dp.zsview zsview on zxlsb.zxbhzd=zsview.siteid and zsview.zs>0 
LEFT JOIN dp.sdvnumview sdvnum on zxlsb.zxbhzd=sdvnum.siteid 
LEFT JOIN dp.zynumview zynum on zxlsb.zxbhzd=zynum.siteid and zynum.zynum >0 
LEFT JOIN dp.pisubjview pisubjview on zxlsb.zxbhzd=pisubjview.siteid and pisubjview.pis >0 

WHERE zxlsb.f3 = '1' ORDER BY zxlsb.zxbhzd;
quit;


