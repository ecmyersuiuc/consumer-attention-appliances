clear all
set more off
set maxvar 15000
set matsize 9000

global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd real_price_zip_mode eleccost_county rebate_estar county_utility year s_estar size_id type_id brand_id_num pid_id brand_week_num state_num kwh_bin3 

eststo clear

label variable real_price_zip_mode "Purchase Price"
label variable eleccost_county "Annual Energy Cost"

label variable year "Year"
label variable kwh_bin3 "kWh Tercile"

eststo: ppmlhdfe sales_hd i.year#c.real_price_zip_mode i.year#c.eleccost_county rebate_estar, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

nlcom (ratio1: _b[2008.year#c.eleccost_county]/(_b[2008.year#c.real_price_zip_mode]*8.86325164) ) (ratio2: _b[2009.year#c.eleccost_county]/(_b[2009.year#c.real_price_zip_mode]*8.86325164) ) (ratio3: _b[2010.year#c.eleccost_county]/(_b[2010.year#c.real_price_zip_mode]*8.86325164) ) (ratio4: _b[2011.year#c.eleccost_county]/(_b[2011.year#c.real_price_zip_mode]*8.86325164) ) (ratio5: _b[2012.year#c.eleccost_county]/(_b[2012.year#c.real_price_zip_mode]*8.86325164) ), post
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
 
eststo: ppmlhdfe sales_hd real_price_zip_mode eleccost_county rebate_estar if year~=2010, absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility)
estadd local fixed "", replace
estadd local fixed0 "Yes", replace
estadd local fixed1 "Yes", replace
estadd local fixed2 "Yes", replace
estadd local fixed3 "Yes", replace

nlcom (ratio12: _b[eleccost_county]/(_b[real_price_zip_mode]*8.86325164) ), post
scalar b6 = round(_b[ratio12],0.001)
scalar se6 = round(_se[ratio12],0.0001)
local b6: di %4.3f b6
local se: di %4.3f se6
scalar disp_string_se = "("+"`se'"+")"
local se6 = disp_string_se


cd $pathresults
 esttab using "Table_heterogeneity_appendix_year_sample50.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("(1)" "(2)") se drop(_cons rebate_estar) /// 
 alignment(D{.}{.}{-1}) width(0.9\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\scriptsize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:heterogeneityappendix}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcc}" "\toprule \\") ///
 postfoot("\midrule" "\underline{Valuation Ratio} & & \\" "Year 2008 & `b1' &  \\" " & `se1'  & \\" "Year 2009 & `b2' &  \\" " & `se2' &  \\" "Year 2010 & `b3' &  \\" " & `se3' &  \\" "Year 2011 & `b4' &  \\" " & `se4' &  \\" "Year 2012 & `b5' &  \\" " & `se5' &  \\" "Years excluding 2010 &  & `b6' \\" " & & `se6'   \\"  ///
"\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The models are estimated using a Poisson regression.  The dependent variable is the number of units of a particular appliance sold in a given week in a given zip code.  The standard errors are clustered at the county level and are in parentheses.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.  The Purchase Price and Annual Energy Cost variables have been re-scaled by 1/100.  Therefore, the coefficients reflect change in amount purchased in a zip code week for a \$100 change in Purchase Price or Energy Cost. The valuation ratios are computed assuming a discount rate of 5\% and a refrigerator lifetime of 12 years.}" "\end{table}") ///
  title(Heterogeneity in the Effect of Price and Energy Costs on Demand by Year) s(fixed fixed0 fixed1 fixed2 fixed3 N, label("\underline{Fixed Effects}" "Product" "County $\times$ Year" "Brand $\times$ Week" "County $\times$ Efficiency Attributes" "Observations"))
