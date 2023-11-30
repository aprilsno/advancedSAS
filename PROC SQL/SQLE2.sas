* Define macros;
%LET job=SQLE2;
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
*  Job name:      SQLE2_saraob.sas   
*
*  Purpose:       Replicate results of SQLD2e using macros
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
ODS PDF FILE="&outdir/Output/SQLE/&job._&onyen..pdf" STYLE=JOURNAL;

proc sql;

	* Overall average length of stay for all ICU stays;
	reset noprint;
	select mean(los) into :overallavg
	from mimic.icustays;
	
	* Care units w/ avg los>overall avg;
	reset print;
	title1 "Care units with an average length of stay";
	title2 "greater than &overallavg days";
	select distinct first_careunit format=$careunit., mean(los) as avglos label='Avg length of stay'
	from mimic.icustays
	group by first_careunit
	having avglos > &overallavg
	order by avglos desc;
	
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;
