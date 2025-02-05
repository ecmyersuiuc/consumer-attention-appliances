//do H:\Research\sears\estar_scripts\Process_Dsire_2007_2013.do


clear
set mem 1000m
set more off
global  pathname="H:\Research\sears\estar_data"
global  censuspath="H:\Research\data_all\census"
global  eiapath="H:\Research\data_all\EIA\stata_eia"  

pause on


use "$pathname/rebate/Cash4Appliances/cash4appliance_refrigerators_weekly_vf", clear
	keep  state year week incentive
	sort state year week
save "$pathname/rebate/Cash4Appliances/cash4appliance_refrigerators_weekly_vf_tmp", replace

use $pathname\rebate\DSIRE_rebate_week_county_2007, clear
	append using $pathname\rebate\DSIRE_rebate_week_county_2008
	append using $pathname\rebate\DSIRE_rebate_week_county_2009
	append using $pathname\rebate\DSIRE_rebate_week_county_2010
	append using $pathname\rebate\DSIRE_rebate_week_county_2011_2013
	replace state="CO" if state==""
	sort county_utility year week
save $pathname\rebate\DSIRE_rebate_week_county_2007_2013, replace


// sort state year week
// merge state year week using "$pathname/rebate/Cash4Appliances/cash4appliance_refrigerators_weekly_vf_tmp"
// tab _m
// drop _m
// mvencode incentive,mv(0)
// gen incentive_all=incentive+incentive_cfa
// save $pathname\rebate\rebate_utility_cfa_week_county_2007_2013, replace


use $pathname\rebate\DSIRE_rebate_week_state_2007, clear
	append using $pathname\rebate\DSIRE_rebate_week_state_2008
	append using $pathname\rebate\DSIRE_rebate_week_state_2009
	append using $pathname\rebate\DSIRE_rebate_week_state_2010
	append using $pathname\rebate\DSIRE_rebate_week_state_2011_2013
	sort state year week
save $pathname\rebate\DSIRE_rebate_week_state_2007_2013, replace


// sort state year week
// merge state year week using "$pathname/rebate/Cash4Appliances/cash4appliance_refrigerators_weekly_vf_tmp"
// tab _m
// drop _m
// gen incentive_all=incentive+incentive_cfa
// save $pathname\rebate\rebate_utility_cfa_week_state_2007_2013, replace
