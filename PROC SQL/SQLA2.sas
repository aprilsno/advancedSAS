* Define macros;
%LET job=SQLA2;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLA/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLA                                         
*                                                                    
*  Description:   First set of SQL problems using MIMIC datasets
*
*  Name:          Sara O'Brien
*
*  Date:          1/19/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLA2_saraob.sas   
*
*  Purpose:       Produce a report on patient stay and wait time for
*				  acknowledgement of consent
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set callout
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Pull in MIMIC data;
LIBNAME mimic "~/my_shared_file_links/klh52250/MIMIC" access=readonly;

* Create PDF output file;
ODS PDF FILE="&outdir/Output/SQLA/&job._&onyen..pdf" STYLE=JOURNAL;

* Create proc sql step;
proc sql number;
	title 'Percent of total wait time for call out request to be acknowledged';
	select hadm_id,
		(outcometime-createtime)/60 as totalwait label 'Total wait time (mins)' format 10.1,
		(((acknowledgetime-createtime)/60)/(CALCULATED totalwait)) as percentack label '% wait time to acknowledge request'
			format=percent10.1
	from mimic.callout
	where ^missing(CALCULATED percentack) 
	order by CALCULATED percentack desc;
	
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run;