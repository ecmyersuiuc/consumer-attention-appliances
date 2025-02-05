clear all
set more off
set maxvar 15000
set matsize 9000

global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode eleccost_county week_num rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num state_num census_division pcounty_elec price_bin* kwh_bin* merge_IV eleccost_countyIV3 mean_promo_out_jw

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Control Function and 2SLS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

eststo clear

label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost"
label variable eleccost_countyIV3 "Fuel Price Energy Cost IV"
label variable mean_promo_out_jw "Leave-one-out Price IV" 

// first stage 1
eststo: reghdfe real_price_zip_mode mean_promo_out_jw eleccost_countyIV3 rebate_estar s_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility) resid
predict resid_1, resid
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace

// first stage 2
eststo: reghdfe eleccost_county mean_promo_out_jw eleccost_countyIV3 rebate_estar s_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility) resid
predict resid_2, resid
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace


// second stage 
eststo: ppmlhdfe sales_hd real_price_zip_mode rebate_estar eleccost_county resid_1 resid_2 if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster(county_utility)
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



// 2SLS 2

eststo: ivreghdfe sales_hd rebate_estar (eleccost_county real_price_zip_mode = eleccost_countyIV3  mean_promo_out_jw) if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster(county_utility)
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b2 = round(_b[ratio12],0.001)
scalar se2 = round(_se[ratio12],0.0001)
local b2: di %4.3f b2
local se: di %4.3f se2
scalar disp_string_se = "("+"`se'"+")"
local se2 = disp_string_se

test _b[ratio12] = 1
scalar Pval = round(r(p),0.0001)
local pval2: di %5.4f Pval

label variable resid_1 "Residuals (Price)"
label variable resid_2 "Residuals (Energy Cost)"

cd $pathresults\\
 esttab using "Table_paper_Control_Function_2SLS_appendix_sample50.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers nomtitles se keep(real_price_zip_mode eleccost_county resid* mean_promo_out_jw eleccost_countyIV3) /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:controlIVappendix}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcccc}" "\toprule " "&&&& \\" "& First & First & Control & 2SLS \\" "& Stage & Stage & Function & \\") ///
 postfoot("\midrule" "Valuation Ratio &  &  & `b1' & `b2' \\" " & & &  & `se2' \\" "\underline{Test valuation ratio = 1} & & & & \\" "p value & `pval1' & `pval2' & `pval3' & `pval4' & `pval5' & `pval6' \\" "\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The Standard errors are clustered at the county level and are in parentheses. ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  Column 3 standard errors are bootstrapped based on 200 iterations. For all estimations the sample is restricted to those observations for which we can construct the annual energy cost instrument.  Columns 1 and 2 display linear first stage regressions.  Columns 3 and 4 display the results of a Poisson control function regression and 2SLS respectively.  We instrument for both energy cost and price.  In Column 4 the outcome variable is sales rather than ln(sales) as in column 3.  We construct instruments for model-specific county-level annual energy costs using the product of the local utility's capacity-weighted fuel price and the manufacturer's reported annual kwh consumption.  The capacity-weighted fuel price is the sum of the local utility's pre-determined shares of coal, oil and gas-fired power plant capacity times their respective annual average fuel prices.  We use data from EIA form 860 to construct the capacity shares from 2007, the year before our sales data begin.  For fuel prices, we use the crude oil WTI spot price for petroleum plants, the annual Henry Hub contract 1 prices for natural gas plants, national average coal price from EIA for coal plants. We instrument for the product price in a particular zip code in a given week using the mean of product price paid at all other zip codes in that week, excluding the particular zip code.  The Purchase Price and Annual Energy Cost variables have been re-scaled by 1/100.  Therefore, the coefficients reflect change in amount purchased in a zip code week for a \$100 change in Purchase Price or Energy Cost.  The valuation ratios are computed assuming a discount rate of 5\% and a refrigerator lifetime of 12 years." "\end{table}") ///
  title(Control Function and 2SLS Estimation of the Effect of Price and Energy Costs on Demand) s(fixed fixed2 fixed3 fixed4 fixed5 N, label("\underline{Fixed Effects}" "Product" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "Observations"))


