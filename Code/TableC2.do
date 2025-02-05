/*
This script createsTable C.2, which looks at variation within store. 
Table C.2 complements Table 1 in the main text.


Table C.2 was created to present raw data patterns that speak to identifying variation. 

One example is the range of options that are available to consumers at the average store, and how energy efficiency varies. 
how much do prices and energy costs differ between the first and second most popular product at each store? 
How many choices are there at the average store?
what are the distribution of market shares across the choices?
*/

clear all
set more off
set maxvar 15000
set matsize 9000
pause on

//Sebastien's server
global  datapath_retail = "/Users/shoude/Dropbox/eegap/EEgap_data/Retailer"
global  datapath_IV     = "/Users/shoude/Dropbox/eegap/EEgap_data/IV_data"
global  datapath_policy = "/Users/shoude/Dropbox/eegap/EEgap_data/PolicyAnalysis_Jpube"
global  datapath_elec   = "/Users/shoude/Dropbox/eegap/EEgap_data/EIA_861"
global  pathresults     = "/Users/shoude/Dropbox/eegap/EEgap_results"


// We use the raw data, so we can have variation within store instead of zip code, 
// which is exactly what one referee asked for. 
use "$datapath_retail/lcidemo_046_2008_2012_struct_v11_11022017_robustb_nocensor_11022017", clear

// If we use this file. The variation will be within zip code. This does not make a big difference given
// that most zip code has only one store. 
//use "$datapath_retail/bup/lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50", clear


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

collapse(sum) o_qty (mean) pcount elec_cost mef_rel kwh AV overall type_id estar retail_p paid_p promo_p,by(pid store zipcode state trimester year)

gsort store zipcode state trimester year -o_qty

by store zipcode state trimester year: egen sales_rank = seq()
by store zipcode state trimester year: egen sales_store = sum(o_qty)
gen mshare = o_qty/sales_store

gen Dsize = cond(AV<29,1,0)
gen Dtop  = cond(type_id ==1,1,0)

by store zipcode state trimester year: egen mean_sales_store     = mean(o_qty)
by store zipcode state trimester year: egen mean_mshare_store    = mean(mshare)
by store zipcode state trimester year: egen mean_kwh_store       = mean(kwh)
by store zipcode state trimester year: egen mean_mef_rel_store   = mean(mef_rel)
by store zipcode state trimester year: egen mean_promo_store     = mean(promo)
by store zipcode state trimester year: egen mean_elec_cost_store = mean(elec_cost)
by store zipcode state trimester year: egen mean_size_store 	 = mean(Dsize)
by store zipcode state trimester year: egen mean_estar_store 	 = mean(estar)
by store zipcode state trimester year: egen mean_top_store 		 = mean(Dtop)

by store zipcode state trimester year: egen sd_sales_store       = sd(o_qty)
by store zipcode state trimester year: egen sd_mshare_store      = sd(mshare)
by store zipcode state trimester year: egen sd_kwh_store         = sd(kwh)
by store zipcode state trimester year: egen sd_mef_rel_store     = sd(mef_rel)
by store zipcode state trimester year: egen sd_promo_store       = sd(promo)
by store zipcode state trimester year: egen sd_elec_cost_store   = sd(elec_cost)
by store zipcode state trimester year: egen sd_size_store 	     = sd(Dsize)
by store zipcode state trimester year: egen sd_estar_store 	     = sd(estar)
by store zipcode state trimester year: egen sd_top_store 		 = sd(Dtop)


save "$datapath_retail/sum_stats_pid_store_trimester", replace

gen nb_options = 1
by store zipcode state trimester year: egen tot_option = sum(nb_options)
gen share_option=nb_options/tot_option
by store zipcode state trimester year: gen cum_option = sum(share_option)
by store zipcode state trimester year: gen cum_share  = sum(mshare)
replace cum_share  = 100*cum_share
hist cum_share if cum_option>0.19 & cum_option<0.21,  graphregion(color(white) fcolor(white) ifcolor(white) icolor(white) lcolor(white) margin( small))  legend( off ) ytitle("Density") xtitle("Market Share (%)") ylabel(,nogrid)
cd $pathresults
graph export "hist_20mostpop_options.eps", as(eps) preview(off) replace


//Comparing stores
preserve

collapse(sum) o_qty nb_options (mean) pcount* mef_rel kwh overall retail_p paid_p promo_p mean_* sd_* ,by(store zipcode state trimester year)

sum nb_options, detail
sum mean*
sum sd*

save "$datapath_retail/sum_stats_store_trimester", replace

pause

collapse(mean) nb_options ,by(store zipcode)

sum nb_options, detail

restore

//Comparing 1st and 2nd most popular products
keep if sales_rank == 1 | sales_rank == 2
keep o_qty mshare sales_rank promo kwh elec_cost mef_rel store zipcode state trimester year AV type_id

gen Dsize = cond(AV<29,1,0)
gen Dtop  = cond(type_id ==1,1,0)

sort store zipcode state trimester year

by store zipcode state trimester year: egen mean_sales_store     = mean(o_qty)
by store zipcode state trimester year: egen mean_mshare_store    = mean(mshare)
by store zipcode state trimester year: egen mean_kwh_store       = mean(kwh)
by store zipcode state trimester year: egen mean_mef_rel_store   = mean(mef_rel)
by store zipcode state trimester year: egen mean_promo_store     = mean(promo)
by store zipcode state trimester year: egen mean_elec_cost_store = mean(elec_cost)
by store zipcode state trimester year: egen mean_size_store 	 = mean(Dsize)

by store zipcode state trimester year: egen sd_sales_store       = sd(o_qty)
by store zipcode state trimester year: egen sd_mshare_store      = sd(mshare)
by store zipcode state trimester year: egen sd_kwh_store         = sd(kwh)
by store zipcode state trimester year: egen sd_mef_rel_store     = sd(mef_rel)
by store zipcode state trimester year: egen sd_promo_store       = sd(promo)
by store zipcode state trimester year: egen sd_elec_cost_store   = sd(elec_cost)
by store zipcode state trimester year: egen sd_size_store 	 = sd(Dsize)

//Comparing stores
preserve
gen nb_options = 1

collapse(sum) o_qty nb_options (mean) mef_rel kwh elec_cost promo_p mean_* sd_* ,by(store zipcode state trimester year)

sum nb_options, detail
sum mean*
sum sd*

save "$datapath_retail/sum_stats_rank_1_2_store_trimester", replace


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



/*

             mshare
-------------------------------------------------------------
      Percentiles      Smallest
 1%     .0009217       .0002797
 5%     .0013414       .0002797
10%     .0016474       .0002797       Obs           1,928,241
25%     .0024876       .0002797       Sum of Wgt.   1,928,241

50%     .0042373                      Mean           .0068876
                        Largest       Std. Dev.      .0088722
75%     .0078125              1
90%     .0143369              1       Variance       .0000787
95%     .0208817              1       Skewness       8.930694
99%     .0434783              1       Kurtosis       471.4405

*/





