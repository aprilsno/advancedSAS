* Define macros;
%LET job=SQLE4;
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
*  Job name:      SQLE4_saraob.sas   
*
*  Purpose:       Create a report of patients admitted to the hospital 
*			   	  in the same month or two consecutive months
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
ODS PDF FILE="&outdir/Output/SQLE/&job._&onyen..pdf" STYLE=JOURNAL;

* Run proc sql;
proc sql number;

	title1 'Patients admitted to the hospital in the same month';
	title2 'or two consecutive months';
	select a.subject_id, 
		year(datepart(a.admittime)) as year label='Year',
		datepart(a.admittime) as month1 format=monname10. label='First month',
		a.diagnosis as diagnosis1 label='First diagnosis',
		datepart(b.admittime) as month2 format=monname10. label='Second month', 
		b.diagnosis as diagnosis2 label='Second diagnosis'
	from mimic.admissions as a,
		mimic.admissions as b
	where a.subject_id = b.subject_id and
		a.admittime < b.admittime and
		year(datepart(a.admittime)) = year(datepart(b.admittime)) and
		(month(datepart(a.admittime)) = month(datepart(b.admittime)) or
		month(datepart(b.admittime)) - month(datepart(a.admittime)) = 1)
	order by year, month1, subject_id;
	
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;
