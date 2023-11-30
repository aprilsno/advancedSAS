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
*  Job name:      REFA2_saraob.sas   
*
*  Purpose:       Produce a list of participants with specially-
*				  allowed medications at baseline.				
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set omra_669 
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

* Define macros;
%LET job=REFA2;
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

* Create a temp data set of participants taking other medication at baseline;
data othermeds;
	set mets.omra_669 (keep=BID OMRA1 OMRA5a);
	by BID;
	where omra5a = 'Y' and 
		(omra1 = 'CIMETIDINE' OR omra1='AMILORIDE' OR omra1='DIGOXIN' 
		OR omra1='MORPHINE' OR omra1='PROCAINAMIDE' OR omra1='QUINIDINE' 
		OR omra1='QUININE'OR omra1='RANITIDINE' OR omra1='TRIAMTERENE' 
		OR omra1='TRIMETHOPRIM' OR omra1='VANCOMYCIN' OR omra1='FUROSEMIDE' 
		OR omra1='NIFEDIPINE' OR omra1='INSULIN');
	drop omra5a;
run;

* Print othermeds dataset;
title1 'Participants with specially-allowed medications at baseline';
proc print data = othermeds noobs label;
	label BID='Participant ID' OMRA1='Medication name';
run;
	
* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 
