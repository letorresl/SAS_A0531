/* ********************************* */
/* ADD ECHO TO LONG FILE             */ 
/* ********************************* */

data echo.import_echo;
	set echo.import_echo_ekg;
	where echo_ekg = "Echo";
	/*if period = "paper files" 	then delete;*/
	if period = "to request" 	THEN delete;
	if ef = "-99" 				THEN ef = . ;
	if ef = "-1" 				THEN ef = . ;
	if sf = "-1"		 		THEN sf = . ;
	IF ef = "Illegible" 		THEN ef = . ;
	IF sf = "Illegible" 		THEN sf = . ;
	IF ef = "."	 				THEN ef = . ;
	IF sf = "." 				THEN sf = . ;
	ef = ef * 1 ;
	sf = sf * 1 ;

	if d_test = "1/30/3009" 	THEN d_test = "1/30/2009";
	if d_test = "0/25/2011"		THEN d_test = "10/25/2011";
	if d_test = "10/19/209"		THEN d_test = "10/19/2009";
run;

proc sort data = echo.import_echo;
	by d_test ;
run;

/* 	frequency table to check the number of entries per patient per induction */
proc freq data = echo.import_echo noprint;
	table regnum * period /out = echo_freq;
run;

/* 	sort data with regard to patient number and course to check duplicates manually */
proc sort data = echo.import_echo;
	by regnum period;
run;

data echo.clean_echos; 
	set echo.import_echo;
	if EF = -1 then EF = .;
	if SF = -1 then SF = .;
	if EF >= 60 and EF NE . then grade_EF = 0;
	if SF >= 30 and SF NE . then grade_SF = 0;
	if EF >= 50 AND EF < 60 and EF NE . then grade_EF = 1;
	if SF >= 24 and SF < 30 and SF NE . then grade_SF = 1;
	if EF >= 40 and EF < 50 and EF NE . then grade_EF = 2;
	if SF >= 15 and SF < 24 and SF NE . then grade_SF = 2;
	if EF >= 20 and EF < 40 and EF NE . then grade_EF = 3;
	if SF < 15 and  SF NE . then grade_SF = 3;
	if EF < 20 and EF NE . then grade = 4;
	/* if then grade = 5; need mortality for 5*/
	if grade_EF > grade_SF and grade_EF NE . and grade_SF NE . then grade = grade_EF;
	if grade_SF > grade_EF and grade_EF NE . and grade_SF NE . then grade = grade_SF;
	if grade_SF = grade_EF and grade_EF NE . and grade_SF NE . then grade = grade_SF;
run; 

DATA echo.clean_echos ; 
	SET echo.clean_echos ;
	format _date MMDDYY10.;
	_date = input(d_test,MMDDYY10.) ;
RUN ;
 
PROC SQL ;
	CREATE TABLE echo.clean_echos AS (select * from echo.clean_echos AS A left join cog.courses AS B ON A.regnum = B.regnr) ;
RUN ;

/* PROC SQL ;
	CREATE TABLE echo.clean_echos AS (select * from echo.clean_echos AS A left join cog.off_therapy AS B ON A.regnum = B.reg) ;
RUN ; */

DATA echo.clean_echos ; 
	SET echo.clean_echos ;
	IF period = "paper files" THEN DELETE ;
	/*Marijana, when we look at EF data, we should prioritize the following methods of obtaining EF:*/
	/* remove m-mode AS it is derived from SF */
	IF sf LE 26 AND sf > 24 			THEN grade_sf = 1.5 ;
	grade = max (grade_sf, grade_ef) ;
	tmp_grade = grade ;
	if grade = . then tmp_grade = 0;
	IF ef_mode = '2D 4chamber Simpson' 	THEN priority = 10 ;
	IF ef_mode = '4C/Simpson' 			THEN priority = 10 ;
	IF ef_mode = 'Biplane' 				THEN priority = 10 ;
	IF ef_mode = 'Planimetric' 			THEN priority = 10 ;
	IF ef_mode = 'Simpson' 				THEN priority = 10 ;
	IF ef_mode = 'apical biplane' 		THEN priority = 10 ;
	IF ef_mode = '5/6 area length' 		THEN priority =  8 ;
	IF ef_mode = '4C AL' 				THEN priority =  8 ;
	IF ef_mode = 'AL method' 			THEN priority =  8 ;
	IF ef_mode = 'area/length' 			THEN priority =  8 ;
	IF ef_mode = '3D' 					THEN priority =  6 ;
	IF ef_mode = 'Bullet' 				THEN priority =  4 ;
	IF ef_mode = '2C' 					THEN priority =  2 ;
	IF ef_mode = '2C AL' 				THEN priority =  2 ; 
	IF ef_mode = '2D' 					THEN priority =  2 ;
	IF ef_mode = '4C' 					THEN priority =  2 ;
	IF ef_mode = 'MOD-sp4' 				THEN priority =  2 ;
	IF ef_mode = 'ModAp4ch' 			THEN priority =  2 ;
	IF ef_mode = 'Teich' 				THEN priority =  2 ;
	IF ef_mode = 'Teichholz' 			THEN priority =  2 ;
	IF ef_mode = 'Visual est' 			THEN priority =  2 ;
	IF ef_mode = 'Volume study' 		THEN priority =  2 ;
	IF ef_mode = 'apical 4 chamber' 	THEN priority =  2 ;
	IF ef_mode = 'apical 4ch'			THEN priority =  2 ;
	IF ef_mode = 'cubed'				THEN priority =  2 ;
	IF ef_mode = 'estimated' 			THEN priority =  2 ;
	IF ef_mode = 'planimetric and m-mode' THEN priority = 2 ;
	IF ef_mode = 'visual est' 			THEN priority =  2 ;
	IF ef_mode = 'm-mode' 				THEN priority =  2 ;
	IF ef_mode = ''						THEN priority = 0 ;
	IF period = "Induction I" 			THEN COURSE =  1 ;
	IF period = "Induction II" 			THEN COURSE =  2 ;
	IF period = "Intensification I" 	THEN COURSE =  3 ;
	IF period = "Intensification II" 	THEN COURSE =  4 ;
	IF period = "Intensification III" 	THEN COURSE =  5 ; 
	IF period = "SCT" 					THEN COURSE =  6 ;
	IF period = "FU 6M" 				THEN COURSE =  7 ;
	IF period = "FU 12M" 				THEN COURSE =  8 ;
	IF period = "FU 18M" 				THEN COURSE =  9 ;
	IF period = "FU 2Y" 				THEN COURSE = 10 ;
	IF period = "FU 3Y" 				THEN COURSE = 11 ;
	IF period = "FU 4Y" 				THEN COURSE = 12 ;
	composite = CAT (regnum, "_", course) ;
	IF _date GE ind1_start 		AND _date LE ind1_end 	+ 7 THEN period_new = 1  ;
	IF _date GT ind2_start + 8 	AND _date LE ind2_end 	+ 7 THEN period_new = 2  ;
	IF _date GT int1_start + 8 	AND _date LE int1_end 	+ 7 THEN period_new = 3  ;
	IF _date GT int2_start + 8 	AND _date LE int2_end 	+ 7	THEN period_new = 4  ;
	IF _date GT int3_start + 8 	AND _date LE int3_end 	+ 7	THEN period_new = 5  ;
	IF _date GT hsct_start + 8 	AND _date LE hsct_end 	+ 7	THEN period_new = 6  ; 
	IF _date GT off_tx 			AND _date LE fu_6m 		+ 7	THEN period_new = 7  ;
	IF _date GT fu_6m      + 8	AND _date LE fu_12m   	+ 7	THEN period_new = 8  ;
	IF _date GT fu_12m     + 8	AND _date LE fu_18m  	+ 7	THEN period_new = 9  ;
	IF _date GT fu_18m     + 8	AND _date LE fu_2y 		+ 7	THEN period_new = 10 ;
	IF _date GT fu_2y      + 8	AND _date LE fu_3y 		+ 7	THEN period_new = 11 ;
	IF _date GT fu_3y      + 8								THEN period_new = 12 ;
	diff = ABS(period_new - course) ;
	/* this is a cheat for the next sorting step (eliminate the unknowns)*/
RUN ;

PROC SORT DATA = echo.clean_echos ; 
	/* BY composite ;*/
	BY composite DESCENDING priority tmp_grade ; 
RUN ;

PROC FREQ DATA = echo.clean_echos NOPRINT ; 
	TABLE composite / OUT = echo.tmp ;
RUN ; 

PROC SORT DATA = echo.tmp; 
	BY DESCENDING count ;
RUN ; 

DATA echo.final_echos ;
   SET echo.clean_echos ;
   BY composite ;
   RETAIN maxprio ;
   IF first.composite THEN maxprio = . ;
   maxprio = MAX(maxprio, priority) ;
   IF last.composite THEN OUTPUT ;
RUN ;

PROC SORT DATA = echo.final_echos ; 
	BY composite ;
RUN ;

DATA echo.final_echos (keep = regnum course grade sf ef ef_mode d_test) ;
	SET echo.final_echos ;
RUN ;

DATA echo.final_echos ;
	SET echo.final_echos ;
	IF regnum NE . THEN echo = 1 ;
RUN ;

