/* ********************************* */
/* Cardiac Master File               */ 
/* ********************************* */

LIBNAME cog 	"T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Baseline" 		 ;
LIBNAME echo 	"T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Echos\On_Study" ;
LIBNAME ltfu 	"T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Echos\LTFU" 	 ;
LIBNAME ae 		"T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Adverse_Events" ;
LIBNAME cardiac	"T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Cardiac_Master" ;

/* ********************************* */
/* MAKE ONE ENTRY P PAT P COURSE     */ 
/* ********************************* */

DATA cardiac.lvsd_course ;
	SET cog.demographics ;
	IF elig = "No" THEN DELETE ;
	IF elig = "NO" THEN DELETE ;
	ind1	=	1 ;
	ind2	=	2 ;
	int1	=	3 ;
	int2	=	4 ;
	int3	=	5 ;
	hsct 	=	6 ;
	fu6m	=	7 ;
	fu12m	=	8 ;
	fu18m	=	9 ;
	fu2y	=	10 ;
	fu3y	=	11 ;
	fu4y	=	12 ;
RUN ;


DATA cardiac.lvsd_course ;
	SET cardiac.lvsd_course ;
    ARRAY course(12) ind1 ind2 int1 int2 int3 hsct fu6m fu12m fu18m fu2y fu3y fu4y ;
	DO i = 1 to 12 ;
    	period = course (i) ;
		OUTPUT ;
  	END ;
	DROP i fid ind1 ind2 int1 int2 int3 hsct fu6m fu12m fu18m fu2y fu3y fu4y ;
RUN ;

/* ********************************* */
/* ADD LTFU TO LONG FILE             */ 
/* ********************************* */

PROC SQL ;
	CREATE TABLE cardiac.lvsd_course  AS 
	SELECT A.*, B.ltfu_ctox AS lvsd_ltfu, B.echo_muga_done, B.ekg_done
	FROM cardiac.lvsd_course AS A 
	LEFT JOIN ltfu.final_ltfu AS B 
	ON A.Regno = B.Regno 
	AND A.period = B.period ;
RUN ;

DATA cardiac.lvsd_course ;
	SET cardiac.lvsd_course ;
	IF echo_muga_done NE "" AND lvsd_ltfu = . THEN lvsd_ltfu = -1 ;
RUN ;

/* ********************************* */
/* ADD AE-LVSD TO LONG FILE          */ 
/* ********************************* */

PROC SQL ;
	CREATE TABLE cardiac.lvsd_course AS 
	SELECT A.*, B.lvsd AS ctc3_lvsd, B.maxG AS ctc3_lvsd_g 
	FROM cardiac.lvsd_course AS A 
	LEFT JOIN ae.CTC3lvsd AS B 
	ON A.Regno = B.REGNO 
	AND A.period = B.period_new ;
RUN ;

/* ********************************* */
/* ADD AE-VGS TO LONG FILE           */ 
/* ********************************* */

PROC SQL ;
	CREATE TABLE cardiac.lvsd_course AS 
	SELECT A.*, B.viridans AS ctc3_vgs, B.maxG AS ctc3_vgs_g 
	FROM cardiac.lvsd_course AS A 
	LEFT JOIN ae.CTC3vgs AS B 
	ON A.Regno = B.REGNO 
	AND A.period = B.period_new ;
RUN ;

/* ********************************* */
/* ADD MANUAL ECHO TO LONG FILE      */ 
/* ********************************* */

PROC SQL ;
	CREATE TABLE cardiac.lvsd_course AS 
	SELECT A.*, B.sf AS echo_sf, B.ef AS echo_ef, B.grade AS echo_lvsd_g, B.echo AS echo_manual 
	FROM  cardiac.lvsd_course AS A 
	LEFT JOIN echo.final_echos AS B 
	ON A.Regno = B.Regnum 
	AND A.period = B.course ;
RUN ;

DATA cardiac.lvsd_course ;
	SET cardiac.lvsd_course ;
	IF echo_lvsd_g = 0 THEN echo_lvsd = 0 ;
	IF echo_lvsd_g > 0 THEN echo_lvsd = 1 ;
RUN ;

/* ********************************* */
/* Max Grade Per Patient             */ 
/* ********************************* */

DATA cardiac.lvsd_course ;
   	SET cardiac.lvsd_course ;
	if lvsd_ltfu = 1 THEN ltfu_lvsd_g = 2.5 ;
	max_grade = MAX(ctc3_lvsd_g, echo_lvsd_g, ltfu_lvsd_g) ;
RUN ;

/* keep the maximum severest cardiac grade from all courses for one patients */
DATA cardiac.lvsd_patient ;
   SET cardiac.lvsd_course ;
   BY regno ;
   RETAIN max_patient ;
   IF first.regno THEN max_patient = . ;
   max_patient = MAX(max_patient, max_grade) ;
   IF last.regno THEN OUTPUT ;
RUN ;

/* ********************************* */
/* Max Grade On Therapy + 6M P Pat   */ 
/* ********************************* */

DATA cardiac.lvsd_patient_onrx ;
   SET cardiac.lvsd_course ;
   IF period = 6 THEN DELETE ;
   IF period > 7 THEN DELETE ;
RUN ;

DATA cardiac.lvsd_patient_onrx ;
   SET cardiac.lvsd_patient_onrx ;
   BY regno ;
   RETAIN max_onrx ;
   IF first.regno THEN max_onrx = . ;
   max_onrx = MAX(max_onrx, max_grade) ;
   IF last.regno THEN OUTPUT ;
RUN ;

/* ********************************* */
/* Merge							 */ 
/* ********************************* */

PROC SQL ;
	CREATE TABLE cardiac.lvsd_patient AS 
	SELECT * FROM cardiac.lvsd_patient AS lvsd 
	LEFT JOIN cardiac.lvsd_patient_onrx AS rx 
	ON lvsd.regno = rx.regno ;
RUN ;

/* delete  */
PROC DELETE DATA = cardiac.lvsd_patient_onrx ;
RUN ;

/* create binary variable for new lvsd */
DATA cardiac.lvsd_patient (KEEP = regno age age_cat sex ethnic_origin rx max_patient max_onrx ctc3_lvsd gwas_lvsd) ;
    SET cardiac.lvsd_patient ;
	IF max_patient > 0 	THEN ctc3_lvsd = 1  ;	
	IF max_patient = 0 	THEN ctc3_lvsd = 0  ;
	IF max_patient = . 	THEN ctc3_lvsd = -9 ;
	IF max_onrx = 1    	THEN gwas_lvsd = -9 ;	
	IF max_onrx = 2    	THEN gwas_lvsd = 1  ;
	IF max_onrx = 3 	THEN gwas_lvsd = 1  ;
	IF max_onrx = 4 	THEN gwas_lvsd = -9 ;
	IF max_onrx = 5 	THEN gwas_lvsd = -9 ;
	IF max_onrx = . 	THEN gwas_lvsd = 0  ;
RUN ;

/* counts of each */
proc freq data = cardiac.lvsd_course ; 
table lvsd_ltfu ctc3_lvsd echo_lvsd_g echo_muga_done; 
run ;

DATA cardiac.lvsd_followup (keep = regno period lvsd_ltfu ctc3_lvsd echo_lvsd echo);
	SET cardiac.lvsd_course ; 
	IF period < 7 THEN DELETE ;
	IF lvsd_ltfu = . AND ctc3_lvsd = . AND echo_Manual = . THEN DELETE;
	IF ctc3_lvsd = . THEN ctc3_lvsd = -1 ;
	IF echo_lvsd = . THEN echo_lvsd = -1 ;
	IF lvsd_ltfu = . THEN lvsd_ltfu = -1 ;
	IF strip(echo_muga_done) = "" THEN echo = -1 ;
	IF strip(echo_muga_done) = "1" THEN echo = 1 ;
	IF strip(echo_muga_done) = "0" THEN echo = 0 ;
	IF strip(echo_muga_done) = "0.5" THEN echo = 0.5 ;
RUN ;


proc freq data = cardiac.lvsd_followup ; 
table ctc3_lvsd * lvsd_ltfu echo_lvsd * lvsd_ltfu / nocum norow nocol ; 
run ;
