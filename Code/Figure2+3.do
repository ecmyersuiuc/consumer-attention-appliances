*This .do file creates data summary figures
clear
clear matrix


set mem 200m
set matsize 800
set more off

global dirpath "[Put your path to the replication folder here]/Replication_JPubE_RR"

***************************************************************************************************************************************************
*STEP 1: GET A SENSE OF CROSS-SECTIONAL VARIATION AND VARIATION OVER TIME IN PRICE
***************************************************************************************************************************************************

use "$dirpath\Data\EIA_861\mapping_zip_county_nov99", clear
ren state state_code
merge 1:m zipcode using "$dirpath\Data\lcidemo_046_2008_2012_allsales", keep(match) nogenerate
ren state state_letter
ren state_code state

ren county5 county_utility
merge m:1 county_utility year using "$dirpath\Data\EIA_861\EIA_861\county_elec_price_2007_2012", keep(match) nogenerate

collapse pcounty_elec, by(county_utility state_letter year)
ren state_letter state
gen region = 4 if state=="WA"|state=="OR"|state=="CA"|state=="HI"|state=="AK"|state=="ID"|state=="MT"|state=="WY"|state=="NV"|state=="UT"|state=="CO"|state=="AZ"|state=="NM"
replace region = 2 if state=="ND"|state=="SD"|state=="MN"|state=="NE"|state=="IA"|state=="KS"|state=="MO"|state=="WI"|state=="IL"|state=="IN"|state=="MI"|state=="OH"
replace region = 1 if state=="ME"|state=="VT"|state=="NH"|state=="MA"|state=="CT"|state=="RI"|state=="NY"|state=="PA"|state=="NJ"
replace region = 3 if region==.

gen division = 9 if state=="WA"|state=="OR"|state=="CA"|state=="HI"|state=="AK"
replace division = 8 if state=="ID"|state=="MT"|state=="WY"|state=="NV"|state=="UT"|state=="CO"|state=="AZ"|state=="NM"
replace division = 7 if state=="AR"|state=="LA"|state=="OK"|state=="TX"
replace division = 6 if state=="AL"|state=="KY"|state=="MS"|state=="TN"
replace division = 4 if state=="ND"|state=="SD"|state=="MN"|state=="NE"|state=="IA"|state=="KS"|state=="MO"
replace division = 3 if state=="WI"|state=="IL"|state=="IN"|state=="MI"|state=="OH"
replace division = 2 if state=="NY"|state=="PA"|state=="NJ"
replace division = 1 if state=="ME"|state=="VT"|state=="NH"|state=="MA"|state=="CT"|state=="RI"
replace division = 5 if division==.

save "$dirpath\Data\prices_regions_divisions", replace

use "$dirpath\Data\prices_regions_divisions", clear

collapse pcounty_elec, by(year state)

twoway (line pcounty_elec year if state=="ME", lwidth(thin)) || (line pcounty_elec year if state=="VT", lwidth(thin)) ///
|| (line pcounty_elec year if state=="NH", lwidth(thin)) || (line pcounty_elec year if state=="MA", lwidth(thin)) ///
|| (line pcounty_elec year if state=="CT", lwidth(thin)) || (line pcounty_elec year if state=="RI", lwidth(thin)), ///
legend(off) title(New England) ytitle("cents/kwh") xtitle(year) yscale(range(6 21)) ylabel(6(4)21) name(d1, replace) scheme(s1color) nodraw

twoway (line pcounty_elec year if state=="NY", lwidth(thin)) || (line pcounty_elec year if state=="PA", lwidth(thin)) ///
|| (line pcounty_elec year if state=="NJ", lwidth(thin)), ///
legend(off) title(Middle Atlantic) ytitle("cents/kwh") xtitle(year) yscale(range(6 21)) ylabel(6(4)21) name(d2, replace) scheme(s1color) nodraw

twoway (line pcounty_elec year if state=="WI", lwidth(thin)) || (line pcounty_elec year if state=="IL", lwidth(thin)) ///
|| (line pcounty_elec year if state=="IN", lwidth(thin)) || (line pcounty_elec year if state=="MI", lwidth(thin)) ///
|| (line pcounty_elec year if state=="OH", lwidth(thin)), ///
legend(off) title(East North Central) ytitle("cents/kwh") xtitle(year) yscale(range(6 21)) ylabel(6(4)21) name(d3, replace) scheme(s1color) nodraw

twoway (line pcounty_elec year if state=="ND", lwidth(thin)) || (line pcounty_elec year if state=="SD", lwidth(thin)) ///
|| (line pcounty_elec year if state=="MN", lwidth(thin)) || (line pcounty_elec year if state=="NE", lwidth(thin)) ///
|| (line pcounty_elec year if state=="IA", lwidth(thin)) || (line pcounty_elec year if state=="KS", lwidth(thin)) ///
|| (line pcounty_elec year if state=="MO", lwidth(thin)), ///
legend(off) title(West North Central) ytitle("cents/kwh") xtitle(year) yscale(range(6 21)) ylabel(6(4)21) name(d4, replace) scheme(s1color) nodraw

twoway (line pcounty_elec year if state=="DE", lwidth(thin)) || (line pcounty_elec year if state=="FL", lwidth(thin)) ///
|| (line pcounty_elec year if state=="GA", lwidth(thin)) || (line pcounty_elec year if state=="MD", lwidth(thin)) ///
|| (line pcounty_elec year if state=="NC", lwidth(thin)) || (line pcounty_elec year if state=="VA", lwidth(thin)) ///
|| (line pcounty_elec year if state=="WV", lwidth(thin)), ///
legend(off) title(South Atlantic) ytitle("cents/kwh") xtitle(year) yscale(range(6 21)) ylabel(6(4)21) name(d5, replace) scheme(s1color) nodraw

twoway (line pcounty_elec year if state=="AL", lwidth(thin)) || (line pcounty_elec year if state=="KY", lwidth(thin)) ///
|| (line pcounty_elec year if state=="MS", lwidth(thin)) || (line pcounty_elec year if state=="TN", lwidth(thin)), ///
legend(off) title(East South Central) ytitle("cents/kwh") xtitle(year) yscale(range(6 21)) ylabel(6(4)21) name(d6, replace) scheme(s1color) nodraw

twoway (line pcounty_elec year if state=="AR", lwidth(thin)) || (line pcounty_elec year if state=="LA", lwidth(thin)) ///
|| (line pcounty_elec year if state=="OK", lwidth(thin)) || (line pcounty_elec year if state=="TX", lwidth(thin)), ///
legend(off) title(West South Central) ytitle("cents/kwh") xtitle(year) yscale(range(6 21)) ylabel(6(4)21) name(d7, replace) scheme(s1color) nodraw

twoway (line pcounty_elec year if state=="ID", lwidth(thin)) || (line pcounty_elec year if state=="MT", lwidth(thin)) ///
|| (line pcounty_elec year if state=="WY", lwidth(thin)) || (line pcounty_elec year if state=="NV", lwidth(thin)) ///
|| (line pcounty_elec year if state=="UT", lwidth(thin)) || (line pcounty_elec year if state=="CO", lwidth(thin)) ///
|| (line pcounty_elec year if state=="AZ", lwidth(thin)) || (line pcounty_elec year if state=="NM", lwidth(thin)), ///
legend(off) title(Mountain) ytitle("cents/kwh") xtitle(year) yscale(range(6 21)) ylabel(6(4)21) name(d8, replace) scheme(s1color) nodraw

twoway (line pcounty_elec year if state=="WA", lwidth(thin)) || (line pcounty_elec year if state=="OR", lwidth(thin)) ///
|| (line pcounty_elec year if state=="CA", lwidth(thin)) || (line pcounty_elec year if state=="AK", lwidth(thin)), ///
legend(off) title(Pacific) ytitle("cents/kwh") xtitle(year) yscale(range(6 21)) ylabel(6(4)21) name(d9, replace) scheme(s1color) nodraw

graph combine d1 d2 d3 d4 d5 d6 d7 d8 d9, scheme(s1color)
graph export "$dirpath\Results\prices_by_division.pdf", as(pdf) replace



***************************************************************************************************************************************************
*STEP 2: GET A SENSE OF VARIATION IN UPFRONT VS. OPERATING COSTS
***************************************************************************************************************************************************

*This file maps zipcodes to counties
use "$dirpath\Data\EIA_861\mapping_zip_county_nov99", clear
ren state state_code

*Merge with file that has the price paid for the appliance
merge 1:m zipcode using "$dirpath\Data\lcidemo_046_2008_2012_allsales", keep(match) nogenerate

ren county5 county_utility
merge m:1 county_utility year using "$dirpath\Data\EIA_861\county_elec_price_2007_2012", keep(match) nogenerate


centile pcounty_elec, centile(10 25 50 75 90)
gen pcounty_elec_10pct = r(c_1)
gen pcounty_elec_25pct = r(c_2)
gen pcounty_elec_50pct = r(c_3)
gen pcounty_elec_75pct = r(c_4)
gen pcounty_elec_90pct = r(c_5)

collapse kwh paid_p pcounty_elec_*, by(pid)

foreach x in 10 25 50 75 90 {
	gen elec_cost_`x'pct = kwh*(pcounty_elec_`x'pct/100)

	gen npv_`x'pct = 0
	forval y = 0/11{
	replace npv_`x'pct = npv_`x'pct+(elec_cost_`x'pct)/(1.05)^`y'
	}
	
	gen ratio_`x'pct = npv_`x'pct/paid_p
	replace ratio_`x'pct = 5 if ratio_`x'pct>5
}


drop if paid_p<100

hist paid_p, name(n2, replace) color(blue%30) scheme(s1color) xtitle(Price Paid) 
graph export "$dirpath\Results\elec_cost_paid_price1.pdf", as(pdf) replace

twoway (hist npv_10pct, color(red%30) width(25)) || (hist npv_50pct, color(blue%30) width(25)) || (hist npv_90pct, color(green%30) width(25)), name(n1, replace) scheme(s1color) ///
legend(label(1 "10th Percentile") label(2 "Median") label(3 "90th Percentile")) xtitle(Lifetime Energy Cost)
graph export "$dirpath\Results\elec_cost_paid_price2.pdf", as(pdf) replace

twoway (hist ratio_10pct, color(red%30) width(.15)) || (hist ratio_50pct, color(blue%30) width(.15)) || (hist ratio_90pct, color(green%30) width(.15)), name(n3, replace) scheme(s1color) ///
legend(label(1 "10th Percentile") label(2 "Median") label(3 "90th Percentile")) xtitle(Lifetime Energy Cost/Price Paid)
graph export "$dirpath\Results\elec_cost_paid_price3.pdf", as(pdf) replace


graph combine n2 n1 n3, cols(1) scheme(s1color) xsize(5) ysize(8.5)
graph export "$dirpath\Results\elec_cost_paid_price.pdf", as(pdf) replace



