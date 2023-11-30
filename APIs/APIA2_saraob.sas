* Define macros;
%LET job=APIA2;
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
*  Job name:      APIA2_saraob.sas   
*
*  Purpose:       Using data pulled from the open air quality API, 
*				  compute mean particulates 10 mm or less in diameter 
*				  (pm10) at 9 AM, 2 PM, and 7 PM (three separate means 
*				  and using local times) for the time span of Feb 27, 
*				  2023-March 3, 2023 in Durham, NC.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Open air API
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/APIA/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in data from API and map;
filename aq1 temp;

proc http
    url="%nrstr(https://api.openaq.org/v1/measurements?country=US&city=Durham&location=Durham%20Armory&limit=10000)"
    method="GET"
    out=aq1;
run;

filename measmap "/home/u49497589/my_shared_file_links/klh52250/APIA files/measurements.user_meas.map";

libname in json fileref=aq1 map=measmap;

* Create data set of interest from map;
data durham;
	set in.meas;
	retain time;
	
	DateTimeAll=input(local,ymddttM19.);
	DateOnly=datepart(datetimeall);
	TimeOnly=timepart(datetimeall);
	
	* Select date ranges;
	if '27FEB2023'd <= dateonly <= '03MAR2023'd;
	
	* Create class/3 times of day;
	if timeonly in ("09:00:00"t, "14:00:00"t, "19:00:00"t);
	if timeonly = "09:00:00"t then time="9 am";
	else if "14:00:00"t = timeonly then time="2 pm";
	else if "19:00:00"t = timeonly then time="7 pm";
	
	* Select particulates 10 mm or less in diameter; 
	if parameter = 'pm10';
run;

* Compute means;
proc means data=durham N mean std min max;
	title1 'Open air quality in Durham, NC from 2/27/23 to 3/3/23';
	title2 'Mean particulates 10 mm or less in diameter (pm10) at 9 AM, 2 PM, and 7 PM';
	class time;
	var value;
run;

ODS PDF CLOSE;