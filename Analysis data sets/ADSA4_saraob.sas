* Define macros;
%LET job=ADSA4;
%LET onyen=saraob;
%LET outdir=/home/u49497589/BIOS669/Output/ADSA;

* Open a log file;
proc printto log="/home/u49497589/BIOS669/Logs/ADSA/&job._&onyen..log" new; 
run; 

*********************************************************************
*  Assignment:    ADSA                                         
*                                                                    
*  Description:   Create an analysis data set
*
*  Name:          Sara O'Brien
*
*  Date:          2/16/23                                       
*------------------------------------------------------------------- 
*  Job name:      ADSA4_saraob.sas   
*
*  Purpose:       Use exclude_data_using_conditions macro
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         chd_manu data set created in ADSA2
*
*  Output:        RTF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;

FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

* Macro being used;
%include "/home/u49497589/my_shared_file_links/klh52250/macros/Exclude_data_using_conditions_for_669.sas";

* Libref for manuscript dataset from ADSA3;
LIBNAME adsa "/home/u49497589/BIOS669/Output/ADSA";

* Call macro;
%exclude_data_using_conditions(_DATA_IN=adsa.chd_merge,
_USE_PRIMARY_EXCLUSIONS=Yes,
_PRIMARY_EXCLUSIONS = race ^in ('B','W') ~ ^((Gender='M' and 600<TotCal<4200) |
(Gender='F' and 500<TotCal<3600)),
_SECONDARY_EXCLUSIONS = missing(BMI) ~ missing(DietMg) ~ missing(SerumMg),
_PREDICTORS = race gender age BMI prevalentCHD,
_CATEGORICAL = race gender prevalentCHD,
_FOOTNOTE =%str(&Job &job._&onyen run on &sysdate at &systime -- produced by macro Exclude_data_using_conditions),
_ID = ID,
_TITLE1 = 'Exclusions in the manuscript dataset'); 