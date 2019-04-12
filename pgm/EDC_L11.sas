data cm;

set derived.cm;
keep studyid--subjid lockstat--cmcom userid--lastmodifytime; 
run;
data edc.cm;

retain studyid subjid lockstat ;set cm ;sn1=input(sn,best.);run;
proc sort data=edc.cm;by subjid sn1;run;
data edc.cm;set edc.cm(drop=sn1);if lockstat ne "δ�ύ";run;

data out.l12(label='������ҩ'); set edc.cm; run;
