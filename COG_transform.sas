/* ********************************* */
/* COG Baseline TransFORMATions      */ 
/* ********************************* */

LIBNAME cog 	"T:\Aplenc_New\Phenotype\AAML_0531\Analytic_DATA\Baseline" ;

/* ********************************* */
/* Demographics Recoding Numeric	 */ 
/* ********************************* */

DATA cog.demographics (drop = acc institutiON physician gender race ethnicity race_other ethnicity_other insurance) ;
  SET cog.enrollments ;

  /* calculate age and make 4 ordinal categories (age_cat) */
  age = (enroll_date - birth_date) / 365.25 ;
  IF missing(age) THEN DO ;
	CALL missing(age_cat) ;
	END ;
	ELSE IF age > 9.99999 THEN age_cat = 4 ;
	ELSE IF age > 5.99999 THEN age_cat = 3 ;
	ELSE IF age > 1.99999 THEN age_cat = 2 ;
	ELSE IF age > 0.99999 THEN age_cat = 1 ;
	ELSE IF age > 0.00000 THEN age_cat = 0 ;
  
  /* recode gender into numerical sex variable */
  /* 0 = male, 1 = female */
  IF missing(gender) 			THEN DO ;
   	CALL missing(sex) ;
	END ;
	ELSE IF gender = 'Male' 	THEN sex = 0 ;
	ELSE IF gender = 'Female' 	THEN sex = 1 ;
  
  /*recode race/ethnicity into one ethnic origin*/
  /* 0 = white, 1 = black, 2 = hispanic, 3 = asian, 4 = other/unkown/mixed */		
  IF ethnicity NE "Non-Spanish, non-Hispanic" 	THEN ethnic_origin = 2 ;
	ELSE IF race = "White" 						THEN ethnic_origin = 0 ;
	ELSE IF race = "Black" 						THEN ethnic_origin = 1 ;
	ELSE IF race = "Asian Indian, Pakistani" 	THEN ethnic_origin = 3 ;
	ELSE IF race = "Chinese" 					THEN ethnic_origin = 3 ;
	ELSE IF race = "Filipino" 					THEN ethnic_origin = 3 ;
	ELSE IF race = "Hmong" 						THEN ethnic_origin = 3 ;
	ELSE IF race = "Japanese" 					THEN ethnic_origin = 3 ;
	ELSE IF race = "Korean" 					THEN ethnic_origin = 3 ;
	ELSE IF race = "Other Asian, incl Asian NOS and Oriental" THEN ethnic_origin = 3 ;
	ELSE IF race = "Samoan" 					THEN ethnic_origin = 3 ;
	ELSE IF race = "Vietnamese" 				THEN ethnic_origin = 3 ;
	ELSE IF race = "Unknown" 					THEN ethnic_origin = 4 ;
	ELSE IF race = "Other" 						THEN ethnic_origin = 4 ;
	ELSE IF race = "American Indian, Aleutian, Eskimo" THEN ethnic_origin = 4 ;
	ELSE IF race = "Hawaiian" 					THEN ethnic_origin = 4 ;
	
	/* incorporate the incidental ethnicity/race occurences*/
IF race = "Laotian" 							THEN ethnic_origin = 3 ;
IF race_other = "Asian descent" 				THEN ethnic_origin = 3 ;
IF race_other = "HISPANIC" 						THEN ethnic_origin = 2 ;
IF race_other = "Hispanic" 						THEN ethnic_origin = 2 ;
IF race_other = "MEXICAN" 						THEN ethnic_origin = 2 ;
IF race_other = "Mexican" 						THEN ethnic_origin = 2 ;
IF race_other = "Non-White Hispanic" 			THEN ethnic_origin = 2 ;

IF insurance = 'MEDICAID' 											THEN pay = 1;
IF insurance = 'MEDICAID AND MEDICARE' 								THEN pay = 2;
IF insurance = 'MEDICARE' 											THEN pay = 3;
IF insurance = 'MEDICARE AND PRIVATE INSURANCE' 					THEN pay = 4;
IF insurance = 'MILITARY SPONSORED (INCLUDING CHAMPUS & TRICARE)' 	THEN pay = 5;
IF insurance = 'NO MEANS OF PAYMENT (NO INSURANCE)' 				THEN pay = 6;
IF insurance = 'OTHER' 												THEN pay = 7;
IF insurance = 'PRIVATE INSURANCE' 									THEN pay = 8;
IF insurance = 'SELF PAY (NO INSURANCE)' 							THEN pay = 9;
IF insurance = 'UNKNOWN' 											THEN pay = 10;
RUN ;

/* add treatment rx to data*/
PROC SQL ;
	CREATE TABLE cog.demographics AS 
	SELECT * FROM cog.demographics AS A 
	LEFT JOIN cog.RX AS B 
	ON A.Regno = B.FID ;
RUN ;

/* ********************************* */
/* Course Info						 */ 
/* ********************************* */

PROC SQL ;
CREATE TABLE cog.grade_courses AS 
	(SELECT * FROM cog.classified_echos AS echo 
	LEFT JOIN cog.course_DATA AS course 
	ON A.regnum = course.regnr) ;
RUN ;

PROC SQL ;
CREATE TABLE cog.grade_courses AS 
	(SELECT * FROM cog.grade_courses AS echo 
	LEFT JOIN cog.off_therapy AS off 
	ON cog.regnum = off.reg) ;
RUN ;

DATA  cog.grade_courses ;
	SET  cog.grade_courses ;
	FORMAT _date mmddyy10. ;
	_date = input(trim(d_test),MMDDYY10.) ;
RUN ;

DATA cog.grade_courses2 ;   length period_new $ 20 ; length comparisON $ 20 ; SET cog.grade_courses ;
	IF _date GE ind1_start 		and _date LE ind1_end +7 	THEN period_new = "InductiON I" ;
	IF _date GT ind2_start+8 	and _date LE ind2_end +7 	THEN period_new = "InductiON II" ;
	IF _date GT int1_start+8 	and _date LE int1_end +7 	THEN period_new = "IntensificatiON I" ;
	IF _date GT int2_start+8 	and _date LE int2_end +7	THEN period_new = "IntensificatiON II" ;
	IF _date GT int3_start+8 	and _date LE int3_end +7	THEN period_new = "IntensificatiON III" ;
	IF _date GT hsct_start+8 	and _date LE hsct_end +7	THEN period_new = "SCT" ;
	IF _date GT off_tx 			and _date LE fu_6m 	+7		THEN period_new = "FU 6M" ;
	IF _date GT fu_6m +8		and _date LE fu_12m +7		THEN period_new = "FU 12M" ;
	IF _date GT fu_12m +8		and _date LE fu_18m +7		THEN period_new = "FU 18M" ;
	IF _date GT fu_18m +8		and _date LE fu_2y 	+7		THEN period_new = "FU 2Y" ;
	IF _date GT fu_2y +8		and _date LE fu_3y 	+7		THEN period_new = "FU 3Y" ;
	IF _date GT fu_3y +8									THEN period_new = "FU 4Y" ;
	IF period = period_new THEN comparisON = "Good" ;
	IF period NE period_new THEN comparisON = "Different" ;
	IF period = "paper files" and period_new NE "" THEN comparisON = "No Previous Info" ;
	IF period NE "" and period_new EQ "" THEN comparisON = "No Course Info" ;
	period_final = period ;
	IF period = "paper files" THEN period_final = period_new ;
	TF = . ; viridans = . ; gnr = . ; ifi = . ;
RUN ;

PROC SORT DATA = cog.grade_courses2 ;
	BY _date ;
RUN ;

PROC FREQ DATA = cog.grade_courses2 ;
	TABLE comparisON ;
RUN ;

/* Combine Course Info*/ 
PROC SQL ;
	CREATE TABLE cog.courses AS 
	SELECT * FROM cog.courses_on_rx AS ON 
	LEFT JOIN cog.courses_off_rx AS off 
	ON on.regnr = off.reg ;
RUN ;


DATA cog.courses_long ;
	SET cog.courses ;
	ARRAY patient_in_period (5) ind1_end ind2_end int1_end int2_end int3_end ;
	DO parent = 1 to 5 ;
		followed_courses = patient_in_period (parent) ;
	   	OUTPUT ;
  	END ;
	DROP off_tx_prime off_tx_contributing ind1_end ind2_end int1_end int2_end int3_end fu_6m fu_12m fu_18m fu_2y fu_3y  ind1_start ind2_start int1_start int2_start int3_start ;
RUN ;

DATA cog.courses_long ;
	SET cog.courses_long ;
	IF followed_courses = . THEN DELETE ;
	sct = 1 ;
	IF hsct_start =  . THEN sct = 0 ;
RUN ;

DATA cog.end_therapy ;
   SET cog.courses_long ;
   BY regnr ;
   RETAIN max_patient ;
   IF first.regnr THEN max_patient = . ;
   max_patient = MAX(max_patient, parent) ;
   IF last.regnr THEN OUTPUT ;
RUN ;

PROC FREQ DATA = cog.end_therapy ;
	TABLE parent sct parent * sct ;
RUN ;


DATA cog.tmp ;
	SET cog.off_therapy ;
	IF off_tx = "NO" 							THEN DELETE ;
	IF rp   = "Induction I" 					THEN completed = 0 ;
	IF rp   = "Induction II" 					THEN completed = 1 ;
	IF rp   = "Intensification I" 				THEN completed = 2 ;
	IF rp   = "Intensification II" 				THEN completed = 3 ;
	IF rp   = "Intensification III" 			THEN completed = 4 ;
	IF rp_1 = "Induction I" 					THEN completed = 0 ;
	IF rp_1 = "Induction II" 					THEN completed = 1 ;
	IF rp_1 = "Intensification I" 				THEN completed = 2 ;
	IF rp_1 = "Intensification II" 				THEN completed = 3 ;
	IF rp_1 = "Intensification III" 			THEN completed = 4 ;
	IF prime = "Completion of planned therapy" 	THEN completed = 5 ;
	IF rp   = "HSCT" 							THEN completed = 9 ;
	IF rp_1  = "HSCT" 							THEN completed = 9 ;
RUN ;

PROC FREQ DATA = cog.off_therapy ; table prime * rp ; RUN ;
