/*soh**********************************************************************************
CODE NAME                 : <alltoexcel.sas>
CODE TYPE                 : <SHR_1210 >
DESCRIPTION               : <数据导出> 
SOFTWARE/VERSION#         : <SAS 9.3>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < bioknow 1.0>
OUTPUT                    : < 结果.xml  >
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & weix
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Weixin				2016-7-25
**eoh**********************************************************************************/;


dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;
proc sql;
	create table hchzb_sum as select input(jl,best.) as jl,yhczdsls 'MED已核查字段数量',xhczdzsls 'MED需核查字段数量' from edc.hchzb where xhczdzsls>yhczdsls;
quit;
 proc format library=RAW cntlout=work.cntlfmt;quit;
 proc sort data=cntlfmt(keep=FMTNAME LENGTH) nodupkeys out=fmt;by _all_;run;
%macro formatall;
data vstable;
	set sashelp.vstable(where=(libname='RAW' and memname ne 'ID'));
	N=_N_;
	call symput('n',max(N));

run;

%put &n.;
%do i=1 %to &n.;
	proc sql;
		select trim(memname) into:name from vstable where N=&i;
	quit;
	proc contents data=RAW.&name. out=_label_&name.(keep=NAME FORMAT INFORMAT LENGTH VARNUM) noprint ;quit;
	proc sql;
		create table _label_fmt_&name. as select a.*,b.LENGTH as fmtlength from _label_&name. as a left join fmt as b on trim(scan(a.FORMAT,1,'$'))=trim(b.FMTNAME);
	quit;
	proc sort;by VARNUM;run;

	data pre_&name.;
		set _label_fmt_&name.;
		length content $20;
		if INFORMAT ='' then content='best.';
		else if INFORMAT ='YYMMDD' then content='YYMMDD10.';
		else if INFORMAT ='DATETIME' then content='DATETIME20.';
		else content=compress(FORMAT||put(fmtlength,best.))||'.';
		if FORMAT='' and INFORMAT ne '' then content=cats("$",put(LENGTH,best.),'.');
		COL=cats('COL',(put(VARNUM,best.)));
		if NAME='pub_tid' then N=1;
		else if NAME='pub_tname' then N=2;
		else if NAME='pub_rid' then N=3;
		else if NAME='studyid' then N=4;
		else if NAME='lockstat' then N=5;
		else if NAME='sitename' then N=6;
		else if NAME='siteid' then N=7;
		else if NAME='subjid' then N=8;
		else if NAME='visit' then N=9;
		else if NAME='visitnum' then N=10;
		else if name='svnum' then N=11;
		else if NAME='invname' then N=12;

		else if NAME='invid' then N=13;
		else if NAME='userid' then N=14;
		else if NAME='unitid' then N=15;
		else if NAME='createtime' then N=16;
		else if NAME='modifyuserid' then N=17;
		else if NAME='lastmodifytime' then N=18;
		else if NAME='sn' then N=19;
		else if name='lbcat' then N=20;
		else if find(NAME,'dat') then N=20+VARNUM;
		

	run;
	proc sort;by N;run;

	data pre1_&name.;
		set pre_&name.(where=(N ne .));
		COL=cats('COL',(put(N,best.)));
	run;
		proc sql ;

		select NAME into :names separated by " " from pre_&name.;
		select COL into :COLs separated by " " from pre1_&name.;
		select COL||"=catx(':',vlabel("||compress(NAME)||"),put("||NAME||","||content||"))" into: fmtseq separated by " ; " from pre1_&name.;
	quit;

	data final_&name.;
		length &COLs. $ 500;
		set RAW.&name.;
			&fmtseq.;
		drop &names.;
	run;
		
	proc sql;
		create table final1_&name.(drop=jl) as select b.*,a.* from final_&name. as a left join hchzb_sum as b on input(scan(COL3,2,':'),best.)=b.jl where b.jl ne . ;
	quit;
%end;

data final_final;

	set final1_:;
	COL2=scan(COL2,2,':');
	COL5=scan(COL5,2,':');
	COL6=scan(COL6,2,':');
	COL7=scan(COL7,2,':');
	COL8=scan(COL8,2,':');
	COL9=scan(COL9,2,':');
	COL10=input(scan(COL10,2,':'),best.);
	COL11=input(scan(COL11,2,':'),best.);
	COL14=scan(COL14,2,':');
	COL16=substr(COL16,10);
	COL17=scan(COL17,2,':');
	COL18=substr(COL18,10);
	drop COL1 COL3 COL4 COL12 COL13 COL15;
run;

data final;
	retain COL6 COL7 COL8 COL2 COL5   COL9 COL10 COL11 yhczdsls xhczdzsls COL14 COL16 COL17 COL18 WARNING ;
	set final_final;
	rename COL2=tid col5=lockstat col6=sitename col7=siteid col8=subjid col9=visit col10=visitnum col11=svnum col14=creator col16=createtime col17=modify col18=modifytime;
	WARNING='后面内容为CRF记录具体信息';
	label COL2='表名称' COL5='CRF状态' COL6='研究中心名称' COL7='研究中心编号' COL8='受试者代码' COL9='访视名称' COL10='访视编号' COL11='访视内序号' COL14='创 建 人' COL16='创建时间' COL17='修 改 人' COL18='修改时间' WARNING='提示';
run;
proc sort; by 	subjid 	visitnum 	svnum tid;run;

%mend;
%formatall;
%macro test;
DATA abs_final;
	SET final;
	length x $4000;
	x=catx('|',of COL:);
	length=length(compress(x,'|','k'));
	keep tid siteid subjid lockstat sitename   visit visitnum svnum yhczdsls xhczdzsls creator createtime modify modifytime WARNING x length;
run;
proc sql;
	select max(length) into:cut from abs_final;
quit;
%put &cut.;


%do i=1 %to &cut.+1;

data abs_final;
	set abs_final;
	var_&i.=scan(x,&i.,'|');
	label var_&i="变量名&i,:变量值";
run;
%end;
%mend;
%test;

data edc.unsdv_MED;
	set abs_final;
	if lockstat ne '未提交';
	drop x length WARNING creator createtime modify ;
run;

data out.l6(label='MED未核查页明细'); set edc.unsdv_MED; run;

