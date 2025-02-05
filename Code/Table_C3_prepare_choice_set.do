// do /Users/shoude/Dropbox/eegap/Replication_JPubE_RR/Table_C3_prepare_choice_set.do


//Sebastien's server
global  datapath_retail = "/Users/shoude/Dropbox/eegap/EEgap_data/Retailer"
global  datapath_IV     = "/Users/shoude/Dropbox/eegap/EEgap_data/IV_data"
global  datapath_policy = "/Users/shoude/Dropbox/eegap/EEgap_data/PolicyAnalysis_Jpube"
global  datapath_elec   = "/Users/shoude/Dropbox/eegap/EEgap_data/EIA_861"
global  pathresults     = "/Users/shoude/Dropbox/eegap/EEgap_results"


// Choice set by store-trimester

use "$datapath_retail/lcidemo_046_2008_2012_struct_v11_11022017_robustb_nocensor_11022017", clear

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


by store zipcode state trimester year: egen max_kwh_store       = max(kwh)
by store zipcode state trimester year: egen min_kwh_store       = min(kwh)
gen range_kwh_store = max_kwh_store - min_kwh_store

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

//Comparing stores
preserve

collapse(sum) o_qty nb_options (mean) pcount* mef_rel kwh overall retail_p paid_p promo_p mean_* sd_* range* max* min*,by(store zipcode state trimester year)

sum nb_options, detail
sum mean*
sum sd*

save "$datapath_retail/sum_stats_store_trimester", replace

restore




// Choice set by store-year

use "$datapath_retail/lcidemo_046_2008_2012_struct_v11_11022017_robustb_nocensor_11022017", clear

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

collapse(sum) o_qty (mean) pcount elec_cost mef_rel kwh AV overall type_id estar retail_p paid_p promo_p,by(pid store zipcode state  year)

gsort store zipcode state  year -o_qty

by store zipcode state  year: egen sales_rank = seq()
by store zipcode state  year: egen sales_store = sum(o_qty)
gen mshare = o_qty/sales_store

gen Dsize = cond(AV<29,1,0)
gen Dtop  = cond(type_id ==1,1,0)

by store zipcode state  year: egen mean_sales_store     = mean(o_qty)
by store zipcode state  year: egen mean_mshare_store    = mean(mshare)
by store zipcode state  year: egen mean_kwh_store       = mean(kwh)
by store zipcode state  year: egen mean_mef_rel_store   = mean(mef_rel)
by store zipcode state  year: egen mean_promo_store     = mean(promo)
by store zipcode state  year: egen mean_elec_cost_store = mean(elec_cost)
by store zipcode state  year: egen mean_size_store 	 = mean(Dsize)
by store zipcode state  year: egen mean_estar_store 	 = mean(estar)
by store zipcode state  year: egen mean_top_store 		 = mean(Dtop)

by store zipcode state  year: egen sd_sales_store       = sd(o_qty)
by store zipcode state  year: egen sd_mshare_store      = sd(mshare)
by store zipcode state  year: egen sd_kwh_store         = sd(kwh)
by store zipcode state  year: egen sd_mef_rel_store     = sd(mef_rel)
by store zipcode state  year: egen sd_promo_store       = sd(promo)
by store zipcode state  year: egen sd_elec_cost_store   = sd(elec_cost)
by store zipcode state  year: egen sd_size_store 	 = sd(Dsize)
by store zipcode state  year: egen sd_estar_store 	 = sd(estar)
by store zipcode state  year: egen sd_top_store 		 = sd(Dtop)


save "$datapath_retail/sum_stats_pid_store_year", replace

gen nb_options = 1
by store zipcode state year: egen tot_option = sum(nb_options)
gen share_option=nb_options/tot_option
by store zipcode state  year: gen cum_option = sum(share_option)
by store zipcode state  year: gen cum_share  = sum(mshare)
replace cum_share  = 100*cum_share
hist cum_share if cum_option>0.19 & cum_option<0.21,  graphregion(color(white) fcolor(white) ifcolor(white) icolor(white) lcolor(white) margin( small))  legend( off ) ytitle("Density") xtitle("Market Share (%)") ylabel(,nogrid)

//Comparing stores
preserve

collapse(sum) o_qty nb_options (mean) pcount* mef_rel kwh overall retail_p paid_p promo_p mean_* sd_* ,by(store zipcode state year)

sum nb_options, detail
sum mean*
sum sd*

save "$datapath_retail/sum_stats_store_year", replace
