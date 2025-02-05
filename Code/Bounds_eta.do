//do /Users/shoude/Dropbox/eegap/Replication_JPube_RR/Bounds_eta.do


clear all
set more off
set maxvar 15000
set matsize 9000
pause off

//Erica's server
//global  datapath_retail = "C:\Users\ecmyers\Dropbox\eegap\EEgap_data\Retailer"
//global  datapath_IV     = "C:\Users\ecmyers\Dropbox\eegap\EEgap_data\IV_data"
//global  pathresults     = "C:\Users\ecmyers\Dropbox\eegap\EEgap_results"
//global  datapath_policy = "C:\Users\ecmyers\Dropbox\eegap\EEgap_data\PolicyAnalysis_Jpube"
//global  datapath_elec   = "C:\Users\ecmyers\Dropbox\eegap\EEgap_data\EIA_861"


//Sebastien's server
global  datapath_retail = "/Users/shoude/Dropbox/eegap/EEgap_data/Retailer"
global  datapath_IV     = "/Users/shoude/Dropbox/eegap/EEgap_data/IV_data"
global  pathresults     = "/Users/shoude/Dropbox/eegap/EEgap_results"
global  datapath_policy = "/Users/shoude/Dropbox/eegap/EEgap_data/PolicyAnalysis_Jpube"
global  datapath_elec   = "/Users/shoude/Dropbox/eegap/EEgap_data/EIA_861"


use "$datapath_retail/bup/lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

keep sales_hd pid zipcode week year real_price_zip_mode
bys zipcode week year: egen sales_rt = sum(sales_hd) 
gen mshare_jrt = sales_hd/sales_rt

gen eta = -0.226
gen theta = -2.074
gen rho_5 = 1/(1+0.05)
gen LLC_5_12 = rho_5*(1-rho_5^12)/(1-rho_5)  
gen lambda = 0.9
gen elas_own = eta*real_price_zip_mode*(1-0.5*mshare_jrt)


gen eta_m5p  =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1-0.05))))
gen eta_m10p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1-0.1))))
gen eta_m15p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1-0.15))))
gen eta_m20p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1-0.20))))
gen eta_m25p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1-0.25))))
gen eta_m30p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1-0.30))))
gen eta_5p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+0.05))))
gen eta_10p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+0.10))))
gen eta_15p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+0.15))))
gen eta_20p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+0.20))))
gen eta_25p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+0.25))))
gen eta_30p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+0.30))))
gen eta_40p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+0.40))))
gen eta_50p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+0.50))))
gen eta_75p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+0.75))))
gen eta_100p =  elas_own/(real_price_zip_mode*(1/lambda + mshare_jrt*( (lambda-1)/lambda - 0.5*(1+1))))


/*
gen eta_m10p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1-0.10))
gen eta_m15p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1-0.15))
gen eta_m20p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1-0.20))
gen eta_m25p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1-0.25))
gen eta_m30p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1-0.30))
gen eta_5p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+0.05))
gen eta_10p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+0.10))
gen eta_15p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+0.15))
gen eta_20p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+0.20))
gen eta_25p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+0.25))
gen eta_30p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+0.30))
gen eta_40p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+0.40))
gen eta_50p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+0.50))
gen eta_75p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+0.75))
gen eta_100p =  elas_own/(real_price_zip_mode*(1-mshare_jrt)*(1+1))
*/

gen m = theta/(eta*LLC_5_12)
gen m_m5p =  theta/(eta_m5p*LLC_5_12)
gen m_m10p =  theta/(eta_m10p*LLC_5_12)
gen m_m15p =  theta/(eta_m15p*LLC_5_12)
gen m_m20p =  theta/(eta_m20p*LLC_5_12)
gen m_m25p =  theta/(eta_m25p*LLC_5_12)
gen m_m30p =  theta/(eta_m30p*LLC_5_12)
gen m_5p =  theta/(eta_5p*LLC_5_12)
gen m_10p =  theta/(eta_10p*LLC_5_12)
gen m_15p =  theta/(eta_15p*LLC_5_12)
gen m_20p =  theta/(eta_20p*LLC_5_12)
gen m_25p =  theta/(eta_25p*LLC_5_12)
gen m_30p =  theta/(eta_30p*LLC_5_12)
gen m_40p =  theta/(eta_40p*LLC_5_12)
gen m_50p =  theta/(eta_50p*LLC_5_12)
gen m_75p =  theta/(eta_75p*LLC_5_12)
gen m_100p =  theta/(eta_100p*LLC_5_12)

sum eta
sum elas_own
sum eta_*
sum m*










