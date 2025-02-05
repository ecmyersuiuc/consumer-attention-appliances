
clear all
set more off
set maxvar 15000
set matsize 9000
pause on

global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode eleccost_county week_num rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num state_num census_division pcounty_elec price_bin* zipcode
egen zipXweek = group(zipcode week_num)

**************************************************************************************************************************************************************************************************************
* Robustness of Price Variation
**************************************************************************************************************************************************************************************************************
eststo clear

label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost"


// countyXyear, week, pid
eststo: ppmlhdfe sales_hd real_price_zip_mode eleccost_county rebate_estar, absorb(i.zipXweek##i.price_bin2 i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "No", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b2 = round(_b[ratio12],0.001)
scalar se2 = round(_se[ratio12],0.0001)
local b2: di %4.3f b2
local se: di %4.3f se2
scalar disp_string_se = "("+"`se'"+")"
local se2 = disp_string_se

test _b[ratio12] = 1
scalar Chi2 = round(r(chi2),0.001)
scalar Pval = round(r(p),0.0001)
local chi2: di %4.3f Chi2
local pval2: di %5.4f Pval

// countyXyear, weekXbrand, pid
eststo: ppmlhdfe sales_hd real_price_zip_mode eleccost_county rebate_estar , absorb(i.zipXweek##i.brand_id_num i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id pid_id) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
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
scalar Chi2 = round(r(chi2),0.001)
scalar Pval = round(r(p),0.0001)
local chi3: di %4.3f Chi2
local pval3: di %5.4f Pval

cd $pathresults
 esttab using "Table_paper_price_variation_robust1_sample50.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)" "(2)") se keep(real_price_zip_mode eleccost_county) /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:zipxweekrobust}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcc}" "\toprule \\") ///
 postfoot("\midrule" "Valuation Ratio & `b2' & `b3'  \\" " & `se2' & `se3'  \\" "\underline{Test valuation ratio = 1} & &  \\"  "p value  & `pval2' & `pval3' \\" "\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The models are estimated using a Poisson regression.  The dependent variable is the number of units of a particular appliance sold in a given week in a given zip code.  The standard errors are clustered at the county level and are in parentheses.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  The Purchase Price and Annual Energy Cost variables are in hundreds of dollars.  The valuation ratios are computed assuming a discount rate of 5\% and a refrigerator lifetime of 12 years.}" "\end{table}") ///
  title(Robustness to ZIP Code-by-Week Controls) s(fixed fixed0 fixed1 fixed2 fixed3 fixed4 fixed5 N, label("\underline{Fixed Effects}" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "ZIP $\times$ Week" "ZIP $\times$ Week $\times$ Above Median Price" "ZIP $\times$ Week $\times$ Brand" "Observations"))

