
clear all
set more off
set maxvar 15000
set matsize 9000
pause on

global  pathname = "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\EEgap_data\Retailer\bup"
global  pathresults = "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\EEgap_results"


local set_seed   `"`1'"'
local init_rep   `"`2'"'
local nb_rep     `"`3'"'
local a_var      `"`4'"'

local tmp_seed = 1000*`a_var'+`set_seed'

set seed `tmp_seed' 

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode eleccost_county week_num rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num state_num census_division pcounty_elec price_bin* kwh_bin* brand_id

replace week_num=0 if brand_id=="Others_Low"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Main table
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
**************************************************************************************************************************************************************************************************************
* Poisson with FEs
**************************************************************************************************************************************************************************************************************
eststo clear

label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost"


//Specification 4 of Table 3


//countyXyear, countyEE-related, countyXbrand, weekXbrand, pid
forvalues i=`init_rep'(1)`nb_rep' {

 gen noise_price_`i' = rnormal(0,1)*real_price_zip_mode*`a_var'
 gen real_price_zip_mode_error_`i' = real_price_zip_mode + noise_price_`i'    
 
eststo: ppmlhdfe sales_hd real_price_zip_mode_error_`i' eleccost_county rebate_estar , absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace
nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b4 = round(_b[ratio12],0.001)
scalar se4 = round(_se[ratio12],0.0001)
local b4: di %4.3f b4
local se: di %4.3f se4
scalar disp_string_se = "("+"`se'"+")"
local se4 = disp_string_se

test _b[ratio12] = 1
scalar Pval = round(r(p),0.0001)
local pval4: di %5.4f Pval

cd "$pathresults"
 esttab using "Table_paper_t3s4_symex_poisson_sample50_seed_`set_seed'_var_`a_var'_rep_`i'.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)" "(2)" "(3)" "(4)") se /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:main}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcccc}" "\toprule \\") ///
 postfoot("\midrule" "Valuation Ratio & `b4' \\" " & `se4' \\" "\underline{Test valuation ratio = 1} & & & & \\" "p value & `pval1' & `pval2' & `pval3' & `pval4' \\" "\bottomrule" "\end{tabular*}" "\end{center}") 


outreg2 using "Table_paper_t3s4_symex_poisson_sample50_seed_`set_seed'_var_`a_var'_rep_`i'.txt", replace stats(coef se) sideway noaster


}

