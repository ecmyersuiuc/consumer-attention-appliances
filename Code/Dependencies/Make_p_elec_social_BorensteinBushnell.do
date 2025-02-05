// do /Users/shoude/Dropbox/eegap/EEgap_scripts/PolicyAnalysis_Jpube/Make_p_elec_social_BorensteinBushnell.do


*This .do file takes the average utility-level social marginal costs and average marginal costs from B&B and maps them to counties by taking the residential consumers-weighted average across utilities that serve a given county

global datapath_bb = "[Put your path to replication folder here]\Replication_JPubE_RR\Data\Borenstein Bushnell"
global datapath_elec   = "[Put your path to replication folder here]\Replication_JPubE_RR\Data\EIA_861"


use "$datapath_bb/retail_final_Borenstein_Bushnell", clear
ren eia_id_d utility_id
collapse(mean) avgcharge, by(utility_id state)

sort utility_id state 	
save "$datapath_bb/utility_id_elec_price_avgcharge.dta", replace 


use "$datapath_bb/calc_annual", clear
ren eia_id_d utility_id
collapse(mean) varcharge price damagesCO2 damagesNOX damagesPM25 damagesSO2 smc pmc emc,by(utility_id state)

sort utility_id state 
merge utility_id state using "$datapath_bb/utility_id_elec_price_avgcharge.dta"
tab _m
drop _m
ren avgcharge avc
sort utility_id state 
save "$datapath_bb/utility_id_elec_price_social.dta", replace 


// We now create a county average using the 2012 sales.
insheet using "$datapath_elec/cons_2012.csv", clear

keep if year ==2012

// Merge Borenstein & Bushnell's fixed charge data
sort utility_id 
ren state_code state
merge m:1 utility_id state using "$datapath_bb/utility_id_elec_price_social.dta"
tab _m
drop if _m == 2
ren _m merge_social

    drop if  service_type=="Delivery"
	sort  utility_id state
    joinby utility_id state using "$datapath_elec/utility_county_2007_2012"

    sort  county_name state
    merge county_name state using  "$datapath_elec/counties_FIPS_Wdup"
    tab _m
    drop _m

    
//Revenues: Thousands Dollars	
//Sales: Megawatthours
	
// Compute Borenstein & Bushnell's average smc (social), pmc (private), and emc (externality) marginal prices

	sort state
	by state : egen smc_state=mean(smc)
	by state : egen emc_state=mean(emc)
	by state : egen pmc_state=mean(pmc)
	by state : egen avc_state=mean(avc)
	by state : egen co2_state=mean(damagesCO2)
	
*If social marginal costs are missing, give them their state level value
	replace smc = smc_state if smc == . | smc == 0
	replace emc = emc_state if emc == . | emc == 0
	replace pmc = pmc_state if pmc == . | pmc == 0
	replace avc = avc_state if avc == . | avc == 0
	gen co2 = damagesCO2
	replace co2 = co2_state if co2 == . | co2 == 0

	egen smc_nat = mean(smc)
	egen emc_nat = mean(emc)
	egen pmc_nat = mean(pmc)
	egen avc_nat = mean(avc)
	egen co2_nat = mean(co2)

*Alaska and Hawaii get the national average as B&B do not provide data on that
	replace smc = smc_nat if smc == . | smc == 0
	replace emc = emc_nat if emc == . | emc == 0
	replace pmc = pmc_nat if pmc == . | pmc == 0
	replace avc = avc_nat if avc == . | avc == 0
	replace co2 = co2_nat if co2 == . | co2 == 0

//This tweak ensures that for the few utilities with zero consumers, we use a simple average.
	replace residential_consumers = 1 if residential_consumers == 0 
	replace residential_consumers = 1 if residential_consumers == . 

    gen w_smc = smc*residential_consumers
	gen w_emc = emc*residential_consumers
	gen w_pmc = pmc*residential_consumers
	gen w_avc = avc*residential_consumers
	gen w_co2 = co2*residential_consumers

	ren county_FIPS county_utility
	sort county_utility
	by county_utility: egen w_smc_tmp = sum(w_smc)
	by county_utility: egen w_emc_tmp = sum(w_emc)
	by county_utility: egen w_pmc_tmp = sum(w_pmc)
	by county_utility: egen w_avc_tmp = sum(w_avc)
	by county_utility: egen w_co2_tmp = sum(w_co2)
	by county_utility: egen residential_consumers_tmp = sum(residential_consumers)
 
 	collapse (mean) w_smc_tmp w_pmc_tmp w_emc_tmp w_avc_tmp w_co2_tmp residential_consumers_tmp, by(county_utility)
	
	gen  smc  = w_smc/residential_consumers
	gen  pmc  = w_pmc/residential_consumers
	gen  emc  = w_emc/residential_consumers
	gen  avc  = w_avc/residential_consumers
	gen  co2  = w_co2/residential_consumers

	gen year = 2012

	expand 5
	sort county_utility year 
	by county_utility: egen tmp_id=seq()
	replace year = 2008 if tmp_id == 1
	replace year = 2009 if tmp_id == 2
	replace year = 2010 if tmp_id == 3
	replace year = 2011 if tmp_id == 4

	keep county_utility year smc pmc emc avc co2
	sort county_utility year
save "$datapath_bb/county_elec_price_social_2007_2012.dta", replace 







 



