* This .do file creates county electricity prices using:  
*Census Bureau’s FIPS code: counties_FIPS.dta
*EIA’s mapping of utility to county: utility_county_`year’.csv for the years 2007 to 2012
*EIA consumption and revenue data for each utility: cons_`year’.csv for the years 2007 to 2012
*Output: 

clear 
set mem 1000m
set more off
pause on


global  pathname "[Put your path to the replication folder here]/EEgap_data_code_heter_SM/Data/EIA_861"


use $pathname/counties_FIPS, clear
		sort county_name state
save $pathname/counties_FIPS, replace
	ren county5 county_FIPS
	append using "$pathname/county_utils_w_FIPS"
	duplicates drop county_name state, force
	keep county_name state county_FIPS
	sort county_name state
	replace county_FIPS=12086 if county_FIPS==12025 
save $pathname/counties_FIPS_Wdup, replace

insheet using "$pathname/utility_county_2012.csv", clear    
	sort utility_id
save "$pathname/utility_county_2012", replace

insheet using "$pathname/utility_county_2011.csv", clear    
	sort utility_id
save "$pathname/utility_county_2011", replace

insheet using "$pathname/utility_county_2010.csv", clear    
	sort utility_id
save "$pathname/utility_county_2010", replace

insheet using "$pathname/utility_county_2009.csv", clear    
	sort utility_id
save "$pathname/utility_county_2009", replace

insheet using "$pathname/utility_county_2008.csv", clear    
	sort utility_id
save "$pathname/utility_county_2008", replace

insheet using "$pathname/utility_county_2007.csv", clear    
	sort utility_id
save "$pathname/utility_county_2007", replace


use "$pathname/utility_county_2012", clear
	append using  "$pathname/utility_county_2011"
	append using  "$pathname/utility_county_2010"
	append using  "$pathname/utility_county_2009"
	append using  "$pathname/utility_county_2008"
	append using  "$pathname/utility_county_2007"
	
duplicates drop utility_id state county_name, force
	replace county_name="San Bernardino" if county_name=="San Bernadino"
	replace county_name="St. Clair" if county_name=="Saint Clair"
	replace county_name="Grand Traverse" if county_name=="Grand Traverse, Ingham, Ionia"
	replace county_name="Prince George's" if county_name=="Prince Georges"
    replace county_name="St. Louis" if county_name=="St Louis"
    replace county_name="St. Charles" if county_name=="Saint Charles"
	replace county_name="St. Louis" if county_name=="Saint Louis"
	replace county_name="St. Francois" if county_name=="Saint Francois"
	replace county_name="Chesapeake (city)" if county_name=="Chesapeake C"
	replace county_name="Chesapeake (city)" if county_name=="Chesapeake City"
	replace county_name="Manassas (city)" if county_name=="Manassas Cit"
	replace county_name="Manassas (city)" if county_name=="Manassas City"
	replace county_name="Manassas (city)" if county_name=="Manassas City"
	replace county_name="Newport News (city)" if county_name=="Newport News City"
	replace county_name="Roanoke (city)" if county_name=="Roanoke"
	replace county_name="Virginia Beach (city)" if county_name=="Virginia Bea"
	replace county_name="Virginia Beach (city)" if county_name=="Virginia Beach"
	replace county_name="Virginia Beach (city)" if county_name=="Virginia Beach City"
	replace county_name="Winchester City" if county_name=="Winchester"
	replace county_name="Winchester City" if county_name=="Winchester C"

	duplicates drop utility_id state county_name, force
 	keep utility_id state county_name
	sort utility_id state
save "$pathname/utility_county_2007_2012", replace
	
//=====================================================================

insheet using "$pathname/cons_2012.csv", clear
    drop if  service_type=="Delivery"
	ren state_code state
/*	
    sort  utility_id state
    joinby utility_id state using "$pathname/utility_county_2007_2012"
/*
//This piece of code shows the within county standard deviation in non-weighted electricity prices.
//This is less than 1.5 cent.
    gen pavg=100* residential_revenues / residential_sales
    sort county_name state
    by county_name state: egen sd_county=sd(pavg)
*/
       
    sort  county_name state
    merge county_name state using  $pathname/counties_FIPS_Wdup
    tab _m
    drop _m
*/
   
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
//	ren county_FIPS county_utility
    //ren county5 county_utility
	sort state year 
    by state year : egen residential_revenues_s=sum(residential_revenues)
    by state year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(state year )
 	gen pstate_elec=100*residential_revenues/residential_sales
// 	drop if pstate_elec>120
// 	drop if pstate_elec<2
 	sort state year 
	save $pathname/state_elec_price_2012_rep, replace


    
insheet using "$pathname/cons_2011.csv", clear
	drop if  service_type=="Delivery"
	ren state_code state
/*
    sort  utility_id state
    joinby utility_id state using "$pathname/utility_county_2007_2012"
	sort  county_name state
    merge county_name state using  $pathname/counties_FIPS_Wdup
    tab _m
    drop _m
*/
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
//	ren county_FIPS county_utility

    sort state year 
    by state year : egen residential_revenues_s=sum(residential_revenues)
    by state year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(state year)
 	gen pstate_elec=100*residential_revenues/residential_sales
// 	drop if pstate>120
// 	drop if pstate<2
 	sort state year 
	save $pathname/state_elec_price_2011_rep, replace
*outsheet using  $pathname/electricity\county_elec_price_2011.csv, comma replace noquote

 
insheet using "$pathname/cons_2010.csv", clear
 	drop if  service_type=="Delivery"
	ren state_code state
   /*
    sort  utility_id state
    joinby utility_id state using "$pathname/utility_county_2007_2012"
	sort  county_name state
    merge county_name state using  $pathname/counties_FIPS_Wdup
    tab _m
    drop _m
*/
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
//	ren county_FIPS county_utility

    sort state year 
    by state year : egen residential_revenues_s=sum(residential_revenues)
    by state year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(state year)
 	gen pstate_elec=100*residential_revenues/residential_sales
// 	drop if pstate>120
// 	drop if pstate<2
 	sort state year 
	save $pathname/state_elec_price_2010_rep, replace


insheet using "$pathname/cons_2009.csv", clear
	drop if  service_type=="Delivery"
	ren state_code state
  /*
    sort  utility_id state
    joinby utility_id state using "$pathname/utility_county_2007_2012"
	sort  county_name state
    merge county_name state using  $pathname/counties_FIPS_Wdup
    tab _m
    drop _m
*/
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
//	ren county_FIPS county_utility

    sort state year 
    by state year : egen residential_revenues_s=sum(residential_revenues)
    by state year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(state year)
 	gen pstate_elec=100*residential_revenues/residential_sales
// 	drop if pstate>120
// 	drop if pstate<2
 	sort state year 
	save $pathname/state_elec_price_2009_rep, replace

    
insheet using "$pathname/cons_2008.csv", clear
    drop if  service_type=="Delivery"
	ren state_code state
   /*
    sort  utility_id state
    joinby utility_id state using "$pathname/utility_county_2007_2012"
	sort  county_name state
    merge county_name state using  $pathname/counties_FIPS_Wdup
    tab _m
    drop _m
*/
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
//	ren county_FIPS county_utility

    sort state year 
    by state year : egen residential_revenues_s=sum(residential_revenues)
    by state year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(state year)
 	gen pstate_elec=100*residential_revenues/residential_sales
// 	drop if pstate>120
// 	drop if pstate<2
 	sort state year 
	save $pathname/state_elec_price_2008_rep, replace
*outsheet using  $pathname/electricity\county_elec_price_2008.csv, comma replace noquote


insheet using "$pathname/cons_2007.csv", clear
    drop if  service_type=="Delivery"
	ren state_code state
   /*
    sort  utility_id state
    joinby utility_id state using "$pathname/utility_county_2007_2012"
	sort  county_name state
    merge county_name state using  $pathname/counties_FIPS_Wdup
    tab _m
    drop _m
*/
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
//	ren county_FIPS county_utility

    sort state year 
    by state year : egen residential_revenues_s=sum(residential_revenues)
    by state year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(state year)
 	gen pstate_elec=100*residential_revenues/residential_sales
// 	drop if pstate>120
// 	drop if pstate<2
 	sort state year 
	save $pathname/state_elec_price_2007_rep, replace
*outsheet using  $pathname/electricity\county_elec_price_2007.csv, comma replace noquote

 

use $pathname/state_elec_price_2012_rep, clear
	append using $pathname/state_elec_price_2011_rep
	append using $pathname/state_elec_price_2010_rep
	append using $pathname/state_elec_price_2009_rep
	append using $pathname/state_elec_price_2008_rep
	append using $pathname/state_elec_price_2007_rep
	keep state year pstate_elec
	order state year pstate_elec
	sort state year 
//save  $pathname/state_elec_price_2007_2012_rep, replace 	
save  $pathname/state_elec_price_2007_2012, replace 	



	    
    



    
    