* Define macros;
%LET job=SQLF1;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLF/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLF                                         
*                                                                    
*  Description:   Sixth set of SQL problems using METS datasets (REFA
*				  and REFB with SQL)
*
*  Name:          Sara O'Brien
*
*  Date:          2/6/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLF1_saraob.sas   
*
*  Purpose:       Produce a list of participants with specially-
*				  allowed medications at baseline.	
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set omra
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/SQLF/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in METS data;
LIBNAME mets "~/my_shared_file_links/klh52250/METS" access=readonly;

* Run proc sql;
proc sql;
	title 'Participants with specially-allowed medications at visit 2';
	select BID, omra1
	from mets.omra_669
	where omra5a = 'Y' and
		scan(upcase(omra1),1) in ('INSULIN','FUROSEMIDE','NIFEDIPINE','CIMETIDINE',
		'AMILORIDE','DIGOXIN','MORPHINE','PROCAINAMIDE','QUINIDINE','QUININE',
		'RANITIDINE','TRIAMTERENE','TRIMETHOPRIM','VANCOMYCIN');                                          
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;