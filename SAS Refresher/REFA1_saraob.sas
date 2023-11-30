*********************************************************************
*  Assignment:    REFA                                         
*                                                                    
*  Description:   First collection of SAS refresher problems using 
*                 METS study data
*
*  Name:          Sara O'Brien
*
*  Date:          1/11/23                                       
*------------------------------------------------------------------- 
*  Job name:      REFA1_saraob.sas   
*
*  Purpose:       Produce a display for evaluating whether treatment
*                 groups are fairly balanced across the METS sites.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set dr_669 
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

* Define macros;
%LET job=REFA1;
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

* Format treatment variable to define values;
proc format;
   value $trt 'A' = 'Metformin'
              'B' = 'Placebo';
run;

* Run a simple proc report to show number in each trt group at each site;
title1 'Number of participants in each treatment group across clinical sites';
proc report data=mets.dr_669;
	column psite trt ;
	format trt $trt.;
	define trt / 'Treatment Group' across;
	define psite / 'Clinical Site' group;
run;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 
