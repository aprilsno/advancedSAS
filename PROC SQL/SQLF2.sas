* Define macros;
%LET job=SQLF2;
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
*  Job name:      SQLF2_saraob.sas   
*
*  Purpose:       Produce a list of participants with less than 3 or
*                 more than 14 days between screening and randomization.	
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set dr_669, ieca_669, rdma_669
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
proc sql number;
	title 'Participants with <3 or >14 days between screening and randomization date';
	select a.BID, a.psite label='Clinic', b.ieca0b label='Screening date', c.rdma0b label='Randomization date', 
		c.rdma0b-b.ieca0b as daysbetween label='Days between screening and randomization'
	from mets.dr_669 as a,
		mets.ieca_669 as b,
		mets.rdma_669 as c
	where a.bid=b.bid=c.bid and (calculated daysbetween<3 or calculated daysbetween>14);
quit;

* Close pdf file;
ODS PDF CLOSE;

* Close log file;
proc printto; 
run; 