* Define macros;
%LET job=SQLD3;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLD/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLD                                         
*                                                                    
*  Description:   Fourth set of SQL problems using MIMIC datasets
*
*  Name:          Sara O'Brien
*
*  Date:          1/31/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLD3_saraob.sas   
*
*  Purpose:       Create a report of patients who stayed in >1 type 
*				  of care unit
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set icustays
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Pull in MIMIC data;
LIBNAME mimic "~/my_shared_file_links/klh52250/MIMIC" access=readonly;

* Create PDF output file;
ODS PDF FILE="&outdir/Output/SQLD/&job._&onyen..pdf" STYLE=JOURNAL;

* Format for care units;
proc format;
	value $careunit
		'CCU' = 'Coronary care unit' 
		'CSRU' = 'Cardiac surgery recovery unit' 
		'MICU' = 'Medical intensive care unit' 
		'NICU' = 'Neonatal intensive care unit' 
		'NWARD' = 'Neonatal ward' 
		'SICU' = 'Surgical intensive care unit' 
		'TSICU' = 'Trauma/surgical intensive care unit' ;
run;

* Run proc sql;

proc sql number;

	title 'Patients who stayed in >1 type of care unit';	
	select distinct(subject_id), first_careunit format=$careunit. label='Different care units'
	from mimic.icustays
	group by subject_id
	having count(distinct first_careunit)>1;
	
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;