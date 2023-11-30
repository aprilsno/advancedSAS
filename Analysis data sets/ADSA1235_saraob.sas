* Define macros;
%LET job=ADSA1235;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/ADSA/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    ADSA                                         
*                                                                    
*  Description:   Create an analysis data set
*
*  Name:          Sara O'Brien
*
*  Date:          2/16/23                                       
*------------------------------------------------------------------- 
*  Job name:      ADSA1235_saraob.sas   
*
*  Purpose:       Creating an analysis data set for a paper looking at 
*				  CHD and magnesium, Part I, mostly focusing on arriving 
*				  at the correct set of observations 
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         CHD data sets core, nutrition, measurements, 
*				  medications_wide
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/ADSA/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in CHD data;
LIBNAME chd "~/my_shared_file_links/klh52250/CHD" access=readonly;

* 1. Use the medications_wide data set to create variables indicating diuretic use and use of lipid
lowering medications;

data array_meds;
	set chd.medications_wide;
	diuretic = 0;
	lipidlowermed = 0;
	
	array med {17} $8 DrugCode1-DrugCode17;
	
	do i=1 to 17;
		if '370000' <=: med{i} <=: '380000' then diuretic=1;
		if (med{i} = '390000' or med{i} = '391000' or med{i} = '240600') then lipidlowermed=1;
	end;
	
	keep id diuretic lipidlowermed;
run;

* Create frequency tables of two newly derived vars;
proc freq data=array_meds;
	title '1. One-way frequency tables for diuretic and lipidlowermed';
	table diuretic lipidlowermed / missing;
run;

* 2. Combine the core, nutrition, measurements, and new meds data sets;

* Create libref for manuscript dataset to permanently write to;
LIBNAME adsa "/home/u49497589/BIOS669/Output/ADSA";

* Sort datasets for merge;
proc sort data = chd.core out = core; by id; run;
proc sort data = chd.nutrition out = nutrition; by id; run;
proc sort data = chd.measurements out = measurements; by id; run;
proc sort data = array_meds; by id; run;

* Merge datasets;
data adsa.chd_merge;
	merge core (in=core) 
		nutrition (rename=(magnesium=DietMg))
		measurements (rename=(magnesium=SerumMg))
		array_meds;
	by id;
	if missing(diuretic) then diuretic = 0;
	if missing(lipidlowermed) then lipidlowermed = 0;
	if core;
run;

* Check merged dataset;
proc contents data = adsa.chd_merge; 
	title '2. Proc contents for new merged dataset';
run;

proc freq data = adsa.chd_merge;
	title '2. One-way frequency tables for diuretic and lipidlowermed';
	table diuretic lipidlowermed / missing;
run;

* 3. Subset the data set made in step 2 to obtain the observations to be used for our manuscript;

* Create subset of merged dataset for manuscript;
proc sql;
	create table adsa.chd_manu as
	select *
	from adsa.chd_merge
	where (race = 'B' or race = 'W')
		and ^missing(BMI) and ^missing(SerumMg) and ^missing(DietMg) and
		(id in 
			(select id
			from adsa.chd_merge
			where gender = 'F' and (totcal > 500 and totcal < 3600)) 
		or id in 
			(select id
			from adsa.chd_merge
			where gender = 'M' and (totcal > 600 and totcal < 4200))
		);
quit;

* Check subset;
proc contents data = adsa.chd_manu;
	title '3. Proc contents on dataset for manuscript';
run;

proc freq data = adsa.chd_manu;
	title '3. One-way freq tables of race and gender';
	table race gender / missing;
run;

proc means data = adsa.chd_manu n nmiss mean min max;
	title '3. Stats for TotCal, BMI, DietMg, and SerumMg';
	var totcal bmi DietMg SerumMg;
run;

* 5. Derive Diuretic and LipidLowerMed using medications_long data set;

* Derive diuretic and lipidlowermed vars from long dataset;
data meds_long;
	set chd.medications_long;
	diuretic = 0;
	lipidlowermed = 0;
	
	if '370000' <=: DrugCode <=: '380000' then diuretic=1;
	if (DrugCode = '390000' or DrugCode = '391000' or DrugCode = '240600') then lipidlowermed=1;
	
	keep id diuretic lipidlowermed;
run;

* Transpose individually, combine diuretic and lipidlowermed values by id, merge transposed datasets by id;
proc transpose data=meds_long out=meds_diuretic;
    by id;
    var diuretic;
run;

proc transpose data=meds_long out=meds_lipid;
    by id;
    var lipidlowermed;
run;

data meds_diuretic;
    set meds_diuretic;
    
    array med {17} $8 Col1-Col17;
    diuretic=0;
	
	do i=1 to 17;
		if med{i}=1 then diuretic=1;
	end;
	keep id diuretic;
run;

data meds_lipid;
    set meds_lipid;
    
    array med {17} $8 Col1-Col17;
    lipidlowermed=0;
	
	do i=1 to 17;
		if med{i}=1 then lipidlowermed=1;
	end;
	keep id lipidlowermed;
run;

proc sort data=meds_diuretic; by id; run;
proc sort data=meds_lipid; by id; run;

data meds_wide;
	merge meds_diuretic meds_lipid;
	by id;
run;

* Run one-way frequency on derived vars;
proc freq data=meds_wide;
	title '5. One-way frequency tables for diuretic and lipidlowermed';
	table diuretic lipidlowermed / missing;
run;

* Compare datasets in 1 and 5;
proc compare base=array_meds compare=meds_wide;
	title 'Comparing datasets creating in 1 and 5';
run;

ODS PDF CLOSE;