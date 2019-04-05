
/*soh**********************************************************************************
CODE NAME                 : <DC_L2.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <LAB_AE> 
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
 Author & weix
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Weixin				2016-8-22
--------------------------------------------------------------------------;*/




dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;
%let pgmname=L4;
proc printto log="&root.\logout\&pgmname..log" new;run;

/*AE*/
proc sql;
create table pre2 as select
pub_rid,
lockstat,
subjid,
visit,
input(visitnum,best.) as visitnum1 '访视编号',
pub_tname,
sn,
aeterm as test,
aectc as sig,
aestdat,
aeout as yn,
aeendat,
createtime,
lastmodifytime

from derived.ae 
;
quit;


data ae22;
	set pre2;
	length dat $10;
	if aeendat ne '' and aestdat ne '' then do;
	   dat=aestdat;
	   pub_tname='不良事件:开始'; 
	   output;
	   dat=aeendat;
	   pub_tname='不良事件:转归'; 
	   output;
	end;
	else if aeendat = '' then do;
		dat=aestdat;
		pub_tname='不良事件:无转归'; 
		output;
	end;
	drop aeendat aestdat;
run;


/*lab*/

data lb1;
	set derived.lb1(where=(lborres ne ''));
	if lb_ref_field_cycle ne '' then visit=lb_ref_field_cycle;
run;
proc sort;by subjid lb_ref_field_labname lbtest visitnum lb_ref_field_lbbdat;run;

data lb2;
	set lb1;
	retain cyclenum;
	by subjid lb_ref_field_labname lbtest visitnum lb_ref_field_lbbdat;
	if  first.visitnum then cyclenum=0;
	else if ^first.visitnum then cyclenum+0.01;
	visitnum1=sum(input(visitnum,best.),cyclenum);
run; 



data pre3;
set lb2(where=(lborres ne ''));


pub_tname=compress('实验室检查'||':'||lbcat);
if lborres^='' then do;
res=compress(lborres||'('||lborresu||')');
end;
if lbornrlo^='' or lbornrhi^='' then do;
range=compress(lbornrlo||'~'||lbornrhi);
end;
rename lbtest=test lbclsig=sig ;
label res='检查值(单位)' range='LAB正常值范围';
dat=lb_ref_field_lbbdat;
drop lbcat lborres lborresu lbornrlo lbornrhi visitnum lb_ref_field_lbbdat;


run;

proc sort data=pre3;
by subjid  test visitnum1;run;


data final21;
set pre3 ae22;
label test=不良事件/检查项 sig=CTCAE分级/LAB临床意义 dat=LAB检查/AE开始(结束)日期  yn=AE的转归;

run;
proc sort data=final21;
by  subjid test dat visitnum1 ;
run;

proc sql;
	create table final as select pub_rid,lockstat,subjid,visit,visitnum1,pub_tname,sn,test,coalesce(res,yn) as res '检查结果/AE的转归' ,sig,dat,range,lastmodifytime from final21;
quit;
proc sort ;
by  subjid    test dat pub_tname  visitnum1 ;
run;



data final1;
	set final;
	retain order;
	by subjid   test dat  ;
	if first.test then order+1;
run;

data final2;
	set final1;
	retain x y;
	by subjid   test dat  ;
	if first.test and index(pub_tname,'实验室检查') then do;
	x=pub_tname;
	y=order;
	end;
run;

data dc.L4;
	set final2;
	if index(pub_tname,'不良事件') and index(x,'实验室检查') then order=y;
	drop x y ;
run;

proc sort;by subjid order dat test visitnum1;run;
/**/
/*ods listing close;*/
/*ods RESULTS off;*/
/*ods excel file="..\output\&study._listing1_4_&sysdate..xlsx" options( sheet_name="lb-ae" contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;*/
/*ods excel options(embedded_titles='no' embedded_footnotes='no');*/
/*Options   nodate nonumber nocenter;*/
/*options nonotes;*/
/*OPTIONS FORMCHAR="|----|+|---+=|-<>*"; */
/**/
/* proc report data=final3(drop=order);*/
/* column _all_;*/
/*DEFINE subjid / STYLE( column )={TAGATTR='type:text'};*/
/* run;*/
/**/
/**/
/**/
/*ods excel close;*/
/*ods  listing;*/
/**/
/**/
/* ***Save all information inclduing log files;*/
/*proc printto log=log; run; */
/**/
/**/
/*****To chceck all log files**;*/
/*%ut_saslogcheck(logfile=&root.\dc\log\&pgmname..log, outfile=&root.\dc\log\&pgmname._logchk.lst,msgdata=msgdata);*/
/**/
/**/



