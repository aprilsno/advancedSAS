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
*  Job name:      REFA3_saraob.sas   
*
*  Purpose:       Produce a list of participants with less than 3 or
*                 more than 14 days between screening and randomization.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set dr_669, ieca_669, rdma_669
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

* Define macros;
%LET job=REFA3;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file to write to;
proc printto log="&outdir/Logs/&job._&onyen..log" new; 
run; 

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Pull in METS data;
LIBNAME mets "~/my_shared_file_links/klh52250/METS" access=readonly;

* Create PDF output file;
ODS PDF FILE="&outdir/Output/&job._&onyen..pdf" STYLE=JOURNAL;

* Create a merged data set to filter by the number of days between screening and randomization;
data daysbetween;
	merge mets.dr_669 mets.ieca_669 mets.rdma_669;
	by BID;
	days = intck('day', ieca0b, rdma0b);
	if days < 3 or days > 14;
	keep BID psite ieca0b rdma0b days;
run;

* Print daysbetween dataset;
title1 'Participants with <3 or >14 days between screening and randomization date';
proc print data = daysbetween noobs label;
	label BID='Participant ID' psite='Clinical site' ieca0b='Screening date' 
	rdma0b='Randomization date' days='Days between screening and randomization';
	format ieca0b rdma0b mmddyy10.;
run;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 
