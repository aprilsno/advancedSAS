* Define macros;
%LET job=RPTD;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/RPTD/&job._&onyen..log" new; 
run;

*********************************************************************
*  Assignment:    RPTD                                      
*                                                                    
*  Description:   PROC Report Assignment D   
*
*  Name:          Sara O'Brien
*
*  Date:          4/4/23                                       
*------------------------------------------------------------------- 
*  Job name:      RPTD_sas_saraob.sas   
*
*  Purpose:       Produce METS Table 8.1, Weight Liability by Treatment Group
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

LIBNAME mets "~/my_shared_file_links/klh52250/METS" access=readonly;

ODS RTF FILE="&outdir/Output/RPTD/RPTD_saraob.RTF" style=journal bodytitle;

* Make data set of OMRA1-based medication values to be classified;
proc sql noprint;
    create table wlmeds as 
    select distinct bid, scan(upcase(omra1),1,' -') as WtLiabMed
    from mets.omra_669
    where omra4='06' and omra5a='Y';
quit;

* Make look-up table: Med as code, Class as value to assign;
data medclass;
    length Med $15 Class $4;
    input med class ;
cards;
CLOZAPINE HIGH
ZYPREXA HIGH
RISPERIDONE HIGH
SEROQUEL HIGH
INVEGA HIGH
CLOZARIL HIGH
OLANZAPINE HIGH
RISPERDAL HIGH
ZIPREXA HIGH
LARI HIGH
QUETIAPINE HIGH
RISPERDONE HIGH
RISPERIDAL HIGH
RISPERIDOL HIGH
SERAQUEL HIGH
ABILIFY LOW
GEODON LOW
ARIPIPRAZOLE LOW
HALOPERIDOL LOW
PROLIXIN LOW
ZIPRASIDONE LOW
GEODONE LOW
HALDOL LOW
PERPHENAZINE LOW
FLUPHENAZINE LOW
THIOTRIXENE LOW
TRILAFON LOW
TRILOFAN LOW
;
run;

* Table look-up using sql join;
proc sql noprint;
    create table classify_med as
    select p.bid, p.wtliabmed, m.class as class
    from wlmeds as p
    	left join
        medclass as m
    	on p.wtliabmed=m.med
    order by bid, wtliabmed;
quit;

* Merge with dr data set;
proc sql;
	create table analysis as
	select b.bid, b.trt, a.WtLiabMed, a.class
	from mets.dr_669 as b
		left join classify_med as a
		on b.bid=a.bid
	order by bid, wtliabmed;
quit;

* For participants with multiple meds, use loop for definition;
data condense;
	set analysis;
	by bid;
	length overall $4;
	retain overall;
	if first.bid then overall='LOW';
	if class = 'HIGH' then overall = 'HIGH';
	if first.bid and last.bid and missing(class) then overall = 'HIGH';
	if last.bid then output;
	keep trt overall; 
run;

data dup;
	set condense;
	output;
	trt = 'C';
	output;
run;
	
* Get counts of high/low per trt group;
proc freq data=dup noprint;
	TABLES overall*trt / MISSING norow nopercent nocum outpct OUT=trtoverall;
	TABLES trt / OUT=trtcnt;
	TABLES overall / OUT=overall;
run;

* Get chi-sq value;
proc freq data=condense noprint;
	tables overall*trt / chisq;
	output out=ChiSqVal chisq;
run;

data _NULL_;
	set chisqval;
	CALL SYMPUT('p',PUT(p_pchi,6.4));
run;
%PUT p=&p;

* Create macro for total counts;
data _NULL_;
	set trtcnt;
	IF trt='A' THEN CALL SYMPUT('a',PUT(count,2.));
	IF trt='B' THEN CALL SYMPUT('b',PUT(count,2.));
	IF trt='C' THEN CALL SYMPUT('c',PUT(count,3.));
run;
%PUT a=&a b=&b c=&c;

* Concatenate count and percent;
data pretrn;
	set trtoverall;
	npct = PUT(count,3.) || ' (' || PUT(pct_col,4.1) || ')';
	keep overall trt npct;
run;

* Transpose count/pct dataset;
proc transpose data=pretrnmerge OUT=trn PREFIX=trt;
	by overall;
	id trt;
	var npct;
run;

* Add p-value from chi-sq test;
data final;
	set trn;
	if overall='HIGH' then pvalue = put(&p,6.4);
run;

* Create format for high/low -- like labels for proc report;
proc format;
	value $highlow
		'HIGH' = 'Participants on higher weight liability antipsychotic meds'
		'LOW' = 'Participants on lower weight liability antipsychotic meds';
run;

* Create final report;
proc report data = final nowd;
	title 'Table 8.1: METS Weight Liability by Treatment Group';
	columns overall trttotal trtA trtB pvalue;	
	define overall / ' ' format=$highlow. style=[CELLWIDTH=4.1cm];
	define trttotal / "Total/N (%)/n=&c" style(header)=[font_style=italic] center;
	define trtA / "Metformin/N (%)/n=&a" style(header)=[font_style=italic] center;
	define trtB / "Placebo/N (%)/n=&b" style(header)=[font_style=italic] center;
	define pvalue / "P-value*" style(header)=[font_style=italic] center;
	footnote1 "*Chi-square statistic comparing metformin and placebo groups";
	footnote2 "Participants taking both higher and lower weight liability meds are included in the higher group.";
run;

ODS RTF CLOSE;