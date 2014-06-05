/* ********************************* */
/* Cardiac Analysis			         */ 
/* ********************************* */

PROC FREQ DATA = cardiac.lvsd_patient;
	TABLE ctc3_lvsd age_cat * ctc3_lvsd sex * ctc3_lvsd ethnic_origin * ctc3_lvsd  / chisq;
RUN ;

PROC FREQ DATA = cardiac.lvsd_course;
	TABLE period * ctc3_lvsd_final / nocum chisq;
RUN ;

PROC FREQ DATA = cardiac.lvsd_patient;
	TABLE gwas_lvsd ;
RUN ;

