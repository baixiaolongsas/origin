/*soh**********************************************************************************
CODE NAME                 : <Uncompress.sas>
CODE TYPE                 : <  >
DESCRIPTION               : <��ʼ������> 
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
 Author & baixiaolong
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		
--------------------------------------------------------------------------;*/
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

/*********************************  raw���ݽ�ѹ   *******************************/

/*��ȡraw�ļ�����ѹ������*/
filename zip pipe "dir &root\data\raw\*.zip /b";
data _null_;
        length fname $200.;
        infile zip truncover;
        input fname $200.;
        call symput ('raw',fname);
run;
%put &raw.;

/*��ѹ��ָ��·��*/
%let from1=&root.\data\raw\&raw.;
%let to1=&root.\data\raw;

option noxwait;
data _null_;
x "cd C:\Program Files\WinRAR";  
x "winrar x &from1. &to1.";     
run;


/*********************************  edc���ݽ�ѹ   *******************************/
/*��ȡedc�ļ�����ѹ������*/
filename zip pipe "dir &root\data\edc\*.zip /b";
data _null_;
        length fname $200.;
        infile zip truncover;
        input fname $200.;
        call symput ('edc1',fname);
		call symput ('edc2',scan(fname,1,'.'));
run;
%put &edc1.;
%put &edc2.;

/*��ѹ��ָ��·��*/
%let from2=&root.\data\edc\&edc1.;
%let to2=&root.\data\edc\&edc2.;

option noxwait;
data _null_;
x "md &to2.";
x "cd C:\Program Files\WinRAR";  
x "winrar x &from2. &to2.";
run;

x "cd &root.\pgm_out";  
