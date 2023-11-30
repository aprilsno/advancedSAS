*********************************************************************
*  Assignment:    REFB                                         
*                                                                    
*  Description:   Second collection of SAS refresher problems using 
*                 METS study data
*
*  Name:          Sara O'Brien
*
*  Date:          1/16/23                                       
*------------------------------------------------------------------- 
*  Job name:      REFB2_saraob.sas   
*
*  Purpose:       Produce a list of forms filled out at unscheduled
*				  visits.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set uvfa, cgia, aesa, saea, vsfa, auqa,
*				  laba, bsfa, smfa 
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

* Define macros;
%LET job=REFB3;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669;

* Open a log file;
proc printto log="&outdir/Logs/&job._&onyen..log" new; 
run; 

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Pull in METS data;
LIBNAME mets "~/my_shared_file_links/klh52250/METS" access=readonly;

* Create PDF output file;
ODS PDF FILE="&outdir/Output/&job._&onyen..pdf" STYLE=JOURNAL;

* Create a merged data set of forms filled out at unscheduled visits;
*proc sort data;

data unscheduledforms;
	merge mets.uvfa_669 (in=unscheduled keep=BID visit uvfa0b uvfa1a uvfa1b uvfa1c uvfa1d form rename=(uvfa0b=visitdate form=form1) ) 
		mets.cgia_669 (keep=BID visit cgia0b form rename=(cgia0b=visitdate form=form2))
		mets.aesa_669 (keep=BID visit aesa0b form rename=(aesa0b=visitdate form=form3))
		mets.saea_669 (keep=BID visit saea0b form rename=(saea0b=visitdate form=form4))
		mets.vsfa_669 (keep=BID visit vsfa0b form rename=(vsfa0b=visitdate form=form5))
		mets.auqa_669 (keep=BID visit auqa0b form rename=(auqa0b=visitdate form=form6))
		mets.laba_669 (keep=BID visit laba0b form rename=(laba0b=visitdate form=form7))
		mets.bsfa_669 (keep=BID visit bsfa0b form rename=(bsfa0b=visitdate form=form8))
		mets.smfa_669 (keep=BID visit smfa0b form rename=(smfa0b=visitdate form=form9));
	by BID visit visitdate;
	if unscheduled;
	length forms $100;
	forms = catx(', ',form1,form2,form3,form4,form5,form6,form7,form8,form9);
	drop form1 form2 form3 form4 form5 form6 form7 form8 form9;
run;

proc format;
	value $yn
		'1'='Yes';
run;	

title1 'Forms filled out at unscheduled visits';
proc print data=unscheduledforms noobs label;
	format visitdate mmddyy10. uvfa1a uvfa1b uvfa1c uvfa1d $yn.;
	label BID='Participant ID'
		forms='Forms filled out at unscheduled visit'
		uvfa1a='Reason for visit: change in psychiatric symptoms'
		uvfa1b='Reason for visit: drug tolerability adverse event'
		uvfa1c='Reason for visit: change in medical status'
		uvfa1d='Reason for visit: medication changes or adjustment';
run;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 
