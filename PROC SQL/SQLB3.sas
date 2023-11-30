* Define macros;
%LET job=SQLB3;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLB/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLB                                         
*                                                                    
*  Description:   Second set of SQL problems using MIMIC datasets
*
*  Name:          Sara O'Brien
*
*  Date:          1/24/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLB3_saraob.sas   
*
*  Purpose:       Produce a report with abnormal vital signs
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set chartevents
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
ODS PDF FILE="&outdir/Output/SQLB/&job._&onyen..pdf" STYLE=JOURNAL;

* Run proc sql;
proc sql number;
	title1 'Abnormal vital signs';
	
	title2 '3a. Unreasonable heart rate values (outside of 45-150 (bpm) range)';
	select subject_id, charttime label='Time of measurement', valuenum label='Heart rate (bpm)',
		case
			when valuenum<45 then 'Unreasonably low'
			when valuenum>150 then 'Unreasonably high' 
			else ''
			end as unreashr label='Issue'
	from mimic.chartevents
	where itemid=220045 and ^missing(valuenum) and ^missing(CALCULATED unreashr)
	order by subject_id, charttime;
	
	title2 '3b. Unreasonable SBP values (outside of 80-180 (mmHg) range)';
	select subject_id, charttime label='Time of measurement', valuenum label='SBP (mmHg)',
		case
			when valuenum<80 then 'Unreasonably low'
			when valuenum>180 then 'Unreasonably high' 
			else ''
			end as unreassbp label='Issue'
	from mimic.chartevents
	where itemid=220179 and ^missing(valuenum) and ^missing(CALCULATED unreassbp)
	order by subject_id, charttime;
	
	title2 '3c. Unreasonable DBP values (outside of 40-110 (mmHg) range)';
	select subject_id, charttime label='Time of measurement', valuenum label='DBP (mmHg)',
		case
			when valuenum<40 then 'Unreasonably low'
			when valuenum>110 then 'Unreasonably high' 
			else ''
			end as unreasdbp label='Issue'
	from mimic.chartevents
	where itemid=220180 and ^missing(valuenum) and ^missing(CALCULATED unreasdbp)
	order by subject_id, charttime;
	
quit;

* Macro version of Q3;
%macro vitals(vital=, range=, unit=, min=, max=, itemid=);
	
	proc sql number;
	title1 'Abnormal vital signs (created using macros)';
	
	title2 "Unreasonable &vital values (outside of &range (&unit) range)";
	select subject_id, charttime label='Time of measurement', valuenum label="&vital (&unit)",
		case
			when valuenum<&min then 'Unreasonably low'
			when valuenum>&max then 'Unreasonably high' 
			else ''
			end as unreas label='Issue'
	from mimic.chartevents
	where itemid=&itemid and ^missing(valuenum) and ^missing(CALCULATED unreas)
	order by subject_id, charttime;
	
quit;

%mend;

%vitals(vital=Heart rate, range=45-150, unit=bpm, min=45, max=150, itemid=220045);
%vitals(vital=SBP, range=80-180, unit=mmHg, min=80, max=180, itemid=220179);
%vitals(vital=DBP, range=40-110, unit=mmHg, min=40, max=110, itemid=220180);

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;