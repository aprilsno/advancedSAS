* Define macros;
%LET job=APIA1;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/APIA/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    APIA                                        
*                                                                    
*  Description:   An Introduction to using APIs to obtain data  
*
*  Name:          Sara O'Brien
*
*  Date:          3/9/23                                       
*------------------------------------------------------------------- 
*  Job name:      APIA1_saraob.sas   
*
*  Purpose:       Using the sunrise-sunset API, find the sunrise time, 
*				  sunset time, and day length for the location of your 
*				  birth on the day that you were born
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Sunset-sunrise API
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/APIA/&job._&onyen..pdf" STYLE=JOURNAL;

filename birth temp;

proc http
    url="%nrstr(https://api.sunrise-sunset.org/json?lat=26.6586779&lng=-80.2414357&date=2001-04-23)"
    method="GET"
    out=birth;
run;

libname sunrise json fileref=birth;

title "Wellington, FL - 04/23/2001";
title2 "Sunrise time, sunset time, and day length";
proc print data=sunrise.results;
	var sunrise sunset day_length;
run;

ODS PDF CLOSE;
