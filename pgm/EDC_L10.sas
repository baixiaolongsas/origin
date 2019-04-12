/*soh**********************************************************************************
CODE NAME                 : <EDC_L10.sas>
CODE TYPE                 : <   >
DESCRIPTION               : <�����߻���> 
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
01		Weixin				2018-10-16
**eoh**********************************************************************************/;

/**/
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/

data edc.hchzb;
	set edc.hchzb;
	if input(yhczdsls,best.)>=input(xhczdzsls,best.) then yhczdsls=xhczdzsls;
	if input(yhczdsly,best.)>=input(xhczdzsl,best.) then yhczdsly=xhczdzsl;
run	;



proc sql;
	create table sdv_subjid as select distinct subjid,
	sum(input(hchzb.xhczdzsl,best.)) as sdvznum1 '��SDV�ֶ���',
	(sum(input(hchzb.xhczdzsl,best.))-sum(input(hchzb.yhczdsly,best.))) as sdvnum1 'δSDV�ֶ���',
	(sum(input(hchzb.xhczdzsle,best.))-sum(input(hchzb.yhczdsle,best.))) as sdvnum2 'DMδ�˲��ֶ���',
	(sum(input(hchzb.xhczdzsls,best.))-sum(input(hchzb.yhczdsls,best.))) as sdvnum3 'ҽѧδ�˲��ֶ���'
	from EDC.hchzb 
	left join EDC.spjlb spjlb on spjlb.jl=COALESCE(hchzb.ejzbfjl,hchzb.jl,) and spjlb.dqzt NE '00'  
	left join DERIVED.subject subject on subject.pub_rid=COALESCE(hchzb.fzbdrkbjl,hchzb.jl) where dqzt is not null and subject.siteid is not null 
	 group by subject.subjid ;
quit;


data ex;
	set derived.ex ;
	if exsdat not in ('','.');
	rename exsdat=exdat;
	keep subjid exsdat;
run;
proc sort;by subjid exdat;run;

data fdd;
	set ex;
	by subjid exdat;
	if first.subjid;
run;

proc sql;
	create table subject as select a_.siteid,a_.sitename,a_.subjid,a_.status,b.exdat '�״θ�ҩ����'
/*    c.lasexdat,coalesce(c.dscom,c.dsreas) as dsres1 '�˳�����ԭ��'*/
/*	,d.statdat,coalesce(d.dscom,d.dsreas) as dsres2 '�˳��о�ԭ��' */
    from derived.subject as a_ 
    left join derived.rand as a on a_.subjid=a.subjid 
    left join fdd as b on a_.subjid=b.subjid 
/*    left join derived.ds1 as c on a_.subjid=c.subjid */
/*    left join derived.ds as d on a_.subjid=d.subjid*/
    ;
quit;


data sv;
	set derived.sv;
	keep subjid visdat createtime;
run;

proc sort;by subjid createtime;run;


data last_visdat;
	set sv;
	by subjid createtime;
	if last.subjid;
run;
/**/
/*data ae;*/
/*	set derived.ae;*/
/*	keep subjid aestdat;*/
/*run;*/
/*proc sort;by subjid aestdat;run;*/
/**/
/*data last_aestdat;*/
/*	set ae;*/
/*	by subjid aestdat;*/
/*	if last.subjid;*/
/*run;*/
/**/
/*data cm;*/
/*	set derived.cm;*/
/*	keep subjid cmstdat;*/
/*run;*/
/*proc sort;by subjid cmstdat;run;*/
/**/
/*data last_cmstdat;*/
/*	set cm;*/
/*	by subjid cmstdat;*/
/*	if last.subjid;*/
/*run;*/






proc sql;
create table vistmiss_subjid as
select qssubjectview.subjid as subjid,
count(*) as qsvisit '����ȱʧ��' from EDC.visitmiss qssubjectview 
group by subjid;

quit;



proc sql;
create table crfmiss_subjid as
select qscrfview.subjid as subjid,
count(*) as qscrf 'ҳ��ȱʧ��' from edc.crfmiss qscrfview group by qscrfview.subjid
;
quit;




proc sql;
	create table unsub_subjid as select subjid,count(pub_tname) as unsub 'δ�ύҳ��' from edc.Unsub group by subjid;
	
quit;

proc sql;
	create table zyb1_subjid as select subjid,count(*) as zy1 '��������' from edc.zyb group by subjid;
	create table zyb2_subjid as select subjid,count(*) as zy2 'δ�ظ�������' from edc.zyb where zt ='1' group by subjid;
	create table zyb3_subjid as select subjid,count(*) as zy3 'δ�ر�������' from edc.zyb where zt ='2' group by subjid;
quit; 

/*�˳��ֶδ�����ڣ���ȡ��ע��*/


proc sql;
	create table edc.subjid_sum as select a.*,
/*    ae.aestdat '����AE��ʼ����',cm.cmstdat '����CM��ʼ����',*/
    b.sdvznum1,b.sdvnum1,sdvnum2,sdvnum3,qsvisit,qscrf,zjl.zs,unsub,zy1,zy2,zy3 from subject as a 
	left join sdv_subjid as b on a.subjid=b.subjid 
	left join vistmiss_subjid as c on a.subjid=c.subjid 
    left join crfmiss_subjid as d on a.subjid=d.subjid
	left join unsub_subjid e on a.subjid=e.subjid
	left join zyb1_subjid as f1 on a.subjid=f1.subjid
	left join zyb2_subjid as f2 on a.subjid=f2.subjid
	left join zyb3_subjid as f3 on a.subjid=f3.subjid
	left join EDC.zjl as zjl on a.subjid=zjl.subjid
/*	left join last_aestdat as ae on a.subjid=ae.subjid*/
/*	left join last_cmstdat as cm on a.subjid=cm.subjid*/
	;
quit;



data out.L9(label='�����߻��ܱ�');
set edc.subjid_sum;
run;


data out.L10(label='�����¼�');
set derived.ae;
run;


data out.L11(label='�ϲ���ҩ');
set derived.cm;
run;
