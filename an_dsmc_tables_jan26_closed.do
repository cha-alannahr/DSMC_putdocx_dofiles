/*_______________________________________________________________________________

	STUDY:	TEST trial 
	PROGRAM NAME: an_dsmc_tables_jan26_closed.do
	PURPOSE: Create tables and graphs for DSMC REPORT Jan2026 - data up to XXX Jan 2026
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

log using log_3, replace

*** Identify dataset 
use test_trial_2.dta, clear

*** DEFINE MACROS
global today "`c(current_date)'"
di "$today"
global cut_date 14Jan2026

********************************************************************************
*****CLOSED report tables
********************************************************************************
/*
Note to statistician - please replace dummy_arm variable with actual randomised drug/treatment
*/
********************************************************************************
rename drug dummy_arm  //changing the variable name from the default data to make this clear
label var dummy_arm "Trial arm"

********************************************************************************
** Table 1: Recruitment by randomisation stratum - type 
********************************************************************************
**make table
count if random_date!=.
tab type if random_date!=.
dtable i.type if random_date!=. , by(dummy_arm)
collect preview
collect export table1_closed.xlsx, replace

********************************************************************************
** Table 2: Participant disposition
********************************************************************************
*** baseline data avaiable 
*** primary outcome data available 
*** Secondary outcome available 
*** Excluded / withdrawn from study 

** baseline 
gen base_data=1 if age!=.
replace base_data=0 if age==. & random_date!=.

** Primary outcome assessed CR
gen pri_out= 1 if cr!=. 
replace pri_out= 0 if cr==. & random_date!=.

**secondary outcome - IgG
gen sec_out= 1 if igg!=. 
replace sec_out= 0 if igg==. & random_date!=.

**withdrawn/ltfu 
foreach var of varlist withdrawn ltfu {
	replace `var'= 0 if `var'==. & random_date!=.
}

**** make table 
dtable 1.base_data 1.pri_out 1.sec_out 1.withdrawn 1.ltfu if random_date!=. , by(dummy_arm)
collect style header base_data , title(hide)
collect label levels base_data 1 "Baseline Data Available", modify
collect style header pri_out , title(hide)
collect label levels pri_out 1 "Primary Outcome Data Available", modify
collect style header sec_out , title(hide)
collect label levels sec_out 1 "Secondary Outcome Data Available", modify
collect style header withdrawn , title(hide)
collect label levels withdrawn 1 "Withdrawn from the study", modify
collect style header ltfu , title(hide)
collect label levels ltfu 1 "Lost to follow up", modify
collect preview
collect export table2_closed.xlsx, replace

********************************************************************************
** Table 3 : Baseline Characteristics
********************************************************************************
dtable age i.gender i.type if random_date!=., nformat(%3.1fc mean sd)  by(dummy_arm)
collect label levels var age "Patient age (years)", modify
collect preview
collect export table3_closed.xlsx, replace

********************************************************************************
** Table 4 : Adverse Events 
********************************************************************************
encode soc , gen (soc_1)
encode aeterm , gen (aeterm_1)
gen ae=1 if aeterm_1!=.

bysort study_id (random_date) : gen pat_id=1 if _n==1
replace ae_no=0 if ae_no==. & pat_id==1
replace ae_no=. if ae_no==2

bysort study_id (pat_id) : replace dummy_arm= dummy_arm[_n-1] if dummy_arm==.

dtable 1.pat_id 1.ae_no ae i.soc_1, nosample factor(pat_id soc_1, stat(fvfreq)) continuous(ae, stat(count))  by(dummy_arm)
collect style header pat_id , title(hide)
collect label levels pat_id 1 "Number of Participants Randomised", modify
collect style header ae_no , title(hide)
collect label levels ae_no 1 "Participants who had at least one AE", modify
collect label levels var ae "Number of AEs:", modify
collect label levels var soc_1 "Number of AEs by category:" , modify
collect preview
collect export table4_closed.xlsx, replace

********************************************************************************
** Table 5 : Serious Adverse Events 
********************************************************************************
replace sae=0 if sae==. & pat_id==1
replace related=. if sae!=1

gen sae_no = 1 if sae==1
gen sae_type= soc_1 if sae==1
lab val sae_type soc_1
replace susar=. if sae!=1

dtable 1.sae sae_no i.related i.sae_type 1.susar , nosample continuous(sae_no, stat(count))  by(dummy_arm)
collect style header sae , title(hide)
collect label levels sae 1 "Participants who experienced Serious Adverse Events", modify
collect label levels var sae_no "Total number of SAEs", modify
collect label levels var related "Relationship of the SAE to the trial" , modify
collect label levels related 1 "Possibly related", modify
collect label levels var sae_type "SAE category" , modify
collect style header susar , title(hide)
collect label levels susar 1 "Suspected Unexpected Serious Adverse Reaction", modify
collect preview
collect export table5_closed.xlsx, replace

********************************************************************************
** Table 6 : Mortality 
********************************************************************************
dtable 1.died if pat_id==1,  by(dummy_arm)
collect style header died , title(hide)
collect label levels died 1 "Participants died on trial", modify
collect preview
collect export table6_closed.xlsx, replace

********************************************************************************
** Table 7 : Protocol Deviations 
********************************************************************************
encode pd_type, gen(pd_type1)
gen pd1=pd 
replace pd1=0 if pat_id==1 & pd==.

tab pd1 
tab pd_type1
gen pd2=pd

dtable 1.pd1 1.pd2 i.pd_type1, nosample factor(pd2, stat(fvfreq))  by(dummy_arm)
collect style header pd1 , title(hide)
collect label levels pd1 1 "Participants with a protocol deviation", modify
collect style header pd2 , title(hide)
collect label levels pd2 1 "Number of protocol deviations", modify
collect preview
collect export table7_closed.xlsx, replace

********************************************************************************
**Listing 1 : Adverse Events 
********************************************************************************
keep if ae_no>0
replace ae_no=2 if ae_no==.
keep study_id dummy_arm ae_no soc_1 aeterm_1 grade sae related susar
order study_id dummy_arm ae_no soc_1 aeterm_1 grade sae related susar
save listing1_closed.dta, replace 
