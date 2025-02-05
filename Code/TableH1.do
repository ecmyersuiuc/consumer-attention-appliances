clear all
set more off
set maxvar 15000
set matsize 9000

global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode eleccost_county rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num state_num kwh_bin3 elec_bin3

eststo clear

label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost"

label variable kwh_bin3 "kWh Tercile"
label variable elec_bin3 "Electricity Price Tercile"

 
eststo: ppmlhdfe sales_hd i.kwh_bin3#c.real_price_zip_mode i.kwh_bin3#c.eleccost_county rebate_estar, absorb(i.county_utility##i.year pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

nlcom (ratio1: _b[1.kwh_bin3#c.eleccost_county]/(_b[1.kwh_bin3#c.real_price_zip_mode]*8.86325164) ) (ratio2: _b[2.kwh_bin3#c.eleccost_county]/(_b[2.kwh_bin3#c.real_price_zip_mode]*8.86325164) ) (ratio3: _b[3.kwh_bin3#c.eleccost_county]/(_b[3.kwh_bin3#c.real_price_zip_mode]*8.86325164) ), post
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

 
eststo: ppmlhdfe sales_hd i.elec_bin3#c.real_price_zip_mode i.elec_bin3#c.eleccost_county rebate_estar, absorb(i.county_utility##i.year pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

nlcom (ratio4: _b[1.elec_bin3#c.eleccost_county]/(_b[1.elec_bin3#c.real_price_zip_mode]*8.86325164) ) (ratio5: _b[2.elec_bin3#c.eleccost_county]/(_b[2.elec_bin3#c.real_price_zip_mode]*8.86325164) ) (ratio6: _b[3.elec_bin3#c.eleccost_county]/(_b[3.elec_bin3#c.real_price_zip_mode]*8.86325164) ), post
scalar b4 = round(_b[ratio4],0.001)
scalar se4 = round(_se[ratio4],0.0001)
local b4: di %4.3f b4
local se: di %4.3f se4
scalar disp_string_se = "("+"`se'"+")"
local se4 = disp_string_se

scalar b5 = round(_b[ratio5],0.001)
scalar se5 = round(_se[ratio5],0.0001)
local b5: di %4.3f b5
local se: di %4.3f se5
scalar disp_string_se = "("+"`se'"+")"
local se5 = disp_string_se

scalar b6 = round(_b[ratio6],0.001)
scalar se6 = round(_se[ratio6],0.0001)
local b6: di %4.3f b6
local se: di %4.3f se6
scalar disp_string_se = "("+"`se'"+")"
local se6 = disp_string_se

cd $pathresults
 esttab using "Table_heterogeneity_appendix_alt2_sample50.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)" "(2)") se drop(_cons rebate_estar) /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\scriptsize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:heterogeneityappendix}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcc}" "\toprule \\") ///
 postfoot("\midrule" "\underline{Valuation Ratio} & & \\" "Category 1 & `b1' & `b4' \\" " & `se1' & `se4' \\" "Category 2 & `b2' & `b5' \\" " & `se2' & `se5' \\" "Category 3 & `b3' & `b6' \\" " & `se3' & `se6' \\" "\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The models are estimated using a Poisson regression.  The dependent variable is the number of units of a particular appliance sold in a given week in a given zip code.  The standard errors are clustered at the county level and are in parentheses.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  The Purchase Price and Annual Energy Cost variables have been re-scaled by 1/100.  Therefore, the coefficients reflect change in amount purchased in a zip code week for a \$100 change in Purchase Price or Energy Cost. The valuation ratios are computed assuming a discount rate of 5\% and a refrigerator lifetime of 12 years.}" "\end{table}") ///
  title(Heterogeneity in the Effect of Price and Energy Costs on Demand by Efficiency and Electricity Price) s(fixed fixed0 fixed1 fixed2 fixed3 N, label("\underline{Fixed Effects}" "Product" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "Observations"))



/* Code with just one output
cd $pathresults
 esttab using "Table_heterogeneity_appendix_alt_sample10.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)") se drop(_cons rebate_estar) /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\scriptsize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:heterogeneityappendix}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lc}" "\toprule \\") ///
 postfoot("\midrule" "\underline{Valuation Ratio} &  \\" "Category 1 & `b1'  \\" " & `se1' \\" "Category 2 & `b2'  \\" " & `se2' \\" "Category 3 & `b3' \\" " & `se3' \\" "\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The models are estimated using a Poisson regression.  The dependent variable is the number of units of a particular appliance sold in a given week in a given zip code.  The standard errors are clustered at the county level and are in parentheses.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  The valuation ratios are computed assuming a discount rate of 5\% and a refrigerator lifetime of 12 years.}" "\end{table}") ///
  title(Estimation of the Effect of Price and Energy Costs on Demand) s(fixed fixed0 fixed1 fixed2 fixed3 N, label("\underline{Fixed Effects}" "Product" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "Observations"))
 

