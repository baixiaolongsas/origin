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
	sum(input(hchzb.xhczdzsl,best.)) as sdvznum1 '需SDV字段数',
	(sum(input(hchzb.xhczdzsl,best.))-sum(input(hchzb.yhczdsly,best.))) as sdvnum1 '未SDV字段数',
	round(sum( input(hchzb.xhczdzsl,best.)-input(hchzb.yhczdsly,best.))/sum(input(hchzb.xhczdzsl,best.))*100,0.0001) as sdvrate '未SDV百分率(%)',
	(sum(input(hchzb.xhczdzsle,best.))-sum(input(hchzb.yhczdsle,best.))) as sdvnum2 'DM未核查字段数',
	(sum(input(hchzb.xhczdzsls,best.))-sum(input(hchzb.yhczdsls,best.))) as sdvnum3 '医学未核查字段数'
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

/*终止日期*/

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
a.siteid,a.sitename,a.subjid,a.status,b.exdat '首次给药日期',
c.dsdat,coalesce(c.dscom,c.dsreas) as dsres1 '退出治疗原因',d.losdat,coalesce(d.dscom,d.dsreas) as dsres2 '退出研究原因',
e.findat '终止日期' from derived.subject as a 
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
count(*) as qsvisit '访视缺失数' from EDC.visitmiss qssubjectview 
group by subjid;

quit;



proc sql;
create table crfmiss_subjid as
select qscrfview.subjid as subjid,
count(*) as qscrf '页面缺失数' from edc.crfmiss qscrfview group by qscrfview.subjid
;
quit;


proc sql;
	create table total_subjid as select subjid,count(pub_rid) as total '总记录页数' from EDC.selected group by subjid;	
quit;


proc sql;
	create table unsub_subjid as select subjid,count(pub_tname) as unsub '未提交页面数' from edc.Unsub group by subjid;	
quit;

proc sql;
	create table unsub_subjid1 as select subjid,count(pub_tname) as unsub1 '未锁定页面数' from edc.Unsub1 group by subjid;	
quit;

proc sql;
	create table unsub_subjid2 as select subjid,count(pub_tname) as unsub2 '未冻结页面数' from edc.Unsub2 group by subjid;	
quit;

proc sql;
	create table zyb1_subjid as select subjid,count(*) as zy1 '总质疑数' from edc.zyb group by subjid;
	create table zyb2_subjid as select subjid,count(*) as zy2 '未回复质疑数' from edc.zyb where zt ='1' group by subjid;
	create table zyb3_subjid as select subjid,count(*) as zy3 '未关闭质疑数' from edc.zyb where zt ='2' group by subjid;
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


data out.l2(label='进展明细'); set EDC.subjid_sum; run;





  
