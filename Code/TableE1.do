clear all
set more off
set maxvar 15000
set matsize 9000

global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode eleccost_county week_num rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num state_num census_division pcounty_elec price_bin* kwh_bin* merge_IV eleccost_countyIV3 group_kwhxtype_eleccost_county2

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// First Stage
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

eststo clear

// first stage 1
eststo: reghdfe eleccost_county real_price_zip_mode eleccost_countyIV3 rebate_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility) resid
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace


// first stage 2
eststo: reghdfe eleccost_county real_price_zip_mode group_kwhxtype_eleccost_county2 rebate_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility) resid
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace


label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost"
label variable eleccost_countyIV3 "Fuel Price IV"
label variable group_kwhxtype_eleccost_county2 "Grouping Estimator IV"


cd $pathresults\\
 esttab using "Table_paper_first_stage_appendix_sample50.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)" "(2)") se keep(real_price_zip_mode eleccost_countyIV3 group_kwhxtype_eleccost_county2) /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:firstIV}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcc}" "\toprule \\") ///
 postfoot("\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The Standard errors are clustered at the county level and are in parentheses. ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  For all estimations the sample is restricted to those observations for which we can construct the annual energy cost instrument.  In the first column, we construct instruments for model-specific county-level annual energy costs using the product of the local utility's capacity-weighted fuel price and the manufacturer's reported annual kwh consumption.  The capacity-weighted fuel price is the sum of the local utility's pre-determined shares of coal, oil and gas-fired power plant capacity times their respective annual average fuel prices.  We use data from EIA form 860 to construct the capacity shares from 2007, the year before our sales data begin.  For fuel prices, we use the crude oil WTI spot price for petroleum plants, the annual Henry Hub contract 1 prices for natural gas plants, national average coal price from EIA for coal plants. In columns 2 we construct an instrument for model-specific county-level annual energy costs using a grouping estimator as follows.  First, we assign models to one of two categories of efficiency: either above or below median kWh consumption in a given year for a given type, based on the manufacturer's reported value.  To create an instrument for annual energy cost, we multiply the mean kwh consumption for the assigned category times the county annual electricity price.}" "\end{table}") ///
  title(First Stage: IV Regression) s(fixed fixed2 fixed3 fixed4 fixed5 N, label("\underline{Fixed Effects}" "Product" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "Observations"))

