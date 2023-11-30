* Define macros;
%LET job=SQLA3;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLA/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLA                                         
*                                                                    
*  Description:   First set of SQL problems using MIMIC datasets
*
*  Name:          Sara O'Brien
*
*  Date:          1/19/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLA3_saraob.sas   
*
*  Purpose:       Produce a list of insurance types, a count of unique
*				  discharge locations, and a list of unique discharge 
*				  locations
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set admissions
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
ODS PDF FILE="&outdir/Output/SQLA/&job._&onyen..pdf" STYLE=JOURNAL;

* Create proc sql step;

proc sql;
	
	* a;
	title '3a. List of all insurance types';
	select distinct insurance
		from mimic.admissions
		order by insurance;
		
	* b;
	title '3b. Count of unique discharge locations';
	select count(distinct discharge_location)
		from mimic.admissions;
		
	* c;
	title '3c. List of unique discharge locations and count';
	select distinct discharge_location,
		count(discharge_location) as frequency
		from mimic.admissions
		group by discharge_location
		order by CALCULATED frequency desc;
		
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;