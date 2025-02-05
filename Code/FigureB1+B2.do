global  dirpath = "[Put your path to the replication folder here]/Replication_JPubE_RR"
global  pathresults = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"

clear
clear matrix
set mem 12g
set more off
set matsize 11000


*STEP 1: Prepare the map coordinates
* Results from this code are in folder already. To replicate, choose a different name for usdb or uscoord or you wil bet an error that they "already exist"
cd "$dirpath\Data\gz_2010_us_050_00_500k"

/*
shp2dta using gz_2010_us_050_00_500k, database(usdb) coordinates(uscoord) genid(id)

use usdb, clear
egen county_utility = concat(STATE COUNTY)
destring county_utility, replace
save usdb, replace

*change to mercator
use uscoord, clear
geo2xy _Y _X, proj (web_mercator) replace
sort _ID
save, replace
*/


*STEP 2: Collapse to get variables of interest for the map

use "$dirpath\Data\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final", clear

gen efficient_sales = kwh_bin2==1

replace efficient_sales = efficient_sales*sales_hd
collapse (sum) sales_hd efficient_sales (mean) pcounty_elec, by(county_utility)
gen share_efficient1 = efficient_sales/sales_hd

merge 1:1 county_utility using usdb, nogenerate
destring STATE, replace
drop if STATE>56|STATE==2|STATE==15
replace pcounty_elec = round(pcounty_elec,0.1)
replace share_efficient = round(share_efficient,0.01)

local char = ustrfrom(char(0162), "cp1252", 1)
spmap pcounty_elec using uscoord, id(id) clmethod(quantile) clnumber(4) fcolor(Reds) osize(vthin vthin vthin vthin) ///
ocolor(gs11 gs11 gs11 gs11) ndsize(vthin) ndocolor(gs11) legtitle(`char'/kwh) 
graph export "$pathresults\EEgap_results\price_map.pdf", as(pdf) replace

spmap share_efficient1 using uscoord, id(id) fcolor(Reds) osize(vthin vthin vthin vthin) ///
 ocolor(gs11 gs11 gs11 gs11) ndsize(vthin) ndocolor(gs11) legtitle("Purchase Share Above Median Efficiency") 
graph export "$pathresults\EEgap_results\share_efficient_map.pdf", as(pdf) replace

local char = ustrfrom(char(0162), "cp1252", 1)
binscatter share_efficient1 pcounty_elec, xtitle(County Electricity Price (`char'/kwh)) ytitle("Purchase Share Above Median Efficiency") mcolor(blue) lcolor(red) scheme(s1color) 
graph export "$pathresults\EEgap_results\binscatter_efficiency_by_price.pdf", as(pdf) replace




