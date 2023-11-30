* Define macros;
%LET job=SQLF3;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/SQLF/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    SQLF                                         
*                                                                    
*  Description:   Sixth set of SQL problems using METS datasets (REFA
*				  and REFB with SQL)
*
*  Name:          Sara O'Brien
*
*  Date:          2/6/23                                       
*------------------------------------------------------------------- 
*  Job name:      SQLF3_saraob.sas   
*
*  Purpose:       Produce a report of forms filled out at unscheduled
*				  visits.	
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data sets uvfa, cgia, aesa, saea, vsfa, auqa,
*				  laba, bsfa, smfa  
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Create PDF output file;
ODS PDF FILE="&outdir/Output/SQLF/&job._&onyen..pdf" STYLE=JOURNAL;

* Pull in METS data;
LIBNAME mets "~/my_shared_file_links/klh52250/METS" access=readonly;

* Create formats for visit reason variables;
proc format;
	value $uvfa1a
		'1'='Change in psychiatric symptoms';
	value $uvfa1b
		'1'='Drug tolerability adverse event';
	value $uvfa1c
		'1'='Change in medical status';
	value $uvfa1d
		'1'='Medication changes or adjustment';	
run;

* Run proc sql;
proc sql;
	title 'Forms filled out at unscheduled visits';
	select uvfa.bid, uvfa.visit, uvfa.uvfa0b format=mmddyy10., catx(', ', put(uvfa.uvfa1a, $uvfa1a.), put(uvfa.uvfa1b, $uvfa1b.),
	put(uvfa.uvfa1c, $uvfa1c.), put(uvfa.uvfa1d, $uvfa1d.)) as reason label='Reason for unscheduled visit',
		catx(', ', uvfa.form, cgia.form, aesa.form, saea.form, vsfa.form, auqa.form, laba.form, 
		bsfa.form, smfa.form) as forms label='Forms filled out at unscheduled visit'
	from mets.uvfa_669 as uvfa
		left join mets.cgia_669 as cgia
			on uvfa.bid=cgia.bid and uvfa.visit=cgia.visit and uvfa.uvfa0b=cgia.cgia0b
		left join mets.aesa_669 as aesa
			on uvfa.bid=aesa.bid and uvfa.visit=aesa.visit and uvfa.uvfa0b=aesa.aesa0b
		left join mets.saea_669 as saea
			on uvfa.bid=saea.bid and uvfa.visit=saea.visit and uvfa.uvfa0b=saea.saea0b
		left join mets.vsfa_669 as vsfa
			on uvfa.bid=vsfa.bid and uvfa.visit=vsfa.visit and uvfa.uvfa0b=vsfa.vsfa0b
		left join mets.auqa_669 as auqa
			on uvfa.bid=auqa.bid and uvfa.visit=auqa.visit and uvfa.uvfa0b=auqa.auqa0b
		left join mets.laba_669 as laba
			on uvfa.bid=laba.bid and uvfa.visit=laba.visit and uvfa.uvfa0b=laba.laba0b
		left join mets.bsfa_669 as bsfa
			on uvfa.bid=bsfa.bid and uvfa.visit=bsfa.visit and uvfa.uvfa0b=bsfa.bsfa0b
		left join mets.smfa_669 as smfa
			on uvfa.bid=smfa.bid and uvfa.visit=smfa.visit and uvfa.uvfa0b=smfa.smfa0b;
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 
