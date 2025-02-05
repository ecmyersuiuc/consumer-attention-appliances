// Create a sales indicator
// do /Users/shoude/Dropbox/eegap/EEgap_scripts/Create_Sales_Indicator.do


clear all
set more off
set maxvar 15000
set matsize 9000
pause on

//Sebastien's server
global  datapath_retail = "/Users/shoude/Dropbox/eegap/EEgap_data/Retailer"
global  datapath_IV     = "/Users/shoude/Dropbox/eegap/EEgap_data/IV_data"
global  datapath_policy = "/Users/shoude/Dropbox/eegap/EEgap_data/PolicyAnalysis_Jpube"
global  datapath_elec   = "/Users/shoude/Dropbox/eegap/EEgap_data/EIA_861"
global  pathresults     = "/Users/shoude/Dropbox/eegap/EEgap_results"

use "$datapath_retail/lcidemo_046_2008_2012_struct_v11_11022017_robustb_nocensor_11022017", clear


collapse(median) retail_p paid_p promo_p pcode, by(pid week year week_num )

sort pid week_num
save "$datapath_retail/promo_price_code_national_week", replace



