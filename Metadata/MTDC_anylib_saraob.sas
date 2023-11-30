* Define macros;
%LET job=MTDC_anylib;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/MTDC/&job._&onyen..log" new; 
run;

*********************************************************************
*  Assignment:    MTDC_anylib                                    
*                                                                    
*  Description:   Metadata Assignment C 
*
*  Name:          Sara O'Brien
*
*  Date:          4/17/23                                       
*------------------------------------------------------------------- 
*  Job name:      MTDC_anylib_saraob.sas   
*
*  Purpose:       Third collection of exercises with SAS metadata.
*				  This macro can produce a codebook for every dataset
*				  in a referenced library (MTDC extension 3)
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set
*
*  Output:        rtf file    
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

LIBNAME METS "/home/u49497589/my_shared_file_links/klh52250/METS" access=readonly;

ODS RTF FILE="&outdir/Output/MTDC/&job._&onyen..rtf" STARTPAGE=NO;

* Define formats for character variables (for METS.DEMA_669 only);		
proc format;
	value $DEMA2_
		'M' = 'M (Male)'
		'F' = 'F (Female)';
	
	value $DEMA4_
		'Y' = 'Y (Yes)'
		'N' = 'N (No)';
		
	value $DEMA5_
		'M' = 'M (Married)'
		'W' = 'W (Widowed)'
		'D' = 'D (Divorced)'
		'S' = 'S (Separated)'
		'N' = 'N (Never Married)';
		
	value $DEMA7_
		'A' = 'A (0 to 1 days)'
		'B' = 'B (2 to 3 days)'
		'C' = 'C (4 to 5 days)'
		'D' = 'D (6 to 7 days)';
	
	value $DEMA9_
		'Y' = 'Y (Yes)'
		'N' = 'N (No)';
run;

%macro anydatadic(lib=);
* List of all datasets in library;
proc sql noprint;
	select unique memname into :dslist separated by ' '
	from dictionary.columns
	where libname=upcase("&lib");
quit;

proc odstext; 
	p "Codebook for &lib" / style=[fontsize=11pt fontweight=bold fontfamily=Arial]; 
run;

%let j=1;

%do %until (%scan(&dslist,&j)=);
	
	%let ds = %scan(&dslist,&j);
	
	proc odstext; 
		p "Dataset &ds" / style=[fontsize=11pt fontweight=bold fontfamily=Arial]; 
	run;
	
	proc sql noprint;
		select name into :varlist separated by ' '
		from dictionary.columns
		where libname=upcase("&lib") and memname=upcase("&ds")
		order by name;
	quit;
	
	%let i=1;
		
		%do %until (%scan(&varlist,&i)=);
			%let var = %scan(&varlist,&i);
			
			* Put type/format of specified var to macro;
			data _null_;
				set &lib..&ds;
				varformat=VFORMAT(&var);
				call symputx("varformat",varformat);
				vartype=VTYPE(&var);
				call symputx("vartype",vartype);
				varlabel=VLABEL(&var);
				call symputx("varlabel",varlabel);
			run;
		
			* Put count of unique values to macro;
			proc sql noprint;
				select count(distinct &var) into :count
				from &lib..&ds;
			quit;
			%put &var &varlabel &varformat &vartype &count;
			
			* Numeric date vars;
			%if &vartype=N and (&varformat=DATE9. or &varformat=MMDDYY10.) %then %do;
				ods exclude all;
				proc means data=&lib..&ds N NMISS MIN MAX;
					var &var;
					ods output summary=want;
				run;
				ods exclude none;
				
				data want;
					set want;
					min = put(&var._min, mmddyy10.);
					max = put(&var._max, mmddyy10.);
					varrange = cat(min, " - ", max);
				run;
				
		      	proc report data=want;
					columns ("&var: &varlabel" &var._n &var._nmiss varrange);
					define &var._nmiss / 'Missing';
					define varrange / 'Range';
				run;
			%end;
			
			* Discrete character/numeric vars;
			%if (&vartype=N or &vartype=C) and &count<=5 and &varformat^=DATE9. and &varformat^=MMDDYY10. %then %do;
				ods exclude all;
				proc freq data=&lib..&ds;
					tables &var / nocum nopercent;
					ods output OneWayFreqs=want;
				run;
				ods exclude none;
				
				%if  %sysfunc(cexist(work.formats.&var._.formatc)) %then %do;
					proc report data=want;
						columns ("&var: &varlabel" &var frequency);
						define &var / 'Value' format=$&var._.;
						define frequency / 'N';
					run;
				%end;
				
				proc report data=want;
					columns ("&var: &varlabel" &var frequency);
					define &var / 'Value';
					define frequency / 'N';
				run;
			%end;
			
			* Continuous numeric vars;
			%if &vartype=N and &count>5 and &varformat^=DATE9. and &varformat^=MMDDYY10. %then %do;
				ods exclude all;
				proc means data=&lib..&ds N NMISS MEAN MIN MAX;
					var &var;
					ods output summary=want;
				run;
				ods exclude none;
				
				data want;
					set want;
					mean = put(&var._mean, 5.2);
					stats = cat("Mean=", mean, " Min=", &var._min, " Max=", &var._max);
				run;
				
		      	proc report data=want;
					columns ("&var: &varlabel" &var._n &var._nmiss stats);
					define &var._nmiss / 'Missing';
					define stats / 'Summary Statistics';
				run;
			%end;
			
			* Character var with many distinct values;
			%if &vartype=C and &count>5 %then %do;
				ods startpage=now; /*prints to new page instead of directly underneath any previous output*/
			    proc odstext; 
			        p "Variable &var: &varlabel not tabulated--all or most values unique." / style=[fontsize=11pt fontweight=bold fontfamily=Arial]; 
			    run;
			%end;
			
		%let i = %eval(&i+1);
			
		%end;
	
	%let j = %eval(&j+1);
	
	%end;

%mend;

%anydatadic(lib=mets);

ODS RTF CLOSE;