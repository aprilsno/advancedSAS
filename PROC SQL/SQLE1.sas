* Define macros;
%LET job=SQLE1;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLE/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLE                                         
*                                                                    
*  Description:   Fifth set of SQL problems using MIMIC datasets
*
*  Name:          Sara O'Brien
*
*  Date:          2/1/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLE1_saraob.sas   
*
*  Purpose:       Use macro to put care unit names to log
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

* Create PDF output file;
* ODS PDF FILE="&outdir/Output/SQLE/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in MIMIC data;
LIBNAME mimic "~/my_shared_file_links/klh52250/MIMIC" access=readonly;

* Run proc sql;
proc sql noprint;

	select distinct first_careunit into :careunits separated by ' '
	from mimic.icustays;
	
	%put unitnames=&careunits;
	
quit;

* Close pdf file;
* ODS PDF CLOSE;

* Close log file;
proc printto; 
run;
