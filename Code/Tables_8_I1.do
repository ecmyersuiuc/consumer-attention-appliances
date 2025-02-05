//do /Users/shoude/Dropbox/eegap/Replication_JPube_RR/Tables_8_I1_R2.do


// Dependencies: 
//         Agreggate raw transaction data at the pid-zip-week (or month) level:
//              -do /Users/shoude/Dropbox/eegap/EEgap_scripts/create_choice_set_struct_rd_byHD_2008_2012.do
//         Create regressors      
// 				-do /Users/shoude/Dropbox/eegap/EEgap_scripts/prepare_reducedform_reg.do
//         Create electricity price Borenstein and Bushnell
//				-do /Users/shoude/Dropbox/eegap/EEgap_scripts/PolicyAnalysis_Jpube/Make_p_elec_social_BorensteinBushnell.do

clear all
set more off
set maxvar 15000
set matsize 9000
pause off

//Set Paths Here

//Erica's server
global  datapath_retail = "C:\Users\erica.myers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Data"
global  datapath_IV     = "C:\Users\erica.myers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Data\IV_data"
global  pathresults     = "C:\Users\erica.myers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Results"
global  datapath_elec   = "C:\Users\erica.myers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Data\EIA_861"



*we get the variable "county_name" from here
use "$datapath_IV/first_stage", clear
destring zcta5, gen(county_utility) 
merge 1:m county_utility year using "$datapath_retail/lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50"
ren _m merge_IV
tempfile mainfile
save `mainfile', replace


// Bup old electricity prices 
ren pcounty_elec bup_pcounty_elec
ren eleccost_county bup_eleccost_county


//Select counties for which we observe county-level electricity prices 
use "$datapath_elec/county_elec_price_2007_2012.dta", clear
sort county_utility year
merge 1:m county_utility year using `mainfile'
tab _m
replace pcounty_elec = . if _m==2
drop _m
unique(county_utility year) if pcounty_elec~=.

//Bring social electricity prices computed by Borenstein and Bushnell 
sort county_utility year
merge m:1 county_utility year using "$datapath_elec/county_elec_price_social_2007_2012.dta"
tab _m
drop _m


//Generate the various electricity costs used for policy simulation
//For the estimation
replace eleccost_county = kwh*pcounty_elec/100
//Social marginal cost
gen eleccost_smc = kwh*smc
//Private marginal cost
gen eleccost_pmc = kwh*pmc
//Private average cost
gen eleccost_avc = kwh*avc

//Rescalling
replace eleccost_county = eleccost_county/100
replace real_price_zip_mode = real_price_zip_mode/100
replace eleccost_smc =  eleccost_smc/100
replace eleccost_pmc =  eleccost_pmc/100
replace eleccost_avc =  eleccost_avc/100

// Controls for FE
egen zipXweek = group(zipcode week_num)

egen brand_id_num = group(brand_id)

gen census_division = 1 if state=="CT"|state=="ME"|state=="MA"|state=="NH"|state=="RI"|state=="VT"
replace census_division = 2 if state=="NJ"|state=="NY"|state=="PA"
replace census_division = 3 if state=="IN"|state=="IL"|state=="MI"|state=="OH"|state=="WI"
replace census_division = 4 if state=="IA"|state=="KS"|state=="MN"|state=="MO"|state=="NE"|state=="ND"|state=="SD"
replace census_division = 5 if state=="DE"|state=="DC"|state=="FL"|state=="GA"|state=="MD"|state=="NC"|state=="SC"|state=="VA"|state=="WV"
replace census_division = 6 if state=="AL"|state=="KY"|state=="MS"|state=="TN"
replace census_division = 7 if state=="AR"|state=="LA"|state=="OK"|state=="TX"
replace census_division = 8 if state=="AZ"|state=="CO"|state=="ID"|state=="NM"|state=="MT"|state=="UT"|state=="NV"|state=="WY"
replace census_division = 9 if state=="AK"|state=="HI"|state=="CA"|state=="OR"|state=="WA"


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Policy Simulation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
**************************************************************************************************************************************************************************************************************
* Outline
* Simulate with three electricity prices: avc, avc+C02, smc 
* Simulate with three m ratios: mean, IC_binf, IC_bsup
*  theta_hat = -2.074; s.e. = 0.177
*  b_sup = -2.42269, scalling factor: 1.168124397
*  b_inf = -1.72531, scalling factor: 0.831875603 
* Specification that we use: Specification 4 of first (main) regression table
*
* High income (tercile 3) Specification 2 Table 7: m = 1.349
* Scalling factor m = 1.349/1.037 = 1.300867888
* Low income (tercile 1) Specification 2 Table 7: m = 1.349
* Scalling factor m = 0.967/1.037 = 0.932497589
**************************************************************************************************************************************************************************************************************
eststo clear


gen eleccost_county_bup = eleccost_county

//Specification 4: First regression table
//countyXyear, countyEE-related, countyXbrand, weekXbrand, pid
eststo: ppmlhdfe sales_hd real_price_zip_mode eleccost_county rebate_estar , absorb(i.county_utility##i.year i.county_utility##i.s_estar i.county_utility##i.size_id i.county_utility##i.type_id i.county_utility##i.brand_id_num pid_id brand_week_num) vce(cluster county_utility) d(sum_FE) 


predict sales_hat_eleccost_county

// For price: avc
replace eleccost_county = eleccost_avc
predict sales_hat_avc

replace eleccost_county = 1.168124397*eleccost_avc
predict sales_hat_avc_sup

replace eleccost_county = 0.831875603*eleccost_avc
predict sales_hat_avc_inf

replace eleccost_county = 0.288059395*eleccost_avc
predict sales_hat_avc_low

replace eleccost_county = 1.300867888*eleccost_avc
predict sales_hat_avc_inc3

replace eleccost_county = 0.932497589*eleccost_avc
predict sales_hat_avc_inc1

// For price: smc
replace eleccost_county = eleccost_smc
predict sales_hat_smc

replace eleccost_county = 1.168124397*eleccost_smc
predict sales_hat_smc_sup

replace eleccost_county = 0.831875603*eleccost_smc
predict sales_hat_smc_inf

replace eleccost_county = 0.288059395*eleccost_smc
predict sales_hat_smc_low

// For price: avc + CO2
gen eleccost_co2 = kwh*((co2)+avc)
replace eleccost_co2 =  eleccost_co2/100
replace eleccost_county = eleccost_co2
predict sales_hat_co2

replace eleccost_county = 1.168124397*eleccost_co2
predict sales_hat_co2_sup

replace eleccost_county = 0.831875603*eleccost_co2
predict sales_hat_co2_inf

replace eleccost_county = 0.288059395*eleccost_co2
predict sales_hat_co2_low

// For price: avc + 0.5*CO2
gen eleccost_0p5co2 = kwh*((0.5*co2)+avc)
replace eleccost_0p5co2 =  eleccost_0p5co2/100
replace eleccost_county = eleccost_0p5co2
predict sales_hat_0p5co2

replace eleccost_county = 1.168124397*eleccost_0p5co2
predict sales_hat_0p5co2_sup

replace eleccost_county = 0.831875603*eleccost_0p5co2
predict sales_hat_0p5co2_inf

replace eleccost_county = 0.288059395*eleccost_0p5co2
predict sales_hat_0p5co2_low

// For price: avc + 1.5*CO2
gen eleccost_1p5co2 = kwh*((1.5*co2)+avc)
replace eleccost_1p5co2 =  eleccost_1p5co2/100
replace eleccost_county = eleccost_1p5co2
predict sales_hat_1p5co2

replace eleccost_county = 1.168124397*eleccost_1p5co2
predict sales_hat_1p5co2_sup

replace eleccost_county = 0.831875603*eleccost_1p5co2
predict sales_hat_1p5co2_inf

replace eleccost_county = 0.288059395*eleccost_1p5co2
predict sales_hat_1p5co2_low


// For price: avc MINUS CO2
gen eleccost_mco2 = kwh*(avc-co2)
replace eleccost_mco2 =  eleccost_mco2/100
replace eleccost_county = eleccost_mco2
predict sales_hat_mco2

replace eleccost_county = 1.168124397*eleccost_mco2
predict sales_hat_mco2_sup

replace eleccost_county = 0.831875603*eleccost_mco2
predict sales_hat_mco2_inf

replace eleccost_county = 0.288059395*eleccost_mco2
predict sales_hat_mco2_low

// For price: pmc
replace eleccost_county = eleccost_pmc
predict sales_hat_pmc

replace eleccost_county = 1.168124397*eleccost_pmc
predict sales_hat_pmc_sup

replace eleccost_county = 0.831875603*eleccost_pmc
predict sales_hat_pmc_inf

replace eleccost_county = 0.288059395*eleccost_pmc
predict sales_hat_pmc_low

gen kwh_base = sales_hat_eleccost_county*kwh
gen kwh_smc  = sales_hat_smc*kwh
gen kwh_pmc  = sales_hat_pmc*kwh
gen kwh_avc  = sales_hat_avc*kwh
gen kwh_co2  = sales_hat_co2*kwh
gen kwh_mco2    = sales_hat_mco2*kwh
gen kwh_0p5co2  = sales_hat_0p5co2*kwh
gen kwh_1p5co2  = sales_hat_1p5co2*kwh

gen kwh_smc_sup  = sales_hat_smc_sup*kwh
gen kwh_pmc_sup  = sales_hat_pmc_sup*kwh
gen kwh_avc_sup  = sales_hat_avc_sup*kwh
gen kwh_co2_sup  = sales_hat_co2_sup*kwh
gen kwh_mco2_sup  = sales_hat_mco2_sup*kwh
gen kwh_0p5co2_sup = sales_hat_0p5co2_sup*kwh
gen kwh_1p5co2_sup = sales_hat_1p5co2_sup*kwh

gen kwh_smc_inf  = sales_hat_smc_inf*kwh
gen kwh_pmc_inf  = sales_hat_pmc_inf*kwh
gen kwh_avc_inf  = sales_hat_avc_inf*kwh
gen kwh_co2_inf  = sales_hat_co2_inf*kwh
gen kwh_mco2_inf  = sales_hat_mco2_inf*kwh
gen kwh_0p5co2_inf  = sales_hat_0p5co2_inf*kwh
gen kwh_1p5co2_inf  = sales_hat_1p5co2_inf*kwh

gen kwh_smc_low  = sales_hat_smc_low*kwh
gen kwh_pmc_low  = sales_hat_pmc_low*kwh
gen kwh_avc_low  = sales_hat_avc_low*kwh
gen kwh_co2_low  = sales_hat_co2_low*kwh
gen kwh_mco2_low  = sales_hat_mco2_low*kwh
gen kwh_0p5co2_low  = sales_hat_0p5co2_low*kwh
gen kwh_1p5co2_low  = sales_hat_1p5co2_low*kwh

gen kwh_avc_inc3  = sales_hat_avc_inc3*kwh
gen kwh_avc_inc1  = sales_hat_avc_inc1*kwh


gen pct_kwh_co2     = ( kwh_co2-kwh_avc ) / kwh_avc 
gen delta_kwh_co2   = ( kwh_co2-kwh_avc ) 
gen delta_ext_co2   = ( kwh_co2-kwh_avc ) * co2
gen pct_price_co2   =  co2 / avc
gen elast_co2       = pct_kwh_co2 / pct_price_co2

gen pct_kwh_co2_sup     = ( kwh_co2_sup-kwh_avc_sup ) / kwh_avc_sup
gen delta_kwh_co2_sup   = ( kwh_co2_sup-kwh_avc_sup ) 
gen delta_ext_co2_sup   = ( kwh_co2_sup-kwh_avc_sup ) * co2 
gen elast_co2_sup       = pct_kwh_co2_sup / pct_price_co2

gen pct_kwh_co2_inf     = ( kwh_co2_inf-kwh_avc_inf ) / kwh_avc_inf 
gen delta_kwh_co2_inf   = ( kwh_co2_inf-kwh_avc_inf ) 
gen delta_ext_co2_inf   = ( kwh_co2_inf-kwh_avc_inf ) * co2 
gen elast_co2_inf       = pct_kwh_co2_inf / pct_price_co2

gen pct_kwh_co2_low     = ( kwh_co2_low - kwh_avc_low ) / kwh_avc_low 
gen delta_kwh_co2_low   = ( kwh_co2_low - kwh_avc_low ) 
gen delta_ext_co2_low   = ( kwh_co2_low - kwh_avc_low ) * co2 
gen elast_co2_low       = pct_kwh_co2_low / pct_price_co2

gen pct_kwh_mco2     = ( kwh_mco2-kwh_avc ) / kwh_avc 
gen delta_kwh_mco2   = ( kwh_mco2-kwh_avc ) 
gen delta_ext_mco2   = ( kwh_mco2-kwh_avc ) * co2
gen pct_price_mco2   =  -co2 / avc
gen elast_mco2       = pct_kwh_mco2 / pct_price_mco2

gen pct_kwh_mco2_sup     = ( kwh_mco2_sup-kwh_avc_sup ) / kwh_avc_sup
gen delta_kwh_mco2_sup   = ( kwh_mco2_sup-kwh_avc_sup ) 
gen delta_ext_mco2_sup   = ( kwh_mco2_sup-kwh_avc_sup ) * co2 
gen elast_mco2_sup       = pct_kwh_mco2_sup / pct_price_mco2

gen pct_kwh_mco2_inf     = ( kwh_mco2_inf-kwh_avc_inf ) / kwh_avc_inf 
gen delta_kwh_mco2_inf   = ( kwh_mco2_inf-kwh_avc_inf ) 
gen delta_ext_mco2_inf   = ( kwh_mco2_inf-kwh_avc_inf ) * co2 
gen elast_mco2_inf       = pct_kwh_mco2_inf / pct_price_mco2

gen pct_kwh_mco2_low     = ( kwh_mco2_low - kwh_avc_low ) / kwh_avc_low 
gen delta_kwh_mco2_low   = ( kwh_mco2_low - kwh_avc_low ) 
gen delta_ext_mco2_low   = ( kwh_mco2_low - kwh_avc_low ) * co2 
gen elast_mco2_low       = pct_kwh_mco2_low / pct_price_mco2



gen pct_kwh_0p5co2     = ( kwh_0p5co2-kwh_avc ) / kwh_avc 
gen delta_kwh_0p5co2   = ( kwh_0p5co2-kwh_avc ) 
gen delta_ext_0p5co2   = ( kwh_0p5co2-kwh_avc ) * co2
gen pct_price_0p5co2   =  0.5*co2 / avc
gen elast_0p5co2       = pct_kwh_0p5co2 / pct_price_0p5co2

gen pct_kwh_0p5co2_sup     = ( kwh_0p5co2_sup-kwh_avc_sup ) / kwh_avc_sup
gen delta_kwh_0p5co2_sup   = ( kwh_0p5co2_sup-kwh_avc_sup ) 
gen delta_ext_0p5co2_sup   = ( kwh_0p5co2_sup-kwh_avc_sup ) * co2 
gen elast_0p5co2_sup       = pct_kwh_0p5co2_sup / pct_price_0p5co2

gen pct_kwh_0p5co2_inf     = ( kwh_0p5co2_inf-kwh_avc_inf ) / kwh_avc_inf 
gen delta_kwh_0p5co2_inf   = ( kwh_0p5co2_inf-kwh_avc_inf ) 
gen delta_ext_0p5co2_inf   = ( kwh_0p5co2_inf-kwh_avc_inf ) * co2 
gen elast_0p5co2_inf       = pct_kwh_0p5co2_inf / pct_price_0p5co2

gen pct_kwh_0p5co2_low     = ( kwh_0p5co2_low - kwh_avc_low ) / kwh_avc_low 
gen delta_kwh_0p5co2_low   = ( kwh_0p5co2_low - kwh_avc_low ) 
gen delta_ext_0p5co2_low   = ( kwh_0p5co2_low - kwh_avc_low ) * co2 
gen elast_0p5co2_low       = pct_kwh_0p5co2_low / pct_price_0p5co2



gen pct_kwh_1p5co2     = ( kwh_1p5co2-kwh_avc ) / kwh_avc 
gen delta_kwh_1p5co2   = ( kwh_1p5co2-kwh_avc ) 
gen delta_ext_1p5co2   = ( kwh_1p5co2-kwh_avc ) * co2
gen pct_price_1p5co2   =  1.5*co2 / avc
gen elast_1p5co2       = pct_kwh_1p5co2 / pct_price_1p5co2

gen pct_kwh_1p5co2_sup     = ( kwh_1p5co2_sup-kwh_avc_sup ) / kwh_avc_sup
gen delta_kwh_1p5co2_sup   = ( kwh_1p5co2_sup-kwh_avc_sup ) 
gen delta_ext_1p5co2_sup   = ( kwh_1p5co2_sup-kwh_avc_sup ) * co2 
gen elast_1p5co2_sup       = pct_kwh_1p5co2_sup / pct_price_1p5co2

gen pct_kwh_1p5co2_inf     = ( kwh_1p5co2_inf-kwh_avc_inf ) / kwh_avc_inf 
gen delta_kwh_1p5co2_inf   = ( kwh_1p5co2_inf-kwh_avc_inf ) 
gen delta_ext_1p5co2_inf   = ( kwh_1p5co2_inf-kwh_avc_inf ) * co2 
gen elast_1p5co2_inf       = pct_kwh_1p5co2_inf / pct_price_1p5co2

gen pct_kwh_1p5co2_low     = ( kwh_1p5co2_low - kwh_avc_low ) / kwh_avc_low 
gen delta_kwh_1p5co2_low   = ( kwh_1p5co2_low - kwh_avc_low ) 
gen delta_ext_1p5co2_low   = ( kwh_1p5co2_low - kwh_avc_low ) * co2 
gen elast_1p5co2_low       = pct_kwh_1p5co2_low / pct_price_1p5co2



gen pct_kwh_smc   = ( kwh_smc-kwh_avc ) / kwh_avc 
gen delta_kwh_smc = ( kwh_smc-kwh_avc ) 
gen delta_ext_smc = ( kwh_smc-kwh_avc ) * ( smc-avc )  
gen pct_price_smc = ( smc-avc ) / avc
gen elast_smc     = pct_kwh_smc / pct_price_smc

gen pct_kwh_smc_sup   = ( kwh_smc_sup-kwh_avc_sup ) / kwh_avc_sup 
gen delta_kwh_smc_sup = ( kwh_smc_sup-kwh_avc_sup ) 
gen delta_ext_smc_sup = ( kwh_smc_sup-kwh_avc_sup ) * ( smc-avc )  
gen elast_smc_sup     = pct_kwh_smc_sup / pct_price_smc

gen pct_kwh_smc_inf   = ( kwh_smc_inf-kwh_avc_inf ) / kwh_avc_inf 
gen delta_kwh_smc_inf = ( kwh_smc_inf-kwh_avc_inf ) 
gen delta_ext_smc_inf = ( kwh_smc_inf-kwh_avc_inf ) * ( smc-avc )  
gen elast_smc_inf     = pct_kwh_smc_inf / pct_price_smc

gen pct_kwh_smc_low   = ( kwh_smc_low - kwh_avc_low ) / kwh_avc_low 
gen delta_kwh_smc_low = ( kwh_smc_low - kwh_avc_low ) 
gen delta_ext_smc_low = ( kwh_smc_low - kwh_avc_low ) * ( smc-avc )  
gen elast_smc_low     = pct_kwh_smc_low / pct_price_smc


gen pct_kwh_avc_inc3     = ( kwh_avc_inc3-kwh_avc ) / kwh_avc 
gen delta_kwh_avc_inc3   = ( kwh_avc_inc3-kwh_avc  ) 

gen pct_kwh_avc_inc1     = ( kwh_avc_inc1-kwh_avc ) / kwh_avc 
gen delta_kwh_avc_inc1   = ( kwh_avc_inc1-kwh_avc  ) 

gen pct_kwh_avc_co2_inc3     = ( kwh_avc_inc3-kwh_co2 ) / kwh_co2 
gen delta_kwh_avc_co2_inc3   = ( kwh_avc_inc3-kwh_co2 ) 

gen pct_kwh_avc_smc_inc1     = ( kwh_avc_inc1-kwh_smc ) / kwh_smc 
gen delta_kwh_avc_smc_inc1   = ( kwh_avc_inc1-kwh_smc  ) 


*sort county_utility

save "$datapath_retail/lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_predicted_policy", replace


preserve
keep delta_kwh_* delta_ext_* pct_kwh_*  pct_price_* elast_* eleccost_* kwh kwh_* county_utility county_name
collapse(sum) delta_kwh_* delta_ext_*  (median) pct_kwh_*  pct_price_* elast_* (mean) eleccost_* kwh kwh_* ,by(county_utility county_name) fast
format delta* pct* elast* kwh* %20.8f
save "$pathresults/predicted_policy_county", replace

restore

preserve
keep delta_kwh_* delta_ext_* pct_kwh_*  pct_price_* elast_* eleccost_* kwh kwh_* 
collapse(sum) delta_kwh_* delta_ext_* (median) pct_kwh_*  pct_price_* elast_* (mean) eleccost_* kwh kwh_* fast
format delta* pct* elast* kwh* %20.8f
save "$pathresults/predicted_policy_national", replace

restore


/*
//Policy simulation
//Table

///MAIN PAPER///////
                mean      s.d.
scenario 1
pct_price_co2 
pct_kwh_co2 [pct_kwh_co2_sup, pct_kwh_co2_inf]
elast_co2 [elast_co2_sup, elast_co2_inf]

scenario 2
pct_price_smc 
pct_kwh_smc [pct_kwh_smc_sup, pct_kwh_smc_inf]
elast_smc [elast_smc_sup, elast_smc_inf]

///APPENDIX///////
scenario 3
pct_price_mco2
pct_kwh_mco2 
elast_mco2 

scenario 4
pct_price_0p5co2
pct_kwh_0p5co2 
elast_0p5co2 

scenario 5
pct_price_1p5co2
pct_kwh_1p5co2
elast_1p5co2

Total change in kwh (retailer fridge market)
Total change in kwh (US fridge market)
Total change in CO2 ext costs (retailer fridge  market)
Total change in CO2 ext costs  (US fridge market)
Total change in kwh (US large appliance market)
Total change in CO2 ext costs  (US large appliance market)
*/

*log close    







