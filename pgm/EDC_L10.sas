data ae;

set derived.ae;
keep studyid--subjid lockstat--aecom userid--lastmodifytime; 
run;
data edc.ae;

retain studyid subjid lockstat ;set ae ;sn1=input(sn,best.);run;
proc sort data=edc.ae;by subjid sn1;run;
data edc.ae;set edc.ae(drop=sn1);if lockstat ne "δ�ύ";run;

data out.l11(label='�����¼�'); set edc.ae; run;
