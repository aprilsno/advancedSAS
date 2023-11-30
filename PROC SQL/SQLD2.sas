* Define macros;
%LET job=SQLD2;
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
*  Job name:      SQLD2_saraob.sas   
*
*  Purpose:       Run queries on maximum and avg length of stays
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set icustays
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

* Create format for care unit var;
proc format;
	value $careunit
		'CCU' = 'Coronary care unit' 
		'CSRU' = 'Cardiac surgery recovery unit' 
		'MICU' = 'Medical intensive care unit' 
		'NICU' = 'Neonatal intensive care unit' 
		'NWARD' = 'Neonatal ward' 
		'SICU' = 'Surgical intensive care unit' 
		'TSICU' = 'Trauma/surgical intensive care unit' ;
run;

* Run proc sql;
proc sql number;
	* 2a. What is the maximum length of stay (LOS) experienced for each patient in the data set?;
	title1 'Maximum length of stay';
	title2 'for each MIMIC patient';
	select a.subject_id, b.los label='Max length of stay'
	from mimic.patients as a
		left join 
		(select b.subject_id
		from mimic.icustays as b
		group by b.subject_id
		having b.los = max(b.los))
	on a.subject_id = b.subject_id
	order by b.los desc;
	
	* 2b. What was the maximum length of stay experienced by each of the care units?;
	title1 'Maximum length of stay';
	title2 'by care unit';
	select distinct first_careunit format=$careunit., max(los) as maxlos label='Max length of stay'
	from mimic.icustays
	group by first_careunit
	order by maxlos desc;
	
	* 2c. What was the average length of stay for each care unit?;
	title1 'Average length of stay';
	title2 'by care unit';
	select distinct first_careunit format=$careunit., mean(los) as avglos label='Avg length of stay'
	from mimic.icustays
	group by first_careunit
	order by avglos desc;
	
	* 2d. What was the overall average length of stay for all ICU stays?;
	title1 'Average length of stay';
	title2 'for all ICU stays';
	select mean(los) as avglos label='Avg length of stay'
	from mimic.icustays;
	
	* 2e. Which care units have an average length of stay that is greater than 
	the overall average length of stay for all ICU stays?;
	select distinct first_careunit format=$careunit., mean(los) as avglos label='Avg length of stay'
	from mimic.icustays
	group by first_careunit
	having avglos > 
		(select mean(los) as overallavglos
		from mimic.icustays) 
	order by avglos desc;

quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;