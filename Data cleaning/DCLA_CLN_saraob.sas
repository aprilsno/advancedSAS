* Define macros;
%LET job=DCLA_CLN;
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
*  Job name:      DCLA_CLN_saraob.sas   
*
*  Purpose:       Clean cln
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Resp data set cln
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
* Check cln does not contain IDs (FAKEID values) not in DEM2018;
proc sql;
	title 'FAKEID value in CLN2018 not found in DEM2018';
	select fakeid
	from resp.cln2018 
	where fakeid not in (select fakeid from resp.dem2018);
quit;

/**************
	VISIT
**************/
* Check visit variable not >1 or <1;
data badvisit;
	set resp.cln2018;
	if visit>1 or visit<1 or missing(visit);
run;
* None found;

/**************
	FSEQNO
**************/
* Check fseqno =0;
data badfseqno;
	set resp.cln2018;
	if fseqno^=0;
run; 
* None found;

/**************
  CLNB1B-E
**************/

* Check for missing values;
proc sql number;
	title 'Missing values for pre- and postbronchodilator FVC (in litres or % predicted)';
	select fakeid, CLNB1B, CLNB1B1, CLNB1D, CLNB1D1
	from resp.cln2018
	where missing(CLNB1B) or missing(CLNB1B1) 
	or missing(CLNB1D) or missing(CLNB1D1);
quit;

proc sql number;
	title 'Missing values for pre- and postbronchodilator FEV1 (in litres or % predicted)';
	select fakeid, CLNB1C, CLNB1C1, CLNB1E, CLNB1E1
	from resp.cln2018
	where missing(CLNB1C) or missing(CLNB1C1) 
	or missing(CLNB1E) or missing(CLNB1E1);
quit;

* Check values of FVC and FEV1 make sense;
proc univariate data=resp.cln2018 nextrobs=10 noprint;
	id fakeid;
	var CLNB1B CLNB1B1 CLNB1C CLNB1C1 CLNB1D CLNB1D1 CLNB1E CLNB1E1;
run; 

* CLNB1D1 has a neg value;
proc sql number;
	title 'Negative values for pre- or postbronchodilator FVC/FEV1 (in litres or % predicted)';
	select fakeid, CLNB1D1
	from resp.cln2018
	where (CLNB1D1<0) and ^missing(CLNB1D1); 
quit;

/**************
  Other vars
**************/
proc freq data=resp.cln2018 noprint;
	table clnb1 / missing;
run;
* No concerning values;

ODS PDF CLOSE;