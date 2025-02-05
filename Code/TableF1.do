
clear all
set more off
set maxvar 15000
set matsize 9000
pause on

global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode eleccost_county week_num rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num state_num census_division pcounty_elec price_bin* kwh_bin* merge_IV eleccost_countyIV3 group_kwhxtype_eleccost_county*

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Control Function and 2SLS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

eststo clear

label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost"

// first stage 1
reghdfe eleccost_county real_price_zip_mode group_kwhxtype_eleccost_county3 rebate_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility) resid
predict resid_1, resid

// first stage 2
reghdfe eleccost_county real_price_zip_mode group_kwhxtype_eleccost_county4 rebate_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility) resid
predict resid_2, resid

label variable resid_1 "Residuals (3 Bins)"
label variable resid_2 "Residuals (4 Bins)"

// second stage 1
eststo: ppmlhdfe sales_hd real_price_zip_mode rebate_estar eleccost_county resid_1 if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster(county_utility)
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b1 = round(_b[ratio12],0.001)
local b1: di %4.3f b1
local se1 = ""
local pval1 = ""

// second stage 2
eststo: ppmlhdfe sales_hd real_price_zip_mode rebate_estar eleccost_county resid_2 if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster(county_utility)
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b2 = round(_b[ratio12],0.001)
local b2: di %4.3f b2
local se2 = ""
local pval2 = ""

// 2SLS 1

eststo: ivreghdfe sales_hd real_price_zip_mode rebate_estar (eleccost_county = group_kwhxtype_eleccost_county3) if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster( county_utility)
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b3 = round(_b[ratio12],0.001)
scalar se3 = round(_se[ratio12],0.0001)
local b3: di %4.3f b3
local se: di %4.3f se3
scalar disp_string_se = "("+"`se'"+")"
local se3 = disp_string_se

test _b[ratio12] = 1
scalar Pval = round(r(p),0.0001)
local pval3: di %5.4f Pval

// 2SLS 2

eststo: ivreghdfe sales_hd rebate_estar real_price_zip_mode (eleccost_county = group_kwhxtype_eleccost_county4) if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster(county_utility)
estadd local fixed "", replace
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

label variable resid_1 "1st Stage Residuals (3 Bins)"
label variable resid_2 "1st Stage Residuals (4 Bins)"


cd $pathresults\\
 esttab using "Table_paper_grouping_robust_sample50.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)" "(2)" "(3)" "(4)") se keep(real_price_zip_mode eleccost_county resid*) /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:groupingapp}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcccc}" "\toprule \\") ///
 postfoot("\midrule" "Valuation Ratio & `b1' & `b2' & `b3' & `b4' \\" " & `se1' & `se2' & `se3' & `se4' \\" "\underline{Test valuation ratio = 1} & & & & \\" "p value & `pval1' & `pval2' & `pval3' & `pval4' \\" "\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The Standard errors are clustered at the county level and are in parentheses. ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  For all estimations the sample is restricted to those observations for which we can construct the annual energy cost instrument.  Columns 1 and 2 display the results of the second stage of control function regressions with each of two alternative instruments for price.  Columns 3 and 4 display the results of 2SLS estimations for the same two instruments where the outcome variable is sales rather than ln(sales). We construct the instruments for model-specific county-level annual energy costs the following way.  First, for each year and type of refrigerator, we assign models to categories accoding to either efficiency terciles (columns 1 and 3) or efficiency quartiles (columns 2 and 4), based on the manufacturer's reported value.  Then we assign each product the mean kwh consumption for its assigned category.  Finally to create an instrument for annual energy cost, we multiply the mean kwh consumption for the category times the county annual electricity price.  The Purchase Price and Annual Energy Cost variables have been re-scaled by 1/100.  Therefore, the coefficients reflect change in amount purchased in a zip code week for a \$100 change in Purchase Price or Energy Cost.  The valuation ratios are computed assuming a discount rate of 5\% and a refrigerator lifetime of 12 years.}" "\end{table}") ///
  title(Control Function and 2SLS Estimation of the Effect of Price and Energy Costs on Demand: Different Grouping Estimators) s(fixed fixed2 fixed3 fixed4 fixed5 N, label("\underline{Fixed Effects}" "Product" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "Observations"))




