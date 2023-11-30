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
*  Job name:      REFA2X_saraob.sas   
*
*  Purpose:       Produce a list of participants with specially-
*				  allowed medications at different visits using macros.	
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set omra_669 (could also list macros or 
*                 other external files that you are accessing)
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

* Define macros;
%LET job=REFA2X;
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

* Write a macro program containing code from REFA2;
%macro specialmeds(visit=, visitmeds=);

	data othermeds2;
		set mets.omra_669 (keep=BID OMRA1 &visitmeds);
		by BID;
		where &visitmeds = 'Y' and 
			(omra1 = 'CIMETIDINE' OR omra1='AMILORIDE' OR omra1='DIGOXIN' 
			OR omra1='MORPHINE' OR omra1='PROCAINAMIDE' OR omra1='QUINIDINE' 
			OR omra1='QUININE' OR omra1='RANITIDINE' OR omra1='TRIAMTERENE' 
			OR omra1='TRIMETHOPRIM' OR omra1='VANCOMYCIN' OR omra1='FUROSEMIDE' 
			OR omra1='NIFEDIPINE' OR omra1='INSULIN');
		drop &visitmeds;
	run;
	
	title "Participants with specially-allowed medications at visit &visit";
	proc print data = othermeds2 noobs label;
		label BID='Participant ID' OMRA1='Medication name';
	run;

%mend;

* Execute the macro for visits 2, 5, and 10;
%specialmeds(visit=2, visitmeds=omra5a);
%specialmeds(visit=5, visitmeds=omra5d);
%specialmeds(visit=10, visitmeds=omra5i);

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 
