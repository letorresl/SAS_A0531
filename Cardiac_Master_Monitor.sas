/* ********************************* */
/* Cardiac Monitoring                */ 
/* ********************************* */

LIBNAME ltfu 	"T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Echos\LTFU" 	 ;
LIBNAME cardiac	"T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Cardiac_Master" ;

/* ********************************* */
/* Take Out All Echo's on Therapy    */ 
/* ********************************* */

DATA cardiac.monitor_missings (keep = regno period course lvsd_tfu echo_muga_done);
	RETAIN regno period course echo_muga_done ;
	SET cardiac.lvsd_course ;
	WHERE echo_muga_done = "1" ;
	IF period > = 6 THEN DELETE ;
	IF period = 1 THEN course = "Ind I" 	;
	IF period = 2 THEN course = "Ind II"	;
	IF period = 3 THEN course = "Int I" 	;
	IF period = 4 THEN course = "Int II" 	;
	IF period = 5 THEN course = "Int III" 	;
	IF echo_manual = 1 THEN DELETE ;
RUN ;

PROC EXPORT DATA = cardiac.monitor_missings  
	OUTFILE = "T:\Aplenc_New\Phenotype\AAML_0531\Summary\Missing_Echo_Reports_On_Therapy.xls"
	DBMS = EXCEL REPLACE;
RUN;

