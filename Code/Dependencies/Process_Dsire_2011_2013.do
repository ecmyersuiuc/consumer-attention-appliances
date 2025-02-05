//do \\fs02\d01\SHoude\EEgap\EEgap_scripts\Process_Dsire_2011_2013.do 

clear
set mem 1000m
set more off
pause off
global  pathname="H:\Research\sears\estar_data"
global  censuspath="H:\Research\data_all\census"
global  eiapath="H:\Research\data_all\EIA\stata_eia"


use "$eiapath\county_utils_w_FIPS_v2", clear
	capture drop _m
	capture drop state_name
	gen county_FIPS=fipsstate+fipscounty
	destring  county_FIPS, replace
	sort utility_name year state
save "$eiapath\county_utils_w_FIPS_v2_tmp", replace


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

insheet using $pathname\rebate\DSIRE_rebate_refrigerators_2011_2013.csv, clear
save $pathname\rebate\DSIRE_rebate_refrigerators_2011_2013, replace


//incentivetype=="Sales Tax Incentive"

keep if incentivetype=="Local Rebate Program" |  incentivetype=="Utility Rebate Program" 

drop if  incentiveappldsc=="Agricultural"
drop if  incentiveappldsc=="Agricultural,Commercial,Construction,Industrial,Installer/Contractor"
drop if  incentiveappldsc=="Agricultural,Commercial,Construction,Industrial,Institutional,Local Government,Nonprofit,Schools,State Government"
drop if  incentiveappldsc=="Agricultural,Commercial,Construction,Industrial,Institutional,Local Government,Nonprofit,State Government"
drop if  incentiveappldsc=="Agricultural,Commercial,Construction,Industrial,Institutional,Nonprofit,Schools"
drop if  incentiveappldsc=="Agricultural,Commercial,Fed. Government,Industrial,Institutional,Local Government,Nonprofit,State Government"
drop if  incentiveappldsc=="Agricultural,Commercial,Industrial,Institutional,Nonprofit,Schools"
drop if  incentiveappldsc=="Commercial,Fed. Government,Industrial,Institutional,Local Government,Nonprofit,Schools,State Government"
drop if  incentiveappldsc=="Commercial,Fed. Government,Industrial,Institutional,Local Government,Schools,State Government"
drop if  incentiveappldsc=="Commercial,Fed. Government,Industrial,Local Government,Nonprofit,State Government"
drop if  incentiveappldsc=="Commercial,Fed. Government,Local Government,Nonprofit,Retail Supplier,State Government"
drop if  incentiveappldsc=="Commercial,Fed. Government,Local Government,Nonprofit,State Government"
drop if  incentiveappldsc=="Commercial,Industrial"
drop if  incentiveappldsc=="Commercial,Industrial,Institutional"
drop if  incentiveappldsc=="Commercial,Industrial,Institutional,Local Government,Nonprofit,State Government"
drop if  incentiveappldsc=="Commercial,Industrial,Institutional,Local Government,State Government"
drop if  incentiveappldsc=="Commercial,Industrial,Local Government,Nonprofit,State Government"
drop if  incentiveappldsc=="Commercial,Industrial,Local Government,Schools,State Government"
drop if  incentiveappldsc=="Commercial,Industrial,Nonprofit"
drop if  incentiveappldsc=="Commercial,Industrial,Nonprofit,Local Government,State Government,Fed. Government"
drop if  incentiveappldsc=="Commercial,Institutional,Nonprofit"
drop if  incentiveappldsc=="Construction"
drop if  incentiveappldsc=="Nonprofit,Local Government,State Government,Fed. Government"

destring high, replace force

gen str_date=date(incentivestartdatestring,"MDY")
gen end_date=date(incentiveexpiredtstring,"MDY")

gen add_date=date(dsiredtadd,"MDY")
gen upd_date=date(dsirelstupdt,"MDY")
gen inc_date=date(incentiveinactdt,"MDY")

replace end_date=inc_date if end_date==.
replace end_date=upd_date 

gen year_end=year(end_date)
drop if year_end<2011

replace str_date=add_date if str_date==.

	ren incentiveprogadmin utility_name
	ren place state_name
	
	gen year=year(str_date)
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
	drop if _m==2
	ren _m merge1
	sort utility_name
// 	merge utility_name using $pathname\rebate\utility_name_refrigerator_rebate_03082013
// 	ren _m merge2
// 	replace id=0 if merge2==3 & utility_name2!=""
// 	replace  utility_name=utility_name2 if merge2==3 & utility_name2!=""
// 	
//manually process	
	
	keep   appliance low high pagename state_name incentivename dsireid utility_name str_date end_date year state incentivecontzip incentivecontplace
	sort utility_name

save $pathname\rebate\DSIRE_rebate_2011_2013_tmp, replace
	

insheet using $pathname\rebate\utility_name_refrigerator_rebate_03092013.csv, clear
	keep utility_name* 
	sort utility_name 
save $pathname\rebate\utility_name_refrigerator_rebate_03092013, replace

insheet using $pathname\rebate\utility_name_refrigerator_rebate_03082013.csv, clear
	keep if _m==1
	keep utility_name* 
	sort utility_name 
save $pathname\rebate\utility_name_refrigerator_rebate_03082013, replace


use $pathname\rebate\DSIRE_rebate_2007_2011_tmp, clear
	merge utility_name using $pathname\rebate\utility_name_refrigerator_rebate_03082013
 	tab _m
 	drop _m
 	replace utility_name=utility_name2 if utility_name2!=""
 	sort utility_name
 	merge utility_name using $pathname\rebate\utility_name_refrigerator_rebate_03092013
 	tab _m
 	drop _m
 	replace utility_name=utility_name3 if utility_name3!=""

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
	
	gen zipcode=substr(incentivecontzip,1,5) 
	destring zipcode, replace
	sort zipcode
/*	
	merge zipcode using $censuspath\mapping_zip_county_nov99
	drop if _m==2
    drop _m
    replace county_utility=county5 if  county_utility==.
*/	
	pause
	
	keep high low zipcode county_utility utility_id utility_name str_date end_date year state_utility state_name
	ren state_utility state
	gen incentive=high
	replace incentive=(low+high)/2 if low!=. & high!=.
	replace incentive=low if low!=. & high==.
save $pathname\rebate\DSIRE_rebate_2007_2011_cleaned, replace
	 
pause

drop if incentive==.
drop if county_utility==.
replace end_date=19383  if end_date==-19905 

collapse(mean) incentive,by(utility_name county_utility state str_date end_date)

gen duration=end_date-str_date
foreach x in duration {
		expand `x'
}

sort utility_name incentive county_utility state str_date end_date
by utility_name incentive county_utility state str_date end_date: egen time_id=seq()

gen datenum=time_id+str_date

gen week=week(datenum)
gen year=year(datenum)

gen week_end=week(end_date)
gen week_str=week(str_date)

gen year_end=year(end_date)
gen year_str=year(str_date)

drop if year<2011

	collapse(mean) incentive,by(county_utility state week year)
	sort county_utility
save $pathname\rebate\DSIRE_rebate_week_county_2011_2013, replace

	replace state="CO" if state==""
	collapse(mean) incentive,by(state week year)
	sort state
save $pathname\rebate\DSIRE_rebate_week_state_2011_2013, replace


pause

//Comparison with 2008
use $pathname\rebate\Dsire_incentives_refrig_county, clear
	keep  county_FIPS utility_name  amount_refrigerator
 	ren county_ county_utility
 	ren utility_name utility_old
	sort county_utility
	merge county_utility using  $pathname\rebate\DSIRE_rebate_week_county_2007_2011
	tab _m
 







