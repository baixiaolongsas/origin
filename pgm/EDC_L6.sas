 /*soh**********************************************************************************
CODE NAME                 : <δ�ύ>
CODE TYPE                 : <dc >
DESCRIPTION               : <��չ����δ�ύҳ��> 
SOFTWARE/VERSION#         : <SAS 9.4>
INFRASTRUCTURE            : <System>
LIMITED-USE MODULES       : <   >
BROAD-USE MODULES         : <	>
INPUT                     : < >
OUTPUT                    : < unsub.sas7dbat>
VALIDATION LEVEL          : <	>
REQUIREMENTS              : <	>
ASSUMPTIONS               : <	>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:
 Author & xwei
	
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
01					2017-11-02
**eoh**********************************************************************************
*****************************************************************************************/

dm log 'clear';
proc datasets lib=work nolist kill; run;
%include '..\init\init.sas' ;

%let visit=visit;/*���ӽ׶εı��������Ƿ��е���Ŀ�ĸñ�����Ϊsvstage��*/
%let visitnum=visitnum; /*������ŵı��������Ƿ��е���Ŀ�ĸñ�����Ϊ�����ģ�*/
%let visdat=visdat;/*�������ڵı��������Ƿ��е���Ŀ��svstdat��*/;

data sv;
	set derived.sv;
	keep subjid &visit &visitnum &visdat;
run;
proc sort ;by subjid &visdat;run;

proc sql;
	create table sv_sfzqb as select coalesce(a.subjid,b.subjid) as subjid,coalesce(a.&visit,b.mc) as visit,coalesce(a.&visitnum,b.bm) as visitnum,a.&visdat,b.checkdat,open,close from sv as a full join EDC.sfzqb(where=(close ne .)) as b on a.subjid=b.subjid and a.&visitnum=b.bm;
quit;

%macro get_unsub_pre;
proc sql;
	select count(*) into:dnum from DICTIONARY.TABLES
                where libname = "DERIVED" ;
 quit;
%put &dnum;
%do i=1 %to &dnum;
	   proc sql noprint;
	   	  select distinct MEMNAME into:DNAME separated by ' ' from SASHELP.vstable where libname = "DERIVED" and monotonic()=&i;
          select name
			into 
			:varnames separated by ','
				 from DICTIONARY.COLUMNS
          where libname = "DERIVED" and memname="&DNAME" and label in ('��Ŀ����','�о����ı��','�����ߴ���','����','CRF״̬','�޸�ʱ��','��¼ID','������','ģ������','ҩ������');

          create table pre_&DNAME as select &varnames from derived.&DNAME;
		  
		  select name,name||"=var"||left(put(varnum,best.))
		  	into
			:varname1 separated by ' ',
			:rename1 separated by ' '
			from DICTIONARY.COLUMNS
		  where libname = "DERIVED" and memname="&DNAME" and label ne '���������'  and (label='��¼ID' or index(label,'���') ) ;

		    select name,"var"||left(put(varnum,best.))||"=catx('��','"||LABEL||"',compress("||NAME||",'.'))"
		  	into
			:varname2 separated by ' ',
			:rename2 separated by ';'
			from DICTIONARY.COLUMNS
		  where libname = "DERIVED" and memname="&DNAME" and (label in('��¼ID','ģ������','ҩ������') or index(label,'����') );
		quit;

		data sn_&DNAME;
			set DERIVED.&DNAME(keep=&varname1.);
			rename &rename1.;
		run;
		
		data dat_&DNAME;
			set DERIVED.&DNAME(keep=&varname2.);
			&rename2.;
			drop &varname2.;
		run;
%end;


%mend get_unsub_pre;

%get_unsub_pre;




data pre;
	set pre_:;
run;
proc datasets lib=work ;delete pre_:;run;
proc sort;by pub_tname pub_rid siteid subjid ;quit;
data select_detail_tid;
	length pub_tname $100.;
	set edc.hchzb(keep=bmc ejzbfjl where=(ejzbfjl is not null));
	pub_tname=bmc;
	drop bmc ;
run;
proc sort nodupkeys;by pub_tname;run;

data selected;
	merge pre select_detail_tid(in=b);
	by pub_tname;
	if ^b;
run;


proc sql;
	create table zsview as select siteid,count(pub_rid) as zs '�ܼ�¼ҳ��' from selected group by siteid;
quit;

data sn;
	set sn_:(rename=(var3=pub_rid));
	x=catx('|',of var:);
	sn=tranwrd(compress(x),'|',',');
	drop var: x ;
run;
proc datasets lib=work ;delete sn_:;run;
data dat;
	length pub_rid $12;
	set dat_:(rename=(var3=pub_rid_));
	pub_rid=compress(scan(pub_rid_,2,'��'));
	dat=tranwrd(catx('|',of var:),'|',',');
	if index(dat,'��');
	drop  var: pub_rid_;
run;
proc datasets lib=work ;delete dat_:;run;
proc sort data=sn ;by pub_rid;run;
proc sort data=dat ;by pub_rid;run;
proc sort data=selected out=selected(where=(lockstat='δ�ύ'));by pub_rid;run;

proc sql;
	create table prefinal as select a.*,b.sn,c.dat,status,icfdat from selected as a 
		left join sn b on compress(a.pub_rid)=compress(b.pub_rid)
			left join dat as c on compress(a.pub_rid)=compress(c.pub_rid)
				left join derived.subject as d on a.subjid=d.subjid;
quit;

data EDC.unsub;
	retain studyid siteid subjid status icfdat visit pub_tname    sn  dat lockstat lastmodifytime;
	set prefinal;
	keep studyid siteid subjid status icfdat visit pub_tname    sn  dat lockstat lastmodifytime;
	label sn='���' dat='�ο��ֶ�';
run;


proc sql;
	create table zsview1 as select siteid,count(pub_rid) as zs1 'δ�ύҳ��' from prefinal group by siteid;
quit;


data out.l7(label='δ�ύҳ�����'); set  EDC.unsub; run;

proc sql;
	create table EDC.zsview as 
    select a.*,coalesce(left(compress(put(b.zs1,best.),'.')),'0') as zs1 'δ�ύҳ��' 
    from zsview as a left join zsview1 as b on a.siteid=b.siteid;
quit;
