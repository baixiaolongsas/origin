/*soh**********************************************************************************
CODE NAME                 : <L_9>
CODE TYPE                 : <listing >
DESCRIPTION               : <疗效评估缺失> 
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
 Author &Jin Yanhong
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01		          		    2018-8-15
**eoh**********************************************************************************/;
dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

proc sql;
	create table zqpre as 
		select 
			a.subjid ,b.status,input(a.exdat,yymmdd10.) as exdat format yymmdd10. "C1D1给药日期",
			(today()-input(a.exdat,yymmdd10.)) as day "C1D1给药距今天数",
			int( (today()-input(a.exdat,yymmdd10.)+1) /7) as zqz,
			mod((today()-input(a.exdat,yymmdd10.)+1),7) as zqy0 
		from derived.ex as a 
        left join derived.subject as b on a.subjid=b.subjid  where visit="C1D1";
quit;

data zq;
    retain subjid exdat day zq ;
	set zqpre;
    if zqy0^=0 then do;  zq=zqz+1;zqy=zqy0;end;
    if  zqy0=0 then do ;zq=zqz;zqy=7;end;
	
	label zq="周期" zqy='第n天';
	drop zqz zqy0;
run;

data mappre;
	set zq;
	zqcount=zq+0.1*zqy;
	/*visstage0="筛选期(28天内)";output;*/
	if zqcount>=11.1 then do;visstage1="第9周";end;output;
	if zqcount>=19.1 then do;visstage1="第9周";visstage2="第17周";end;output;
	if zqcount>=27.1 then do;visstage1="第9周";visstage2="第17周";visstage3="第25周";end;output;
	if zqcount>=39.1 then do;visstage1="第9周";visstage2="第17周";visstage3="第25周";visstage4="第37周";end;output;
	if zqcount>=68.1 then do;visstage1="第9周";visstage2="第17周";visstage3="第25周";visstage4="第37周";visstage5="第49周";end;output;
	if zqcount>=84.1 then do;visstage1="第9周";visstage2="第17周";visstage3="第25周";visstage4="第37周";visstage5="第49周";visstage6="第65周";end;output;
	if zqcount>=100.1 then do;visstage1="第9周";visstage2="第17周";visstage3="第25周";visstage4="第37周";visstage5="第49周";visstage6="第65周";visstage7="第81周";end;output;
	if zqcount>=127.1 then do;visstage1="第9周";visstage2="第17周";visstage3="第25周";visstage4="第37周";visstage5="第49周";visstage6="第65周";visstage7="第81周";visstage8="第97周";end;output;
	if zqcount>=153.1 then do;visstage1="第9周";visstage2="第17周";visstage3="第25周";visstage4="第37周";visstage5="第49周";visstage6="第65周";visstage7="第81周";visstage8="第97周";visstage9="第123周";end;output;
	if zqcount>=179.1 then do;visstage1="第9周";visstage2="第17周";visstage3="第25周";visstage4="第37周";visstage5="第49周";visstage6="第65周";visstage7="第81周";visstage8="第97周";visstage9="第123周";visstage10="第149周";end;output;
	if zqcount>=195.1 then do;visstage1="第9周";visstage2="第17周";visstage3="第25周";visstage4="第37周";visstage5="第49周";visstage6="第65周";visstage7="第81周";visstage8="第97周";visstage9="第123周";visstage10="第149周";visstage11="第175周";end;output;
	drop zqcount;
run; 
proc sort ;by subjid;run;

data map;
	set mappre ;
	by subjid;
	length pub_tid$20 pub_tname $20;
	if last.subjid;
	if visstage1 ne "";
	pub_tid="rst1" ;pub_tname="靶病灶评估测量";output;
	pub_tid="rsnt1" ;pub_tname="非靶病灶评估测量";output;
	pub_tid="zq" ;pub_tname="脏器增大";output;
	pub_tid="rsnl" ;pub_tname="肿瘤影像学评估";output;
	pub_tid="pet" ;pub_tname="肿瘤FDG-PET检查";output;
	pub_tid="rsnl2" ;pub_tname="肿瘤代谢评估";output;
	pub_tid="rsnl3" ;pub_tname="肿瘤总体疗效评估";output;
	length result1$200 result2$200 result3$200  result4$200 result5$200 result6$200 result7$200 result8$200 result9$200 result10$200 result11$200 ;
run;
proc sort ;by pub_tid subjid;run;


data visstagenum;
input visstageid$ visstage$ 20.;
cards;
1   第9周                 
2   第17周                  
3   第25周              
4   第37周         
5   第49周             
6   第65周              
7   第81周                 
8   第97周                       
9   第123周                        
10   第149周                              
11   第175周  
;
run;





%macro pg(data,result,key );
proc sql;
	create table &data.pre as 
		select a.pub_tid,a.pub_tname, a.subjid, a.lockstat,a.&key. as sn "病灶序号",a.visstage,c.visstageid ,&result. as result "结果",notdone "是否测量/评估"
	from derived.&data. as a 
	left join visstagenum  as c on a.visstage=c.visstage
	where find(a.visstage,"周") 
	order by subjid  ,sn,visstageid
	;
quit;

data &data.pre1;
	set &data.pre;
	if notdone in("未做","不适用","否") then  result="未做或不适用或无结果";
	drop notdone;
run;


proc transpose data= &data.pre1 out= &data.pre_ (drop= _name_) prefix=result;
   by pub_tid pub_tname   subjid   sn;
   id visstageid ;
   var result  ;
run;
proc sort ;by subjid;run;

data &data.;
	retain   subjid  status exdat day zq zqy   pub_tid pub_tname  sn;
	merge map(where=(pub_tid="&data."))  &data.pre_;
	by pub_tid pub_tid subjid ;
	if visstage1 ne "";
run;


%do i=1 %to 11;
proc sql;
	create table &data._&i. as 
	select subjid , status ,exdat, day ,zq ,zqy,   
	pub_tid, pub_tname,  sn,
	visstage&i. "访视阶段&i.",result&i. "结果&i."
	from &data. order by subjid;
	quit;
%end;


data &data.final;
merge &data._:;
run;

%mend pg;

%pg(rst1,rspsorre,%str(lesionno));
%pg(rsnt1,rslsstat,%str(lesionno));




/*zq的序号和病灶序号不一样，是按检查顺序标的，因此特殊处理*/
%macro zqpg(data,result,key );
proc sql;
	create table &data.pre as 
		select a.pub_tid,a.pub_tname, a.subjid, a.lockstat,&key. as sn "病灶序号",a.visstage,c.visstageid ,&result. as result "结果",notdone "是否测量/评估"
	from derived.&data. as a 
	left join visstagenum  as c on a.visstage=c.visstage
	where find(a.visstage,"周") 
	order by subjid ,sn,visstageid
	;
quit;

data &data.pre1;
	set &data.pre;
	if notdone in("未做","不适用","否") then  result="未做或不适用或无结果";
	drop notdone;
run;


proc transpose data= &data.pre1 out= &data.pre_ (drop= _name_) prefix=result;
   by pub_tid pub_tname   subjid  sn;
   id visstageid;
   var result  ;
run;
proc sort ;by subjid;run;

data &data.;
	retain   subjid  status exdat day zq zqy   pub_tid pub_tname  sn;
	merge map(where=(pub_tid="&data.")) &data.pre_;
	by pub_tid pub_tid subjid ;
	if visstage1 ne "";
run;


%do i=1 %to 11;
proc sql;
	create table &data._&i. as 
	select subjid , status ,exdat, day ,zq ,zqy,   
	pub_tid, pub_tname,  sn,
	visstage&i. "访视阶段&i.",result&i. "结果&i."
	from &data. order by subjid;
	quit;
%end;


data &data.final;
merge &data._:;
run;

%mend zqpg;

%zqpg(zq,zqcj,%str(''));


%macro pg1(data,result,visstage );
	proc sql;
	create table &data.pre as 
	select a.pub_tid,a.pub_tname, a.subjid, a.lockstat,"" as sn "病灶序号",a.&visstage. as visstage "当前访视阶段",c.visstageid ,&result. as result "结果",notdone "是否测量/评估"
	from derived.&data. as a 
	left join visstagenum  as c on a.&visstage.=c.visstage
	where find(a.&visstage.,"周")
	order by subjid ,visstageid 
	;
quit;

data &data.pre1;
	set &data.pre;
	if notdone in("未做","不适用","否") then  result="未做或不适用或无结果";
	drop notdone;
run;


proc transpose data= &data.pre1 out= &data.pre_ (drop= _name_) prefix=result;
   by pub_tid pub_tname   subjid  sn;
   id visstageid;
   var result  ;
run;

data &data.;
	retain   subjid  status exdat day zq zqy   pub_tid pub_tname lockstat ;
	merge map(where=(pub_tid="&data.")) &data.pre_;
	by pub_tid pub_tid subjid ;
	if visstage1 ne "";
run;
proc sort ;by subjid;run;

%do i=1 %to 11;
proc sql;
	create table &data._&i. as 
		select subjid , status ,exdat, day ,zq ,zqy,   
			pub_tid, pub_tname, sn,
			visstage&i. ,result&i. 
		from &data. where pub_tid="&data." order by subjid;
quit;
%end;


data &data.final;
merge &data._:;
run;

%mend pg1;


%pg1(rsnl,rsevltot,visstage);
%pg1(rsnl3,rsevltot,visstage);

/*pet rsnl 只看17和25周*/
%pg1(pet,petre,petvs);
%pg1(rsnl2,rsevltot,visstage);


data tot0;
set  rst1final  rsnt1final zqfinal rsnlfinal rsnl3final petfinal rsnl2final;
run;
proc sort ;by  subjid pub_tid;run;

proc sort data=map;by  subjid pub_tid;run;
data tot;
retain subjid status exdat day zq  zqy pub_tid pub_tname  sn 
visstage1 result1 visstage2 result2 visstage3 result3 visstage4 result4 visstage5 
result5 visstage6 result6 visstage7 result7 visstage8 result8 visstage9 result9 visstage10 result10 visstage11 result11 
;
merge   map tot0;
by  subjid pub_tid;
run;

%macro que;
data zlpg;
	set tot;
	%do i=1 %to 11;
	if  pub_tid ^in("pet","rsnl2") then do;
	        length result&i. $200;
			if visstage&i. ^= "" and result&i. ="" then  result&i.="缺失";
	end;
	if pub_tid in("pet","rsnl2") then do;
	    if visstage2 ^= "" and result2 ="" then  result2="缺失";
		if visstage3 ^= "" and result3 ="" then  result3="缺失";
	end;
	label visstage&i.="访视阶段&i."   result&i.="结果&i.";
	%end;
run;

data zlpg1;set zlpg;keep subjid--sn;run;
%do i=1 %to 11;
data viss_&i.;set zlpg;keep visstage&i. result&i.;run;
%end;

data edc.zlpg1;merge zlpg1 viss_1-viss_11;run;

%mend que;
%que;

/*比如死亡日期在第九周第1天前的则第九周不计算缺失*/
proc sql;
	create table edc.zlpg2 as 
		select input(d.lasexdat,YYMMDD10.) as lasexdat '末次研究药物给药日期'  format yymmdd10.,
			d.dsreas,c.dsreas as dsreasds,input(c.dsdat,yymmdd10.) as dsdat '终止研究日期' format yymmdd10.,
			input(b.dthdat,yymmdd10.) as dthdat '死亡日期' format yymmdd10.,a.*
		from edc.zlpg1 as a
		left join derived.dth as b on a.subjid=b.subjid
		left join derived.ds as c on a.subjid=c.subjid 
		left join derived.ds1 as d on a.subjid=d.subjid
	;
quit;

%macro dth;
data edc.zlpg;
retain subjid status exdat day zq  zqy dsdat dthdat lasexdat dsreas pub_tid pub_tname  sn ;
set edc.zlpg2;
%do i=1 %to 11;
	zq&i=input(scan(visstage&i,1,'第周'),best.);
	day&i=exdat+(zq&i-1)*7;format day&i yymmdd10.;
	if ( dthdat^=. and  dthdat<day&i) /*or (dsdat^=. and  dsdat<day&i) */then result&i='已死亡';
	if dsreas='影像学进展' and lasexdat ^=.  and day&i>lasexdat then result&i='已因影像学进展退出治疗';
    if dsreasds^='死亡' and dsdat^=. and  dsdat<day&i  then result&i='已终止研究';
%end;
drop zq1-zq11 day1-day11 dsreasds;
run;

%mend;
%dth;
proc sort data=edc.zlpg;by subjid pub_tid;run;


%macro fbbz;
data edc.zlpg;
	set edc.zlpg;
	if  pub_tname='非靶病灶评估测量' and result1='缺失' then do;
	   %do i=1 %to 11;
	   if result&i^='' then  result&i='无非靶病灶';
	   %end;
	end;
run;
%mend fbbz;
%fbbz;

data out.l10(label='疗效评估缺失'); set edc.zlpg; run;
