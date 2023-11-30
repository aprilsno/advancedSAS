* Define macros;
%LET job=APIA3automap;
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
*  Job name:      APIA3automap_saraob.sas   
*
*  Purpose:       Build a custom JSON map that will make a data set 
*				  named books and pulls only book name, number of pages, 
*				  publisher, and release time information from this API
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Ice and fire API
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
* ODS PDF FILE="&outdir/Output/APIA/&job._&onyen..pdf" STYLE=JOURNAL;

* Create automap;
filename bk1 temp;

proc http
	url="%nrstr(https://www.anapioficeandfire.com/api/books)"
 	method="GET"
 	out=bk1;
run;

libname in json fileref=bk1 map="&outdir/Output/APIA/books.user.map" automap=create; 

* Vars of interest name publisher numberOfPages released selected manually from automap;
