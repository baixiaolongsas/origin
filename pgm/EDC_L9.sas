/*soh**********************************************************************************
CODE NAME                 : <L_>
CODE TYPE                 : <listing >
DESCRIPTION               : <> 
SOFTWARE/VERSION#         : <SAS 9.3>
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
 Author & weix
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Weixin				2017-4-27
**eoh**********************************************************************************/;
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

/*value $f1_fmt '1'='δ����' '2'='�Ѵ���' '3'='�ѹر�';*/
/*dm log 'clear';*/

data ae;
set DERIVED.ae;
keep subjid studyid lockstat--siteid visit--lastmodifytime sn1 visitnum1; 
sn1=input(sn,best.);visitnum1=input(visitnum,best.);
label sn1 ="���" visitnum1= "���ӱ��";
run;
data EDC.ae;
drop sn visitnum;
retain studyid subjid lockstat sitename siteid visit visitnum1 svnum none sn1 ;
set ae ;
run;
proc sort data=edc.ae;by siteid subjid visitnum1 sn1;run;


data out.l9(label="�����¼�") ;set edc.ae;run;





