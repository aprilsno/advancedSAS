* Define macros;
%LET job=MTDB;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/MTDB/&job._&onyen..log" new; 
run;

*********************************************************************
*  Assignment:    MTDB                                     
*                                                                    
*  Description:   Metadata Assignment B  
*
*  Name:          Sara O'Brien
*
*  Date:          4/13/23                                       
*------------------------------------------------------------------- 
*  Job name:      MTDB_saraob.sas   
*
*  Purpose:       Second collection of exercises with SAS metadata
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Cars2011
*
*  Output:        pdf file    
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

LIBNAME bios511 "/home/u49497589/my_shared_file_links/klh52250/BIOS511" access=readonly;
LIBNAME mets "/home/u49497589/my_shared_file_links/klh52250/METS" access=readonly;

ODS PDF FILE="&outdir/Output/MTDB/MTDB_saraob.pdf" style=journal;

* Question 1;
proc sql noprint;
	select name into :varlist separated by ' '
	from dictionary.columns
	where libname='BIOS511' and memname='CARS2011'
	order by name;
quit;
%put &varlist;

* Question 2;
proc sql noprint;
	select name into :cmrvar separated by ' '
	from dictionary.columns
	where libname='BIOS511' and memname='CARS2011' and first(name) in ('C','M','R')
	order by name;
quit;

%macro uniquecmr;

%let i=1;

%do %until (%scan(&cmrvar,&i)=);
	%let cmr = %scan(&cmrvar,&i);
	proc sql noprint;
		select count(distinct &cmr) into :count
		from bios511.cars2011;
	quit;
	%put Variable &cmr has &count unique values;
	%let i = %eval(&i+1);
%end;

%mend;

%uniquecmr;

* Question 3;
proc sql noprint;
	select name into :numvar separated by ' '
	from dictionary.columns
	where libname='BIOS511' and memname='CARS2011' and type='num'
	order by name;
quit;
%put &numvar;

%macro carsnum;

%let i=1;

%do %until (%scan(&numvar,&i)=);
	%let var = %scan(&numvar,&i);
        proc sql noprint;
            select count(distinct &var) into :valcount
                from bios511.cars2011;
        quit;
        %put valcount=&valcount;

        %if &valcount<=6 %then %do;
            proc freq data=bios511.cars2011;
                tables &var / missing;
                title "#2 - Frequency table for &var";
            run;
        %end;

        %else %do;
            proc means data=bios511.cars2011 maxdec=2 n nmiss mean std min max;
                var &var;
                title "#2 - Summary statistics for &var";
            run;
        %end;

        title;
    %let i = %eval(&i+1);
    %end;
    
%mend;

%carsnum;

* Question 4;

/* Using a query to the appropriate dictionary table, make a macro variable list of all date variables in METS
data set BSFA_669. Use a macro to loop through the date variable list and, for each one, produce a small
PROC TABULATE or PROC REPORT table that shows the minimum and maximum values for the date as
well as the number of non-missing and missing values. If N date variables are found, your output should
be N tables like this, with the appropriate variable name, variable label, counts, and date values in place.
Please check again to make sure that your display somehow includes both the variable’s name and its
label and all of the specified summary statistics. */

proc sql noprint;
	select name into :datelist separated by ' '
	from dictionary.columns
	where libname='METS' and memname='BSFA_669' and type='num' and
 		(index(format,'DATE')>0 or index(format,'MMDDYY')>0);
quit;
%put &datelist;

%macro carsdates;

%let i=1;

%do %until (%scan(&datelist,&i)=);
	%let datevar = %scan(&datelist,&i);

	ods exclude all;
	proc means data=mets.bsfa_669 N NMISS MIN MAX;
		var &datevar;
		ods output summary=want ;
	run;
	ods exclude none;
	
	data _null_;
		set mets.bsfa_669 (keep=&datevar);
		varlabel=VLABEL(&datevar);
 		CALL SYMPUTX("varlabel",varlabel);
	run;
	
	proc report data=want;
		columns &datevar._n &datevar._nmiss &datevar._min &datevar._max;
		define &datevar._min / format=date9.;
		define &datevar._max / format=date9.;
		title "&datevar: &varlabel";
	run;

	%let i = %eval(&i+1);
%end;
    
%mend;

%carsdates;

ODS PDF CLOSE;