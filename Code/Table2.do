//do /Users/shoude/Dropbox/eegap/Replication_JPube_RR/Table2.do

// This script shows how much idiosyncratic variation there is in the price paid variable

// Dependencies: 
//              Agreggate raw transaction data at the pid-zip-week (or month) level:
//              -do \\c3\rdat\SHoude\Research\sears\estar_scripts\create_choice_set_struct_rd_byHD_2008_2012.do
//              Create regressors      
// 				-do \\c3\rdat\SHoude\Research\EEgap\EEgap_scripts\prepare_reducedform_reg.do

clear all
set more off
set maxvar 15000
set matsize 9000

pause on

//Sebastien's server
global  pathreplication = "[Put your path to the replication folder here]/Replication_JPube_RR"

log using $pathreplication/log_Table2.txt, replace
use "$pathreplication/Data/lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50", clear

gen estarxeleccost_county = estar*eleccost_county
gen log_sales = ln(sales+1)
egen brand_group = group(brand)
egen brand_id_group = group(brand_id)

label var real_price_zip_mode "Purchase Price"
label var eleccost_county "Energy Cost"
label var estarxeleccost_county "Energy Star x Energy Cost"
label var rebate_estar "Energy Star Rebate"
label var pcounty_elec "County Electric Price"


**************************************************************************************************************************************************************************************************************
*TABLES: HOW MUCH VARIATION IN PRICE IS DRIVEN BY DEMAND SIDE SHIFTS FOR CHARACTERISTICS?
**************************************************************************************************************************************************************************************************************
gen lg_promo_f = ln(promo_f)
eststo clear

// Variation there is relative to the mean product price
eststo t_var_1: reghdfe lg_promo_f, absorb(pid_id) residuals(res_pid_only)
bys pid_id: egen sd_res_pid_only  = sd(res_pid_only)
bys pid_id: egen min_res_pid_only = min(res_pid_only)
bys pid_id: egen max_res_pid_only = sd(res_pid_only)
*graph box res_pid_only, over(pid_id)

bys pid_id: egen mean_promo_f  = mean(promo_f)
gen pct_change = (promo_f-mean_promo_f)/mean_promo_f 
sum pct_change 

// Taking out week-of-sample FE 
eststo t_var_2: reghdfe lg_promo_f, absorb(pid_id week_num) residuals(res_pid_week)
bys pid_id: egen sd_res_pid_week  = sd(res_pid_week)
bys pid_id: egen min_res_pid_week = min(res_pid_week)
bys pid_id: egen max_res_pid_week = sd(res_pid_week)
sum sd_res_pid_week 
*graph box res_pid_only, over(pid_id)

eststo t_var_3: reghdfe lg_promo_f, absorb(pid_id brand_week_num) residuals(res_pid_brandweek)
bys pid_id: egen sd_res_pid_brandweek  = sd(res_pid_brandweek)
bys pid_id: egen min_res_pid_brandweek = min(res_pid_brandweek)
bys pid_id: egen max_res_pid_brandweek = sd(res_pid_brandweek)
sum sd_res_pid_brandweek if sd_res_pid_brandweek>0
*graph box res_pid_only, over(pid_id)

eststo t_var_4: reghdfe lg_promo_f, absorb(pid_id brand_week_num i.s_estar##i.week_num i.size_id##i.week_num i.type_id##i.week_num) residuals(res_pid_attweek)
bys pid_id: egen sd_res_pid_attweek  = sd(res_pid_attweek)
bys pid_id: egen min_res_pid_attweek = min(res_pid_attweek)
bys pid_id: egen max_res_pid_attweek = sd(res_pid_attweek)
sum sd_res_pid_attweek 

eststo t_var_5: reghdfe lg_promo_f, absorb(i.county_utility##i.pid_id pid_id brand_week_num i.s_estar##i.week_num i.size_id##i.week_num i.type_id##i.week_num) residuals(res_pid_attweek_cnty)
bys pid_id: egen sd_res_pid_attweek_cnty  = sd(res_pid_attweek_cnty)
bys pid_id: egen min_res_pid_attweek_cnty = min(res_pid_attweek_cnty)
bys pid_id: egen max_res_pid_attweek_cnty = sd(res_pid_attweek_cnty)
sum sd_res_pid_attweek_cnty

eststo t_var_6: reghdfe lg_promo_f, absorb(i.county_utility##i.brand_week_num i.county_utility##i.pid_id pid_id brand_week_num i.s_estar##i.week_num i.size_id##i.week_num i.type_id##i.week_num) residuals(res_pid_attweek_brandcnty)
bys pid_id: egen sd_res_pid_attweek_brandcnty  = sd(res_pid_attweek_brandcnty)
bys pid_id: egen min_res_pid_attweek_brandcnty = min(res_pid_attweek_brandcnty)
bys pid_id: egen max_res_pid_attweek_brandcnty = sd(res_pid_attweek_brandcnty)
sum sd_res_pid_attweek_cnty

log close

pause

cd $pathresults

esttab using "$pathreplication\Results\Tables_exogeneous_price_variation_complete_sample_seed_1_sample_50.tex", replace 




