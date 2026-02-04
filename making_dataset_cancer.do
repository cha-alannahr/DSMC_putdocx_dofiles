********* Adding to the Stata cancer dataset for a DSMC example *****************

*** import cancer dataset from Stata 
clear all
use https://www.stata-press.com/data/r19/cancer, clear

*** fix treatments 
set seed 12345
replace drug= (runiform() <= 0.5)

** treatment labels 
label define trtlbl 0 "Placebo" 1 "Intervention"
label val drug trtlbl 

** make a study_id 
gen study_id = _n 

***** enrolment date 
local start_date = mdy(12, 1, 2024)
local end_date = mdy(12, 31, 2025)

generate random_date = `start_date' if study_id==1
replace random_date = random_date[_n-1] +  (runiform()*10) if study_id!=1
format random_date %td

** make study time missing if not feasible 
local today = mdy(01, 14, 2026)
gen today = `today'
format today %td
gen double diff= datediff(random_date,today,"month") 
replace studytime=. if studytime>diff
replace _t=. if studytime==.

replace studytime = round(diff/2,1) if _d==1
replace _t= studytime if _t==.

*** make withdrawn option 
gen withdrawn=1 if studytime!=. & _d!=1 

** make lost to follow up 
gen ltfu= 1 if studytime==. & diff>8

***** make other demographics 
** gender 
gen gender = (runiform() <= 0.5)

** gender labels 
label define genlbl 0 "Male" 1 "Female"
label val gender genlbl 

*** cancer type 
gen type = runiformint(1, 3)
** labels 
label define typelbl 1 "GIT" 2 "Brain" 3 "Haematological"
label val type typelbl

** Outcomes 
**** complete response 
gen cr = (runiform() <= 0.5)
label define crlbl 0 "No" 1 "Yes"
label val cr crlbl 
label var cr "Complete Response"
replace cr=. if _t==.

** immunoglobin G 
gen igg= runiformint(600,1600)
label var igg "Immunoglobin G"

******* Make some adverse events variables 
gen soc=""
lab var soc "System Organ Class"

gen aeterm=""
lab var aeterm "Adverse event term"

gen grade=. 
lab var grade "Grade"

gen sae=. 
lab var sae "Serious Adverse Event"

gen related=. 
lab var related "Related to trial"

gen susar=.
lab var susar "Suspected Unexpected Serious Adverse Reaction"

gen ssi=.
lab var ssi "Significant Safety Issues"

gen usm=.
lab var usm "Urgent Safety Measure"

*** make adverse events 
*** generate five random ids for aes 
gen rand_key = runiform()
sort rand_key
replace rand_key=. if _n > 5
replace rand_key= _n if rand_key!=.
sort study_id
***** Assign first AE
replace soc="Blood and lymphatic system disorders" if rand_key==1
replace aeterm="Febrile neutropenia" if rand_key==1
replace grade=3 if rand_key==1
replace sae= 1 if rand_key==1
replace related= 1 if rand_key==1
replace susar=0 if rand_key==1
replace ssi=0 if rand_key==1
replace usm=0 if rand_key==1

**** 2nd AE 
replace soc="Gastrointestinal disorders" if rand_key==2
replace aeterm="Diarrhea" if rand_key==2
replace grade=1 if rand_key==2
replace sae= 0 if rand_key==2
replace related= 1 if rand_key==2
replace susar=0 if rand_key==2
replace ssi=0 if rand_key==2
replace usm=0 if rand_key==2

**** 3rd AE 
replace soc="General disorders and administration site conditions" if rand_key==3
replace aeterm="Fatigue" if rand_key==3
replace grade=2 if rand_key==3
replace sae= 0 if rand_key==3
replace related= 0 if rand_key==3
replace susar=0 if rand_key==3
replace ssi=0 if rand_key==3
replace usm=0 if rand_key==3

*** 4th AE 
replace soc="Nervous system disorders" if rand_key==4
replace aeterm="Peripheral motor neuropathy " if rand_key==4
replace grade=3 if rand_key==4
replace sae= 0 if rand_key==4
replace related= 0 if rand_key==4
replace susar=0 if rand_key==4
replace ssi=0 if rand_key==4
replace usm=0 if rand_key==4

*** 5th AE 
replace soc="Gastrointestinal disorders" if rand_key==5
replace aeterm="Pancreatitis" if rand_key==5
replace grade=4 if rand_key==5
replace sae= 1 if rand_key==5
replace related= 1 if rand_key==5
replace susar=1 if rand_key==5
replace ssi=0 if rand_key==5
replace usm=0 if rand_key==5

drop rand_key 
**** make a second ae in a patient 
sort study_id 
insobs 1 ,after(41)
replace study_id=41 if study_id==. 
gen ae_no=. 
replace ae_no=1 if aeterm!=""
replace soc="Blood and lymphatic system disorders" if study_id==41 & ae_no!=1
replace aeterm="Febrile neutropenia" if study_id==41 & ae_no!=1
replace grade=2 if study_id==41 & ae_no!=1
replace sae= 0 if study_id==41 & ae_no!=1
replace related= 0 if study_id==41 & ae_no!=1
replace susar=0 if study_id==41 & ae_no!=1
replace ssi=0 if study_id==41 & ae_no!=1
replace usm=0 if study_id==41 & ae_no!=1
replace ae_no=2 if aeterm!="" & ae_no!=1

** Protocol deviations
** make 3 
gen rand_key = runiform()
sort rand_key
replace rand_key=. if _n > 3
replace rand_key= _n if rand_key!=.
sort study_id
gen pd=. 
replace pd=1 if rand_key!=.
label val pd crlbl 
label var pd "Protocol Deviation"
gen pd_type= ""
replace pd_type= "Blood test not done" if rand_key==1
replace pd_type= "Treatment skipped over weekend" if rand_key==2
replace pd_type= "Visit late" if rand_key==3

*** drop unneeded 
drop rand_key diff today 
** label rest of variables 
lab var study_id "Study identifier"
lab var random_date "Date of randomisation"
lab var withdrawn "Withdrawn - indicator variable"
lab var ltfu "Lost to follow up - indicator variable"
lab var gender "Gender"
lab var type "Cancer diagnosis type"
lab var pd_type "Protocol Deviation type"

** save dataset for meeting #2 
save "$output\test_trial_2.dta", replace

** save dataset for meeting #1 
drop if random_date>=td(01Jun2025)
save "$output\test_trial_1.dta", replace




