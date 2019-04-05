/*soh**********************************************************************************
CODE NAME                 : <compare_check.sas>
CODE TYPE                 : <dc >
DESCRIPTION               : <比较上次的核查数据> 
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
 Author & zouq
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		Zouqing				2019-2-26
--------------------------------------------------------------------------;*/



%let PATH1=FZPL-I-103-GC项目进展报告__12FEB19.xlsx; /* 上一次清理表地址 */

%let PATH2=FZPL-I-103-GC项目进展报告__25FEB19.xlsx; /* 本次清理表地址 */

%let unselected='FZPL-I-103-GC项目进展报告'; /* 不需要比对的表
											   填写格式：  %let unselected='访视缺失','FZPL-I-103-GC项目进展报告','未SDV_CRA';  */

	
/*  */
libname OLD excel "&root.\doc\&PATH1" scan_text=no;
libname NEW excel "&root.\doc\&PATH2" scan_text=no; 

/* 获取表sheet name sheet name 太长的话读不进 */

proc sql;
		create table NEW_data as
		select * from SASHELP.vstable where libname='NEW' and not find(MEMNAME,'#');
quit;



%macro tag_template;
options nofmterr missing=" ";

proc template;
define style Styles.tag_1;
parent = styles.printer;
style fonts /                                                         

"TitleFont" = ("Times New Roman",10pt, Medium)
"TitleFont2" = ("Times New Roman",10pt, Medium) 
"StrongFont" = ("Times New Roman",10pt,Medium) 
"EmphasisFont" = ("Times New Roman",10pt,Italic)                                                              
"FixedStrongFont" = ("Times New Roman",10pt,Medium)  
"FixedHeadingFont" = ("Times New Roman",10pt,Medium) 
"FixedEmphasisFont" = ("Times New Roman",10pt,Italic)                                                              
"BatchFixedFont" = ("Times New Roman",10pt,Medium)        
"FixedFont" = ("Times New Roman",10pt,Medium)
"headingEmphasisFont" = ("Times New Roman",10pt,Medium)                                                      
"headingFont" = ("Times New Roman",10pt,Medium)
"docFont" = ("Times New Roman",10pt,Medium);
*定义表头;
style header /
backgroundcolor=#B2DFEE
color=black
font=("Times New Roman",15pt)
fontweight=bold;

*定义文件的布局;
style body from document / 
bottommargin = 0mm
topmargin = 0mm
rightmargin = 0mm
leftmargin = 0 mm;


STYLE Table /
RightMargin=0 cm
LeftMargin=0 cm
TopMargin= 0 cm 
BottomMargin=0 cm
CELLSPACING = 0
CELLPADDING = 0
FRAME = BOX
RULES = All
OUTPUTWIDTH = 925;
end;
run;
%mend tag_template;
%tag_template;

ods path tpt.template(read)  sasuser.templat(read) sashelp.tmplmst(read);
ods listing close;
ods RESULTS off;
ods escapechar='^';
ods excel file="&root.\output\&study.数据核查比较&sysdate..xlsx" options(contents="no"  FROZEN_HEADERS="Yes" autofilter='all' flow='tables' ) style=tag_1 ;
ods excel options(embedded_titles='no' embedded_footnotes='no');
%let ps1=1000;
%let ls1=256;
Options ps=&ps1 ls=&ls1  nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 

%macro compare_early_latest(shname);


data early;
	set OLD."&shname"n;
run;

data latest;
	set NEW."&shname"n;
run;


/* 变量获取 */
proc contents data=work.latest out=temp11(keep=NAME) noprint;run;

/**/


/* 合并变量-匹配 */
data latest_1;
	length all $500.;
	set latest;
	all=catx('-',of _all_);
	sn=_N_;
run;

data early_1;
	length all1 $500.;
	set early;
	all1=catx('-',of _all_);
run;

proc sql;
	create table latest_2 as
		select a.*,b.all1
		from latest_1 as a left join early_1 as b
		on a.all=b.all1
		order by sn;
quit;


data latest_3;
	set latest_2;
	if all1=all then flag='1';
	drop sn;
run;



proc sql noprint;
	select 'compute '|| compress(NAME) ||'; if flag="1" then call define(_col_,"style","style=[background=cx90EE90]"); endcomp;'
	into :draw separated by ' '
	from temp11;
quit;


ods excel options(sheet_name="&shname" START_AT='A1');
proc report data=latest_3 nowd headline headskip;
	column flag  _all_;  /* 这一步变量顺序影响后面的计算 */
	define flag / noprint;
	define all: /noprint;
	&draw.;

run;

%mend;

/* sheet获取 */
data NEW_data;
	set NEW_data;
	name=tranwrd(memname,'#','.');
	sn=scan(scan(memname,2,'#'),1,'_');
	sn=input(sn,best.);
	sn2=scan(scan(scan(memname,2,'#'),2,'_'),1,'_');
	name2=compress(tranwrd(tranwrd(memname,'$',''),"'",''));
	if name2 not in (&unselected);
run;

proc sort data=NEW_data;by sn sn2;run;


proc sql noprint;select compress(name) into:tname1- from NEW_data;quit;


%macro list_pro;
	%do i=1 %to &sqlobs;
	%put  "&&tname&i";
	%compare_early_latest( &&tname&i);
	%end;
%mend;

%list_pro;

ods excel close;
ods  listing;
