/* ********************************* */
/* AE Transformations                */ 
/* ********************************* */

LIBNAME ae 	"T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Adverse_Events" ;

/* ********************************* */
/* ADD LVSD / VGS CODING             */ 
/* ********************************* */

/* Reorganize the Adverse Events, and extract information on cardiac toxicity and viridans group strep infections */ 
DATA ae.ae_all(DROP = study vgse vgso vgsevere acc inst ctc_txt adeers_filed adeers_ticket comment p1begin p1end p2begin p2end p3begin p3end p4begin p4end p5begin p5end p6begin p6end pstart_d pend_d);
	SET ae.ae_import;

	if regno = . THEN DELETE;
	
	/* Extract Cardiac Events */
	IF (CTC3 = 2238000) THEN  lvsd = 1;
	IF missing(lvsd) 	THEN  lvsd = 0;

	/* Extract Viridans Group infections */
	IF (CTC3 = 5128077 | CTC3= 5137077 | CTC3 = 5146077) 										THEN  vgse=1;
	IF (CTC3 = 5128077 ) 																		THEN  vgsevere=1;
	IF (ORG_NAME= 1037 | ORG_NAME = 1038 | ORG_NAME = 1039 | ORG_NAME = 1042 | ORG_NAME = 1044) THEN  vgso = 1;
	IF (vgse=1 & vgso=1) 																		THEN  viridans=1;
	IF (vgsevere=1 & vgso=1) 																	THEN  viridans_severe=1;
	IF missing(viridans) 																		THEN  viridans = 0;
	IF missing(viridans_severe) 																THEN  viridans_severe = 0;

	/* optional: GNR & IFI */
	/*gnr = 0; 
	ifi = 0;
	IF (inf_class >= 3102 & inf_class <= 3127 & inf_class ~= 3114 & org_name ~= 3115) THEN  ifi=30;
	IF (inf_class >= 2000 & inf_class <= 2274) THEN  gnr = 40;
		
	/* optional: timevariables for survival analysis */
	/*time2event = (onset_date - date_enrolled); */
	/*time2endFU = (date_form - date_enrolled); */
	/*if missing(time2endFU) then time2endFU = '06-JUN-2012'd - date_enrolled; */
	/*if missing(time2event) then time2event = time2endFU; */
run;

proc sort data = ae.ae_all;
	by ctc3 ;
run;

proc sort data = ae.adversities;
	by ctc3 ;
run;

proc freq data = ae.ae_all;
	table lvsd;
run;

proc freq data = ae.adversities;
	table lvsd viridans viridans_severe ;
run;

PROC SQL;
	CREATE TABLE ae.ae_all AS 
	SELECT * FROM ae.ae_all AS A 
	LEFT JOIN cog.courses_on_rx AS B 
	ON A.regno = B.regnr ;
RUN;

PROC SQL;
	CREATE TABLE ae.ae_all AS 
	SELECT * FROM ae.ae_all AS A 
	LEFT JOIN cog.courses_off_rx AS B 
	ON A.regno = B.reg ;
RUN;

DATA ae.ae_lvsd (keep = regno period_new lvsd grade composite) ;
	SET ae.ae_all ;
	IF LVSD = 0 THEN DELETE ;
	composite = CAT (regno, "_", period) ;
RUN ;

PROC SORT DATA = ae.ae_lvsd ;
	BY composite grade ;
RUN ;

DATA ae.ae_lvsd ;
   SET ae.ae_lvsd ;
   BY composite ;
   RETAIN maxg ;
   IF first.composite THEN maxg = . ;
   maxg = MAX(maxg, grade) ;
   IF last.composite THEN OUTPUT ;
RUN ;
