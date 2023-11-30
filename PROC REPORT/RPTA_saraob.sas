* Define macros;
%LET job=RPTA;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/RPTA/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    RPTA                                        
*                                                                    
*  Description:   PROC Report Assignment A   
*
*  Name:          Sara O'Brien
*
*  Date:          3/23/23                                       
*------------------------------------------------------------------- 
*  Job name:      WSCR_sas_saraob.sas   
*
*  Purpose:       Basic PROC REPORT exercises using the CARS2011 data set
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         CARS2011
*
*  Output:        pdf file    
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/RPTA/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in cars data;
LIBNAME bios "/home/u49497589/my_shared_file_links/klh52250/BIOS511" access=readonly;

* Table 1;

proc report data=bios.cars2011 nowd;
	title 'Table 1. Comparison of Car Characteristics across Various Countries';
	columns country baseMSRP=baseMSRPn ('Mean' baseMSRP seating reliability satisfaction);
	define country / group 'Country/of Origin';
	define baseMSRPn / analysis n 'N'  STYLE=[CELLWIDTH=2cm] center;
	define baseMSRP / analysis mean 'Base Price' format=dollar10.2;
	define seating / analysis mean 'Number/of/Seats' format=3.1 center;
	define reliability / analysis mean 'Reliability/(lower is/better)' format=3.1 center;
	define satisfaction / analysis mean 'Satisfaction/(lower is/better)' format=3.1 center;
	where country in ('Germany', 'Japan', 'USA');
run;
	
* Table 2;

proc report data=bios.cars2011 nowd;
	title1 'Table 2. Average MPG of Cars from Different Countries';
	title2 ' ';
	title3 '(average MPG = average of city MPG and highway MPG)';
	columns country citympg hwympg avgmpg;
	define country / group 'Country/of Origin';
	define citympg / analysis mean noprint;
	define hwympg / analysis mean noprint;
	define avgmpg / 'Average/MPG' format=4.1 center;
	compute avgmpg;
		avgmpg=(citympg.mean+hwympg.mean)/2;
	endcomp;
	where country in ('Germany', 'Japan', 'USA');
run;

* Table 3;

proc report data=bios.cars2011 nowd;
	title1 'Table 3. Average MPG by Car Type and Country of Origin';
	title2 ' ';
	columns type country citympg hwympg;
	define type / group 'Type of/Car';
	define country / group 'Country/of Origin';
	define citympg / analysis mean 'City/MPG' format=5.1;
	define hwympg / analysis mean 'Highway/MPG' format=5.1;
	break after type / summarize style=[backgroundcolor=ltgray];
	where country in ('Germany', 'Japan', 'USA') and type in ('Hatchback','SUV','Sedan');
run;

* Table 4;
proc report data=bios.cars2011 nowd;
	title1 'Table 4. German SUVs Available in the United States, 2011';
	title2 ' ';
	columns country type make model ('MPG' citympg hwympg) ('Quality' reliability satisfaction ownercost5years);
	define country / noprint;
	define type / noprint;
	define make / group display; 
	define model / left;
	define citympg / 'City' center;
	define hwympg / 'Highway' center;
	define reliability / display 'Reliability:/1=more/5=less' center;
	define satisfaction / 'Satisfaction:/1=more/5=less' center;
	define ownercost5years / display 'Maintenance/cost:/1=less/5=more' center;
	*compute before model;
	*	i+1;
	*endcomp;
	compute reliability;
		if reliability = 5 then do;
			call define(_col_,"STYLE","STYLE=[FONT_WEIGHT=Bold]");
		end;
	endcomp;
	compute ownercost5years;
		if ownercost5years = 5 then do;
			call define(_col_,"STYLE","STYLE=[FONT_WEIGHT=Bold]");
		end;
		*if mod(i,2) eq 1 then do;
		*	call define(_row_,"STYLE","STYLE=[BACKGROUND=cxDDDDDD]");
		*end;
		if not missing(_break_) then c=0;
		if not missing(make) then c+1;
		if mod(c,2) eq 1 then do;
			call define(_row_,"style","style=[background=cxDDDDDD]");
		end;
	endcomp;
	where country='Germany' and type='SUV';
run;

ODS PDF CLOSE;

