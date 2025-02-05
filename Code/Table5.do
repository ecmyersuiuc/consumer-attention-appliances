
clear all
set more off
set maxvar 15000
set matsize 9000
pause on



*global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
*global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

global  pathname = "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Data"
global  pathresults = "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice/Replication_JPubE_RR\Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode eleccost_county week_num rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num state_num census_division pcounty_elec price_bin* kwh_bin* merge_IV eleccost_countyIV3 group_kwhxtype_eleccost_county2

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Control Function and 2SLS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

eststo clear

label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost"


eststo: ppmlhdfe sales_hd real_price_zip_mode eleccost_county rebate_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b1 = round(_b[ratio12],0.001)
scalar se1 = round(_se[ratio12],0.0001)
local b1: di %4.3f b1
local se: di %4.3f se1
scalar disp_string_se = "("+"`se'"+")"
local se1 = disp_string_se

test _b[ratio12] = 1
scalar Pval = round(r(p),0.0001)
local pval1: di %5.4f Pval

// first stage 1
reghdfe eleccost_county real_price_zip_mode eleccost_countyIV3 rebate_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility) resid
predict resid_1, resid

// first stage 2
reghdfe eleccost_county real_price_zip_mode group_kwhxtype_eleccost_county2 rebate_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility) resid
predict resid_2, resid

label variable resid_1 "Residuals (IV 1)"
label variable resid_2 "Residuals (IV 2)"

// second stage 1
eststo: ppmlhdfe sales_hd real_price_zip_mode rebate_estar eleccost_county resid_1 if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster(county_utility)
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


// second stage 2
eststo: ppmlhdfe sales_hd real_price_zip_mode rebate_estar eleccost_county resid_2 if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster(county_utility)
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b3 = round(_b[ratio12],0.001)
local b3: di %4.3f b3
local se3 = ""
local pval3 = ""

// OLS
eststo: reghdfe sales_hd real_price_zip_mode eleccost_county rebate_estar if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
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

// 2SLS 1

eststo: ivreghdfe sales_hd real_price_zip_mode rebate_estar (eleccost_county = eleccost_countyIV3) if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster( county_utility)
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b5 = round(_b[ratio12],0.001)
scalar se5 = round(_se[ratio12],0.0001)
local b5: di %4.3f b5
local se: di %4.3f se5
scalar disp_string_se = "("+"`se'"+")"
local se5 = disp_string_se

test _b[ratio12] = 1
scalar Pval = round(r(p),0.0001)
local pval5: di %5.4f Pval

// 2SLS 2

eststo: ivreghdfe sales_hd rebate_estar real_price_zip_mode (eleccost_county = group_kwhxtype_eleccost_county2) if merge_IV==3, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.brand_id_num pid_id brand_week_num) cluster(county_utility)
estadd local fixed "", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b6 = round(_b[ratio12],0.001)
scalar se6 = round(_se[ratio12],0.0001)
local b6: di %4.3f b6
local se: di %4.3f se6
scalar disp_string_se = "("+"`se'"+")"
local se6 = disp_string_se

test _b[ratio12] = 1
scalar Pval = round(r(p),0.0001)
local pval6: di %5.4f Pval

label variable resid_1 "1st Stage Residuals (IV 1)"
label variable resid_2 "1st Stage Residuals (IV 2)"


cd $pathresults\\
 esttab using "Table_paper_Control_Function_2SLS_sample50.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") se keep(real_price_zip_mode eleccost_county resid*) /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:controlIV}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcccccc}" "\toprule \\") ///
 postfoot("\midrule" "Valuation Ratio & `b1' & `b2' & `b3' & `b4' & `b5' & `b6' \\" " & `se1' & `se2' & `se3' & `se4' & `se5' & `se6' \\" "\underline{Test valuation ratio = 1} & & & & \\" "p value$ & `pval1' & `pval2' & `pval3' & `pval4' & `pval5' & `pval6' \\" "\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The Standard errors are clustered at the county level and are in parentheses. ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  For all estimations the sample is restricted to those observations for which we can construct the capacity-weighted fuel price instrument for energy cost.  The first column is our preferred Poisson estimation.  Columns 2 and 3 display the results of the second stage of control function regressions with each of two different instruments for price.  Column 4 is our preferred specification estimated with OLS.  Columns 5 and 6 display the results of 2SLS estimations. In columns 2 and 5, we instrument for annual energy costs using the product of the local utility's capacity-weighted fuel price and the manufacturer's reported annual kwh consumption.  In columns 3 and 6 we instrument using a grouping estimator as described in the main text. The first-stage results are presented in Table \ref{t:firstIV}.  The Purchase Price and Annual Energy Cost variables have been re-scaled by 1/100.  Therefore, the coefficients reflect change in amount purchased in a zip code week for a \$100 change in Purchase Price or Energy Cost. Valuation ratios are computed assuming a 5\% discount rate and refrigerator lifetime of 12 years.}" "\end{table}") ///
  title(Control Function and 2SLS Estimation of the Effect of Price and Energy Costs on Demand) s(fixed fixed2 fixed3 fixed4 fixed5 N, label("\underline{Fixed Effects}" "Product" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "Observations"))




