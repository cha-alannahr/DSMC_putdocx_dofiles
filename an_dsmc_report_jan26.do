/*_______________________________________________________________________________

	STUDY:	TEST trial 
	PROGRAM NAME: an_dsmc_report_jan26.do
	PURPOSE: Create template in word for DSMC report
	DATE: 30 Jan 2026
	UPDATE: XX-XXX-XXXX
	AUTHOR: Alannah Rudkin
   ____________________________________________________________________________*/

clear all
version 19.5
capture log close

set more off
set graphics off

*set directory 
cd "$output"

log using log_2, replace

*** Identify dataset 
use test_trial_2.dta, clear

*** DEFINE MACROS
global today "`c(current_date)'"
di "$today"
global cut_date 14Jan2026

** Number enrolled at cut date 
count if random_date <= td($cut_date)
global totno=r(N)

**last patient enrolled date_enroll
preserve
gen negdate_enrol=-(random_date)
sort negdate_enrol
gen lastenrol= random_date if _n==1 
sum lastenrol if lastenrol!=.
local lastenrol :disp %tdDDMonCCYY r(mean) 
di "`lastenrol'"
restore

********************************************************************************
* Start a Word document
set docx_paramode on
capture putdocx clear
putdocx begin, pagenum() header(header1) footer(footer1) font("Calibri", 12, black )

putdocx paragraph, toheader(header1)
putdocx image ("C:\Users\alannah.rudkin\OneDrive - Murdoch Children's Research Institute\Other\Contracts and PD\PD\Stata 2026\Picture1.png"), linebreak
putdocx text ("Confidential"), underline(single)

putdocx paragraph, tofooter(footer1) halign(center)
putdocx text ("TEST trial DSMC OPEN REPORT Jan 2026                          Page ")
putdocx pagenumber

*putdocx save "TEST_OPEN_report_$today.docx", replace


* TITLE PAGE Text
putdocx paragraph, halign(center) 
putdocx text ("Data Safety Monitoring Committee (DSMC)"), bold font("Calibri", 14, black ) linebreak
putdocx text ("OPEN Report"), bold font("Calibri", 14, black ) linebreak
putdocx text ("Date of Report: $today"), bold font("Calibri", 14, black )
putdocx paragraph
putdocx paragraph  
putdocx paragraph, halign(center)
putdocx text ("Name of trial:"), bold font("Calibri", 12, black )
putdocx text (" TEST trial - Randomised cancer treatment trial for example purposes"), font("Calibri", 12, black ) 
putdocx paragraph, halign(center)
putdocx text ("Meeting:"), bold font("Calibri", 12, black ) linebreak
putdocx text ("2nd meeting - Jan 2026"), font("Calibri", 12, black ) 
putdocx paragraph, halign(center)
putdocx text ("Trial registration number: Clinicaltrials.gov Identifier NCTXXXXXX"), font("Calibri", 12, black) linebreak
putdocx text ("Based on: Protocol Version 1.0, Dated 1 August 2022"), font("Calibri", 12, black)
putdocx paragraph,halign(left)
putdocx text ("Investigators: "), bold font("Calibri", 11, black ) linebreak
putdocx text ("1.	Dr Bob Smith"), font("Calibri", 11, black ) linebreak
putdocx text ("2.	Dr Penny Hudson"), font("Calibri", 11, black ) linebreak

putdocx paragraph,halign(left)
putdocx text ("Study biostatistician:"), bold font("Calibri", 11, black )
putdocx text (" Alannah Rudkin"), font("Calibri", 11, black )
putdocx paragraph,halign(left)
putdocx text ("Data and Safety Monitoring Committee Report produced by:"), bold font("Calibri", 11, black ) linebreak
putdocx text ("Alannah Rudkin"), font("Calibri", 11, black ) linebreak
putdocx text ("Murdoch Children's Research Institute"), font("Calibri", 11, black ) linebreak
putdocx text ("Melbourne"), font("Calibri", 11, black ) 
putdocx paragraph
putdocx paragraph
putdocx paragraph,halign(center)
putdocx text ("This report is based on data up to and including $cut_date."),  font("Calibri", 11, black )
putdocx pagebreak

**** SUMMARY
putdocx paragraph, style(Heading2)
putdocx text ("Trial Summary"), bold font("Calibri Light", 14, black)
putdocx paragraph, font("Calibri", 11, black )
putdocx textblock begin
This trial is a multicentre, randomised, blinded, controlled trial with a parallel group design of treatment versus placebo.

The planned number of participants is 100 (50 per group).

With consent, eligible participants are randomly allocated using a web-based randomisation server, with stratification by cancer diagnosis type (brain, haematological, or gastrointestinal (GI)). 

The primary aim of the study is complete response at 28 days. 

Secondary aim of the study is lowered IgG level. 
putdocx textblock end
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("The current report includes all participants recruited and their follow-up data collected up to and including $cut_date, to allow for full data entry, data cleaning, data analysis, and report writing.  The $totno th participant was randomised on `lastenrol'." )
putdocx pagebreak

**** PROTOCOL AMENDMENTS
putdocx paragraph, style(Heading2)
putdocx text ("Protocol Amendments"), bold font("Calibri Light", 14, black)
putdocx paragraph, font("Calibri", 12, black ) 
putdocx textblock begin
Version 1.0, Dated 1 August 2022 is the most recent version of the protocol. No changes were made since the previous meeting. But if any changes were made this is where we'd put them. 
putdocx textblock end

**** SECTION 1
putdocx paragraph, style(Heading2)
putdocx text ("1. Recruitment"), bold font("Calibri Light", 14, black)
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("The planned sample size is 100 participants, of which 50 will be assigned to each of the 2 study arms."), linebreak
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("Figure 1 shows the accrual of the first $totno participants into the study up to the $cut_date, and Table 1 shows a breakdown of these participants by randomisation stratum."), linebreak
putdocx text ("Since the beginning of the study, there has been 1 issue related to the randomisation procedure. Details are listed below.")
putdocx paragraph
putdocx text ("Electronic randomisation system was down for 24hours on 06Jan2025. Unable to randomise in this time. Back-up paper/phone randomisation system now available.")

***Insert Table 1 
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("Table 1: Recruitment by randomisation stratum"), italic
import excel using table1.xlsx , clear
putdocx table table1 =  data(A B) , border(insideH, nil) border(start) border(insideV,nil) border(end) headerrow(1) layout(autofitw)
putdocx table table1(1,.), bold 
putdocx table table1(1,2) = ("Total"), bold 
putdocx table table1(2,1) = ("Number of Participants Randomised"), bold 
putdocx table table1(2,.), border(bottom)
putdocx table table1(.,2), halign(center)
putdocx table table1(6,.),  border(bottom)
putdocx paragraph 

***Insert graph 1 
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("Figure 1: Recruitment Rate as of $cut_date"), bold linebreak
putdocx image ("$output\Graph1.png") 

***Insert Table 2
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("Table 2: Participant disposition"), italic
import excel using table2.xlsx , clear
putdocx table table1 =  data(A B) , border(insideH, nil) border(start) border(insideV,nil) border(end) headerrow(1) layout(autofitw)
putdocx table table1(1,.), bold 
putdocx table table1(1,2) = ("Total"), bold 
putdocx table table1(2,1) = (""), bold 
putdocx table table1(2,2) = ("N= $totno")
putdocx table table1(2,.), border(bottom)
putdocx table table1(.,2), halign(center)
putdocx table table1(7,.),  border(bottom)
putdocx pagebreak

**** SECTION 2
putdocx paragraph, style(Heading2)
putdocx text ("2. Participant Characteristics"), bold font("Calibri Light", 14, black)
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("Table 3 shows the baseline characteristics of the $totno participants recruited to date."), linebreak
***Insert Table 3
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("Table 3: Baseline characteristics"), italic
import excel using table3.xlsx , clear
putdocx table table1 =  data(A B) , border(insideH, nil) border(start) border(insideV,nil) border(end) headerrow(1) layout(autofitw)
putdocx table table1(1,.), bold 
putdocx table table1(1,2) = ("Total"), bold 
putdocx table table1(2,1) = (""), bold 
putdocx table table1(2,2) = ("N= $totno")
putdocx table table1(2,.), border(bottom)
putdocx table table1(.,2), halign(center)
putdocx table table1(10,.),  border(bottom)

**** SECTION 3
putdocx paragraph, style(Heading2)
putdocx text ("3. Safety"), bold font("Calibri Light", 14, black)
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("3.1 Adverse events"), bold linebreak
putdocx text ("Table 4 shows a summary of all the adverse events (AEs) before $cut_date. Listing 1 lists adverse event (AE) details.")
***Insert Table 4
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("Table 4: Adverse Events"), italic
import excel using table4.xlsx , clear
putdocx table table1 =  data(A B) , border(insideH, nil) border(start) border(insideV,nil) border(end) headerrow(1) layout(autofitw) note("Highest grade reported if multiple grades reported for the same participant adverse event.", italic) 
putdocx table table1(1,.), bold 
putdocx table table1(1,2) = ("Total"), bold 
putdocx table table1(2,.),  border(bottom)
putdocx table table1(3,.), bold 
putdocx table table1(.,2), halign(center)
putdocx table table1(9,.),  border(bottom)
putdocx sectionbreak, landscape

** Listing 1 
use listing1.dta, clear 
putdocx paragraph
putdocx text ("Listing 1: Adverse events"), italic linebreak 
gsort  -grade 
putdocx table list1=  data(study_id ae_no soc_1 aeterm_1 grade sae related susar) , varnames border(insideH, nil) border(start) border(insideV,nil) border(end) headerrow(1) layout(autofitc)  
putdocx table list1(1,1)= ("Study ID")
putdocx table list1(1,2)= ("Adverse Event Number")
putdocx table list1(1,3)= ("Adverse Event - System Organ Class")
putdocx table list1(1,4)= ("Adverse Event term")
putdocx table list1(1,5)= ("Grade")
putdocx table list1(1,6)= ("Serious Adverse Event")
putdocx table list1(1,7)= ("Attribution to treatment")
putdocx table list1(1,8)= ("SUSAR")
putdocx table list1(1,.), bold border(bottom)
putdocx table list1(.,3/8), halign(center)
putdocx sectionbreak

*** saes 
use listing1.dta, clear 
count if sae==1 
local sae= r(N)

***Insert Table 5
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("Table 5: Serious Adverse Events"), italic
import excel using table5.xlsx , clear
putdocx table table1 =  data(A B) , border(insideH, nil) border(start) border(insideV,nil) border(end) headerrow(1) layout(autofitw) note("Highest grade reported if multiple grades reported for the same participant adverse event.", italic) 
putdocx table table1(1,2) = ("Total"), bold 
putdocx table table1(1,.), bold border(bottom)
putdocx table table1(3,.), bold 
putdocx table table1(.,2), halign(center)
putdocx table table1(9,.),  border(bottom)

***Insert Table 6
putdocx paragraph, font("Calibri", 12, black )
putdocx text ("Table 6: Mortality"), italic
import excel using table6.xlsx , clear
putdocx table table1 =  data(A B) , border(insideH, nil) border(start) border(insideV,nil) border(end) headerrow(1) layout(autofitw)
putdocx table table1(1,.), bold 
putdocx table table1(1,2) = ("Total"), bold 
putdocx table table1(2,1) = (""), bold 
putdocx table table1(2,2) = ("N= $totno")
putdocx table table1(2,.), border(bottom)
putdocx table table1(.,2), halign(center)
putdocx table table1(3,.),  border(bottom)

putdocx describe

** Save report 
* Save document	
putdocx save "TEST_OPEN_report_$today.docx", replace


