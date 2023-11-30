* Define macros;
%LET job=MTDA;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/MTDA/&job._&onyen..log" new; 
run;

*********************************************************************
*  Assignment:    MTDA                                      
*                                                                    
*  Description:   Metadata Assignment A   
*
*  Name:          Sara O'Brien
*
*  Date:          4/11/23                                       
*------------------------------------------------------------------- 
*  Job name:      MTDA_saraob.sas   
*
*  Purpose:       Familiarize with metadata in SAS
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

ODS PDF FILE="&outdir/Output/MTDA/MTDA_saraob.pdf" style=journal;

* Question 1;

%macro dsexists(ds=);
	%IF %SYSFUNC(EXIST(&ds))=1 %THEN %DO;
		DATA _null_;
		dsid=OPEN("&ds");
	 	numobs=ATTRN(dsid,'NOBS');
	 	rc=CLOSE(dsid);
	 	CALL SYMPUTX("numobs",numobs);
 		RUN;
 		%PUT Data set &ds exists and has &numobs observations.; 
	%END;
	
	%ELSE %DO;
		DATA _null_;
		PUT "Data set &ds does not exist.";
		RUN;
	%END;
%mend;

%dsexists(ds=bios511.cars2011);
%dsexists(ds=bios511.cars2012);

* Question 2;

%macro carsnum(var=);

PROC SQL noprint; 
		select COUNT(DISTINCT &var) into :count
		from bios511.cars2011;
quit;
		
data cars;
	set bios511.cars2011;
	type = vtype(&var);
	CALL SYMPUTX("type",type);
run;

	%if &type = C %then %do;
		data _null;
		PUT "&var is a character variable.";
		run;
	%end;
	
	%else %do;
		%if &count > 6 %then %do;
			proc means data = bios511.cars2011;
				var &var;
			run;
		%end;
		
		%else %if &count <= 6 %then %do;
			proc freq data = bios511.cars2011;
				tables &var / missing;
			run;
		%end;
	%end;

%mend;

ods noptitle;
%carsnum(var=make);
%carsnum(var=reliability);
%carsnum(var=seating);

* Question 3;

%macro carlabel(var=);

data _null_;
	dsid=open('bios511.cars2011');
	vartype=vartype(dsid,varnum(dsid,"&var"));
	if vartype = 'C' then vartype = 'Character';
	else if vartype = 'N' then vartype = 'Numeric';
	call symputx('vartype',vartype);
	varlabel=varlabel(dsid,varnum(dsid,"&var"));
	call symputx('varlabel',varlabel);
	rc = CLOSE(dsid);
run;

%PUT &vartype variable &var is labeled &varlabel;

%mend;

%carlabel(var=make);
%carlabel(var=reliability);

* Question 4;

%macro carlabel2(var=);

data _null_;
	dsid=open('bios511.cars2011');
	vartype=vartype(dsid,varnum(dsid,"&var"));
	if vartype = 'C' then vartype = 'Character';
	else if vartype = 'N' then vartype = 'Numeric';
	call symputx('vartype',vartype);
	varlabel=varlabel(dsid,varnum(dsid,"&var"));
	call symputx('varlabel',varlabel);
	
	file print;
	sentence = "&vartype variable &var is labeled &varlabel";
	PUT sentence;
	
	rc = CLOSE(dsid);
	
	%let var=;
	%let vartype=;
	%let varlabel=;
run;

%mend;

%carlabel2(var=make);
%carlabel2(var=reliability);

ODS PDF CLOSE;