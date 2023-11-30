* Define macros;
%LET job=DCLA_DEM;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/DCLA/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    DCLA                                        
*                                                                    
*  Description:   Data cleaning exercise
*
*  Name:          Sara O'Brien
*
*  Date:          2/23/23                                       
*------------------------------------------------------------------- 
*  Job name:      DCLA_DEM_saraob.sas   
*
*  Purpose:       Clean cdf
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Resp data set dem
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/DCLA/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in dataset;
LIBNAME resp "~/my_shared_file_links/klh52250/Resp" access=readonly;

/**************
	FAKEID
**************/
* Check only numeric values in fakeid string;
data badfakeid;
	set resp.dem2018;
	if notdigit(strip(fakeid))>0;
run;
* No obs extraneous;

* Check no duplicates of fakeid, should be 1 obs per participant;
proc sort data=resp.dem2018 out=nodupobs dupout=dupobs nodupkey;
	by fakeid;
run; 
* No duplicates found;

/**************
	VISIT
**************/
* Check visit variable=1;
proc freq data=resp.dem2018;
	where visit^=1;
	table visit / missing;
run;
* None found;

/**************
	FSEQNO
**************/
* Check fseqno =0;
data badfseqno;
	set resp.dem2018;
	if fseqno^=0;
run; 
* None found;

/**************
	GENDER
**************/
proc freq data=resp.dem2018 noprint;
	table DEMA2 / missing;
run; 
* One missing;

proc sql number;
	title1 'Gender variable not M or F in DEM';
	title2 'One missing value found';
	select fakeid, DEMA2 
	from resp.dem2018
	where missing(DEMA2);
quit;

/**************
	WEIGHT
**************/
* Check weight and units (kilograms or pounds);

* Can look at lowest and highest values;
proc univariate data=resp.dem2018 nextrobs=10 noprint;
	id fakeid;
	class dema6b;
	var dema6a;
run; 

/* Can also look for values more than 2 or 3 or 4 standard deviations from the mean
proc means data=resp.dem2018;
	where dema6b='K';
	var dema6a;
	output out=kgstats(drop=_type_ _freq_) mean=kgmean std=kgstd;
run; 

data extremeweightkg;
	set resp.dem2018(keep=fakeid dema6a dema6b);
	if dema6b='K';
	if _N_=1 then set kgstats;
	if (dema6a<kgmean-3*kgstd or dema6a>kgmean+3*kgstd) and^missing(dema6a) then output;
run;

proc print data=extremeweightkg; 
run; */

* There are some particularly over/underweight adults, but since these values
are not actually outliers we are not highly concerned;

proc sql number;
	title1 'Missing values for weight or weight units in DEM';
	select fakeid, DEMA6a, DEMA6b
	from resp.dem2018
	where missing(DEMA6a) or missing(DEMA6b);
quit;

* Another way to check;
proc freq data=resp.dem2018 noprint;
	where missing(DEMA6a);
	table DEMA6a / missing;
run; 

/**************
	HEIGHT
**************/
* Check height and units (cm or in);

* Can look at lowest and highest values;
proc univariate data=resp.dem2018 nextrobs=10 noprint;
	id fakeid;
	class dema6d;
	var dema6c;
run; 

proc sql number;
	title 'Missing values for height or height units in DEM';
	select fakeid, DEMA6c, DEMA6d
	from resp.dem2018
	where missing(DEMA6c) or missing(DEMA6d);
quit;

* Another way to check;
proc freq data=resp.dem2018 noprint;
	where missing(DEMA6c);
	table DEMA6c / missing;
run; 

proc sql number;
	title 'Extreme values for height or height units in DEM';
	select fakeid, DEMA6c, DEMA6d
	from resp.dem2018
	where fakeid in
		(select fakeid
		from resp.dem2018
		where DEMA6d='C' and DEMA6c<140) or fakeid in
		(select fakeid
		from resp.dem2018
		where DEMA6d='I' and DEMA6c>90);
quit;

/**************
  Other vars
**************/

* Age may be useful when considering weight and height values as well,
so we can check the variable;
proc freq data=resp.dem2018 noprint;
	where age<1 or age>120;
	tables age / missing;
run; 

proc sql number;
	title 'Unusual or missing values of age';
	select fakeid, age
	from resp.dem2018
	where age<1 or missing(age);
quit;

* All other vars;
proc freq data=resp.dem2018 noprint;
	table dema3 dema4a dema4b dema4c dema4d dema4e dema4f dema5 dema7 dema8 dema9
	dema11a dema11b dema11c / missing;
run;
* dema7 lowercase n coded as different to uppercase N, may be important to note
if ever used for analysis;

ODS PDF CLOSE;