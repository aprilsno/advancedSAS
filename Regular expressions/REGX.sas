* Define macros;
%LET job=REGX;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/REGX/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    REGX                                        
*                                                                    
*  Description:   An introduction to regular expressions   
*
*  Name:          Sara O'Brien
*
*  Date:          3/9/23                                       
*------------------------------------------------------------------- 
*  Job name:      REGX_saraob.sas   
*
*  Purpose:       Develop regular expressions to find patterns in the 
*				  OMRA1 (medication name) variable of the METS omra_669 
*				  data set
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
ODS PDF FILE="&outdir/Output/REGX/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in dataset;
LIBNAME mets "~/my_shared_file_links/klh52250/METS" access=readonly;

%macro regexmacro(q=, question=, val=);

	%let regex = &val;

	data checkRegEx;
	    set mets.omra_669;
	    retain testRegEx;
	    if _N_=1 then do;
	        testRegEx = prxparse("/&regex/");
	        if missing(testRegEx)then do;
	            putlog 'ERROR: regex is malformed';
	            stop;
	        end;
	    end;
	    
	    if prxmatch(testRegEx, strip(omra1));
	run;
	
	title1 "Question &q";
	title2 "Medication matches &regex";
	proc print data=checkRegEx;
	    var omra1;
	run;
	title;	

%mend;

*1; %regexmacro(q=1, val=ASPIRIN);
*2; %regexmacro(q=2, val=ASPI?RIN);
*3; %regexmacro(q=3, val=%NRSTR(ASPI?RIN.*\d{1,}));
*4; %regexmacro(q=4, val=RO..REM);
*5; %regexmacro(q=5, val=%NRSTR((.*L.*){3,})); * same as %regexmacro(val=.*L.*L.*L.*);
*6; %regexmacro(q=6, val=TRAZ.DONE);
*7; %regexmacro(q=7, val=PRIL$);
*8; %regexmacro(q=8, val=%);
*9; %regexmacro(q=9, val=\d.*MG);
*10; %regexmacro(q=10, val=%NRSTR(\d{1,}$));
*11; %regexmacro(q=11, val=^.+PRO);
*12; %regexmacro(q=12, val=%NRSTR((^(.){1,3}\b)$)); * same as %regexmacro(val=(^(.|..|...)\b)$);
*13; %regexmacro(q=13, val=%NRSTR((A|E|I|O|U){3,}));
*14; %regexmacro(q=14, val=(.+\s){4});
*15. Find all medication values that include dosage information in MG whose dosage is >=100; 
%regexmacro(q=15. Find all medication values that include dosage information in MG and whose dosage is >=100,
val=%NRSTR(\d{3,}.*MG));

ODS PDF CLOSE;
