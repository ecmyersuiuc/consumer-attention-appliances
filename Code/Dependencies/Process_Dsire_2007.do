//do \\fs02\d01\SHoude\EEgap\EEgap_scripts\Process_Dsire_2007.do 



clear
set mem 1000m
set more off
global  pathname="H:\Research\sears\estar_data"
global  censuspath="H:\Research\data_all\census"
global  eiapath="H:\Research\data_all\EIA\stata_eia"

pause on

use "$eiapath\county_utils_w_FIPS_v2", clear
	capture drop _m
	capture drop state_name
	gen county_FIPS=fipsstate+fipscounty
	destring  county_FIPS, replace
	sort utility_name year state
save "$eiapath\county_utils_w_FIPS_v2_tmp", replace

pause

insheet using $censuspath\mapping_zip_county_nov99.csv, clear
	replace state=state*1000
	gen county5=state+county
	ren zip_code zipcode
	sort zipcode
save $censuspath\mapping_zip_county_nov99, replace


insheet using $pathname\rebate\Dsire_Organization_2008.csv, clear
	ren org_org_code org_code 
	sort org_code
save $pathname\rebate\Dsire_Organization_2008, replace

//This file match full state names to acronyms
insheet using  $censuspath\state_accro.txt, clear
	ren v2 state
	ren v1 state_name
	keep state_name state
	order state_name state
	egen state_id=seq()
	sort state_name
save   $censuspath\state_accro, replace 

//insheet using $pathname\rebate\DSIRE_rebate_2007_2011.csv, clear
//save $pathname\rebate\DSIRE_rebate_2007_2011, replace

insheet using $pathname\rebate\DSIRE_rebate_refrigerators_2007.csv, clear
save $pathname\rebate\DSIRE_rebate_refrigerators_2007, replace

keep if residential=="TRUE"
keep if incentive_type=="Utility Rebate Program" |  incentive_type=="Local Rebate Program" | incentive_type=="State Rebate Program"

destring high, replace force

	gen year=2007

	split program_name,parse(" - ")
	ren program_name1 utility_name
	sort utility_name year
	merge utility_name year using "$eiapath\county_utils_w_FIPS_v2_tmp"
	tab _m 
    sort utility_name
	gen id=0
	replace id=1 if _m==1 & utility_name!=""
	foreach x in id{
		replace `x'=1 if _m[_n]==2 & _m[_n-1]==1
		replace `x'=1 if _m[_n]==2 & _m[_n+1]==1
	}
	//drop if _m==2
	ren _m merge1
	sort utility_name
// 	merge utility_name using $pathname\rebate\utility_name_refrigerator_rebate_03082013
// 	ren _m merge2
// 	replace id=0 if merge2==3 & utility_name2!=""
// 	replace  utility_name=utility_name2 if merge2==3 & utility_name2!=""
// 	
//manually process	
//	br if id==1

	drop if merge1==2
	ren state state_name
	keep   appliance low high utility_name state_name year
	sort utility_name

save $pathname\rebate\DSIRE_rebate_2007, replace
	

//Create a file (manually) with utility name
insheet using $pathname\rebate\utility_name_refrigerator_rebate_2007_03092013.csv, clear
	keep if merge1==1
	keep utility_name* 
	ren utility_name2 utility_name2007
	sort utility_name 
save $pathname\rebate\utility_name_refrigerator_rebate_2007_03092013, replace

insheet using $pathname\rebate\utility_name_refrigerator_rebate_03092013.csv, clear
	keep utility_name*   incentivecontzip
	ren  incentivecontzip zipcode
	sort utility_name 
save $pathname\rebate\utility_name_refrigerator_rebate_03092013, replace

insheet using $pathname\rebate\utility_name_refrigerator_rebate_03082013.csv, clear
	keep if _m==1
	keep utility_name* 
	sort utility_name 
save $pathname\rebate\utility_name_refrigerator_rebate_03082013, replace

merge utility_name using  $pathname\rebate\utility_name_refrigerator_rebate_2007_03092013
	drop _m
	sort utility_name 
merge utility_name using $pathname\rebate\utility_name_refrigerator_rebate_03092013
	drop _m
	sort utility_name
save $pathname\rebate\utility_name_refrigerator_rebate_2007_2013, replace



use $pathname\rebate\DSIRE_rebate_2007, clear
	merge utility_name using $pathname\rebate\utility_name_refrigerator_rebate_2007_2013
 	tab _m
 	drop if _m==2
 	drop _m
 	replace utility_name=utility_name2007 if utility_name2007!=""
 	replace utility_name=utility_name2 if utility_name2!="" & utility_name2007==""
 	replace utility_name=utility_name3 if utility_name3!="" & utility_name2007=="" & utility_name2==""

 	sort state_name
	merge state_name using $censuspath\state_accro
	drop if _m==2
	drop _m
	 	
 	sort utility_name year state
	merge utility_name year state using "$eiapath\county_utils_w_FIPS_v2_tmp"
	tab _m 
	drop if _m==2
	drop _m

	
	pause 
	
	ren county_FIPS county_utility 
	ren state state_utility
	
	
	replace zipcode=substr(zipcode,1,5) 
	destring zipcode, replace
	sort zipcode
/*	
	merge zipcode using $censuspath\mapping_zip_county_nov99
	drop if _m==2
    drop _m
    replace county_utility=county5 if  county_utility==.
*/	
	pause
	
	keep high low zipcode county_utility utility_id utility_name year state_utility state_name
	ren state_utility state
	gen incentive=high
	replace incentive=(low+high)/2 if low!=. & high!=.
	replace incentive=low if low!=. & high==.
save $pathname\rebate\DSIRE_rebate_2007_cleaned, replace
	 
pause

drop if incentive==.
drop if county_utility==.


collapse(mean) incentive,by(utility_name county_utility state year)

expand 52


sort utility_name county_utility state
by utility_name county_utility state: egen week=seq()

pause

	collapse(mean) incentive,by(county_utility state week year)
	sort county_utility
save $pathname\rebate\DSIRE_rebate_week_county_2007, replace

	replace state="CO" if state==""
	collapse(mean) incentive,by(state week year)
	sort state
save $pathname\rebate\DSIRE_rebate_week_state_2007, replace


pause

//Comparison with 2008
use $pathname\rebate\Dsire_incentives_refrig_county, clear
	keep  county_FIPS utility_name  amount_refrigerator
 	ren county_ county_utility
 	ren utility_name utility_old
	sort county_utility
	merge county_utility using  $pathname\rebate\DSIRE_rebate_week_county_2007_2011
	tab _m
 
