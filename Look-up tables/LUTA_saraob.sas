* Define macros;
%LET job=LUTA;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/LUTA/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    LUTA                                         
*                                                                    
*  Description:   Look-up tables assignment
*
*  Name:          Sara O'Brien
*
*  Date:          2/9/23                                       
*------------------------------------------------------------------- 
*  Job name:      LUTA_saraob.sas   
*
*  Purpose:       Use look-up table methods to classify METS baseline 
*				  anti-psychotic medications as HIGH or LOW weight 
*				  liability.	
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set omra
*
*  Output:        PDF file     
*                                                                    
********************************************************************;


OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/LUTA/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in METS data;
LIBNAME mets "~/my_shared_file_links/klh52250/METS" access=readonly;

* 1. Use the OMRA data set to make a data set of the meds to be classified;

proc sql;
	* Note that ' ' and '-' are default delimiters in SAS, so we don't need to 
	specify in scan; 
	create table wlmeds as
		select distinct bid, scan(omra1,1) as WtLiabMed
		from mets.omra_669
		where omra5a='Y' and omra4='06';
quit;

* 2. Make a look-up data set based on the Word table in the LUTA assignment 
document; 

data lookup;
	infile datalines delimiter='	';
	length start $15 label $4;
	input start label;
	datalines;
CLOZAPINE	HIGH
ZYPREXA	HIGH
RISPERIDONE	HIGH
SEROQUEL	HIGH
INVEGA	HIGH
CLOZARIL	HIGH
OLANZAPINE	HIGH
RISPERDAL	HIGH
ZIPREXA	HIGH
LARI	HIGH
QUETIAPINE	HIGH
RISPERDONE	HIGH
RISPERIDAL	HIGH
RISPERIDOL	HIGH
SERAQUEL	HIGH
ABILIFY	LOW
GEODON	LOW
ARIPIPRAZOLE	LOW
HALOPERIDOL	LOW
PROLIXIN	LOW
ZIPRASIDONE	LOW
GEODONE	LOW
HALDOL	LOW
PERPHENAZINE	LOW
FLUPHENAZINE	LOW
THIOTRIXENE	LOW
TRILAFON	LOW
TRILOFAN	LOW
	;
run;
 
* 3. Use at least three of the look-up table methods to classify the meds in #1 as 
HIGH or LOW.  Depending on the methods you choose, some of these 
methods will use the look-up data set from #2 and some will not;
 
* Method 1: Using a hash object;
data hash_lu;
	
	length start $15 label $4;
	
	if _n_=1 then do;
		declare hash med(dataset:'lookup');
		med.definekey('start');
		med.definedata('label');
		med.definedone();
		call missing(start,label);
	end;
	
	set wlmeds;
	
	rc=med.find(key:WtLiabMed);
	drop rc start;
	
run;

* Method 2: Using a format and put;

data fmt;
	set lookup;
	retain fmtname '$classification';
run;

proc format cntlin=fmt;	
	value $class
		'LORAZEPAM' = ' '
		'DEPAKOTE' = ' '
		'RITALIN' = ' '
		'DEPALCOTE' = ' '
		'TRAZIDONE' = ' '
		'LOXAPINE' = ' '
		'DEPECOT' = ' '
		other = [$classification.];
run; 

data fmt_lu;
	set wlmeds;
	label=put(WtLiabMed,$class.);
run;

* Method 3: Using a SQL left join;
proc sql;
	create table sql_lu as 
	select a.bid, a.WtLiabMed, b.label
	from wlmeds as a
		left join lookup as b
	on a.WtLiabMed=b.start;
quit;
	
* 4. Examine / show me your results. Do all of the methods result in the same 
HIGH / LOW classification for every med?;

* A. Crosstab of classification*WtLiabMed;
proc freq data=sql_lu;
	title 'Crosstabulation of medications and classification for SQL classification';
	tables label*WtLiabMed / list missing;
run;

* B. Join all classifications and produce crosstab as in part A;
proc sql;
	create table allclass as
	select a.bid, a.WtLiabMed, a.label, a.label as class1, b.label as class2, c.label as class3
	from hash_lu as a, sql_lu as b, fmt_lu as c
	where a.bid=b.bid=c.bid and a.WtLiabMed=b.WtLiabMed=c.WtLiabMed;
quit;

proc freq data=allclass;
	title 'Crosstabulation of classification for all lookup methods';
	tables class1*class2*class3 / list missing;
run;

* C. Print a list of all BID/WtLiabMed combinations that were not classified as either HIGH or LOW;
proc print data=allclass;
	title 'BID and WtLiabMed combinations not classified as high or low';
	var BID WtLiabMed;
	where label='';
run;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;