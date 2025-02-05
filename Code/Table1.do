// do /Users/shoude/Dropbox/eegap/Replication_JPube_RR/Table1.do

/*
Table 1: Summary Statistics: Main Sample.
This script computes the main summary statistics of the estimation sample.
*/

clear all
set more off
set maxvar 15000
set matsize 9000
pause on

//Sebastien's server

global  pathreplication = "[Put your path to the replication folder here]/Replication_JPube_RR"

log using $pathreplication/log_Table1.txt, replace
use "pathreplication/Data/lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50", clear

/*
sort state year
merge state year using $datapath_elec/electricity_price_state_2007_2012
tab _m
tab state if _m==1
tab year if _m==1
drop if _m==2
drop _m

sort zipcode
merge zipcode using $datapath_elec/mapping_zip_county_nov99_short
tab _m
drop if _m==2
drop _m
ren county5 county_utility

//Electricity County	
sort county_utility year
merge county_utility year using $datapath_elec/county_elec_price_2007_2012
tab _m
drop if _m==2
drop _m
replace pcount = p_elec if pcount==.

gen elec_cost = kwh*pcount/100
*/


// Table 1: Sum stats for main attributes
gen Dsize     = cond(AV<29,1,0)
gen Dtop      = cond(type_id ==1,1,0)
gen promo_tax = promo_f + tax_zip_mode

/*
egen sd_kwh         = sd(kwh)
egen sd_mef_rel     = sd(mef_rel)
egen sd_promo       = sd(promo)
egen sd_promo_tax   = sd(promo_tax)
egen sd_elec_cost   = sd(elec_cost)
egen sd_size 	    = sd(Dsize)
egen sd_estar 	    = sd(estar)
egen sd_top 		= sd(Dtop)
*/

sum promo_f, detail
sum promo_tax, detail
sum sales, detail
sum eleccost_county, detail
sum kwh, detail
sum Dsize, detail
sum estar, detail
sum Dtop, detail

log close

/*
Table ##. Summary Statistics Choice Set

Nb models/store                   ,  145.1879   , 68.30831 

mean/dispersion price within store,  1282.669  ,  597.7016 
dispersion kwh within store		,	508.7679    72.51712
dispersion elec cost within store  , 60.74145  ,  8.659218 
mef rel, 							.1631693   , .0758287
D size                               .5361882,   ,.4948813
mshare/store           ,             .0095269  ,  .0085567
mshare rank 1 or 2/store    ,        .0525402   , .0139258
mshare rank 1/store      ,           .0527185 ,   .0275709
mshare rank 2/store      ,           .0523618  ,  .0205507
dispertion rank 1 vs rank 2 price within store  ,    765.7156 , 333.6499 
dispertion rank 1 vs rank 2 kwh within store    ,    492.6452 , 42.26189 
dispertion rank 1 vs rank 2 elec cost within store , 58.54796 , 5.091376 
mef_rel, 							.074949, .0635137
D size, 							.7297888, .2474021

*/





