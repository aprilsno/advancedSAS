* Define macros;
%LET job=WSCR_sas;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/WSCR/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    WSCR                                        
*                                                                    
*  Description:   Web scraping   
*
*  Name:          Sara O'Brien
*
*  Date:          3/23/23                                       
*------------------------------------------------------------------- 
*  Job name:      WSCR_sas_saraob.sas   
*
*  Purpose:       Scrape web file for cast names
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Glass Onion webpage
*
*  Output:        pdf file    
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/WSCR/&job._&onyen..pdf" STYLE=JOURNAL;

* Set up a file location for writing the page source;
%let fileloc=/home/u49497589/BIOS669/Program/WSCR;
filename cast "&fileloc/glassonion.txt";

* Use PROC HTTP to get the page source and write it to our file;
proc http
	method="GET"
	url="https://www.imdb.com/title/tt11564570/fullcredits"
	out=cast;
run;

data go_cast;
	infile cast length=len lrecl=32767;
	input line $varying32767. len;
	line = strip(line);
	if len>0;
run;

data parsedcast;
	set go_cast;
	line_begin = find(line, '><img');
	line_end = find(line, '</td>');
	name_begin = find(line, 'alt="');
	name_end = find(line, '" title=');
	if line_end > 0;
	if line_begin > 0;
	if name_begin > 0;
	if name_end > 0;
run;

* ><img height="44" width="32" alt="Mark Newman" title="Mark Newman" src="https://m.media-amazon.com/images/S/sash/N1QWYSqAfSJV62Y.png" class="" /></a>          </td>;
data castnames;
	set parsedcast;
	length name $100;
	name = substr(line,name_begin+5,name_end-(name_begin+5));
	*title = substr(line,)
	*title = substr(line,href_end+2,title_end-(href_end+2));
	* parse = substr(line,link_end+2,para_end-(link_end+3));
	* line, beginning point, length;
	*name = scan(title,1,',');
 	keep name;
run;

proc print data=castnames; 
	title 'Glass Onions Cast';
run;

ODS PDF CLOSE;