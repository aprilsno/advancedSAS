* Define macros;
%LET job=SQLB2;
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
*  Job name:      SQLB2_saraob.sas   
*
*  Purpose:       Produce a report of ICU stays per care unit
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
ODS PDF FILE="&outdir/Output/SQLB/&job._&onyen..pdf" STYLE=JOURNAL;

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

* Run proc sql for 2a-2c;
proc sql;
	title '2a. Number of ICU stays per care unit';
	select first_careunit format=$careunit. label='Care unit', count(subject_id) as NumICUStays 
		label='Number of ICU stays'
	from mimic.icustays
	group by first_careunit
	order by NumICUStays desc;
	
	title '2b. Number of subjects per care unit';
	select first_careunit format=$careunit. label='Care unit', count(distinct subject_id) as NumSub
		label='Number of Subjects'
	from mimic.icustays
	group by first_careunit
	order by NumSub desc;
	
	create table AvgLOSpCU as
	select first_careunit format=$careunit. label='Care unit', count(subject_id) as NumICUStays 
		label='Number of ICU stays', mean(LOS) as AvgLOS label='Average length of stay (days)' format=4.2
	from mimic.icustays
	group by first_careunit
	order by NumICUStays desc;
quit;

* Print 2c dataset;
proc print data=AvgLOSpCU label noobs;
	title '2c. Number of ICU stays and mean length of stay per care unit';
run;

* Use proc means and proc print to create same dataset as in 2c;
proc means data=mimic.icustays nway mean noprint;
	class first_careunit;
	var los;
	format first_careunit $careunit.;
	output out=AvgLOSpCU2 n=NumICUStays mean=AvgLOS;
run;

* Print 2d data set;
proc print data=AvgLOSpCU2 label noobs;
	title '2d. Number of ICU stays and average length of stay per care unit';
	var first_careunit NumICUStays AvgLOS;
	format AvgLOS 4.2;
	label first_careunit='Care unit' AvgLOS='Average length of stay (days)' NumICUStays='Number of ICU stays';
run;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;