/*_______________________________________________________________________________

	STUDY:	TEST trial 
	PROGRAM NAME: an_dsmc_tables_jan26.do
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

log using log_1, replace

*** Identify dataset 
use test_trial_2.dta, clear

*** DEFINE MACROS
global today "`c(current_date)'"
di "$today"
global cut_date 14Jan2026

********************************************************************************
** Recruitment **
********************************************************************************
** Figure 1: Number of participants randomised to date compared with projected recruitment
********************************************************************************
gen month = 1 if random_date < td(01/01/2025)   // dec2024
replace month = 2 if (random_date > td(31/12/2024)) & (random_date < td(1/02/2025))   //jan2025
replace month = 3 if (random_date > td(31/01/2025)) & (random_date < td(1/03/2025))   //feb2025
replace month = 4 if (random_date > td(28/02/2025)) & (random_date < td(1/04/2025))   //mar2025
replace month = 5 if (random_date > td(31/03/2025)) & (random_date < td(1/05/2025))   //apr2025
replace month = 6 if (random_date > td(30/04/2025)) & (random_date < td(1/06/2025))   //may2025
replace month = 7 if (random_date > td(31/05/2025)) & (random_date < td(1/07/2025))   //jun2025
replace month = 8 if (random_date > td(30/06/2025)) & (random_date < td(1/08/2025))   //jul2025

** labels for months 
label define month1 0 "Recruitment start" 1 "Dec 2024" 2 "Jan 2025" 3 "Feb 2025" 4 "Mar 2025" 5 "Apr 2025" 6 "May 2025" 7 "Jun 2025" 8 " Jul 2025"
label values month month1
tab month, label 

**  culm freq
by month, sort: gen freq = _N 
sort month random_date

** keep first of month
by month: gen tag = freq if _n== 1 
gen cumfreq = sum(tag)
lab var cumfreq "Actual enrolment"
tabdisp month, cell(freq cumfreq)

*** Projected recruitment for this trial is 65
foreach var of varlist month{
gen expct=`var'*(65/8)
}
gen trgt= round(expct, 1)
lab var trgt "Target Enrolment"

sort month tag
bysort month : gen tag_months = 1 if _n == 1 

insobs 1, before(1)
foreach var of varlist month freq cumfreq trgt expct {
	replace `var'=0 if _n==1
}

foreach var of varlist tag tag_months {
	replace `var'=1 if _n==1
}

** Graph **
preserve
keep month freq cumfreq trgt tag 

twoway (line cumfreq month if freq!=. , lpat(dash)) ///
  (lfit trgt month if freq!=. , lpat(dash)) , legend(label(1 "Actual enrolment")  label(2 "Target enrolment") size(*0.8)) xlabel(0(1)8, valuelabel labsize(vsmall) angle(45)) ylabel(0(10)70 ,labsize(vsmall)) ytitle("Patients enrolled") xtitle("Month of enrolment") graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white))
	graph export "Graph1.png", as(png) name("Graph") replace width(1500)
	
	restore
	
	
 drop if month==0
********************************************************************************
** Table 1: Recruitment by randomisation stratum - type 
********************************************************************************
**make table
count if random_date!=.
tab type if random_date!=.
dtable i.type if random_date!=.
collect preview
collect export table1.xlsx, replace

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
dtable 1.base_data 1.pri_out 1.sec_out 1.withdrawn 1.ltfu if random_date!=.
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
collect export table2.xlsx, replace

********************************************************************************
** Table 3 : Baseline Characteristics
********************************************************************************
dtable age i.gender i.type if random_date!=., nformat(%3.1fc mean sd) 
collect label levels var age "Patient age (years)", modify
collect preview
collect export table3.xlsx, replace

********************************************************************************
** Table 4 : Adverse Events 
********************************************************************************
encode soc , gen (soc_1)
encode aeterm , gen (aeterm_1)
gen ae=1 if aeterm_1!=.

bysort study_id (random_date) : gen pat_id=1 if _n==1
replace ae_no=0 if ae_no==. & pat_id==1
replace ae_no=. if ae_no==2

dtable 1.pat_id 1.ae_no ae i.soc_1, nosample factor(pat_id soc_1, stat(fvfreq)) continuous(ae, stat(count))
collect style header pat_id , title(hide)
collect label levels pat_id 1 "Number of Participants Randomised", modify
collect style header ae_no , title(hide)
collect label levels ae_no 1 "Participants who had at least one AE", modify
collect label levels var ae "Number of AEs:", modify
collect label levels var soc_1 "Number of AEs by category:" , modify
collect preview
collect export table4.xlsx, replace

********************************************************************************
** Table 5 : Serious Adverse Events 
********************************************************************************
replace sae=0 if sae==. & pat_id==1
replace related=. if sae!=1

gen sae_no = 1 if sae==1
gen sae_type= soc_1 if sae==1
lab val sae_type soc_1
replace susar=. if sae!=1

dtable 1.sae sae_no i.related i.sae_type 1.susar , nosample continuous(sae_no, stat(count))
collect style header sae , title(hide)
collect label levels sae 1 "Participants who experienced Serious Adverse Events", modify
collect label levels var sae_no "Total number of SAEs", modify
collect label levels var related "Relationship of the SAE to the trial" , modify
collect label levels related 1 "Possibly related", modify
collect label levels var sae_type "SAE category" , modify
collect style header susar , title(hide)
collect label levels susar 1 "Suspected Unexpected Serious Adverse Reaction", modify
collect preview
collect export table5.xlsx, replace

********************************************************************************
** Table 6 : Mortality 
********************************************************************************
dtable 1.died if pat_id==1
collect style header died , title(hide)
collect label levels died 1 "Participants died on trial", modify
collect preview
collect export table6.xlsx, replace

********************************************************************************
** Table 7 : Protocol Deviations 
********************************************************************************
encode pd_type, gen(pd_type1)
gen pd1=pd 
replace pd1=0 if pat_id==1 & pd==.

tab pd1 
tab pd_type1
gen pd2=pd

dtable 1.pd1 1.pd2 i.pd_type1, nosample factor(pd2, stat(fvfreq))
collect style header pd1 , title(hide)
collect label levels pd1 1 "Participants with a protocol deviation", modify
collect style header pd2 , title(hide)
collect label levels pd2 1 "Number of protocol deviations", modify
collect preview
collect export table7.xlsx, replace

********************************************************************************
**Listing 1 : Adverse Events 
********************************************************************************
keep if ae_no>0
replace ae_no=2 if ae_no==.
keep study_id ae_no soc_1 aeterm_1 grade sae related susar
order study_id ae_no soc_1 aeterm_1 grade sae related susar
save listing1.dta, replace 
