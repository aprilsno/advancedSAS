* Define macros;
%LET job=SQLF4;
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
*  Job name:      SQLF4_saraob.sas   
*
*  Purpose:       	
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data sets  
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

* Run proc sql;
proc sql;
	title1 'Forms filled out at unscheduled visits';
	title2 'on or 1 day before/after the UVF visit date';
	select uvfa.bid, uvfa.visit, 
	uvfa.uvfa0b format=mmddyy10. label='UVF Visit Date', 
	cgia.cgia0b format=mmddyy10. label='CGI Visit Date', 
	aesa.aesa0b format=mmddyy10. label='AES Visit Date', 
	saea.saea0b format=mmddyy10. label='SAE Visit Date', 
	vsfa.vsfa0b format=mmddyy10. label='VSF Visit Date', 
	auqa.auqa0b format=mmddyy10. label='AUQ Visit Date', 
	laba.laba0b format=mmddyy10. label='LAB Visit Date', 
	bsfa.bsfa0b format=mmddyy10. label='BSF Visit Date', 
	smfa.smfa0b format=mmddyy10. label='SMF Visit Date'
	from mets.uvfa_669 as uvfa
		left join mets.cgia_669 as cgia
			on uvfa.bid=cgia.bid and uvfa.visit=cgia.visit and cgia.cgia0b-uvfa.uvfa0b in (-1,0,1)
		left join mets.aesa_669 as aesa
			on uvfa.bid=aesa.bid and uvfa.visit=aesa.visit and aesa.aesa0b-uvfa.uvfa0b in (-1,0,1)
		left join mets.saea_669 as saea
			on uvfa.bid=saea.bid and uvfa.visit=saea.visit and saea.saea0b-uvfa.uvfa0b in (-1,0,1)
		left join mets.vsfa_669 as vsfa
			on uvfa.bid=vsfa.bid and uvfa.visit=vsfa.visit and vsfa.vsfa0b-uvfa.uvfa0b in (-1,0,1)
		left join mets.auqa_669 as auqa
			on uvfa.bid=auqa.bid and uvfa.visit=auqa.visit and auqa.auqa0b-uvfa.uvfa0b in (-1,0,1)
		left join mets.laba_669 as laba
			on uvfa.bid=laba.bid and uvfa.visit=laba.visit and laba.laba0b-uvfa.uvfa0b in (-1,0,1)
		left join mets.bsfa_669 as bsfa
			on uvfa.bid=bsfa.bid and uvfa.visit=bsfa.visit and bsfa.bsfa0b-uvfa.uvfa0b in (-1,0,1)
		left join mets.smfa_669 as smfa
			on uvfa.bid=smfa.bid and uvfa.visit=smfa.visit and smfa.smfa0b-uvfa.uvfa0b in (-1,0,1);
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 