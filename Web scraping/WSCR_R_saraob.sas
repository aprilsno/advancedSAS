* Define macros;
%LET job=WSCR_R;
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
*  Purpose:       Scrape web file for basketball stats
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         2021-22 NBA Player Stats: Per Game webpage
*
*  Output:        pdf file    
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/WSCR/&job._&onyen..pdf" STYLE=JOURNAL;

* Since I use SAS OnDemand, I chose to first create a dataframe in R,
export a CSV, and import that CSV to SAS to complete the rest of the 
WSCR R portion of the assignment;
proc import datafile="&outdir/Program/WSCR/WSCR_R_df.csv"
	out=basketball
	dbms=csv
	replace;
	guessingrows=3000; * this avoids truncating any values like pos;
	getnames=no;
run;

* Since input var names had some non-SAS names, renaming manually for vars of interest;
data basketball;
	set basketball;
	rk=var2;
	player=var3;
	pos=var4;
	tm=var6;
	fgpct=var12;
	ast=var26;
	keep rk player pos tm fgpct ast;
run;

* Identify players with more than one record;
proc sql;
	create table duplicatecount as
	select distinct *, count(*) as playercount
	from basketball
	group by player;
quit;

* Create final data set of interest;
data basketball;
	set duplicatecount;
	if Rk ^= 'Rk';
	if playercount > 1 then do;
		if tm='TOT';
	end;
	astnum = input(ast, 8.2);
	fgnum = input(fgpct, 8.2);
	drop playercount ast fgpct;
run;

* Using format to combine positions like PG-SG and SG-PG;
proc format;
	value $positions
		'C' = 'C'
		'C-PF' = 'C-PF'
		'PF' = 'PF'
		'PF-SF' = 'PF-SF'
		'SF-PF' = 'SF-PF'
		'PG' = 'PG'
		'PG-SG' = 'PG-SG'
		'SG-PG' = 'PF-SG'
		'SF' = 'SF'
		'SF-SG' = 'SF-SG'
		'SG-SF' = 'SF-SG'
		'SG' = 'SG'
		'SG-PG-SF' = 'SG-PG-SF';
run;

* Calc avg ast and fg%;
proc means data=basketball mean;
	format pos $positions.;
	class pos;
	var astnum fgnum;
run;

ODS PDF CLOSE;