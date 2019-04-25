/*soh**********************************************************************************
CODE NAME                 : <m_exportxlsx.sas>
CODE TYPE                 : <macro >
DESCRIPTION               : <生成excel列表> 
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
01		Weixin				2018-6-22
--------------------------------------------------------------------------;*/



%macro m_exportxlsx(title=,creator=,num=) ;

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

proc sql;
        create table listing as select memname as sn 'Sn',memlabel as contents 'Contents',crdate 'Create Time',input(compress(memname,'0123456789','k'),best.) as sn1 
        from dictionary.tables where libname eq "OUT" and memlabel ne "" order by sn1;
		select count(*) into:N from listing;
    
quit;


ods path tpt.template(read)  sasuser.templat(read) sashelp.tmplmst(read);
ods listing close;
ods RESULTS off;
ods escapechar='^';
ods excel file="&root.\output\&study.&title._&sysdate..xlsx" options(contents="no"  FROZEN_HEADERS="Yes" autofilter='all' ) style=tag_1 ;
ods excel options(embedded_titles='no' embedded_footnotes='no');
%let ps1=1000;
%let ls1=256;
Options ps=&ps1 ls=&ls1  nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 

	ods excel options(sheet_name="&study.封面"  START_AT='B2') ;

	proc report data=listing  headskip headline nowd  
	/*-------- 设置header格式样式（边框）-------------------*/
	style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	column ("Contents of Table"  sn  contents crdate);

	/*-------- 设置column格式样式（边框）-------------------*/

	define sn / display  '序号' style=[ just=left tagattr='text'  cellwidth=10% ] ;
	define contents/ display "内容" style=[ just=left tagattr='text' cellwidth=60% ] ;
	define crdate/ display "创建时间" style=[ just=left tagattr='text' cellwidth=60% ] ;
	
		compute before  _PAGE_/ style = [ font_style=italic just=l font_weight=bold font_size=8pt borderbottomcolor=black borderbottomwidth=.5pt  background=white ];
	line "Project Name: &study.";	
	line "Create table by hengrui data management";
	line "Create table Time：%sysfunc(today(),yymmdd10.) %sysfunc(time(),hhmm5.)                                        creator：&creator.                                        raw data：&rawdate.	";
	endcomp;

    run;

%do i=1 %to &n;

		proc sql noprint noprint;
			select sn,contents into:table ,:sheet from listing where monotonic() = &i.;

		 create table temp as
		 select name,count(*) as num  from dictionary.columns
		 where libname=upcase("OUT") and memname=upcase("&table.");
		quit;

		data temp2;
		set temp;
		n+1;
		def="DEFINE "||compress(name)||" /display STYLE(column)={TAGATTR='type:text'};";
		call symputx("n",n);
		proc sort data=temp2 ; 
		by num n;
		run;
		
		data _null_;
			call symput('len',input(&n.,best.)*100);
		run;;

		data temp3;
		set temp2;
		length allvarb $&len.;
		by num n;
		retain allvarb;
		if first.num then allvarb=def;
		else allvarb=trim(def)||allvarb;
		if num eq n;
		run;

		data _Null_;
		set temp3;

		call symputx("allvarb",allvarb);
		run;

	ods excel options(sheet_name="&sheet" START_AT='A1');
	proc report data=OUT.&table. headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	column _all_;
	&allvarb.
	run;
%end;

ods excel close;
ods  listing;



/*对导出的次数进行计数*/
data temp1; 
  length projects title creator creatime $50 ;
  projects="&study.";
  title="&title.";
  creator="&creator.";
  creatime=put(input("&sysdate.",date7.),yymmdd10.);
  num="&num.";
run;

PROC IMPORT OUT= WORK.temp
            DATAFILE= "D:\hr_projects\summary.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data temp2; 
  length projects title creator creatime num $50 ;
  set temp; 
  format projects title creator creatime num $50. ;
run;

data summary;
  length projects title creator creatime num $50 ;
  set temp2 temp1; 
run;
proc sort nodupkeys; by title creator creatime projects num; run;

ods listing close; 
ods RESULTS off; 
ods html close; 
ods escapechar='^';
ods excel file="D:\hr_projects\summary.xlsx" options(sheet_name="Sheet1"  contents="no"  FROZEN_HEADERS="Yes" autofilter='all' )  ;
ods excel options(embedded_titles='no' embedded_footnotes='no');
Options   nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 
proc report data=summary nowd ;
     column _all_;	
 run;
ods excel close;
ods listing;

%mend;



