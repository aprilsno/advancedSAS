* Define macros;
%LET job=ADSC2;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/ADSC/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    ADSC                                        
*                                                                    
*  Description:   Analysis data set and graphing exercise
*
*  Name:          Sara O'Brien
*
*  Date:          2/21/23                                       
*------------------------------------------------------------------- 
*  Job name:      ADSC2_saraob.sas   
*
*  Purpose:       Create graphs from analysis data set
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Analysis data set from ADSC1
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/ADSC/&job._&onyen..pdf" STYLE=JOURNAL;

* Library with permanent version of final analysis data set;
libname adsc "&outdir/Output/ADSC";

* Graph 1;
proc format;
	value $gender
		'M' = 'Males'
		'F' = 'Females';
	value visit
		1 = 'Baseline'
		2 = 'Follow-up Year 1'
		3 = '2'
		4 = '3'
		5 = '4'
		6 = '5';
run; 

proc sgpanel data=adsc.final;
	title 'Graph 1: BMI of Study Participants by Gender and Visit';
	panelby gender / novarname;
	format gender $gender. visit visit.; 
	vbox bmi / category = visit;
	colaxis display=(nolabel);
run;

* Graph 2;
proc sql;
	create table bmiavg as
	select *
	from adsc.final
	group by basegold, visit
	having count(bmi) > 3; * Graph looks same with or without this sql step;
quit;

proc means data = bmiavg mean noprint;
	title 'Summary statistics for bmi in final analysis data set';
	class basegold visit;
	var bmi; 
	output out=bmiavg(drop=_type_ _freq_) mean= / autoname;
run;

proc sgplot data=bmiavg ;
	title 'Graph 2: Mean BMI Over Time by Baseline GOLD Status';
	format visit visit.;
	series y=bmi_mean x=visit / nomissinggroup markers group = basegold;
	xaxis display=(nolabel);
	yaxis label='Mean BMI';
	keylegend  / title="Baseline GOLD Status"; 
	footnote 'Omitting GOLD groups with N < 3';
run;

ODS PDF CLOSE;
