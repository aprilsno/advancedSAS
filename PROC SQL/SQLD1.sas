* Define macros;
%LET job=SQLD1;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLD/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLD                                         
*                                                                    
*  Description:   Fourth set of SQL problems using MIMIC datasets
*
*  Name:          Sara O'Brien
*
*  Date:          1/31/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLD1_saraob.sas   
*
*  Purpose:       Create a report of female patients in the MIMIC study
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data sets patients, admits
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
ODS PDF FILE="&outdir/Output/SQLD/&job._&onyen..pdf" STYLE=JOURNAL;

* Run proc sql;

proc sql number;
	title 'Female patients in the MIMIC study';
	select subject_id, datepart(admittime) format=mmddyy10. as admitdate label='Admission date', diagnosis
	from mimic.admissions 
	where subject_id in 
		(select subject_id
		from mimic.patients 
		where upcase(gender)='F');
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;