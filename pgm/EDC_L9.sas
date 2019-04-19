/*soh**********************************************************************************
CODE NAME                 : < >
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
 Author & weix
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Weixin				2018-12-21
**eoh**********************************************************************************/;
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/

/*value $f1_fmt '1'='未处理' '2'='已处理' '3'='已关闭';*/
/*dm log 'clear';*/

data edc.ae;
set derived.ae(drop=subject_ref_field  invid invname);
sn_=input(sn,best.);
proc sort;
by subjid sn_;
run;

data edc.ae;
set edc.ae;
drop sn_;
run;



data edc.cm;
set derived.cm(drop=subject_ref_field  invid invname);
sn_=input(sn,best.);
proc sort;
by subjid sn_;
run;

data edc.cm;
set edc.cm;
drop sn_;
run;


/*data out.L10(label='生存随访');*/
/*set derived.fup;*/
/*run;*/

data out.L11(label='不良事件');
set edc.ae;
run;


data out.L12(label='合并用药');
set edc.cm;
run;




