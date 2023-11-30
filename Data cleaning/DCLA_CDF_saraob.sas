* Define macros;
%LET job=DCLA_CDF;
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
*  Job name:      DCLA_CDF_saraob.sas   
*
*  Purpose:       Clean cdf
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Resp data set cdf
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
proc sort data=resp.cdf2018 out=nodupobs dupout=dupobs nodupkey;
	by fakeid visit fseqno;
run; 

* Check cdf does not contain IDs (FAKEID values) not in DEM2018;
proc sql;
	select fakeid
	from resp.cdf2018 
	where fakeid not in (select fakeid from resp.dem2018);
quit;
* Number of obs did not decrease, no fakeids not in dem;

/**************
	VISIT
**************/
* Check visit variable not >1 or <1;
data badvisit;
	set resp.cdf2018;
	if visit>1 or visit<1 or missing(visit);
run;
* None found;

/**************
	FSEQNO
**************/
* Check fseqno not <0;
data badfseqno;
	set resp.cdf2018;
	if fseqno<0 or missing(fseqno);
run; 
* None found;

/**************
  Other vars
**************/
proc freq data=resp.cdf2018 noprint;
	table cdfa1 cdfa2 cdfa3 / missing;
run;
* No concerning values;

ODS PDF CLOSE;