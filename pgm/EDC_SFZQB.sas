/*soh**********************************************************************************
CODE NAME                 : <sfzqb new.sas>
CODE TYPE                 : <macro >
DESCRIPTION               : <动态访视窗> 
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
 Author & Jin Yanhong
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01						2018.7.7
-
-------------------------------------------------------------------------;*/
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

data qw;
  set edc.sfzqb;
  bm1=input(bm,best.);
  if subjid ne '';
  run;

proc sort data=qw;by subjid bm1;run;

data qw1;
  set qw;
  by subjid;
bm2=lag(bm1);
if first.subjid then bm2=.;
run;

proc sql;
  create table pre as
     select 
		 a.*,
		 input(a.bm,besyt.) as bmn "访视编号",
		 b.checkdat as checkdat1 "上一访视预期随访日期",
	     (a.checkdat-b.checkdat) as dif "与上一访视间隔天数",
		 (a.open-a.checkdat) as openc "open窗",
         (a.close-a.checkdat) as closec "close窗",
		 input(c.visdat,yymmdd10.) as visdat format yymmdd10. "访视日期",
		 input(d.visdat,yymmdd10.)  as visdat1 format yymmdd10. "上一访视日期" ,
       input(e.exstdat,yymmdd10.) as exstdat format yymmdd10. "给药日期" ,
  input(f.exstdat,yymmdd10.) as exstdat1 format yymmdd10. "上一访视给药日期"
	from qw1 as a
	left join qw1 as b on a.subjid=b.subjid and a.bm2=input(b.bm,best.) 
	left join derived.sv as c on a.subjid=c.subjid and c.visitnum=a.bm
    left join derived.sv as d on a.subjid=d.subjid and input(d.visitnum,best.)=input(a.bm,best.)-1
	left join derived.exi as e on a.subjid=e.subjid and e.visitnum=a.bm
	left join derived.exi as f on a.subjid=f.subjid and input(f.visitnum,best.)=input(a.bm,best.)-1
	where a.subjid ne ''
    order by siteid ,subjid ,bmn
;
quit;



/*基线为上次访视日期或本访视给药日期*/
data pre1;
	set pre ;
	by siteid subjid;
**本访视日期为空，上一访视日期不为空，则本访视预计访视日期为上一访视日期+与上一访视的日期差;
/*	if visdat=. and visdat1 ^=.  then do;*/
/*		checkdatsv=visdat1+dif;*/
/*		opensv=checkdatsv+openc;*/
/*		closesv=checkdatsv+closec;*/
/*	end;*/
**本访视给药日期为空，上一访视给药日期不为空，则本访视预计访视日期为上一访视给药日期+与上一访视的日期差;
    if  exstdat=. and exstdat1^=.  then do;
	    checkdatex=exstdat1+dif;
        openex=checkdatex+openc;
		closeex=checkdatex+closec;
	end;

/*	checkdatcu=coalesce(checkdatmr,checkdatsv);*/
/*	opencu=coalesce(openmr,opensv);*/
/*  closecu=coalesce(closemr,closesv);*/
	checkdatcu=checkdatex;
	opencu=openex;
    closecu=closeex;

/*	format checkdatsv YYMMDD10.  opensv YYMMDD10.  closesv YYMMDD10. */
	 format      checkdatex YYMMDD10.   openex YYMMDD10.  closeex YYMMDD10. 
            checkdatcu YYMMDD10.   opencu YYMMDD10.  closecu YYMMDD10.;
/*    label checkdatsv ="预期随访日期(sv)"  opensv="open(sv)" closesv="close(sv)"*/
	label       checkdatex ="预期随访日期(ex)"  openex="open(ex)" closeex="close(ex)";
                  ;
run;

/*本访视没有，上一访视有的*/
data pre211;
	set pre1;
    by  subjid bmn;
	if checkdatcu ne .;
	keep  subjid  bmn checkdat checkdatcu  datc ;
	datc=checkdatcu-checkdat ;
run;

data testqw;
  set pre211;
  by subjid;
  if last.subjid;
  run;
/*每个受试者 本访视没有，上一访视有的 个数*/
/*data pre21;*/
/*	set pre211;  */
/*	retain n;by  subjid bmn;*/
/*	if first.subjid then n=0;*/
/*	n+1;*/
/*run;*/

data pre21;
	set testqw;  
	retain n;by  subjid bmn;
	if first.subjid then n=0;
	n+1;
run;
/*m为受试者数*/
proc sort data=pre21 out=subdis nodupkey ;by subjid;run;
data subdis;set subdis;m+1;run;


proc sql;
	create table pre210 as 
	select a.* ,b.m from pre21 as a left join subdis as b on a.subjid=b.subjid;
quit;

%macro putdatc;
data _null_;
set subdis  nobs=lastobs point=lastobs;
call symputx('subnum',m);
stop;
run;

%put &subnum;

%do i=1 %to &subnum;
	proc sql noprint;
	select max(n) into: maxn  from subdis where m=&i;
	quit;
    %if &maxn=1 %then %do;
	    proc sql;
			   create table pre22_&i as 
			   select 
					a.*,
					b.datc  
			  from pre1 as a 
			  left join pre210 as b on a.subjid=b.subjid and a.bmn>= b.bmn
			  where  b.m=&i and a.dif ne .
		      order by  siteid ,subjid ,bmn
			;
		 quit;
   %end;
   %if &maxn>1 %then  %do;
		%do 1=j %to &maxn;
		proc sql;
			   create table pre22_&i&j as 
			   select 
					a.*,
					b.datc  
			  from pre1 as a 
			  left join pre210 as b on a.subjid=b.subjid and a.bmn>=b.bmn
			  where b.m=&i and a.dif ne .
		      order by  siteid ,subjid ,bmn
			;
		 quit;
		 %end;
/*		 data pre22_&i;*/
/*		 	merge pre22_&i:;*/
/*		 run;*/
     %end;
      data pre22;
	    merge pre1 pre22_:;
		by subjid bmn;
	  run;

%end;
%mend putdatc;
%putdatc;

data pre2;
	set pre22;
    if checkdat ne . and exstdat ne . then checkdatcu=exstdat;
     else if checkdat ne . and checkdatcu eq . then 	checkdatcu =checkdat+datc;
     checkdat=checkdatcu;
	open=checkdat+openc;
	close=checkdat+closec;
run;

data pre2; set pre2(rename=(bm=visitid)); if datc ne .;run;
 
data pre3;
  set pre22(rename=(bm=visitid));
if datc=.;
run;

data cvbn;
  set pre2 pre3;
	keep subjid open close visitid;
run;


data edc.sfzqb11;
  set pre2 pre3;
	keep subjid open close visitid;
run;





/*快速核对比对新访视窗和原访视窗*/
/*data new;*/
/*retain subjid mc bm;*/
/*set pre2 ;keep subjid mc bm checkdat--close dif--visdat;*/
/*run;*/
/*data old;*/
/*retain subjid mc bm;*/
/*set edc.sfzqb ;keep subjid mc bm checkdat--close  bm1;*/
/*bm1=input(bm,best.);*/
/*run;*/
/*proc sort data=old;by  subjid bm1;run;*/





