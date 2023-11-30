* Define macros;
%LET job=SQLC1;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLC/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLC                                         
*                                                                    
*  Description:   Third set of SQL problems using MIMIC datasets
*
*  Name:          Sara O'Brien
*
*  Date:          1/26/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLC1_saraob.sas   
*
*  Purpose:       Produce a report of subjects who were admitted in
*				  the same month as their birthday
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data sets patients, admissions
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
ODS PDF FILE="&outdir/Output/SQLC/&job._&onyen..pdf" STYLE=JOURNAL;

* Run proc sql;

proc sql number;	
	title 'MIMIC subjects admitted in their birth month';
	select a.subject_id, datepart(a.admittime) as month label='Month' format=monname.
	from mimic.admissions as A,
		mimic.patients as B
	where a.subject_id=b.subject_id and put(datepart(a.admittime),monname.)=put(b.dob,monname.);
	
	/* Alternative code with month number instead of month name:
	select a.subject_id, month(datepart(a.admittime)) as month label='Month' 
	from mimic.admissions as A,
		mimic.patients as B
	where a.subject_id=b.subject_id and CALCULATED month=month(b.dob)
	order by subject_id; */
	
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;