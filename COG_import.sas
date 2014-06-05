/* ********************************* */
/* COG Import 						 */ 
/* ********************************* */

LIBNAME cog "T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Baseline" ;

/* ********************************* */
/* Off Therapye Info				 */ 
/* ********************************* */
OPTIONS VALIDVARNAME = ANY ;
PROC IMPORT 
	DATAFILE = "T:\Aplenc_New\Phenotype\AAML_0531\COG_Data\Enrollments\20140310_RPoffTX_A0531.txt" 
	OUT = cog.off_therapy DBMS = DLM REPLACE ; 
	GUESSINGROWS = 32767 ; 
	DELIMITER = '09'x ;
	GETNAMES = YES ;
	DATAROW = 2 ;
RUN ;

/* ********************************* */
/* Enrollments						 */ 
/* ********************************* */

data cog.enrollments;
  %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
  infile 'T:\Aplenc_New\Phenotype\AAML_0531\COG_Data\Enrollments\20140311_Enrollments_A0531.txt' delimiter='09'x MISSOVER DSD lrecl=32767 firstobs=2 ;
  INFORMAT REGNO 			 	  10.;
  INFORMAT Acc 				  10.;
  INFORMAT Elig				 $10.;
  INFORMAT Enroll_Date	mmddyy10.;
  INFORMAT Institution		$40.0;
  INFORMAT Physician			$40.0;
  INFORMAT Birth_Date		mmddyy10.;
  INFORMAT Gender				$10.0;
  INFORMAT Ethnicity			$40.0;
  INFORMAT Ethnicity_Other	$40.0;
  INFORMAT Race				$40.0;
  INFORMAT Race_Other			$40.0;
  INFORMAT Insurance			$40.0;
  FORMAT REGNO 			 	  10.;
  FORMAT Acc 				 	  10.;
  FORMAT Elig					 $10.;
  FORMAT Enroll_Date		mmddyy10.;
  FORMAT Institution			$40.0;
  FORMAT Physician			$40.0;
  FORMAT Birth_Date			mmddyy10.;
  FORMAT Gender				$10.0;
  FORMAT Ethnicity			$40.0;
  FORMAT Ethnicity_Other		$40.0;
  FORMAT Race					$40.0;
  FORMAT Race_Other			$40.0;
  FORMAT Insurance			$40.0;
  INPUT regno acc elig $ enroll_date institution $ physician $ birth_date gender $ ethnicity $ ethnicity_other $ race $ race_other $ insurance $; 
  if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
RUN;

