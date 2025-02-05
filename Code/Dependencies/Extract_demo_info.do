//do /Users/shoude/Dropbox/eegap/EEgap_scripts/Extract_demo_info.do

// Extract demographic information by zip-week

// Dependencies: 
//              Agreggate raw transaction data at the pid-zip-week (or month) level:
//              -do \\c3\rdat\SHoude\Research\sears\estar_scripts\create_choice_set_struct_rd_byHD_2008_2012.do


clear all
set more off
set maxvar 15000
set matsize 9000
pause on

//Erica's server
//global  pathname = "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\EEgap_data\Retailer"
//global  pathresults = "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\EEgap_results"
//global  dirpath="C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\EEgap_data\IV_data"
//global  EEGap_pathname = "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\EEgap_data"

//Sebastien's server
//global  pathname = "\\fsa\faculty\shoude\TempDataCode\EEGap"
//global  pathresults = "\\fsa\faculty\shoude\TempDataCode\EEGap"
//global  EEGap_pathname = "\\fsa\faculty\shoude\TempDataCode\EEGap"

//Sebastien's Dropbox
global  pathname = "/Users/shoude/Dropbox/eegap/EEgap_data/Retailer"
//global  pathresults = "\\fsa\faculty\shoude\TempDataCode\EEGap"
//global  EEGap_pathname = "\\fsa\faculty\shoude\TempDataCode\EEGap"

use $pathname\lcidemo_046_2008_2012_struct_v11_11022017_robustb_nocensor_11022017, clear 
              
xtile age_gr = age, n(4)

gen fam_size = adult+children

gen income_sub1 = cond(income_sub==35, 1, 0)
gen income_sub2 = cond(income_sub==45, 1, 0)
gen income_sub3 = cond(income_sub==55, 1, 0)

collapse(median) age age_gr fam_size adult children income education (mean) income_sub1 income_sub2 income_sub3,by( zip year week )
gen age_med = round(age)
gen age_gr_med = round(age_gr) 
gen fam_size_med = round(fam_size)
gen education_med = round(education)
gen income_med = round(income)


keep zip year week age_gr_med education_med fam_size_med income_med
sort zip year week

save $pathname\demo_046_2008_2012_by_zip_week, replace






