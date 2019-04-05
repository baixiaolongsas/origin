/*soh**********************************************************************************
CODE NAME                 : <m_get_edc.sas>
CODE TYPE                 : <macro >
DESCRIPTION               : <获得新数据> 
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

proc datasets lib=edc nolist kill; run;
%macro m_get_edc;

filename zip pipe "dir &root\data\edc\*.zip /b";
data vname;
        length fname $200.;
        infile zip truncover;
        input fname $200.;
        call symput ('nvars',_n_);
run;
proc sort;by fname;run;

data _null_;
	set vname(firstobs=&nvars);
	call symput ('newest',scan(fname,1,'.'));
	call symput ('lib',substr(fname,1,8));
run;

%include "..\data\edc\&newest.\*.sas";
proc copy in=&lib out=edc;run;
proc datasets lib= &lib  nolist nodetails kill;quit;


%mend m_get_edc;

