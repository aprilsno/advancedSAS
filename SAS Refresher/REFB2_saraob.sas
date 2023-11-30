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
*  Purpose:       Produce a list of participants with lab measurement
*				  values outside of the reasonable range.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set laba_669
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

* Define macros;
%LET job=REFB2;
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

* Create data set of participants with unreasonable sodium value;
data unreasonablesodium;
	set mets.laba_669;
	length issue $20;
	where ^missing(laba11) and (laba11<130 or laba11>150);
	if laba11<130 then issue='Unreasonably low';
	if laba11>150 then issue='Unreasonably high';
	keep BID visit laba11 issue;
run;

* Print unreasonable sodium data set;
proc print data = unreasonablesodium noobs label;
	title1 'Participants with sodium level outside of 130 – 150 (mmol/L) range';
	label BID='Participant ID' Visit='Visit' laba11='Sodium level' issue='Issue';
run;

* Create data set of participants with unreasonable calcium value;
data unreasonablecalcium;
	set mets.laba_669;
	length issue $20;
	where ^missing(laba15) and (laba15<8 or laba15>10.5);
	if laba15<8 then issue='Unreasonably low';
	if laba15>10.5 then issue='Unreasonably high';
	keep BID visit laba15 issue;
run;

* Print unreasonable calcium data set;
proc print data = unreasonablecalcium noobs label;
	title1 'Participants with calcium level outside of 8 – 10.5 (mg/dL) range';
	label BID='Participant ID' Visit='Visit' laba15='Calcium level' issue='Issue';
run;

* Create data set of participants with unreasonable protein value;
data unreasonableprotein;
	set mets.laba_669;
	length issue $20;
	where ^missing(laba16) and (laba16<6 or laba16>9);
	if laba16<6 then issue='Unreasonably low';
	if laba16>9 then issue='Unreasonably high';
	keep BID visit laba16 issue;
run;

* Print unreasonable protein data set;
proc print data = unreasonableprotein noobs label;
	title1 'Participants with protein level outside of 6 – 9 (g/dL) range';
	label BID='Participant ID' Visit='Visit' laba16='Protein level' issue='Issue';
run;

* Create data set of participants with unreasonable HDL value;
data unreasonablehdl;
	set mets.laba_669;
	length issue $20;
	where ^missing(laba5) and laba5<25;
	if laba5<25 then issue='Unreasonably low';
	keep BID visit laba5 issue;
run;

* Print unreasonable HDL data set;
proc print data = unreasonablehdl noobs label;
	title1 'Participants with HDL level below 25 (mg/dL)';
	label BID='Participant ID' Visit='Visit' laba5='HDL level' issue='Issue';
run;

* Create data set of participants with unreasonable LDL value;
data unreasonableldl;
	set mets.laba_669;
	length issue $20;
	where ^missing(laba6) and laba6>200;
	if laba6>200 then issue='Unreasonably high';
	keep BID visit laba6 issue;
run;

* Print unreasonable HDL data set;
proc print data = unreasonableldl noobs label;
	title1 'Participants with LDL level above 200 (mg/dL)';
	label BID='Participant ID' Visit='Visit' laba6='LDL level' issue='Issue';
run;

* Macro for the 5 analytes;

%macro unreasonable(analyte=, value=, min=, max=, range=);

	data unreasonabledata;
		set mets.laba_669;
		length issue $20;
		%if &min ne . and &max ne . %then %do;
			where ^missing(&value) and (&value<&min or &value>&max);
				if &value<&min then issue='Unreasonably low';
				if &value>&max then issue='Unreasonably high';
		%end;
		
		%else %if &max=. %then %do;
			where ^missing(&value) and &value<&min;
			if &value<&min then issue='Unreasonably low';
		%end;
		
		%else %if &min=. %then %do;
			where ^missing(&value) and &value>&max;
			if &value>&max then issue='Unreasonably high';
		%end;
		
		keep BID visit &value issue;
	run;

	proc print data = unreasonabledata noobs label;
		title1 "Participants with &analyte level outside of &range range (generated with macros)";
		label BID='Participant ID' Visit='Visit' &value="&analyte level" issue='Issue';
	run;
	
%mend;

* Execute the macro unreasonable;
%unreasonable(analyte=Sodium, value=laba11, min=130, max=150, range=130 – 150 (mmol/L));
%unreasonable(analyte=Calcium, value=laba15, min=8, max=10.5, range=8 – 10.5 (mg/dL));
%unreasonable(analyte=Protein, value=laba16, min=6, max=9, range=6 – 9 (g/dL));
%unreasonable(analyte=HDL, value=laba5, min=25, max=., range=25 or above (mg/dL) [only unreasonable if below 25]);
%unreasonable(analyte=LDL, value=laba6, min=., max=200, range=200 or below (mg/dL) [only unreasonable if above 200]);

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 
