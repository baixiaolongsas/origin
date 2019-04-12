/*soh**********************************************************************************
CODE NAME                 : <L_9>
CODE TYPE                 : <listing >
DESCRIPTION               : <��Ч����ȱʧ> 
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
			a.subjid ,b.status,input(a.exdat,yymmdd10.) as exdat format yymmdd10. "C1D1��ҩ����",
			(today()-input(a.exdat,yymmdd10.)) as day "C1D1��ҩ�������",
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
	
	label zq="����" zqy='��n��';
	drop zqz zqy0;
run;

data mappre;
	set zq;
	zqcount=zq+0.1*zqy;
	/*visstage0="ɸѡ��(28����)";output;*/
	if zqcount>=11.1 then do;visstage1="��9��";end;output;
	if zqcount>=19.1 then do;visstage1="��9��";visstage2="��17��";end;output;
	if zqcount>=27.1 then do;visstage1="��9��";visstage2="��17��";visstage3="��25��";end;output;
	if zqcount>=39.1 then do;visstage1="��9��";visstage2="��17��";visstage3="��25��";visstage4="��37��";end;output;
	if zqcount>=68.1 then do;visstage1="��9��";visstage2="��17��";visstage3="��25��";visstage4="��37��";visstage5="��49��";end;output;
	if zqcount>=84.1 then do;visstage1="��9��";visstage2="��17��";visstage3="��25��";visstage4="��37��";visstage5="��49��";visstage6="��65��";end;output;
	if zqcount>=100.1 then do;visstage1="��9��";visstage2="��17��";visstage3="��25��";visstage4="��37��";visstage5="��49��";visstage6="��65��";visstage7="��81��";end;output;
	if zqcount>=127.1 then do;visstage1="��9��";visstage2="��17��";visstage3="��25��";visstage4="��37��";visstage5="��49��";visstage6="��65��";visstage7="��81��";visstage8="��97��";end;output;
	if zqcount>=153.1 then do;visstage1="��9��";visstage2="��17��";visstage3="��25��";visstage4="��37��";visstage5="��49��";visstage6="��65��";visstage7="��81��";visstage8="��97��";visstage9="��123��";end;output;
	if zqcount>=179.1 then do;visstage1="��9��";visstage2="��17��";visstage3="��25��";visstage4="��37��";visstage5="��49��";visstage6="��65��";visstage7="��81��";visstage8="��97��";visstage9="��123��";visstage10="��149��";end;output;
	if zqcount>=195.1 then do;visstage1="��9��";visstage2="��17��";visstage3="��25��";visstage4="��37��";visstage5="��49��";visstage6="��65��";visstage7="��81��";visstage8="��97��";visstage9="��123��";visstage10="��149��";visstage11="��175��";end;output;
	drop zqcount;
run; 
proc sort ;by subjid;run;

data map;
	set mappre ;
	by subjid;
	length pub_tid$20 pub_tname $20;
	if last.subjid;
	if visstage1 ne "";
	pub_tid="rst1" ;pub_tname="�в�����������";output;
	pub_tid="rsnt1" ;pub_tname="�ǰв�����������";output;
	pub_tid="zq" ;pub_tname="��������";output;
	pub_tid="rsnl" ;pub_tname="����Ӱ��ѧ����";output;
	pub_tid="pet" ;pub_tname="����FDG-PET���";output;
	pub_tid="rsnl2" ;pub_tname="������л����";output;
	pub_tid="rsnl3" ;pub_tname="����������Ч����";output;
	length result1$200 result2$200 result3$200  result4$200 result5$200 result6$200 result7$200 result8$200 result9$200 result10$200 result11$200 ;
run;
proc sort ;by pub_tid subjid;run;


data visstagenum;
input visstageid$ visstage$ 20.;
cards;
1   ��9��                 
2   ��17��                  
3   ��25��              
4   ��37��         
5   ��49��             
6   ��65��              
7   ��81��                 
8   ��97��                       
9   ��123��                        
10   ��149��                              
11   ��175��  
;
run;





%macro pg(data,result,key );
proc sql;
	create table &data.pre as 
		select a.pub_tid,a.pub_tname, a.subjid, a.lockstat,a.&key. as sn "�������",a.visstage,c.visstageid ,&result. as result "���",notdone "�Ƿ����/����"
	from derived.&data. as a 
	left join visstagenum  as c on a.visstage=c.visstage
	where find(a.visstage,"��") 
	order by subjid  ,sn,visstageid
	;
quit;

data &data.pre1;
	set &data.pre;
	if notdone in("δ��","������","��") then  result="δ�������û��޽��";
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
	visstage&i. "���ӽ׶�&i.",result&i. "���&i."
	from &data. order by subjid;
	quit;
%end;


data &data.final;
merge &data._:;
run;

%mend pg;

%pg(rst1,rspsorre,%str(lesionno));
%pg(rsnt1,rslsstat,%str(lesionno));




/*zq����źͲ�����Ų�һ�����ǰ����˳���ģ�������⴦��*/
%macro zqpg(data,result,key );
proc sql;
	create table &data.pre as 
		select a.pub_tid,a.pub_tname, a.subjid, a.lockstat,&key. as sn "�������",a.visstage,c.visstageid ,&result. as result "���",notdone "�Ƿ����/����"
	from derived.&data. as a 
	left join visstagenum  as c on a.visstage=c.visstage
	where find(a.visstage,"��") 
	order by subjid ,sn,visstageid
	;
quit;

data &data.pre1;
	set &data.pre;
	if notdone in("δ��","������","��") then  result="δ�������û��޽��";
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
	visstage&i. "���ӽ׶�&i.",result&i. "���&i."
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
	select a.pub_tid,a.pub_tname, a.subjid, a.lockstat,"" as sn "�������",a.&visstage. as visstage "��ǰ���ӽ׶�",c.visstageid ,&result. as result "���",notdone "�Ƿ����/����"
	from derived.&data. as a 
	left join visstagenum  as c on a.&visstage.=c.visstage
	where find(a.&visstage.,"��")
	order by subjid ,visstageid 
	;
quit;

data &data.pre1;
	set &data.pre;
	if notdone in("δ��","������","��") then  result="δ�������û��޽��";
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

/*pet rsnl ֻ��17��25��*/
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
			if visstage&i. ^= "" and result&i. ="" then  result&i.="ȱʧ";
	end;
	if pub_tid in("pet","rsnl2") then do;
	    if visstage2 ^= "" and result2 ="" then  result2="ȱʧ";
		if visstage3 ^= "" and result3 ="" then  result3="ȱʧ";
	end;
	label visstage&i.="���ӽ׶�&i."   result&i.="���&i.";
	%end;
run;

data zlpg1;set zlpg;keep subjid--sn;run;
%do i=1 %to 11;
data viss_&i.;set zlpg;keep visstage&i. result&i.;run;
%end;

data edc.zlpg1;merge zlpg1 viss_1-viss_11;run;

%mend que;
%que;

/*�������������ڵھ��ܵ�1��ǰ����ھ��ܲ�����ȱʧ*/
proc sql;
	create table edc.zlpg2 as 
		select input(d.lasexdat,YYMMDD10.) as lasexdat 'ĩ���о�ҩ���ҩ����'  format yymmdd10.,
			d.dsreas,c.dsreas as dsreasds,input(c.dsdat,yymmdd10.) as dsdat '��ֹ�о�����' format yymmdd10.,
			input(b.dthdat,yymmdd10.) as dthdat '��������' format yymmdd10.,a.*
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
	zq&i=input(scan(visstage&i,1,'����'),best.);
	day&i=exdat+(zq&i-1)*7;format day&i yymmdd10.;
	if ( dthdat^=. and  dthdat<day&i) /*or (dsdat^=. and  dsdat<day&i) */then result&i='������';
	if dsreas='Ӱ��ѧ��չ' and lasexdat ^=.  and day&i>lasexdat then result&i='����Ӱ��ѧ��չ�˳�����';
    if dsreasds^='����' and dsdat^=. and  dsdat<day&i  then result&i='����ֹ�о�';
%end;
drop zq1-zq11 day1-day11 dsreasds;
run;

%mend;
%dth;
proc sort data=edc.zlpg;by subjid pub_tid;run;


%macro fbbz;
data edc.zlpg;
	set edc.zlpg;
	if  pub_tname='�ǰв�����������' and result1='ȱʧ' then do;
	   %do i=1 %to 11;
	   if result&i^='' then  result&i='�޷ǰв���';
	   %end;
	end;
run;
%mend fbbz;
%fbbz;

data out.l10(label='��Ч����ȱʧ'); set edc.zlpg; run;
