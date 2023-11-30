* Define macros;
%LET job=ADSB;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/ADSB/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    ADSB                                        
*                                                                    
*  Description:   Checking derived variables
*
*  Name:          Sara O'Brien
*
*  Date:          2/21/23                                       
*------------------------------------------------------------------- 
*  Job name:      ADSB_saraob.sas   
*
*  Purpose:       Checking derived variables in an analysis data set for a 
*				  paper looking at CHD and magnesium, Part II 
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         adsb data set
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/ADSB/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in dataset;
LIBNAME adsb "~/my_shared_file_links/klh52250/ADSB" access=readonly;

* 1. Check the derivation of EmpStatus (character);
proc freq data=adsb.adsb;
	title1 'Check EmpStatus'; 
	title2 'to check, ensure EmpStatus values match specs';
	tables hom55*EmpStatus / missing nocum nopercent list;
run;

* 2. Check DietMg_Group (numeric);
proc means data=adsb.adsb n nmiss mean std min max; 
	title1 'Check DietMg_Group'; 
	title2 'to check, ensure DietMg_Group min/max values match specs';
	class DietMg_Group / missing;  
	var DietMg;  
run; 

/* Given than the minimum for Group 1 is 31.27, but the minimum in
that group range is 0, we can also confirm that 31.27 is our overall min;
proc means data=adsb.adsb min;
	var DietMg;
run;

We don't need to output this, it is just an extra confirmation */

* 3. Check AdjGlucose (numeric);
data CheckAdjGlucose;
	set adsb.adsb;
	if ^missing(BloodDrawDate) and BloodDrawDate<='15JUL88'd then date=1; 
	else date=0;
	keep CHMX07 AdjGlucose date; 
run;

proc format;
	value blooddrawdate
		1 = 'Blood Draw Date on or before July 15, 1988 (AdjGlucose = CHMX07*0.963)'
		0 = 'Blood Draw Date after July 15, 1988';
		
proc means data=CheckAdjGlucose n nmiss mean std min max; 
	title1 'Check AdjGlucose'; 
	title2 'to check for date after 15JUL88, CHMX07=AdjGlucose';
	title3 'to check for date on/before 15JUL88, AdjGlucose/0.963=CHMX07';
	class date;
	format date blooddrawdate.; 
	var CHMX07 AdjGlucose;  
run; 

* 4. Check CHD (numeric);
proc freq data=adsb.adsb;
	title1 'Check CHD'; 
	title2 'to check, ensure CHD values match specs';
	tables CHD*PrevalentCHD*RoseIC*HOM10D / missing nocum nopercent list;
run;

* 5. Check Ethanol (numeric);
* It would be easiest to check ethanol in two parts:
	Part 1: Ethanol for all Drinker values ^=1
	Part 2: Ethanol for Drinker value = 1;
	
* Part 1;
data CheckEthanol;
	set adsb.adsb;
	where Drinker ^= 1;
run;

proc freq data=CheckEthanol;
	title1 'Check Ethanol (for non-current drinkers)';
	title2 'to check, ensure ethanol values match specs';
	tables Drinker*Ethanol / missing nocum nopercent list;
run;

* Part 2;
proc print data=adsb.adsb (obs=10);
	title1 'Check Ethanol (for current drinkers)';
	title2 'to check, refer to calculation in specs for ethanol';
	where Drinker=1;
	var DTIA96 DTIA97 DTIA98 Ethanol;
run;

* Since the first 10 obs don't have any missing, we could also confirm that the missing vals 
are derived as expected;

proc print data=adsb.adsb (obs=10);
	title1 'Check missing ethanol (for current drinkers)';
	title2 'to check, if any DTIA are missing, ethanol should be missing';
	where Drinker=1 and (missing(DTIA96) or missing(DTIA97) or missing(DTIA98));
	var DTIA96 DTIA97 DTIA98 Ethanol;
run;

* 6. Check LowBP (numeric);

* Create a categorical age variable;
data CheckLowBP;
	set adsb.adsb;
	if age <= 60 then agecat = 0;
	if age > 60 then agecat = 1;
run;

proc format;
	value agecat
		0 = '<=60 years'
		1 = '>60 years';
run;
	
proc means data=CheckLowBP max min mean std; 
	title1 'Check LowBP';
	title2 'to check, check missing and ensure DBP max values match max in specs';
	class gender agecat LowBP / missing;
	format agecat agecat.;
	var dbp;  
run;  

* Output PDF file;
ODS PDF CLOSE;