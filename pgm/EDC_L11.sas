/*soh**********************************************************************************
CODE NAME                 : <L_11>
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


data edc.hchzb;
	set edc.hchzb;
	if input(yhczdsls,best.)>=input(xhczdzsls,best.) then yhczdsls=xhczdzsls;
	if input(yhczdsly,best.)>=input(xhczdzsl,best.) then yhczdsly=xhczdzsl;
run	;



proc sql;
	create table sdv_subjid as select distinct subjid,
	sum(input(hchzb.xhczdzsl,best.)) as sdvznum1 '��SDV�ֶ���',
	(sum(input(hchzb.xhczdzsl,best.))-sum(input(hchzb.yhczdsly,best.))) as sdvnum1 'δSDV�ֶ���',
	round(sum( input(hchzb.xhczdzsl,best.)-input(hchzb.yhczdsly,best.))/sum(input(hchzb.xhczdzsl,best.))*100,0.0001) as sdvrate 'δSDV�ٷ���(%)',
	(sum(input(hchzb.xhczdzsle,best.))-sum(input(hchzb.yhczdsle,best.))) as sdvnum2 'DMδ�˲��ֶ���',
	(sum(input(hchzb.xhczdzsls,best.))-sum(input(hchzb.yhczdsls,best.))) as sdvnum3 'ҽѧδ�˲��ֶ���'
	from EDC.hchzb 
	left join EDC.spjlb spjlb on spjlb.jl=COALESCE(hchzb.ejzbfjl,hchzb.jl,) and spjlb.dqzt NE '00'  
	left join DERIVED.subject subject on subject.pub_rid=COALESCE(hchzb.fzbdrkbjl,hchzb.jl) where dqzt is not null and subject.siteid is not null 
	 group by subject.subjid ;
quit;


data ex;
	set derived.ex;
	if exdat not in ('','.');
	keep subjid exdat;
run;
proc sort;by subjid exdat;run;

data fdd;
	set ex;
	by subjid exdat;
	if first.subjid;
run;

/*��ֹ����*/

data fin;
length findat $100;
  set derived.ds1 (rename=(dsdat=findat))
       derived.ds  (rename=(losdat=findat))
       derived.dth (rename=(dthdat=findat)) ;	 
 dat11=input(findat,yymmdd10.);
run;

proc sort data=fin;
by subjid descending dat11;run;

data fin;
  set fin;
by subjid;
if first.subjid;
run;

proc sql;
	create table subject as select 
a.siteid,a.sitename,a.subjid,a.status,b.exdat '�״θ�ҩ����',
c.dsdat,coalesce(c.dscom,c.dsreas) as dsres1 '�˳�����ԭ��',d.losdat,coalesce(d.dscom,d.dsreas) as dsres2 '�˳��о�ԭ��',
e.findat '��ֹ����' from derived.subject as a 
left join fdd as b on a.subjid=b.subjid left join derived.ds1 as c on a.subjid=c.subjid 
left join derived.ds as d on a.subjid=d.subjid left join fin as e on a.subjid=e.subjid ;
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
	create table total_subjid as select subjid,count(pub_rid) as total '�ܼ�¼ҳ��' from EDC.selected group by subjid;	
quit;


proc sql;
	create table unsub_subjid as select subjid,count(pub_tname) as unsub 'δ�ύҳ����' from edc.Unsub group by subjid;	
quit;

proc sql;
	create table unsub_subjid1 as select subjid,count(pub_tname) as unsub1 'δ����ҳ����' from edc.Unsub1 group by subjid;	
quit;

proc sql;
	create table unsub_subjid2 as select subjid,count(pub_tname) as unsub2 'δ����ҳ����' from edc.Unsub2 group by subjid;	
quit;

proc sql;
	create table zyb1_subjid as select subjid,count(*) as zy1 '��������' from edc.zyb group by subjid;
	create table zyb2_subjid as select subjid,count(*) as zy2 'δ�ظ�������' from edc.zyb where zt ='1' group by subjid;
	create table zyb3_subjid as select subjid,count(*) as zy3 'δ�ر�������' from edc.zyb where zt ='2' group by subjid;
quit; 

proc sql;
	create table edc.subjid_sum as select a.*,b.sdvznum1,b.sdvnum1,b.sdvrate,b.sdvnum2,b.sdvnum3,c.qsvisit,d.qscrf,e.total,f.unsub,g.unsub1,h.unsub2,f1.zy1,f2.zy2,f3.zy3 from subject as a left join
	sdv_subjid as b on a.subjid=b.subjid left join vistmiss_subjid as c on a.subjid=c.subjid left join crfmiss_subjid as d on a.subjid=d.subjid
	left join total_subjid e on a.subjid=e.subjid
	left join unsub_subjid f on a.subjid=f.subjid
    left join unsub_subjid1 g on a.subjid=g.subjid
	left join unsub_subjid2 h on a.subjid=h.subjid
	left join zyb1_subjid as f1 on a.subjid=f1.subjid
	left join zyb2_subjid as f2 on a.subjid=f2.subjid
	left join zyb3_subjid as f3 on a.subjid=f3.subjid;
quit;


data out.l2(label='��չ��ϸ'); set EDC.subjid_sum; run;





  
