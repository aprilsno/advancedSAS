* Define macros;
%LET job=RPTB;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/RPTB/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    RPTB                                        
*                                                                    
*  Description:   PROC Report Assignment B   
*
*  Name:          Sara O'Brien
*
*  Date:          3/28/23                                       
*------------------------------------------------------------------- 
*  Job name:      WSCR_sas_saraob.sas   
*
*  Purpose:       Produce METS Table 2.2, Baseline Physical Exam – Systematic Inquiry
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

FOOTNOTE1 "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/RPTB/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in cars data;
LIBNAME mets "/home/u49497589/my_shared_file_links/klh52250/METS" access=readonly;

* Merge dr and mhxa datasets;
proc sql;
	create table mets as
	select a.bid, a.trt, b.MHXA25, b.MHXA26, b.MHXA27, b.MHXA28, b.MHXA29, b.MHXA30, b.MHXA31, b.MHXA32
	from mets.dr_669 as a, mets.mhxa_669 as b
	where a.bid=b.bid;
quit;

* Duplicate incoming data for overall data;
data mets2;
	set mets;
	output;
	trt = 'C';
	output;
run;

* Compute basic counts and percents required by table shell;
proc freq data=mets2 noprint;
	title 'Basic counts and percents';
	TABLES trt*MHXA25 / MISSING OUTPCT OUT=MHXA25cnt (where=(MHXA25='A'));
	TABLES trt*MHXA26 / MISSING OUTPCT OUT=MHXA26cnt (where=(MHXA26='A'));
	TABLES trt*MHXA27 / MISSING OUTPCT OUT=MHXA27cnt (where=(MHXA27='A'));
	TABLES trt*MHXA28 / MISSING OUTPCT OUT=MHXA28cnt (where=(MHXA28='A'));
	TABLES trt*MHXA29 / MISSING OUTPCT OUT=MHXA29cnt (where=(MHXA29='A'));
	TABLES trt*MHXA30 / MISSING OUTPCT OUT=MHXA30cnt (where=(MHXA30='A'));
	TABLES trt*MHXA31 / MISSING OUTPCT OUT=MHXA31cnt (where=(MHXA31='A'));
	TABLES trt*MHXA32 / MISSING OUTPCT OUT=MHXA32cnt (where=(MHXA32='A'));
	TABLES trt / OUT=trtcnt;
run;

* Store treatment group counts in macro variables for later display;
*** in column headings;
data _NULL_;
	set trtcnt;
	IF trt='A' THEN CALL SYMPUT('a',PUT(count,2.));
	IF trt='B' THEN CALL SYMPUT('b',PUT(count,2.));
	IF trt='C' THEN CALL SYMPUT('c',PUT(count,3.));
RUN;
%PUT a=&a b=&b c=&c;

* Create N (%) character values requested in table shell;
%macro npct(mhxapct=,mhxacnt=,mhxa=);
data &mhxapct;
	SET &mhxacnt(KEEP=trt &mhxa count pct_row);
	LENGTH cp $10;
	cp=PUT(count,2.) || ' (' || PUT(pct_row,2.) || '%)';
	drop count pct_row;
run;
%mend;

%npct(mhxapct=MHXA25pct,mhxacnt=MHXA25cnt,mhxa=MHXA25);
%npct(mhxapct=MHXA26pct,mhxacnt=MHXA26cnt,mhxa=MHXA26);
%npct(mhxapct=MHXA27pct,mhxacnt=MHXA27cnt,mhxa=MHXA27);
%npct(mhxapct=MHXA28pct,mhxacnt=MHXA28cnt,mhxa=MHXA28);
%npct(mhxapct=MHXA29pct,mhxacnt=MHXA29cnt,mhxa=MHXA29);
%npct(mhxapct=MHXA30pct,mhxacnt=MHXA30cnt,mhxa=MHXA30);
%npct(mhxapct=MHXA31pct,mhxacnt=MHXA31cnt,mhxa=MHXA31);
%npct(mhxapct=MHXA32pct,mhxacnt=MHXA32cnt,mhxa=MHXA32);

* Basic transposition by MHXA to get treatment A & B values on same record per table shell;
%macro datatrn(mhxapct=,mhxatrn=,mhxa=);
proc sort data=&mhxapct; 
	by &mhxa; 
run;

proc transpose data=&mhxapct OUT=&mhxatrn PREFIX=trt;
	by &mhxa;
	id trt;
	var cp;
run;
%mend;

%datatrn(mhxapct=MHXA25pct,mhxatrn=MHXA25trn,mhxa=MHXA25);
%datatrn(mhxapct=MHXA26pct,mhxatrn=MHXA26trn,mhxa=MHXA26);
%datatrn(mhxapct=MHXA27pct,mhxatrn=MHXA27trn,mhxa=MHXA27);
%datatrn(mhxapct=MHXA28pct,mhxatrn=MHXA28trn,mhxa=MHXA28);
%datatrn(mhxapct=MHXA29pct,mhxatrn=MHXA29trn,mhxa=MHXA29);
%datatrn(mhxapct=MHXA30pct,mhxatrn=MHXA30trn,mhxa=MHXA30);
%datatrn(mhxapct=MHXA31pct,mhxatrn=MHXA31trn,mhxa=MHXA31);
%datatrn(mhxapct=MHXA32pct,mhxatrn=MHXA32trn,mhxa=MHXA32);

* Stack transposed datasets;
data stackdata;
	set MHXA25trn
	MHXA26trn
	MHXA27trn
	MHXA28trn
	MHXA29trn
	MHXA30trn
	MHXA31trn
	MHXA32trn;
	
	if ^missing(MHXA25) then npct = 'Abnormal General Appearance/Skin';
	if ^missing(MHXA26) then npct = 'Abnormal HEENT';
	if ^missing(MHXA27) then npct = 'Abnormal Cardiovascular';
	if ^missing(MHXA28) then npct = 'Abnormal Chest';
	if ^missing(MHXA29) then npct = 'Abnormal Abdominal';
	if ^missing(MHXA30) then npct = 'Abnormal Extremities/Joints';
	if ^missing(MHXA31) then npct = 'Abnormal Neurological';
	if ^missing(MHXA32) then npct = 'Abnormal Physical Exam Other';
	
	totalcount = input(scan(trtc,1),5.);
	
	keep npct trta trtb trtc totalcount;
run;

* Sort by total counts;
proc sort data=stackdata;
	by descending totalcount;
run;

* Create final report;
proc report data=stackdata;
	title1 'Table 2.2: METS Baseline Physical Exam - Systematic Inquiry';
	title2 ' ';
	*footnote j=l "^S={fontstyle=roman just=l fontfamily='courier new'fontsize=2.5 fontweight=medium } Note: Is my footnote just under the line and aligned ?";
	columns npct trtc trta trtb;
	define npct / 'N (%)' style(header)={just=r verticalalign=bottom};
	define trtc / "Total/N=&c" style=[CELLWIDTH=2.5cm];
	define trta / "Metformin/N=&a" center style=[CELLWIDTH=2.5cm];
	define trtb / "Placebo/N=&b" center style=[CELLWIDTH=2.5cm];
	compute trtc;
 		CALL DEFINE(_COL_, "style", "STYLE=[BACKGROUND=LIGHTGREY]");
 	endcomp;  
run;
* Using ods text statement rather than footnote so that text is directly beneath report
and separate from page footnote;
ods escapechar='^';
ods pdf text=' '; ods pdf text=' ';
ods pdf text='^S={leftmargin=1.4in}Participants could have experienced more than one medical disorder.';

ODS PDF CLOSE;