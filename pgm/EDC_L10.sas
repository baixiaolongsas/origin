/*soh**********************************************************************************
CODE NAME                 : <数据清理追踪表>
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
01		Shishuo				2019-02-12
**eoh**********************************************************************************/;
/*dm log 'clear';*/
/*proc datasets lib=work nolist kill; run;*/
/*%include '..\init\init.sas' ;*/
/*dm log 'clear';*/



proc sql;


create table EDC.zynumsub as
select zyb.subjid as subjid,
count(*) as zynum '质疑数',
sum(case when zyb.zt= '1' then 1 else 0 end) as zynum1 '未处理质疑数',
sum(case when zyb.zt= '2' then 1 else 0 end) as zynum2 '未关闭质疑数' from EDC.zyb zyb 
group by zyb.subjid 
;

quit;


/*最后一次肿瘤疗效评估，日期，疗效结果，是否pd，评估日期距今天数；*/

data ex;
set derived.ex;
exdat_=input(exdat,YYMMDD10.);
if exdat ne '.';
keep subjid exdat_  exdat visit; 
proc sort ;
by subjid exdat_;
run;

data ex_last;
set ex;
by subjid;
if last.subjid;
run;



data rs;
set derived.rs;
rsdat_=input(rsdat,YYMMDD10.);
keep subjid rsdat_  rsdat visit rsorres; 
proc sort ;
by subjid rsdat_;
run;

data rs_;
set rs;
by subjid;
dif=today()-rsdat_;
if rsorres eq '疾病进展(PD)'  then war1='否';
else war1='是';
if dif  gt 56   then war2='是';
else  war2='否';
if last.subjid;
label war1='M≠PD' war2='TODAY-N1>56' dif='最后一次评估日期距今天数';
run;


proc sql;
create table ae_num as 
select subjid ,count(subjid) as aenum 'AE个数' from derived.ae
group by subjid
order by subjid
;

create table cm_num as 
select subjid ,count(subjid) as cmnum 'CM个数' from derived.cm
group by subjid
order by subjid
;

quit; 





proc sql;
create table EDC.subject_trace as 
SELECT subject.siteid as siteid '研究中心编号',
subject.sitename as sitename '研究中心名称' ,
subject.subjid as subjid '受试者代码' ,
subject.status as status '受试者状态' ,
rand.randat as randat ,
rand.randno as randno,
COALESCE(ex.exdat,ex1.exdat,ex.exdat) as exdat '给药日期',
COALESCE(eot.eotdat,eot1.eotdat,eot2.eotdat) as eotdat '治疗结束日期',
COALESCE(eot.eotreas,eot1.eotreas,eot2.eotreas) as eotreas '治疗结束原因',
COALESCE(eot.eotcom,eot1.eotcom,eot2.eotcom) as eotcom '其他原因详述',
ds.dsreas as dsreas '研究终止原因',
ds.dscom as dscom '其他请说明',
ex_last.exdat as exdat_last '最后一次SHR-1210用药日期',
rs.rsdat as rsdat '最近一次肿瘤疗效评估日期',
rs.rsorres as rsorres '最近一次肿瘤疗效评估',
rs.dif as dif,
rs.war1 as war1,
rs.war2 as war2,

COALESCE(ae_num.aenum,0) as aenum 'AE个数',
COALESCE(cm_num.cmnum,0) as cmnum 'CM个数',

COALESCE(Sdvsubjid.sdvznum,0) as sdvznum '需SDV字段数',
COALESCE(Sdvsubjid.sdvnum,0) as sdvnum '未SDV字段数',
COALESCE(Sdvsubjid_dm.sdvnum,0) as sdvnum_dm 'DM未核查字段数',
COALESCE(Sdvsubjid_med.sdvnum,0) as sdvnum_med 'MED未核查字段数',



COALESCE(qsvisitview.qsvisit,0) as qsvisit '访视缺失数',
COALESCE(qscrf.qscrf,0) as qscrf '页面缺失数',
COALESCE(zsview.zs1,0) as zs1 '总记录页数',
COALESCE(zsview.zs2,0) as zs2 '未提交页数',
COALESCE(zsview.zs3,0) as zs3 '未锁定页数',
COALESCE(zsview.zs4,0) as zs4 '未冻结页数',


COALESCE(zynum.zynum,0) as zynum '总质疑数',
COALESCE(zynum.zynum1,0) as zynum1 '未回复质疑数',
COALESCE(zynum.zynum2,0) as zynum2 '未关闭质疑数'
FROM derived.subject subject 
left join derived.ex ex on ex.subjid=subject.subjid and ex.visit='C1D1'
left join derived.ex1 ex1 on ex1.subjid=subject.subjid and ex1.visit='C1D1'
left join derived.ex2 ex2 on ex2.subjid=subject.subjid and ex2.visit='C1D1'
left join derived.eot eot on eot.subjid=subject.subjid
left join derived.eot1 eot1 on eot1.subjid=subject.subjid
left join derived.eot2 eot2 on eot2.subjid=subject.subjid
left join derived.ds ds on ds.subjid=subject.subjid
left join derived.rand  rand on rand.subjid=subject.subjid

LEFT JOIN EDC.qsvisitview_sub qsvisitview on subject.subjid=qsvisitview.subjid 
LEFT JOIN EDC.qscrfview_sub qscrf on subject.subjid=qscrf.subjid 
LEFT JOIN EDC.zssub zsview on subject.subjid=zsview.subjid 
LEFT JOIN EDC.Sdvsubjid Sdvsubjid on Sdvsubjid.subjid=subject.subjid 
LEFT JOIN EDC.Sdvsubjid_dm Sdvsubjid_dm on Sdvsubjid_dm.subjid=subject.subjid 
LEFT JOIN EDC.Sdvsubjid_med Sdvsubjid_med on Sdvsubjid_med.subjid=subject.subjid 
LEFT JOIN EDC.zynumsub zynum on subject.subjid=zynum.subjid 
left join ex_last ex_last on ex_last.subjid=subject.subjid 
left join ae_num ae_num on ae_num.subjid=subject.subjid 
left join cm_num cm_num on cm_num.subjid=subject.subjid 
left join rs_ rs on rs.subjid=subject.subjid 

/*where subject.status ^='筛选失败'*/
ORDER BY subject.subjid
;
quit;

data out.L2(label='数据清理追踪表');
set EDC.subject_trace;
run;


