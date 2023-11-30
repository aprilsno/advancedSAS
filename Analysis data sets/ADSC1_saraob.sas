* Define macros;
%LET job=ADSC1;
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
*  Job name:      ADSC1_saraob.sas   
*
*  Purpose:       Create an analysis data set 
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Resp data set
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/ADSC/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in dataset;
LIBNAME resp "~/my_shared_file_links/klh52250/Resp" access=readonly;

* Select participants whose final cdf record has a cdfa2 value of F, P, or D;
proc sort data = resp.cdf2018 out = cdf_sort;
	by fakeid visit fseqno;
run;

data cdf_criteria;
	set cdf_sort;
	by fakeid;
	if last.fakeid then do;
		if cdfa2 in ('F', 'P', 'D') then output;
	end;
run;

* Select participants in dem who meet the criteria above;
proc sql;
	create table dem_criteria as
	select *
	from resp.dem2018
	where fakeid in
		(select fakeid
		from cdf_criteria);
quit;

* Hard code changes to data in dem and fup;
data dem_criteria;
	set dem_criteria;
	if fakeid = '1575' then DEMA6b = 'K';
	if fakeid = '0524' then DEMA6b = 'P';
	if fakeid = '0260' then DEMA6d = 'I';
	if fakeid = '0804' then DEMA6d = 'C';
run;

proc sort data = resp.fup2018 out = fup_sort; by fakeid visit fseqno; run;
data fup_sort;
	set fup_sort;
	if fakeid = '0467' and visit = 2 then fupa3b = 'P';
	if fakeid = '0648' and visit = 3 then fupa3b = 'K';
	if fakeid = '0799' and visit = 2 then fupa3b = 'P';
	if fakeid = '1194' and visit = 6 then fupa3b = 'P';
	if fakeid = '1742' and visit = 2 then fupa3b = 'K';
	if fakeid = '1779' and visit = 2 then fupa3b = 'P';
run;

* Create analysis data set;
proc sort data = resp.cln2018 out = cln_sort; by fakeid visit fseqno; run;

data analysis;
	merge dem_criteria (keep=fakeid visit dema2 dema6a dema6b dema6c dema6d) 
		fup_sort (keep=fakeid visit fupa3a fupa3b fupa4e fupa4d fupa4e1)
		cln_sort (keep=fakeid visit clnb1e clnb1d clnb1e1);
	by fakeid visit;
		
	length basegold gold $25;
	format weight height bmi 6.2;
	
	* Define gender;
	retain gender;
	if first.fakeid then gender='';
	if first.fakeid then gender=dema2;
	
	* Define height;
	retain height;
	if first.fakeid then height=.;
	if first.fakeid then do;
		if DEMA6d = 'C' then height = DEMA6c*0.01;
		else if DEMA6d = 'I' then height = DEMA6c*0.0254;
		else height = .;
	end;
	
	* Define weight and calculate bmi;
	if visit = 1 then do;
		if DEMA6b = 'K' then weight = DEMA6a;
		else if DEMA6b = 'P' then weight = DEMA6a*0.45359237;
		else weight = .;
		bmi = (weight/(height**2));
	end;
	
	else if visit >1 then do;
		if first.fakeid then weight = .;
		if FUPA3b = 'K' then weight = FUPA3a;
		else if FUPA3b = 'P' then weight = FUPA3a*0.45359237;
		else weight = .;
		bmi = (weight/(height**2));
	end;
	
	* Define basegold;
	postbroncratio = CLNB1E/CLNB1D;
	postbroncpercent = CLNB1E1;
	
	retain basegold;
	if first.fakeid then basegold = '';
	if first.fakeid then do;
		if (CLNB1E/CLNB1D) < 0.7 and (not missing(CLNB1E/CLNB1D)) and (CLNB1E1 >= 80) then basegold = 'Stage I, Mild';
		else if (CLNB1E/CLNB1D) < 0.7 and (not missing(CLNB1E/CLNB1D)) and (50 <= CLNB1E1 < 80) then basegold = 'Stage II, Moderate';
		else if (CLNB1E/CLNB1D) < 0.7 and (not missing(CLNB1E/CLNB1D)) and (30 <= CLNB1E1 < 50) then basegold = 'Stage III, Severe';
		else if (CLNB1E/CLNB1D) < 0.7 and (not missing(CLNB1E/CLNB1D)) and (CLNB1E1 < 30) and (not missing(CLNB1E1)) then basegold = 'Stage IV, Very Severe';
		else basegold = 'At Risk';
	end;
	
	* Define gold;
	if visit = 1 then gold = basegold;
	else if visit > 1 then do;
		postbroncratio = FUPA4e/FUPA4d;
		postbroncpercent = FUPA4e1;
		if (FUPA4e/FUPA4d < 0.7) and (not missing(FUPA4e/FUPA4d)) and (FUPA4e1 >= 80) then gold = 'Stage I, Mild';
		else if (FUPA4e/FUPA4d < 0.7) and (not missing(FUPA4e/FUPA4d)) and (50 <= FUPA4e1 < 80) then gold = 'Stage II, Moderate';
		else if (FUPA4e/FUPA4d < 0.7) and (not missing(FUPA4e/FUPA4d)) and (30 <= FUPA4e1 < 50) then gold = 'Stage III, Severe';
		else if (FUPA4e/FUPA4d < 0.7) and (not missing(FUPA4e/FUPA4d)) and (FUPA4e1 < 30) and (not missing(FUPA4e1)) then gold = 'Stage IV, Very Severe';
		else gold = 'At Risk';
	end;
run;

* Select from analysis only those with records in the dem dataset meeting consent criteria;
libname adsc "&outdir/Output/ADSC";

* Main data set to be used with only relevant vars;
proc sql;
	create table adsc.final as
	select fakeid, visit, weight label='Weight (kg)', height label='Height (m)', bmi, baseGOLD, gold, gender
	from analysis
	where fakeid in
		(select fakeid
		from dem_criteria);
quit;

* Alternate final data set with all vars from analysis;
proc sql;
	create table final as
	select *
	from analysis
	where fakeid in
		(select fakeid
		from dem_criteria);
quit;

data adsc.ADSC_dataset_saraob;
	set adsc.final;
run;

* Output for checking dataset;
proc contents data = adsc.final;
	title 'PROC contents of final analysis data set';
run;

proc print data = adsc.final (obs=10) label;
	title 'First 10 obs of final analysis data set';
run;

proc print data = final (obs=20);
	title 'First 20 obs of bmi and relevant vars';
	var fakeid visit dema6c dema6d height dema6a dema6b fupa3a fupa3b weight bmi;
run;

proc means data = final;
	class gold;
	var postbroncratio postbroncpercent;
run;

proc freq data = adsc.final;
	title 'Frequency tables for gender, visit, baseGOLD, and GOLD';
	table gender visit basegold gold / missing;
run;

proc freq data = adsc.final;
	title 'Cross-tabulation of visit and GOLD variables in final analysis dataset';
	table visit*gold / list missing;
run;

proc means data = adsc.final n nmiss mean min max;
	title 'Summary statistics for bmi in final analysis data set';
	var bmi; 
run;

ODS PDF CLOSE;