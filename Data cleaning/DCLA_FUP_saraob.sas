* Define macros;
%LET job=DCLA_FUP;
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
*  Job name:      DCLA_FUP_saraob.sas   
*
*  Purpose:       Clean fup
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Resp data set fup
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
* Check no duplicates by variables sequence fakeid visit fseqno;	
proc sort data=resp.fup2018 out=nodupobs dupout=dupobs nodupkey;
	by fakeid visit fseqno;
run;
* No duplicates found;

* Check fup does not contain IDs (FAKEID values) not in DEM2018;
proc sql;
	select fakeid
	from resp.fup2018 
	where fakeid not in (select fakeid from resp.dem2018);
quit;
* Number of obs did not decrease, no fakeids not in dem;

/**************
	VISIT
**************/
* Check visit variable not >6 or <1;
data badvisit;
	set resp.fup2018;
	if visit<1 or visit>6 or missing(visit);
run;
* None found;

/**************
	FSEQNO
**************/
* Check fseqno =0;
data badfseqno;
	set resp.fup2018;
	if fseqno^=0;
run; 
* None found;

/**************
	FUPA4B-E
**************/

proc sql number;
	title 'Missing values for pre- and postbronchodilator FVC (in litres or % predicted)';
	select fakeid, visit, FUPA4b, FUPA4b1, FUPA4d, FUPA4d1
	from resp.fup2018
	where missing(FUPA4b) or missing(FUPA4b1) 
	or missing(FUPA4d) or missing(FUPA4d1);
quit;

proc sql number;
	title 'Missing values for pre- and postbronchodilator FEV1 (in litres or % predicted)';
	select fakeid, visit, FUPA4c, FUPA4c1, FUPA4e, FUPA4e1
	from resp.fup2018
	where missing(FUPA4c) or missing(FUPA4c1)
	or missing(FUPA4e) or missing(FUPA4e1);
quit;

* Check values of FVC and FEV1 make sense;
proc univariate data=resp.fup2018 nextrobs=10 noprint;
	id fakeid;
	var FUPA4b FUPA4b1 FUPA4c FUPA4c1 FUPA4d FUPA4d1 FUPA4e FUPA4e1;
run;

* FUPA4D1 has a neg value;
proc sql number;
	title 'Negative values for pre- or postbronchodilator FVC and FEV1 (in litres or % predicted)';
	select fakeid, visit, FUPA4d1
	from resp.fup2018
	where FUPA4d1<0 and ^missing(FUPA4d1);
quit;

/**************
  Other vars
**************/
proc freq data=resp.fup2018 noprint;
	table fupa1 fupa2 fupa3b fupa4 fupa5 fupa6 fupa7 fupa8 fupa9 fupa10 fupa11
	fupa12 fupa13 fupa14 fupa15 fupa28a fupa28b fupa28c/ missing;
run;
* No concerning values;

proc univariate data=resp.fup2018 nextrobs=10 noprint;
	var fupa3a;
run;
* No concerning values;

ODS PDF CLOSE;