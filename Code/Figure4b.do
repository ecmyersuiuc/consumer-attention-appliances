clear all
set more off
set maxvar 15000
set matsize 9000

global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode pcounty_elec eleccost_county week_num rebate_estar county_utility year s_estar size_id type_id brand_week_num pid_id brand_id_num

replace eleccost_county = eleccost_county*100
replace real_price_zip_mode = real_price_zip_mode*100
egen mean_sales_hd = mean(sales_hd)
egen mean_real_price_zip_mode = mean(real_price_zip_mode) 

*partition regression to absorb many high-dimensional categorical variables (binscatter can only absorb 1)
reghdfe sales_hd eleccost_county rebate_estar, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) residuals(y_tilde) noconstant

reghdfe real_price_zip_mode eleccost_county rebate_estar, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) residuals(x_tilde) noconstant

*add mean of variables back in
replace y_tilde = y_tilde + mean_sales_hd
replace x_tilde = x_tilde + mean_real_price_zip_mode

binscatter y_tilde x_tilde, xtitle(Purchase Price ($), size(medlarge)) ytitle("Weekly Sales", size(medlarge)) n(20) mcolor(blue) lcolor(red) scheme(s1color)
graph export "$pathresults\binscatter_sales_by_purchase_price.pdf", as(pdf) replace







