/*soh**********************************************************************************
CODE NAME                 : <���е���>
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
01		Shishuo				2018-06-20
**eoh**********************************************************************************/;
dm log 'clear';
proc datasets lib=work nolist kill; run;


%include '..\init\init.sas' ;
%include '.\BASE.sas';
%include '.\������ϸ.sas';
%include '.\����ȱʧ.sas';
%include '.\ҳ��ȱʧ.sas';
%include '.\unsdv_cra.sas';
/*%include '.\unsdv_dm.sas';*/
/*%include '.\unsdv_med.sas';*/
%include '.\δ�ύҳ��.sas';
%include '.\EDC��չ����.sas';

data summary;

	length sn 8 content $20;
	input sn $ content $;
	datalines;
1        EDC��չ����
2        ����ȱʧ����
3        ҳ��ȱʧ����
4        CRAδ�˲�ҳ��ϸ
5        δ�ύҳ�����
6        δ�ظ�����
7        �ѻظ�δȷ������
;
run;

/*5		 MEDδ�˲�ҳ��ϸ*/
/*6		 DMδ�˲�ҳ��ϸ*/


%macro tag_template;
options nofmterr missing=" ";

proc template;
define style Styles.tag_1;
parent = styles.printer;
style fonts /                                                         

"TitleFont" = ("Times New Roman",10pt, Medium)  
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
*�����ͷ;
style header /
backgroundcolor=#B2DFEE
color=black
font=("Times New Roman",12pt)
fontweight=bold;

*�����ļ��Ĳ���;
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
ods excel file="&root.\output\&study.��Ŀ��չ����_&sysdate..xlsx" options(contents="no"  FROZEN_HEADERS="Yes" autofilter='all' ) style=tag_1 ;
ods excel options(embedded_titles='no' embedded_footnotes='no');
%let ps1=1000;
%let ls1=256;
Options ps=&ps1 ls=&ls1  nodate nonumber nocenter;
options nonotes;
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*"; 
	ods excel options(sheet_name="&study.��Ŀ��չ����"  START_AT='B2') ;

	proc report data=summary  headskip headline nowd  
	/*-------- ����header��ʽ��ʽ���߿�-------------------*/
	style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	column ("Contents of Table"  sn  content);

	/*-------- ����column��ʽ��ʽ���߿�-------------------*/

	define sn / display  '���' style=[ just=left tagattr='text'  cellwidth=30% ] ;
	define content/ display "����" style=[ just=left tagattr='text' cellwidth=70% ] ;
	
	
	compute before  _PAGE_/ style = [ font_style=italic just=l font_weight=bold font_size=8pt borderbottomcolor=black borderbottomwidth=.5pt  background=white ];
	line "Project Name: &study.";	


	line "Create table by hengrui data management";

	line "Create table Time��%sysfunc(today(),yymmdd10.) %sysfunc(time(),hhmm5.)	";	
	endcomp;

    run;
	ods excel options(sheet_name='EDC��չ����' START_AT='A1'  FROZEN_ROWHEADERS='3');
	proc report data=dp.EDC_metrics headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	column _all_;
	DEFINE zxbhzd / STYLE( column )={TAGATTR='type:text'};
	run;
	ods excel options(sheet_name='����ȱʧ' START_AT='A1' FROZEN_ROWHEADERS='4');
	proc report data=dp.visitmiss headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	

			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
	DEFINE siteid / STYLE( column )={TAGATTR='type:text'};
	run;



	ods excel options(sheet_name='ҳ��ȱʧ' START_AT='A1' FROZEN_ROWHEADERS='4' );
	proc report data=dp.crfmiss headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	column _all_;
			
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
	DEFINE siteid / STYLE( column )={TAGATTR='type:text'};
	run;
	ods excel options(sheet_name='δSDV_CRA'  START_AT='A1' FROZEN_ROWHEADERS='4');
	proc report data=dp.unsdv_cra headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	column _all_;
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
	DEFINE siteid / STYLE( column )={TAGATTR='type:text'};
	run;
/*	ods excel options(sheet_name='δ�˲�_MED'  START_AT='A1' FROZEN_ROWHEADERS='4');*/
/*	proc report data=dp.unsdv_med headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;*/
/*	column _all_;*/
/*	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};*/
/*	DEFINE siteid / STYLE( column )={TAGATTR='type:text'};*/
/*	run;*/
/*	ods excel options(sheet_name='δ�˲�_DM'  START_AT='A1' FROZEN_ROWHEADERS='4');*/
/*	proc report data=dp.unsdv_dm headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;*/
/*	column _all_;*/
/*	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};*/
/*	DEFINE siteid / STYLE( column )={TAGATTR='type:text'};*/
/*	run;*/
	ods excel options(sheet_name='δ�ύҳ�����'  START_AT='A1' FROZEN_ROWHEADERS='4');
	proc report data=dp.unsub headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	column _all_;
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
	DEFINE siteid / STYLE( column )={TAGATTR='type:text'};
	run;

	ods excel options(sheet_name='δ�ظ�����' START_AT='A1');
	proc report data=dp.zyb_un headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	column _all_;
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
	run;

	ods excel options(sheet_name='�ѻظ�δȷ������' START_AT='A1');
	proc report data=dp.zyb_rep headskip headline nowd style(header)={just=c asis=on font_weight=bold font_style=italic} ;
	column _all_;
	DEFINE subjid / STYLE( column )={TAGATTR='type:text'};
	run;
	

ods excel close;
ods  listing;

