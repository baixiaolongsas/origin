/*soh**********************************************************************************
CODE NAME                 : <m_get_derived.sas>
CODE TYPE                 : <macro >
DESCRIPTION               : <生成无格式数据> 
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

proc datasets lib=derived nolist kill; run;
options fmtsearch=(raw);
%macro m_get_derived;

 proc format library=raw cntlout=work.cntlfmt;quit;
 proc sort data=cntlfmt(keep=FMTNAME LENGTH) nodupkeys out=fmt;by _all_;run;

%let ExtOut=sas7bdat;
 %let RC=%sysfunc(filename(FilRF,&root.\data\raw));                                                                                                
   %let Did=%sysfunc(dopen(&FilRF)); 
	 %let MemCnt=%sysfunc(dnum(&Did));
		 %do i = 1 %to &MemCnt;   
	
	 %let Name=%qscan(%qsysfunc(dread(&Did,&i)),-1,.); 
      %let EXPname=%scan(%qsysfunc(dread(&Did,&i)),1,.);
		%if %qupcase(%qsysfunc(dread(&Did,&i))) ne %qupcase(&Name) %then %do;                                                                                                      
           %if (%qupcase(&Name) = %qupcase(&ExtOut))  %then %do;  

			proc contents data=raw.&EXPname.  out=content_&EXPname.(keep=NAME FORMAT INFORMAT LENGTH VARNUM LABEL) noprint ;quit;
			proc sql;
			create table _label_fmt_&EXPname.  as select a.* ,b.LENGTH as fmtlength from content_&EXPname. as a left join fmt as b on trim(scan(a.FORMAT,1,'$'))=trim(b.FMTNAME);
			quit;
			proc datasets lib=work ;delete content_:;run;
			data pre_&EXPname.;
				set _label_fmt_&EXPname.;
				length content $20;
				if INFORMAT ='' then content='best.';
				else if INFORMAT ='YYMMDD' then content='YYMMDD10.';
				else if INFORMAT ='DATETIME' then content='e8601dt.';
				else content=compress(FORMAT||put(fmtlength,best.))||'.';
				if FORMAT='' and INFORMAT ne '' then content=cats("$",put(LENGTH,best.),'.');
			run;
			proc sort;by VARNUM;run;
			
			proc sql;
				select NAME ,
						cats('_',NAME),
						catx('=_',NAME,NAME),
						 compress(NAME)||"=left(put(_"||compress(NAME)||","||compress(content)||"))",
					      compress(NAME)||'="'||compress(label)||'"'
						into 
						:names separated by " ", 
						:drops separated by " ",
						:rename separated by " " ,
						:fmtvar separated by ";",
						:labels  separated by " " 
						from pre_&EXPname.;
				select 
					
					   compress(NAME)||' $'||coalesce(compress(left(put(fmtlength,best.)),'.'),compress(content,'$.'))
					  
						into 
					
						:nlength separated by " " 
				
					   from pre_&EXPname.(where=(INFORMAT='$'));
			quit;
		proc datasets lib=work ;delete pre_: _label_:;run;
			data derived.&EXPname.;
				retain &names.;
				length &nlength.;
				set raw.&EXPname.(rename=(&rename.));
				&fmtvar.;
				label &labels.;

				drop &drops.;
			run;
			%end;
        %end;   
    %end;                                                                                                                                                                                                                                                       
   %let RC=%sysfunc(dclose(&Did));  





%mend m_get_derived;

