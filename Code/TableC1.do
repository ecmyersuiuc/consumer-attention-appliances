
clear all
set more off
set maxvar 15000
set matsize 9000


global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode eleccost_county eleccost week_num rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num zipcode utility_count

**************************************************************************************************************************************************************************************************************
* Poisson with FEs
**************************************************************************************************************************************************************************************************************
eststo clear

label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost (County)"
label variable eleccost "Annual Energy Cost (State)"

eststo: ppmlhdfe sales_hd real_price_zip_mode eleccost_county rebate_estar, absorb(i.county_utility##i.week_num pid_id i.county##i.s_estar i.county##i.size_id i.county##i.type_id i.county##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "No", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "No", replace
estadd local fixed6 "No", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b1 = round(_b[ratio12],0.001)
scalar se1 = round(_se[ratio12],0.0001)
local b1: di %4.3f b1
local se: di %4.3f se1
scalar disp_string_se = "("+"`se'"+")"
local se1 = disp_string_se

test _b[ratio12] = 1
scalar Chi2 = round(r(chi2),0.001)
scalar Pval = round(r(p),0.0001)
local chi1: di %4.3f Chi2
local pval1: di %5.4f Pval
 
eststo: ppmlhdfe sales_hd real_price_zip_mode eleccost_county rebate_estar, absorb(i.county_utility##i.year pid_id i.county##i.s_estar##i.year i.county##i.size_id##i.year i.county##i.type_id##i.year i.county##i.brand_id_num##i.year pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "No", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "No", replace
estadd local fixed5 "Yes", replace
estadd local fixed6 "No", replace


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

eststo: ppmlhdfe sales_hd real_price_zip_mode eleccost rebate_estar, absorb(i.county_utility##i.year pid_id i.county##i.s_estar i.county##i.size_id i.county##i.type_id i.county##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "No", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "No", replace
estadd local fixed6 "No", replace

nlcom (ratio12: _b[eleccost]/(_b[real_price_zip_mode]*8.86325164) ), post
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


eststo: ppmlhdfe sales_hd real_price_zip_mode eleccost_county rebate_estar if utility_count==1, absorb(i.county_utility##i.year pid_id i.county##i.s_estar i.county##i.size_id i.county##i.type_id i.county##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "No", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace
estadd local fixed4 "Yes", replace
estadd local fixed5 "No", replace
estadd local fixed6 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b4 = round(_b[ratio12],0.001)
scalar se4 = round(_se[ratio12],0.0001)
local b4: di %4.3f b4
local se: di %4.3f se4
scalar disp_string_se = "("+"`se'"+")"
local se4 = disp_string_se

test _b[ratio12] = 1
scalar Chi2 = round(r(chi2),0.001)
scalar Pval = round(r(p),0.0001)
local chi4: di %4.3f Chi2
local pval4: di %5.4f Pval

cd $pathresults
 esttab using "Table_paper_main_poisson_additional_sample50.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)" "(2)" "(3)" "(4)") se keep(real_price_zip_mode eleccost_county eleccost) /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:main}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcccc}" "\toprule \\") ///
 postfoot("\midrule" "Valuation Ratio & `b1' & `b2' & `b3' & `b4' \\" " & `se1' & `se2' & `se3' & `se4' \\" "\underline{Test valuation ratio = 1} & & & & \\" "p value & `pval1' & `pval2' & `pval3' & `pval4' \\" "\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The models are estimated using a Poisson regression.  The dependent variable is the number of units of a particular appliance sold in a given week in a given zip code.  The standard errors are clustered at the county level and are in parentheses.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  The Purchase Price and Annual Energy Cost variables have been re-scaled by 1/100.  Therefore, the coefficients reflect change in amount purchased in a zip code week for a \$100 change in Purchase Price or Energy Cost.  The valuation ratios are computed assuming a discount rate of 5\% and a refrigerator lifetime of 12 years.}" "\end{table}") ///
  title(Additional Robustness Checks) s(fixed fixed0 fixed1 fixed2 fixed3 fixed4 fixed5 fixed6 N, label("\underline{Fixed Effects}" "Product" "County $\times$ Week" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "County $\times$ Efficiency Attributes $\times$ Year" "County Served by 1 Utility" "Observations"))
