// do /Users/shoude/Dropbox/eegap/EEgap_scripts/Final_data_build.do

// Dependencies: 
// 				-do \\c3\rdat\SHoude\Research\EEgap\EEgap_scripts\prepare_reducedform_reg.do
//              -do \\c3\rdat\SHoude\Research\sears\estar_scripts\create_choice_set_struct_rd_byHD_2008_2012.do


clear all
set more off
set maxvar 15000
set matsize 9000
//adopath + H:\ADO
pause on


global  pathname = "[Put your path to the replication folder here]\Replication_JPubE_RR\Data"
global  IV_pathname = "[Put your path to the replication folder here]\Replication_JPubE_RR\Data\IV_data"


//merge data with electricity price instrument
use "$IV_pathname\first_stage", clear
destring zcta5, gen(county_utility) 
merge 1:m county_utility year using "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50"
ren _m merge_IV
drop if real_price_zip_mode==.

gen eleccost_countyIV = elec_priceIV*kwh
gen eleccost_countyIV2 = elec_priceIV2*kwh
gen eleccost_countyIV3 = elec_priceIV3*kwh

egen brand_id_num = group(brand_id)
egen state_num = group(state)

//create census division and region
gen census_division = 1 if state=="CT"|state=="ME"|state=="MA"|state=="NH"|state=="RI"|state=="VT"
replace census_division = 2 if state=="NJ"|state=="NY"|state=="PA"
replace census_division = 3 if state=="IN"|state=="IL"|state=="MI"|state=="OH"|state=="WI"
replace census_division = 4 if state=="IA"|state=="KS"|state=="MN"|state=="MO"|state=="NE"|state=="ND"|state=="SD"
replace census_division = 5 if state=="DE"|state=="DC"|state=="FL"|state=="GA"|state=="MD"|state=="NC"|state=="SC"|state=="VA"|state=="WV"
replace census_division = 6 if state=="AL"|state=="KY"|state=="MS"|state=="TN"
replace census_division = 7 if state=="AR"|state=="LA"|state=="OK"|state=="TX"
replace census_division = 8 if state=="AZ"|state=="CO"|state=="ID"|state=="NM"|state=="MT"|state=="UT"|state=="NV"|state=="WY"
replace census_division = 9 if state=="AK"|state=="HI"|state=="CA"|state=="OR"|state=="WA"

gen census_region = 1 if census_division<=2
replace census_region = 2 if census_division>2&census_division<=4
replace census_region = 3 if census_division>4&census_division<=7
replace census_region = 4 if census_division>=8

//create bins for heterogeneity analysis and robustness controls
gen kwh_bin2 = 0
gen kwh_bin3 = 0 
foreach x in 2008 2009 2010 2011 2012 {
	centile kwh if year==`x', centile(33 50 67)
	replace kwh_bin2 = 1 if kwh<r(c_2)&year==`x'
	replace kwh_bin2 = 2 if kwh>=r(c_2)&year==`x'
	replace kwh_bin3 = 1 if kwh<r(c_1)&year==`x'
	replace kwh_bin3 = 2 if kwh>=r(c_1)&kwh<r(c_3)&year==`x'
	replace kwh_bin3 = 3 if kwh>=r(c_3)
}

gen elec_bin2 = 0
gen elec_bin3 = 0 
foreach x in 2008 2009 2010 2011 2012 {
	centile pcounty_elec if year==`x', centile(33 50 67)
	replace elec_bin2 = 1 if pcounty_elec<r(c_2)&year==`x'
	replace elec_bin2 = 2 if pcounty_elec>=r(c_2)&year==`x'
	replace elec_bin3 = 1 if pcounty_elec<r(c_1)&year==`x'
	replace elec_bin3 = 2 if pcounty_elec>=r(c_1)&pcounty_elec<r(c_3)&year==`x'
	replace elec_bin3 = 3 if pcounty_elec>=r(c_3)
}

gen price_bin2 = 0
gen price_bin3 = 0 
gen price_bin4 = 0
foreach x in 2008 2009 2010 2011 2012 {
	centile real_price_zip_mode if year==`x', centile(25 33 50 67 75)
	replace price_bin2 = 1 if real_price_zip_mode<r(c_3)&year==`x'
	replace price_bin2 = 2 if real_price_zip_mode>=r(c_3)&year==`x'
	replace price_bin3 = 1 if real_price_zip_mode<r(c_2)&year==`x'
	replace price_bin3 = 2 if real_price_zip_mode>=r(c_2)&real_price_zip_mode<r(c_4)&year==`x'
	replace price_bin3 = 3 if real_price_zip_mode>=r(c_4)&year==`x'
	replace price_bin4 = 1 if real_price_zip_mode<r(c_1)&year==`x'
	replace price_bin4 = 2 if real_price_zip_mode>=r(c_1)&real_price_zip_mode<r(c_3)&year==`x'
	replace price_bin4 = 3 if real_price_zip_mode>=r(c_3)&real_price_zip_mode<r(c_5)&year==`x'
	replace price_bin4 = 4 if real_price_zip_mode>=r(c_5)&year==`x'
}
gen kwhxtype_bin2 = 2
gen kwhxtype_bin3 = 2
gen kwhxtype_bin4 = 2
foreach x in 2008 2009 2010 2011 2012 {
	forval t = 1/3 {
		centile kwh if year==`x' & type_id==`t', centile(25 33 50 67 75)
		replace kwhxtype_bin2 = 1 if kwh<r(c_3)&year==`x'&type_id==`t'
		replace kwhxtype_bin3 = 1 if kwh<r(c_2)&year==`x'&type_id==`t'
		replace kwhxtype_bin3 = 3 if kwh>=r(c_4)&year==`x'&type_id==`t'
		replace kwhxtype_bin4 = 1 if kwh<r(c_1)&year==`x'&type_id==`t'
		replace kwhxtype_bin4 = 3 if kwh>=r(c_3)&kwh<r(c_5)&year==`x'&type_id==`t'
		replace kwhxtype_bin4 = 4 if kwh>=r(c_5)&year==`x'&type_id==`t'
	}
}

// Prepare grouping estimator
bysort kwh_bin2 year: egen mean_kwh_bin2 = mean(kwh)
bysort kwh_bin3 year: egen mean_kwh_bin3 = mean(kwh)
bysort kwhxtype_bin2 year type_id: egen mean_kwh_type2 = mean(kwh)
bysort kwhxtype_bin3 year type_id: egen mean_kwh_type3 = mean(kwh)
bysort kwhxtype_bin4 year type_id: egen mean_kwh_type4 = mean(kwh)

gen group_kwhxtype_eleccost_county2 = (pcounty_elec/100)*mean_kwh_type2
gen group_kwhxtype_eleccost_county3 = (pcounty_elec/100)*mean_kwh_type3
gen group_kwhxtype_eleccost_county4 = (pcounty_elec/100)*mean_kwh_type4

// Promotional with leave one out
bys pid_id week_num: egen mean_promo_jw = mean(promo_f)
bys pid_id week_num: egen nb_promo_jw = count(promo_f)
gen nb_m1_promo_jw = nb_promo_jw - 1
gen mean_promo_out_jw = mean_promo_jw * (nb_promo_jw / nb_m1_promo_jw) - (promo_f/nb_promo_jw)

gen above_mean = kwh_bin2==2
gen above_mean_price = price_bin2==2


// Merge with demographic information
merge m:1 zipcode year week using "$pathname\demo_046_2008_2012_by_zip_week"
ren _m merge_w_demo
tab merge_w_demo

// Merge with utility county
merge m:1 county_utility year using "$pathname\utility_count", nogenerate

drop if sales_hd == .

xtile income_med3 = income_med, nq(3)

gen income_med4 = 1 if income_med<=5
replace income_med4 = 2 if income_med==6
replace income_med4 = 3 if income_med==7
replace income_med4 = 4 if income_med>7

// Create lags of the price variable
preserve

gen lag_price_mean   = real_price_zip_mode
gen lag_price_median = real_price_zip_mode

collapse(mean) lag_price_mean (median) lag_price_median,by(pid_id week_num)

xtset pid_id week_num
gen lag1_price_mean = L.lag_price_mean
gen lag2_price_mean = L2.lag_price_mean
gen lag3_price_mean = L3.lag_price_mean
gen lag4_price_mean = L4.lag_price_mean

drop lag_price_mean 
sort pid week_num
cd $pathdata
save "$pathname\lag_lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", replace

restore
merge m:1 pid_id week_num using "$pathname\lag_lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", nogenerate

//create a count of the assortment size per trimester
gen trimester =  (month_num <=4|(month_num>=13&month_num<=16)|(month_num>=25&month_num<=28)|(month_num>=37&month_num<=40)|(month_num>=49&month_num<=52))
replace trimester = 2 if (month_num>=5&month_num<=8)|(month_num>=17&month_num<=20)|(month_num>=29&month_num<=32)|(month_num>=41&month_num<=44)|(month_num>=53&month_num<=56)
replace trimester = 3 if (month_num>=9&month_num<=12)|(month_num>=21&month_num<=24)|(month_num>=33&month_num<=36)|(month_num>=45&month_num<=48)|(month_num>=57&month_num<=60)

preserve
collapse (count) sales_hd, by(pid_id zipcode trimester year)
collapse (count) assortment_size = pid_id, by(zipcode trimester year)
save temp, replace
restore

merge m:1 zipcode trimester year using temp, keep(match) nogenerate
erase temp.dta

//Create an indicator for no subsidy
bysort zipcode week_num: egen incentive_utility_ind = total(incentive_utility)
bysort zipcode week_num: egen incentive_cfa_ind = total(incentive_cfa)

replace incentive_utility_ind = 1 if incentive_utility_ind~=0
replace incentive_cfa_ind = 1 if incentive_cfa_ind~=0

//Bring in the sales indicator
merge m:1 pid week_num using "$pathname\promo_price_code_national_week"
drop _merge

//Rescale variables 

replace eleccost_county = eleccost_county/100
replace real_price_zip_mode = real_price_zip_mode/100
replace mean_promo_out_jw = mean_promo_out_jw/100
replace group_kwhxtype_eleccost_county2 = group_kwhxtype_eleccost_county2/100
replace group_kwhxtype_eleccost_county3 = group_kwhxtype_eleccost_county3/100
replace group_kwhxtype_eleccost_county4 = group_kwhxtype_eleccost_county4/100
replace eleccost_countyIV3 = eleccost_countyIV3/100
replace eleccost = eleccost/100
replace lag1_price_mean = lag1_price_mean/100
replace lag2_price_mean = lag2_price_mean/100
replace lag3_price_mean = lag3_price_mean/100
replace lag4_price_mean = lag4_price_mean/100

save "$pathname\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", replace


