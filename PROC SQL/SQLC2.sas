* Define macros;
%LET job=SQLC2;
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
*  Job name:      SQLC2_saraob.sas   
*
*  Purpose:       Create a schedule data set
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data sets patients, caregivers, admissions,
*				  chartevents, d_item
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

* Run proc sql to create caregiversched data set;
proc sql number;
	create table caregiversched as
		select b.subject_id, c.admission_type, d.gender, a.cgid, a.label, e.label as task, b.charttime 
		from mimic.caregivers as A,
			mimic.chartevents as B,
			mimic.admissions as C,
			mimic.patients as D,
			mimic.d_items as E
		where a.cgid=b.cgid and b.itemid=e.itemid and b.subject_id=c.subject_id=d.subject_id 
			and b.hadm_id=c.hadm_id
			and datepart(b.charttime) = '06Feb2107'd and a.label='RN'
		order by b.charttime, a.cgid, task;
quit;

* Print first 10 obs of caregiversched;
proc print data=caregiversched (obs=10) label;
	title1 'Caregiver schedule data set (10 obs)';
	title2 'Charting done on February 6th, 2107 (SQL version)';
	label task='Caregiver task' label='Caregiver type' 
		charttime='Time at which observation was made';
run;

* 2b. Replicate the caregiver schedule dataset without proc sql;

* Sort chartevents, patients, admissions by subject id for merge;
proc sort data=mimic.chartevents(keep=charttime hadm_id subject_id itemid cgid) out=chartevents;
	by subject_id hadm_id;
run;

proc sort data=mimic.patients(keep=subject_id gender) out=patients;
	by subject_id;
run;

proc sort data=mimic.admissions(keep=subject_id hadm_id admission_type) out=admissions;
	by subject_id hadm_id;
run;

* Merge chartevents, patients, admissions;
data caregiversched2;
	merge chartevents(in=a) admissions(in=b);
	by subject_id hadm_id;
	if a and b and datepart(charttime) = '06Feb2107'd;
run;

data caregiversched2;
	merge caregiversched2(in=a) patients(in=b);
	by subject_id;
	if a and b;
run;

* Sort caregiversched2 and d_items by itemid;
proc sort data=caregiversched2;
	by itemid;
run;

proc sort data=mimic.d_items out=d_items;
	by itemid;
run;

* Merge caregiversched2 and d_items;
data caregiversched2;
	merge caregiversched2(in=a) d_items (in=b keep=itemid label rename=(label=task));
	by itemid;
	if a and b;
run;

* Sort caregiversched2 and caregivers by cgid;
proc sort data=caregiversched2;
	by cgid;
run;

proc sort data=mimic.caregivers out=caregivers;
	by cgid;
run;

* Merge caregiversched2 and caregivers, restrict by date and RN, and drop other vars brought in to merge;
data caregiversched2;
	merge caregiversched2(in=a) caregivers (in=b keep=cgid label);
	by cgid;
	if a and b and label='RN';
	drop itemid hadm_id;
run;

* Sort caregiversched2 by vars of interest;
proc sort data=caregiversched2;
	by charttime cgid task;
run;

* Print first ten obs of caregiversched2;
proc print data=caregiversched2 (obs=10) label;
	title1 'Caregiver schedule data set (10 obs)';
	title2 'Charting done on February 6th, 2107 (SAS version)';
	label task='Caregiver task' label='Caregiver type' 
		charttime='Time at which observation was made';
run;

*2c. Compare the sas and sql datasets using proc compare;
proc compare base=caregiversched compare=caregiversched2 listall;
	title 'Comparison of caregiver schedule datasets made in SQL and SAS';
run;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;