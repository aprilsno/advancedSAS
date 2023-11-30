* Define macros;
%LET job=RPTC;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/RPTC/&job._&onyen..log" new; 
run;

*********************************************************************
*  Assignment:    RPTC                                        
*                                                                    
*  Description:   PROC Report Assignment C   
*
*  Name:          Sara O'Brien
*
*  Date:          3/30/23                                       
*------------------------------------------------------------------- 
*  Job name:      RPTC_sas_saraob.sas   
*
*  Purpose:       Use a provided macro to produce a comparative METS report
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS
*
*  Output:        pdf file    
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Macro being used;
%include "/home/u49497589/my_shared_file_links/klh52250/macros/Compare_baseline_669.sas";

* Pull in rptc dataset;
libname rptc '/home/u49497589/my_shared_file_links/klh52250/RPTC';

* Call the macro;
%Compare_baseline_669(	_DATA_IN=rptc.rptc, 
						_DATA_OUT=comparerptc,
						_GROUP=trt, 
						_PREDICTORS=Race1 Gender BMI Cholesterol Age HeartRate, 
						_CATEGORICAL=Race1 Gender, 
						_COUNTABLE=Age HeartRate, 
						_ID=BID);
								
* Coding hard blanks;
ods escapechar='#';
* #{nbspace 6};

/*
proc format;
 value pvalue2_best 
 	0-<0.001='<0.001' 
 	0.001-<0.005=[5.3]
	0.005-<0.045= [5.2] 
	0.045-<0.055=[5.3] 
	other=[5.2];
run; */


data display;
	set comparerptc;
	length characteristic $200;
	if variable=" " and label=" " then do;
		characteristic="Baseline Characteristics";
 		order=1; 
 		end;
 	if variable="RACE1" and label=" " then do;
		characteristic="#{nbspace 6}Race";
 		order=2; 
 		end;
 	if variable="RACE1" and label="- Black" then do;
		characteristic="#{nbspace 6}#{nbspace 6}Black";
 		order=3; 
 		end;
 	if variable="RACE1" and label="- White" then do;
		characteristic="#{nbspace 6}#{nbspace 6}White";
 		order=4; 
 		end;
 	if variable="RACE1" and label="- Other" then do;
		characteristic="#{nbspace 6}#{nbspace 6}Other";
 		order=5; 
 		end;
 	if variable="GENDER" and label="Sex" then do;
		characteristic="#{nbspace 6}Sex";
 		order=6; 
 		end;
 	if variable="GENDER" and label="- F" then do;
		characteristic="#{nbspace 6}#{nbspace 6}Female";
 		order=7; 
 		end;
 	if variable="GENDER" and label="- M" then do;
		characteristic="#{nbspace 6}#{nbspace 6}Male";
 		order=8; 
 		end;
 	if variable="BMI" and label="Computed BMI (wt/ht2)" then do;
		characteristic="#{nbspace 6}Computed BMI (wt/ht2)";
 		order=9; 
 		end;
 	if variable="CHOLESTEROL" and label="Cholesterol(mg/dL)" then do;
		characteristic="#{nbspace 6}Cholesterol(mg/dL)";
 		order=10; 
 		end;
 	if variable="AGE" and label="Age" then do;
		characteristic="#{nbspace 6}Age";
 		order=11; 
 		end;
 	if variable="HEARTRATE" and label="Heart Rate (beats/min)" then do;
		characteristic="#{nbspace 6}Heart Rate (beats/min)";
 		order=12; 
 		end;
 	if order in (9,10,11,12) then do;
 		column_2 = compress(column_2,"{}");
 		column_1 = compress(column_1,"{}");
 		column_overall = compress(column_overall,"{}");	
 	end;
 	if order in (3,4,5,7,8) then do;
 		pvalue = '';
 	end;
	if missing (order) then delete;
run;

* Get counts for row headers;
data rptc;
	set rptc.rptc ;
	output;
	trt = 'C';
	output;
run;

proc freq data = rptc;
	tables trt / out=trtcnt;
run; 

data _NULL_;
	set trtcnt;
	IF trt='A' THEN CALL SYMPUT('a',PUT(count,2.));
	IF trt='B' THEN CALL SYMPUT('b',PUT(count,2.));
	IF trt='C' THEN CALL SYMPUT('c',PUT(count,3.));
run;
%PUT a=&a b=&b c=&c;

ODS RTF FILE="&outdir/Output/RPTC/customised_table.RTF" style=journal bodytitle;
ods listing; title; footnote; ods listing close;

footnote1 "Note: Values expressed as N(%), mean ± standard deviation or median (25th, 75th percentiles)" justify=L;
footnote2 "P-value comparisons across treatment groups for categorical variables are based on chi-square test of homogeneity";
footnote3 "P-values for continuous variables are based on ANOVA or Kruskal-Wallis test for median" ; 
* Create final report;
proc report data=display nowd style=[cellpadding=6 font_size=8.5 pt rules=none];
	title1 'Comparison of Baseline Characteristics by Treatment Group';
	title2 "Created using Polina Kukhareva's SAS macro";
	column order characteristic('Treatment Group' column_overall column_2 column_1 pvalue);
	define order / order noprint;
	define characteristic / display " " style=[asis=on just=left cellwidth=9.0 cm font_weight=bold font_size=8.5 pt];
	define column_2 / display "Treatment A/(N=&a)" center;
	define column_1 / display "Treatment B/(N=&b)" center;
	define column_overall / display "Overall/(N=&c)" center;
	define pvalue / display "p-value" format=5.2 style(column)=[just=right cellwidth=2 cm vjust=bottom font_size=8.5 pt] style(header)=[just=right cellwidth=2 cm font_size=8.5 pt] ;
run; 

ods rtf close; ods listing;