* Define macros;
%LET job=SQLB1;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLB/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLB                                         
*                                                                    
*  Description:   Second set of SQL problems using MIMIC datasets
*
*  Name:          Sara O'Brien
*
*  Date:          1/24/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLB1_saraob.sas   
*
*  Purpose:       Produce a report with number of ICU stays per ppt
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
ODS PDF FILE="&outdir/Output/SQLB/&job._&onyen..pdf" STYLE=JOURNAL;

* Run proc sql;
proc sql;
	title '1a. Number of ICU stays and total number of days spent in ICU per subject';
	select subject_id, count(distinct icustay_id) as NumICUStays label='Number of ICU stays',
		sum(LOS) as TotalICUDays label='Total number of days in ICU'
	from mimic.icustays
	group by subject_id
	order by NumICUStays desc;
	
	title1 '1b. Number of ICU stays and total number of days spent in ICU per subject';
	title2 'for subjects with >2 stays or >20 total days';
	select subject_id, count(distinct icustay_id) as NumICUStays label='Number of ICU stays',
		sum(LOS) as TotalICUDays label='Total number of days in ICU'
	from mimic.icustays
	group by subject_id
	having NumICUStays>2 or TotalICUDays>20
	order by NumICUStays desc;

quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;