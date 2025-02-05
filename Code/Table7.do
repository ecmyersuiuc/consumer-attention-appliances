
clear all
set more off
set maxvar 15000
set matsize 9000
pause on


global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear


keep sales_hd real_price_zip_mode eleccost_county rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num state_num income_med3 price_bin3 education_med

**************************************************************************************************************************************************************************************************************
* Poisson with FEs
**************************************************************************************************************************************************************************************************************
eststo clear

label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost"

label variable education_med "Education Level"
label variable income_med3 "Income Tercile"
label variable price_bin3 "Purchase Price Tercile"

eststo: ppmlhdfe sales_hd i.price_bin3#c.real_price_zip_mode i.price_bin3#c.eleccost_county rebate_estar, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

nlcom (ratio1: _b[1.price_bin3#c.eleccost_county]/(_b[1.price_bin3#c.real_price_zip_mode]*8.86325164) ) (ratio2: _b[2.price_bin3#c.eleccost_county]/(_b[2.price_bin3#c.real_price_zip_mode]*8.86325164) ) (ratio3: _b[3.price_bin3#c.eleccost_county]/(_b[3.price_bin3#c.real_price_zip_mode]*8.86325164) ), post
scalar b1 = round(_b[ratio1],0.001)
scalar se1 = round(_se[ratio1],0.0001)
local b1: di %4.3f b1
local se: di %4.3f se1
scalar disp_string_se = "("+"`se'"+")"
local se1 = disp_string_se

scalar b2 = round(_b[ratio2],0.001)
scalar se2 = round(_se[ratio2],0.0001)
local b2: di %4.3f b2
local se: di %4.3f se2
scalar disp_string_se = "("+"`se'"+")"
local se2 = disp_string_se

scalar b3 = round(_b[ratio3],0.001)
scalar se3 = round(_se[ratio3],0.0001)
local b3: di %4.3f b3
local se: di %4.3f se3
scalar disp_string_se = "("+"`se'"+")"
local se3 = disp_string_se

eststo: ppmlhdfe sales_hd i.income_med3#c.real_price_zip_mode i.income_med3#c.eleccost_county rebate_estar, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

nlcom (ratio1: _b[1.income_med3#c.eleccost_county]/(_b[1.income_med3#c.real_price_zip_mode]*8.86325164) ) (ratio2: _b[2.income_med3#c.eleccost_county]/(_b[2.income_med3#c.real_price_zip_mode]*8.86325164) ) (ratio3: _b[3.income_med3#c.eleccost_county]/(_b[3.income_med3#c.real_price_zip_mode]*8.86325164) ), post
scalar b4 = round(_b[ratio1],0.001)
scalar se4 = round(_se[ratio1],0.0001)
local b4: di %4.3f b4
local se: di %4.3f se4
scalar disp_string_se = "("+"`se'"+")"
local se4 = disp_string_se

scalar b5 = round(_b[ratio2],0.001)
scalar se5 = round(_se[ratio2],0.0001)
local b5: di %4.3f b5
local se: di %4.3f se5
scalar disp_string_se = "("+"`se'"+")"
local se5 = disp_string_se

scalar b6 = round(_b[ratio3],0.001)
scalar se6 = round(_se[ratio3],0.0001)
local b6: di %4.3f b6
local se: di %4.3f se6
scalar disp_string_se = "("+"`se'"+")"
local se6 = disp_string_se

eststo: ppmlhdfe sales_hd i.education_med#c.real_price_zip_mode i.education_med#c.eleccost_county rebate_estar, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

nlcom (ratio1: _b[1.education_med#c.eleccost_county]/(_b[1.education_med#c.real_price_zip_mode]*8.86325164) ) (ratio2: _b[2.education_med#c.eleccost_county]/(_b[2.education_med#c.real_price_zip_mode]*8.86325164) ) (ratio3: _b[3.education_med#c.eleccost_county]/(_b[3.education_med#c.real_price_zip_mode]*8.86325164) ), post
scalar b7 = round(_b[ratio1],0.001)
scalar se7 = round(_se[ratio1],0.0001)
local b7: di %4.3f b7
local se: di %4.3f se7
scalar disp_string_se = "("+"`se'"+")"
local se7 = disp_string_se

scalar b8 = round(_b[ratio2],0.001)
scalar se8 = round(_se[ratio2],0.0001)
local b8: di %4.3f b8
local se: di %4.3f se8
scalar disp_string_se = "("+"`se'"+")"
local se8 = disp_string_se

scalar b9 = round(_b[ratio3],0.001)
scalar se9 = round(_se[ratio3],0.0001)
local b9: di %4.3f b9
local se: di %4.3f se9
scalar disp_string_se = "("+"`se'"+")"
local se9 = disp_string_se


cd $pathresults
 esttab using "Table_heterogeneity_sample50.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)" "(2)" "(3)") se drop(_cons rebate_estar) /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\tiny" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:heterogeneity}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lccc}" "\toprule") ///
 postfoot("\midrule" "\underline{Valuation Ratio} & & & \\" "Category 1 & `b1' & `b4' & `b7' \\" " & `se1' & `se4' & `se7' \\" "Category 2 & `b2' & `b5' & `b8' \\" " & `se2' & `se5' & `se8' \\" "Category 3 & `b3' & `b6' & `b9' \\" " & `se3' & `se6' & `se9' \\" "\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The models are estimated using a Poisson regression.  The dependent variable is the number of units of a particular appliance sold in a given week in a given zip code.  The standard errors are clustered at the county level and are in parentheses.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  The Purchase Price and Annual Energy Cost variables have been re-scaled by 1/100.  Therefore, the coefficients reflect change in amount purchased in a zip code week for a \$100 change in Purchase Price or Energy Cost.  The valuation ratios are computed assuming a discount rate of 5\% and a refrigerator lifetime of 12 years.  Education category 1 refers to secondary and professional training, category 2 refers to college and category 3 refers to post-graduate education.}" "\end{table}") ///
  title(Heterogeneity in the Effects of Price and Energy Costs on Demand) s(fixed fixed0 fixed1 fixed2 fixed3 N, label("\underline{Fixed Effects}" "Product" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "Observations"))
  
