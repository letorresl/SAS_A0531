/* ********************************* */
/* AE Import 						 */ 
/* ********************************* */

data ae.ae_import   ;
%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
infile 'T:\Aplenc_New\Phenotype\AAML_0531\COG_Data\Adverse_Events\20130709_AdverseEvents_A0531.txt' delimiter='09'x MISSOVER DSD lrecl=32767 firstobs=2 ;
informat study $215. ;
informat regno best32. ;
informat GENDER best32. ;
informat ACC best32. ;
informat dob mmddyy10. ;
informat date_enrolled mmddyy10. ;
informat race best32. ;
informat ethnicity best32. ;
informat inst $69. ;
informat ddx mmddyy10. ;
informat p1begin mmddyy10. ;
informat p1end mmddyy10. ;
informat p2begin mmddyy10. ;
informat p2end mmddyy10. ;
informat p3begin mmddyy10. ;
informat p3end mmddyy10. ;
informat p4begin mmddyy10. ;
informat p4end mmddyy10. ;
informat p5begin mmddyy10. ;
informat p5end mmddyy10. ;
informat p6begin mmddyy10. ;
informat p6end mmddyy10. ;
informat death_p1 mmddyy10. ;
informat death_p2 mmddyy10. ;
informat period best32. ;
informat pstart_d mmddyy10. ;
informat pend_d mmddyy10. ;
informat height best32. ;
informat weight best32. ;
informat ldose_d mmddyy10. ;
informat ievalp best32. ;
informat ekgrcv best32. ;
informat doserd best32. ;
informat hospdys best32. ;
informat icudys best32. ;
informat serial best32. ;
informat ctc3 best32. ;
informat grade best32. ;
informat ctc4 best32. ;
informat ctc4_grade best32. ;
informat onset_date mmddyy10. ;
informat inf_class best32. ;
informat org_name best32. ;
informat comment $260. ;
format study $215. ;
format regno best12. ;
format GENDER best12. ;
format acc best12. ;
format dob mmddyy10. ;
format date_enrolled mmddyy10. ;
format race best12. ;
format ethnicity best12. ;
format inst $69. ;
format ddx mmddyy10. ;
format p1begin mmddyy10. ;
format p1end mmddyy10. ;
format p2begin mmddyy10. ;
format p2end mmddyy10. ;
format p3begin mmddyy10. ;
format p3end mmddyy10. ;
format p4begin mmddyy10. ;
format p4end mmddyy10. ;
format p5begin mmddyy10. ;
format p5end mmddyy10. ;
format p6begin mmddyy10. ;
format p6end mmddyy10. ;
format death_p1 mmddyy10. ;
format death_p2 mmddyy10. ;
format period best12. ;
format pstart_d mmddyy10. ;
format pend_d mmddyy10. ;
format height best12. ;
format weight best12. ;
format ldose_d mmddyy10. ;
format ievalp best12. ;
format ekgrcv best12. ;
format doserd best12. ;
format hospdys best12. ;
format icudys best12. ;
format serial best12. ;
format ctc3 best12. ;
format grade best12. ;
format ctc4 best12. ;
format ctc4_grade best12. ;
format onset_date mmddyy10. ;
format inf_class best12. ;
format org_name best12. ;
format comment $260. ;
input
study $
regno
GENDER
acc
dob
date_enrolled
race
ethnicity
inst $
ddx
p1begin
p1end
p2begin
p2end
p3begin
p3end
p4begin
p4end
p5begin
p5end
p6begin
p6end
death_p1
death_p2
period
pstart_d
pend_d
height
weight
ldose_d
ievalp
ekgrcv
doserd
hospdys
icudys
serial
ctc3
grade
ctc4
ctc4_grade
onset_date
inf_class
org_name
comment $
;
if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;
