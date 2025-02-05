
clear all
set more off
set maxvar 15000
set matsize 9000
pause on



global  pathname = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

use "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_10", clear

**************************************************************************************************************************************************************************************************************
* Variation from our controls
**************************************************************************************************************************************************************************************************************
*create brand id's
egen brand_id_num = group(brand_id)

*create indicator for above median kwh
preserve
collapse kwh, by(pid_id)
xtile kwh_bin4 = kwh, nq(4)
xtile kwh_bin3 = kwh, nq(3)
xtile kwh_bin2 = kwh, nq(2)
save temp
restore

merge m:1 pid_id using temp, nogenerate
erase temp.dta

*create indicator for above median price
preserve
collapse real_price_zip_mode, by(pid_id)
xtile price_bin4 = real_price_zip_mode, nq(4)
xtile price_bin3 = real_price_zip_mode, nq(3)
xtile price_bin2 = real_price_zip_mode, nq(2)
save temp
restore

merge m:1 pid_id using temp, nogenerate
erase temp.dta

gen above_mean = kwh_bin2==2
gen above_mean_price = price_bin2==2

collapse (mean) kwh type_id size_id above_mean above_mean_price brand_id_num (max) s_estar (sd) kwh_std = kwh, by(pid_id)
// Drop the 15 models that change kwh during the sample
drop if kwh_std>0&kwh_std~=.
drop kwh_std

label variable type_id "Freezer Location"
label variable size_id "Size"
label variable s_estar "Energy Star Indicator"
label variable above_mean "Above Mean Usage Indicator"
label variable above_mean_price "Above Mean Price Indicator"

eststo clear
eststo: reg kwh i.type_id, vce(robust)
estadd scalar R2 = e(r2)

eststo: reg kwh i.type_id i.size_id, vce(robust)
estadd scalar R2 = e(r2)

eststo: reg kwh i.type_id i.size_id i.s_estar, vce(robust)
estadd scalar R2 = e(r2)

eststo: reg kwh i.type_id i.size_id i.s_estar i.brand_id_num, vce(robust)
estadd scalar R2 = e(r2)

eststo: reg kwh i.type_id i.size_id i.s_estar i.brand_id_num i.above_mean, vce(robust)
estadd scalar R2 = e(r2)


eststo: reg kwh i.type_id i.size_id i.s_estar i.brand_id_num i.above_mean i.above_mean_price, vce(robust)
estadd scalar R2 = e(r2)

label variable type_id "Freezer Location"
label variable size_id "Above Mean Size"
label variable s_estar "Energy Star Indicator"
label variable brand_id_num "Brand Indicator"
label variable above_mean "Above Mean Usage Indicator"
label variable above_mean_price "Above Mean Price Indicator"

cd $pathresults\\
 esttab using "kwh_attributes.tex", replace legend label star(* 0.1 ** 0.05 *** 0.01) nonumbers mtitles("kWh" "kWh" "kWh" "kWh" "kWh" "kWh" "kWh")  drop(1.type_id 1.size_id 0.s_estar 0.above_mean 0.above_mean_price 1.brand_id_num) se  /// 
 alignment(D{.}{.}{-1}) width(1.0\hsize) nonotes prehead("\begin{table}[htbp]" "\begin{center}" "\footnotesize" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{@title}" "\label{t:kwhAttributes}" ///
"\begin{tabular*}{1.0\hsize}{@{\hskip\tabcolsep\extracolsep\fill}lcccccc}" "\toprule") ///
 postfoot("\bottomrule" "\end{tabular*}" "\end{center}" ///
 "\par \noindent \footnotesize {Notes: The dependent variable is the manufacturer reported annual kWh consumption of an appliance.  Robust standard errors are in parentheses.  ***, ** and * denote statistical significance at the 1, 5 and 10 percent levels.}" "\end{table}") ///
 title(Correlation Between Annual Energy Cosnumption and Attributes) s(R2 N, label("R$^{2}$" "Observations"))
