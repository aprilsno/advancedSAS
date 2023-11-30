*********************************************************************
*  Assignment:    REFB                                         
*                                                                    
*  Description:   Second collection of SAS refresher problems using 
*                 METS study data
*
*  Name:          Sara O'Brien
*
*  Date:          1/16/23                                       
*------------------------------------------------------------------- 
*  Job name:      REFB1_saraob.sas   
*
*  Purpose:       Produce a report showing the joint age and gender 
*				  breakdown of participants in the METS study.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set dema_669 
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

* Define macros;
%LET job=REFB1;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/&job._&onyen..log" new; 
run; 

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Pull in METS data;
LIBNAME mets "~/my_shared_file_links/klh52250/METS" access=readonly;

* Create PDF output file;
ODS PDF FILE="&outdir/Output/&job._&onyen..pdf" STYLE=JOURNAL;

* Create age groups;
proc format;
    value agegroup 
    	10 - 19  =  '10-19'
        20  - 29  =  '20-29'
        30 - 39  =  '30-39'
        40 - 49  =  '40-49'
        50 - 59  =  '50-59'
        60 - 69 =  '60-69';
   	value $sex
   		'F' = 'Female'
   		'M' = 'Male';
run;

* Run a proc report to get counts of participants by sex and age;
title1 'Age and gender breakdown of participants in the METS study';
options missing="0";
proc report data = mets.dema_669 ;
	column  dema1 dema2;
	format dema1 agegroup. dema2 $sex.;
	define dema1 / 'Age' group;
	define dema2 / 'Sex' across ;	
run;

/* Could alternatively use proc freq to get same results;
proc freq data = mets.dema_669;
	table dema1*dema2 / nopercent nocum norow nocol;
	format dema1 agegroup. dema2 $sex.;
run; */

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 
