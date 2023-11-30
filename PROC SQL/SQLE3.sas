* Define macros;
%LET job=SQLE3;
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
*  Job name:      SQLE3_saraob.sas   
*
*  Purpose:       Write a macro that, when provided with an item ID, 
				  will list all patients who had an average recorded 
				  measurement of that type during their hospital stay 
				  that was above the overall average for that item ID.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set chartevents, admissions, d_items
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

* Create macro for report;
%macro avgmeasurement(itemid=);

	reset noprint;
	select mean(valuenum) into :overallavgvalue
	from mimic.chartevents
	where itemid=&itemid;
	
	select label into :itemlabel
	from mimic.d_items
	where itemid=&itemid;
	
	reset print;
	title1 "Patients with an average &itemlabel (item id &itemid)";
	title2 "above the overall average, &overallavgvalue";
	select a.subject_id, a.hadm_id, a.diagnosis, 
		mean(b.valuenum) as avgvalue label='Avg measurement'
	from mimic.admissions as a, 
		mimic.chartevents as b
	where itemid=&itemid and a.subject_id = b.subject_id and a.hadm_id = b.hadm_id
	group by a.subject_id, a.hadm_id, a.diagnosis
	having avgvalue > &overallavgvalue
	order by subject_id, hadm_id;
	
%mend;

* Call on macro;
%avgmeasurement(itemid=220045);
%avgmeasurement(itemid=220179);
	
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;
