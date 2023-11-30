* Define macros;
%LET job=SQLA1;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLA/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLA                                         
*                                                                    
*  Description:   First set of SQL problems using MIMIC datasets
*
*  Name:          Sara O'Brien
*
*  Date:          1/19/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLA1_saraob.sas   
*
*  Purpose:       Run basic queries on patients data set using proc sql
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set patients
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
ODS PDF FILE="&outdir/Output/SQLA/&job._&onyen..pdf" STYLE=JOURNAL;

* Create formats;
proc format;
	value $gender
		'M' = 'Male'
		'F' = 'Female';
run;

* Run proc sql step;
proc sql number;
	
	* a;
	title '1a. All rows and columns in patients data set';
	select *
		from mimic.patients;
		
	* b;
	title '1b. Subject ID, gender, DOB, and DOD for all patients';
	select subject_id, gender, dob, dod
		from mimic.patients;
		
	* c; 
	title '1c. Subject ID, gender (w/ format), DOB, and DOD for all patients';
	select subject_id, gender format=$gender., dob, dod
		from mimic.patients;
		
	* d;
	title '1d. Subject ID, gender (w/ format), DOB, DOD, and age at death for all patients';
	select subject_id, gender format=$gender., dob, dod, 
			int((DOD-DOB)/365.25) as AgeAtDeath label 'Age at death'
		from mimic.patients;
		
	* e;
	title '1e. Subject ID, gender (w/ format), DOB, DOD, and age at death for patients <120 years old at death';
	select subject_id, gender format=$gender., dob, dod, 
			int((DOD-DOB)/365.25) as AgeAtDeath label 'Age at death'
		from mimic.patients
		where CALCULATED AgeAtDeath<120;
		
	* f;
	title '1f. Subject ID, gender (w/ format), and age at death for male patients <120 years old at death';
	select subject_id, gender format=$gender., 
			int((DOD-DOB)/365.25) as AgeAtDeath label 'Age at death'
		from mimic.patients
		where CALCULATED AgeAtDeath<120 and gender='M';
	
	* g;
	title '1g. Ordered list of subject ID, gender (w/ format), and age at death for male patients <120 years old at death by descending age';
	select subject_id, gender format=$gender., 
			int((DOD-DOB)/365.25) as AgeAtDeath label 'Age at death'
		from mimic.patients
		where CALCULATED AgeAtDeath<120 and gender='M'
		order by AgeAtDeath desc;
	
	* h;
	create table HIGH_AGE as 
		select subject_id, gender format=$gender.,
			int((DOD-DOB)/365.25) as AgeAtDeath label 'Age at death'
		from mimic.patients
		where 80<= CALCULATED AgeAtDeath <120
		order by subject_id;
		
quit;

title '1h. Subject ID, gender (formatted), and age at death >=80 and <120 by subject ID';
proc print data=high_age label;
run;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;