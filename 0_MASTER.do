**************************************************
* Study: TEST trial - fictional trial data used for DSMC demonstration purposes 
* Program Name: Master
* Creation Date: 20 Jan 2026
* Purpose: MASTER programme
* Author: Alannah Rudkin
* Version: 1
* Note:  master and globals for DSMC 

* Update: XXXXX, dd‐mm‐yyyy, Name Surname
**************************************************

clear all
version 19.5
set more off

global projectfolder "C:\yourfilepath\Stata 2026\Analysis"
global output "$projectfolder\outputs"


*set directory 
cd "$projectfolder"

********************************************************************************
** Create datasets
********************************************************************************
do "$projectfolder\making_dataset_cancer.do"

********************************************************************************
****************OPEN report
********************************************************************************
** Make required tables and graphs 
do "$projectfolder\an_dsmc_tables_jan26.do"

** Make report 
do "$projectfolder\an_dsmc_report_jan26.do"

********************************************************************************
**************** CLOSED report - code for another statistician 
********************************************************************************
**** When making tables be sure to merge in correct randomised arm
**** When generating report be sure you add your name, and update variable name for arm ( from dummy arm)
********************************************************************************
** make tables 
do "$projectfolder\an_dsmc_tables_jan26_closed.do"

** make report
do "$projectfolder\an_dsmc_report_jan26_closed.do"








