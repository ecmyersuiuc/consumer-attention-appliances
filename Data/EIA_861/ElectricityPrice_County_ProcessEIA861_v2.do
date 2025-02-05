//do H:\Research\sears\estar_scripts\ElectricityPrice_County_ProcessEIA861_v2.do
//Documentation



clear 
set mem 1000m
set more off
pause on

global  eiapath="H:\Research\data_all\EIA"
global  censuspath="H:\Research\data_all\census"
global  pathname="H:\Research\sears\estar_data"

//This file is based on 2007 data. 
/*
use "$eiapath\stata_eia\county_utils_w_FIPS", clear
	sort county_name state
save "$eiapath\stata_eia\county_utils_w_FIPS", replace
*/


use $censuspath\counties_FIPS, clear
		sort county_name state
save $censuspath\counties_FIPS, replace
	ren county5 county_FIPS
	append using "$eiapath\stata_eia\county_utils_w_FIPS"
	duplicates drop county_name state, force
	keep county_name state county_FIPS
	sort county_name state
	replace county_FIPS=12086 if county_FIPS==12025 
save $censuspath\counties_FIPS_Wdup, replace

insheet using "$eiapath\f8612012\utility_county_2012.csv", clear    
	sort utility_id
save "$eiapath\f8612012\utility_county_2012", replace

insheet using "$eiapath\f86111\utility_county_2011.csv", clear    
	sort utility_id
save "$eiapath\f86111\utility_county_2011", replace

insheet using "$eiapath\f86110\utility_county_2010.csv", clear    
	sort utility_id
save "$eiapath\f86110\utility_county_2010", replace

insheet using "$eiapath\f86109\utility_county_2009.csv", clear    
	sort utility_id
save "$eiapath\f86109\utility_county_2009", replace

insheet using "$eiapath\f86108\utility_county_2008.csv", clear    
	sort utility_id
save "$eiapath\f86108\utility_county_2008", replace

insheet using "$eiapath\f86107\utility_county_2007.csv", clear    
	sort utility_id
save "$eiapath\f86107\utility_county_2007", replace


use "$eiapath\f8612012\utility_county_2012", clear
	append using  "$eiapath\f86111\utility_county_2011"
	append using  "$eiapath\f86110\utility_county_2010"
	append using  "$eiapath\f86109\utility_county_2009"
	append using  "$eiapath\f86108\utility_county_2008"
	append using  "$eiapath\f86107\utility_county_2007"
	
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
save "$eiapath\utility_county_2007_2012", replace
	
//=====================================================================

insheet using "$eiapath\f8612012\cons_2012.csv", clear
    drop if  service_type=="Delivery"
	ren state_code state
    sort  utility_id state
    joinby utility_id state using "$eiapath\utility_county_2007_2012"
/*
//This piece of code shows the within county standard deviation in non-weighted electricity prices.
//This is less than 1.5 cent.
    gen pavg=100* residential_revenues / residential_sales
    sort county_name state
    by county_name state: egen sd_county=sd(pavg)
*/
       
    sort  county_name state
    merge county_name state using  $censuspath\counties_FIPS_Wdup
    tab _m
    drop _m
    
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
	ren county_FIPS county_utility
    //ren county5 county_utility
	sort county_utility year 
    by county_utility year : egen residential_revenues_s=sum(residential_revenues)
    by county_utility year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(county_utility year )
 	gen pcounty_elec=100*residential_revenues/residential_sales
 	drop if pcount>120
 	drop if pcount<2
 	sort county_utility year 
	save $pathname\electricity\county_elec_price_2012, replace
outsheet using  $pathname\electricity\county_elec_price_2012.csv, comma replace noquote


    
insheet using "$eiapath\f86111\cons_2011.csv", clear
	drop if  service_type=="Delivery"
	ren state_code state
    sort  utility_id state
    joinby utility_id state using "$eiapath\utility_county_2007_2012"
	sort  county_name state
    merge county_name state using  $censuspath\counties_FIPS_Wdup
    tab _m
    drop _m
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
	ren county_FIPS county_utility
    sort county_utility year 
    by county_utility year : egen residential_revenues_s=sum(residential_revenues)
    by county_utility year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(county_utility year)
 	gen pcounty_elec=100*residential_revenues/residential_sales
 	drop if pcount>120
 	drop if pcount<2
 	sort county_utility year 
	save $pathname\electricity\county_elec_price_2011, replace
outsheet using  $pathname\electricity\county_elec_price_2011.csv, comma replace noquote

 
insheet using "$eiapath\f86110\cons_2010.csv", clear
 	drop if  service_type=="Delivery"
	ren state_code state
    sort  utility_id state
    joinby utility_id state using "$eiapath\utility_county_2007_2012"
	sort  county_name state
    merge county_name state using  $censuspath\counties_FIPS_Wdup
    tab _m
    drop _m
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
	ren county_FIPS county_utility
    sort county_utility year 
    by county_utility year : egen residential_revenues_s=sum(residential_revenues)
    by county_utility year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(county_utility year)
 	gen pcounty_elec=100*residential_revenues/residential_sales
 	drop if pcount>120
 	drop if pcount<2
 	sort county_utility year 
	save $pathname\electricity\county_elec_price_2010, replace
outsheet using  $pathname\electricity\county_elec_price_2010.csv, comma replace noquote


insheet using "$eiapath\f86109\cons_2009.csv", clear
	drop if  service_type=="Delivery"
	ren state_code state
    sort  utility_id state
    joinby utility_id state using "$eiapath\utility_county_2007_2012"
	sort  county_name state
    merge county_name state using  $censuspath\counties_FIPS_Wdup
    tab _m
    drop _m
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
	ren county_FIPS county_utility
    sort county_utility year
    by county_utility year : egen residential_revenues_s=sum(residential_revenues)
    by county_utility year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(county_utility year )
 	gen pcounty_elec=100*residential_revenues/residential_sales
 	drop if pcount>120
 	drop if pcount<2
 	sort county_utility year 
	save $pathname\electricity\county_elec_price_2009, replace
outsheet using  $pathname\electricity\county_elec_price_2009.csv, comma replace noquote

    
insheet using "$eiapath\f86108\cons_2008.csv", clear
    drop if  service_type=="Delivery"
	ren state_code state
    sort  utility_id state
    joinby utility_id state using "$eiapath\utility_county_2007_2012"

	sort  county_name state
    merge county_name state using  $censuspath\counties_FIPS_Wdup
    tab _m
    drop _m
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
	ren county_FIPS county_utility
    sort county_utility year
    by county_utility year : egen residential_revenues_s=sum(residential_revenues)
    by county_utility year : egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(county_utility year)
 	gen pcounty_elec=100*residential_revenues/residential_sales
 	drop if pcount>120
 	drop if pcount<2
 	sort county_utility year 
	save $pathname\electricity\county_elec_price_2008, replace
outsheet using  $pathname\electricity\county_elec_price_2008.csv, comma replace noquote


insheet using "$eiapath\f86107\cons_2007.csv", clear
    drop if  service_type=="Delivery"
	ren state_code state
    sort  utility_id state
    joinby utility_id state using "$eiapath\utility_county_2007_2012"
	sort  county_name state
    merge county_name state using  $censuspath\counties_FIPS_Wdup
    tab _m
    drop _m
//Revenues: Thousands Dollars	
//Sales: Megawatthours
    destring residential_revenues	 residential_sales,replace force
//egen is skippin missing values    
	ren county_FIPS county_utility
    sort county_utility year 
    by county_utility year : egen residential_revenues_s=sum(residential_revenues)
    by county_utility year: egen residential_sales_s=sum(residential_sales)
    
 	collapse(mean) residential_revenues_s residential_sales_s,by(county_utility year)
 	gen pcounty_elec=100*residential_revenues/residential_sales
 	drop if pcount>120
 	drop if pcount<2
 	sort county_utility year 
	save $pathname\electricity\county_elec_price_2007, replace
outsheet using  $pathname\electricity\county_elec_price_2007.csv, comma replace noquote

 

use $pathname\electricity\county_elec_price_2012, clear
	append using $pathname\electricity\county_elec_price_2011
	append using $pathname\electricity\county_elec_price_2010
	append using $pathname\electricity\county_elec_price_2009
	append using $pathname\electricity\county_elec_price_2008
	append using $pathname\electricity\county_elec_price_2007
	keep county_utility year pcounty_elec
	order county_utility year pcounty_elec
	sort county_utility year 
save  $pathname\electricity\county_elec_price_2007_2012, replace 
	
	

//Check    
use $pathname\electricity\county_price_tmp, clear
	sort  county_utility year
save $pathname\electricity\county_price_tmp, replace   
 
use $pathname\electricity\county_elec_price_2011, clear
ren pcounty_elec pcounty_2011_revised
	append using $pathname\electricity\county_elec_price_2010
ren pcounty_elec pcounty_2010_revised	
	append using $pathname\electricity\county_elec_price_2009
ren pcounty_elec pcounty_2009_revised
	append using $pathname\electricity\county_elec_price_2008
ren pcounty_elec pcounty_2008_revised
	append using $pathname\electricity\county_elec_price_2007
ren pcounty_elec pcounty_2007_revised	

	keep county_utility year pcounty_*
	sort county_utility year
	merge county_utility year using $pathname\electricity\county_price_tmp
	    
    



    
    