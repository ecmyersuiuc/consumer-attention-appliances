//do H:\Research\sears\rebate_script\cash4appliances_v2.do
clear 

//This version use a version of the file cash4appliance_refrigerators.csv that has a different structure.
//The structure of the file is the following:
//Each line corresponds to a state-criterion rebate, on the same line you have the multiple open and end dates.

//Script used as of 11-22-2012


set mem 1000m
global  pathname="H:\Research\sears\estar_data\rebate"

/*
insheet using "$pathname/Cash4Appliances/cash4appliance.csv", clear 

ren v1 state
ren v2	product	
ren v3 reqs	
ren v4 rebate
ren v5	reb_str
ren v6	reb_end
ren v7	reb_str2
ren v8	reb_end2
ren v9	reb_str3
ren v10	reb_end3
ren v11	reb_str4
ren v12	reb_end4
ren v13	online
ren v14	comments
ren v15	allocation
drop if _n==1

keep if product=="Refrigerators"
*/

//This file was processed manually
insheet using "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012.csv", clear 

gen avg_rebate=(rebate1+rebate2)/2
replace avg_rebate=rebate1 if avg_rebate==.
gen avg_discount=(discount1*900+discount2*900)/2
replace avg_discount=discount1*900 if discount2==.
gen avg_all=(avg_rebate+avg_discount)/2
replace avg_all=avg_rebate if avg_discount==.
replace avg_all=avg_discount if avg_all==.
gen Drecycle=0
replace Drecycle=1 if reqs1_recycling=="yes"
gen Dmef=0
replace Dmef=1 if reqs1_mef!=.

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", replace 

pause on
pause

//1.
//Extract the first rebate

use "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", clear

sort state
by state: egen id=seq()
tab id
keep if id==1


gen str_datenum=date(reb_str, "MDY")
gen end_datenum=date(reb_end, "MDY")

gen duration=end_datenum-str_datenum

foreach x in duration{
	expand `x'+1
}

sort state reb_str
by state reb_str: egen timeid=seq()
gen datenum=str_datenum+timeid-1

gen year=year(datenum )
keep state datenum year avg* D* reqs1_mef
sort state datenum
save "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v1", replace

//Weekly
gen week=week(datenum)
collapse(mean) avg* D* reqs1_mef,by(state week year)
// gen week_str=week+2495
// format week_str %tw

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v1", replace


/*
//We create a long file, with WEEKLY observation for each state
//---------------------------------------------------------------------------------
use "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", clear

sort state
by state: egen id=seq()
tab id
keep if id==1


foreach x in reb_end{
replace `x'="December 12, 2010" if `x'=="-"
}
gen str_datenum=date(reb_str, "MDY")
gen end_datenum=date(reb_end, "MDY")

gen str_week=week(str_datenum)
gen end_week=week(end_datenum)


gen duration=end_week-str_week

foreach x in duration{
expand `x'+1
}

sort state reb_str
by state reb_str: egen timeid=seq()
gen week=str_week+timeid-1


gen year=year(str_datenum )
keep state week year avg* D* reqs1_mef
sort state week

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v1", replace
*/

//2.
//Extract the second rebate

use "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", clear 

sort state
by state: egen id=seq()
tab id
keep if id==1
keep if reb_str2!="-"

foreach x in reb_end2{
	replace `x'="December 12, 2010" if `x'=="-" & reb_str2!="-"
}
gen str_datenum=date(reb_str2, "MDY")
gen end_datenum=date(reb_end2, "MDY")

gen duration=end_datenum-str_datenum

foreach x in duration{
	expand `x'+1
}

sort state reb_str2
by state reb_str2: egen timeid=seq()
gen datenum=str_datenum+timeid-1


gen year=year(datenum )
keep state datenum year avg* D* reqs1_mef
sort state datenum

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v2", replace

//Weekly
gen week=week(datenum)
collapse(mean) avg* D* reqs1_mef,by(state week year)
// gen week_str=week+2495
// format week_str %tw

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v2", replace



/*
//We create a long file, with WEEKLY observation for each state
//---------------------------------------------------------------------------------
use "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", clear 

sort state
by state: egen id=seq()
tab id
keep if id==1
keep if reb_str2!="-"

foreach x in reb_end2{
	replace `x'="December 12, 2010" if `x'=="-" & reb_str2!="-"
}

gen str_datenum=date(reb_str2, "MDY")
gen end_datenum=date(reb_end2, "MDY")

gen str_week=week(str_datenum)
gen end_week=week(end_datenum)


gen duration=end_week-str_week

foreach x in duration{
expand `x'+1
}

sort state reb_str2
by state reb_str2: egen timeid=seq()
gen week=str_week+timeid-1


gen year=year(str_datenum )
keep state week year avg* D* reqs1_mef
sort state week

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v2", replace
*/

//3.
//Extract the first rebate, second round


use "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", clear

sort state
by state: egen id=seq()
tab id
keep if id==2

foreach x in reb_end{
	replace `x'="December 12, 2010" if `x'=="-"
}

gen str_datenum=date(reb_str, "MDY")
gen end_datenum=date(reb_end, "MDY")

gen duration=end_datenum-str_datenum

foreach x in duration{
	expand `x'+1
}

sort state reb_str
by state reb_str: egen timeid=seq()
gen datenum=str_datenum+timeid-1

gen year=year(datenum )
keep state datenum year avg* D* reqs1_mef
sort state datenum
save "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v3", replace

//Weekly
gen week=week(datenum)
collapse(mean) avg* D* reqs1_mef,by(state week year)
// gen week_str=week+2495
// format week_str %tw

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v3", replace



/*
//We create a long file, with WEEKLY observation for each state
//---------------------------------------------------------------------------------
use "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", clear

sort state
by state: egen id=seq()
tab id
keep if id==2

foreach x in reb_end{
replace `x'="December 12, 2010" if `x'=="-"
}
gen str_datenum=date(reb_str, "MDY")
gen end_datenum=date(reb_end, "MDY")

gen str_week=week(str_datenum)
gen end_week=week(end_datenum)


gen duration=end_week-str_week

foreach x in duration{
expand `x'+1
}

sort state reb_str
by state reb_str: egen timeid=seq()
gen week=str_week+timeid-1

gen year=year(str_datenum )
keep state week year avg* D* reqs1_mef
sort state week

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v3", replace
*/

//4.
//Extract the second rebate, second round

use "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", clear 

sort state
by state: egen id=seq()
tab id
keep if id==2
keep if reb_str2!="-"

foreach x in reb_end2{
	replace `x'="December 12, 2010" if `x'=="-" & reb_str2!="-"
}
gen str_datenum=date(reb_str2, "MDY")
gen end_datenum=date(reb_end2, "MDY")

gen duration=end_datenum-str_datenum

foreach x in duration{
	expand `x'+1
}

sort state reb_str2
by state reb_str2: egen timeid=seq()
gen datenum=str_datenum+timeid-1


gen year=year(datenum )
keep state datenum year avg* D* reqs1_mef
sort state datenum

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v4", replace

//Weekly
gen week=week(datenum)
collapse(mean) avg* D* reqs1_mef,by(state week year)
// gen week_str=week+2495
// format week_str %tw

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v4", replace


/*
//We create a long file, with WEEKLY observation for each state
//---------------------------------------------------------------------------------
use "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", clear 

sort state
by state: egen id=seq()
tab id
keep if id==2
keep if reb_str2!="-"

foreach x in reb_end2{
	replace `x'="December 12, 2010" if `x'=="-" & reb_str2!="-"
}

gen str_datenum=date(reb_str2, "MDY")
gen end_datenum=date(reb_end2, "MDY")

gen str_week=week(str_datenum)
gen end_week=week(end_datenum)


gen duration=end_week-str_week

foreach x in duration{
expand `x'+1
}

sort state reb_str2
by state reb_str2: egen timeid=seq()
gen week=str_week+timeid-1


gen year=year(str_datenum )
keep state week year avg* D* reqs1_mef
sort state week

save "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v4", replace
*/


///////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Create a weekly file with an "average rebate"
use "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v3", clear
	append using "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v4"
	ren avg_rebate avg_rebate2
	ren avg_discount avg_discount2
	ren avg_all avg_all2
	ren reqs1_mef reqs2_mef
	sort state year week
save "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v5", replace


use "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v1", clear
	append using "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v2"
	sort state year week
	merge state year week using "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_v5"
	tab _m
	gen incentive=(avg_all+avg_all2)/2 if _m==3
	replace incentive=avg_all if _m==1
	replace incentive=avg_all2 if _m==2	
    drop _m
    sort week state year
save  "$pathname/Cash4Appliances/cash4appliance_refrigerators_weekly_vf", replace

pause

//Create a daily file with an "average rebate"
use "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v3", clear
	append using "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v4"
	ren avg_rebate avg_rebate2
	ren avg_discount avg_discount2
	ren avg_all avg_all2
	ren reqs1_mef reqs2_mef
	sort state year datenum
save "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v5", replace


use "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v1", clear
	append using "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v2"
	sort state year datenum
	merge state year datenum using "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_v5"
	tab _m
	gen incentive=(avg_all+avg_all2)/2 if _m==3
	replace incentive=avg_all if _m==1
	replace incentive=avg_all2 if _m==2	
    drop _m
    sort state  datenum 
save  "$pathname/Cash4Appliances/cash4appliance_refrigerators_daily_vf", replace



use "$pathname/Cash4Appliances/cash4appliance_refrigerators_11212012", clear
	gen st_datenum1=date(reb_str, "MDY")
	gen st_datenum2=date(reb_str2, "MDY")
	collapse(mean) st_datenum*,by(state)
	sort state
save "$pathname/Cash4Appliances/starts_refrigerators", replace



