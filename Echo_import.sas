/* ********************************* */
/* Echo Import		                 */ 
/* ********************************* */

LIBNAME echo "T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data\Echos\On_Study";

OPTIONS VALIDVARNAME = ANY ;
PROC IMPORT 
	DATAFILE = "T:\Aplenc_New\Phenotype\AAML_0531\COG_Data\Echos\20140218_Echos_Manual_Entry_A0531.txt" 
	OUT = echo.import_echo_ekg DBMS = DLM REPLACE ; 
	GUESSINGROWS = 32767 ; 
	DELIMITER = '09'x ;
	GETNAMES = YES ;
	DATAROW = 2 ;
RUN;

