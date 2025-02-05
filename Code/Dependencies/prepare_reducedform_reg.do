// do \\c3\rdat\SHoude\Research\EEgap\EEgap_scripts\prepare_reducedform_reg.do

// Create a sample with all transactions and a sample that drops: Drop zip40 and pid20
 
// Dependencies: 
//              -do \\c3\rdat\SHoude\Research\sears\estar_scripts\create_choice_set_struct_rd_byHD_2008_2012.do


clear all
set more off
set maxvar 15000
set matsize 9000
adopath + H:\ADO
pause on


global  pathname = "\\c3\rdat\SHoude\Research\sears\estar_data"
global  pathresults = "\\c3\rdat\SHoude\Research\EEgap\EEgap_results"
global  EEGap_pathname = "\\c3\rdat\SHoude\Research\EEgap\EEgap_data"


local set_seed    `"`1'"'
local sample_size `"`2'"'
local do_process = 0


if `do_process'==1 {

use $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_week_store_ts_cleaned, clear
	collapse(sum) count,by(month standard pid zipcode year)
	by standard zipcode month, sort: egen nb_models=count(count)
	collapse(mean) nb_models,by(month pid zipcode year)
    sort pid month year zipcode
save $pathname\refrigerators\nbmodels_monthzip_046_2008_2012_Dhd, replace


use $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_week_store_ts_cleaned, clear
	
// Dependant variable for OLS		
	gen ln_sales=ln(sales)
	mvencode ln_sales,mv(0) over
	gen ln_salesP=ln(sales+1)
	
	gen ln_sales_hd=ln(sales_hd)
	mvencode ln_sales_hd,mv(0) over
	gen ln_sales_hdP=ln(sales_hd+1)
	
	gen ln_sales_non_hd=ln(sales_non_hd)
	mvencode ln_sales_non_hd,mv(0) over
	gen ln_sales_non_hdP=ln(sales_non_hd+1)
	
	
// Bring IVs for prices
	sort pid_id week_num
	merge pid_id week_num using $pathname\refrigerators\IVretail_046_2007_2012_Dhd_week_store_ts_cleaned	
	tab _m
	drop if _m==2
	drop _m
	
// Product age
	gen age=year-year_add
	gen age2=age^2	
	
// Rebates
	gen rebate_estar=s_estar*amount
	gen rebate_utility=s_estar*incentive_utility
	gen rebate_cfa=s_estar*incentive_cfa	
	    
// Energy Operating Costs
	replace kwh=kwh+50 if (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977") & year>=2010 & week>4
	gen eleccost=kwh*p_elec/100
	gen eleccost_county=kwh*pcounty_elec/100
	 
//Bring the MEA data 	
	//keep if state=="IL"
	merge m:1 zipcode using "$EEGap_pathname\MEA\zip_placename_utility"
	tab _m
	//keep if _merge==3
	ren _merge merge_ratezone
	ren RateZone ratezone
	
	//merge rate zones with standard prices
	merge m:1 month year utility ratezone using "$EEGap_pathname\MEA\Standard_Prices"
	drop if _merge==2
	drop _merge
	ren residentialnonspaceheat std_elec_price  
	
	//merge in referendum information
	merge m:1 Community utility using "$EEGap_pathname\MEA\mea_rates"
	drop if _merge==2
	drop _m
	gen post = Referendum=="Apr-11"&(year>2011|(year==2011&month>4))
	replace post = 1 if Referendum=="Mar-11"&(year>2011|(year==2011&month>3))
	replace post = 1 if Referendum=="Mar-12"&(year>2012|(year==2012&month>3))
	replace post = 1 if Referendum=="Nov-12"&(year>2012|(year==2012&month>11))
	
	gen delta_std_elec_price=std_elec_price
	replace delta_std_elec_price=Rate if post==1
	gen eleccost_zip=kwh*delta_std_elec_price/100
	
// ES dummy	
	drop delisted2010
	gen  delisted2010=0
	replace delisted2010=1 if (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977") 

	gen s_estar_del_2008=0
	replace s_estar_del_2008=1 if standard_class=="15" | standard_class=="20"
	replace s_estar_del_2008=0 if standard_class=="15" & year==2008 & week>=17
	replace s_estar_del_2008=0 if standard_class=="15" & year>2008
	gen s_estar_del_2010=0
	replace s_estar_del_2010=1 if (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977") & year==2010 & week<=4
	replace s_estar_del_2010=1 if (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977") & year<2010

// Fixed Effects
	
	//quietly tabulate week_num, gen(Dweek_id)
	//quietly tabulate zipcode, gen(Dstore_id)
 	quietly tabulate state, gen(Dstate_id)
		
	egen state_id=group(state)						
	gen state_es=state_id*s_estar						
	
	egen state_year_es=group(state year s_estar)
	replace state_year_es=0 if s_estar==0	
								
	egen brand_week_num=group(brand_id week_num)
	replace brand_week_num=0 if brand_id=="Others_Low"
	
	egen brand_month_num=group(brand_id month)
	replace brand_month_num=0 if brand_id=="Others_Low"  

// Features rebate program
//CFA rebate feature
		sort state
		merge state using "$pathname/rebate/Cash4Appliances/ProgramCharacteristics_Ref_CFA"
		tab _m
		drop if _m==2
		drop _m
//duration_weeks_cfa online_cfa reservations_cfa switch_cfa disabled_elderly_cfa meantested_cfa advalorem_cfa recyclingrequirement_cfa recyclingincentive_cfa	
	gen Dmeantested_other_req=(disabled_elderly_cfa==1 | meantested_cfa==1)
	gen Drecycling=(recyclingrequirement_cfa==1 | recyclingincentive_cfa==1)	
	
//Marginal probability of taking rebate		
	gen Drebate_utility_0_50=(rebate_utility<=50)
	gen Drebate_utility_51_100=(rebate_utility>50 & rebate_utility<=100)
	gen Drebate_utility_101_plus=(rebate_utility>100)
	

//Dynamic effect of rebates		
	sort state year week
	merge state year week using  "$pathname\rebate\Cash4Appliances\Cash4Appliances_announcement"
	tab _m
	ren _m merge_announce
	gen week_announce_tmp=week if merge_announce==3
	
	replace week_announce=week_announce+52 if year==2009
	replace week_announce=week_announce+104 if year==2010
	replace week_announce=week_announce+156 if year==2011
	replace week_announce=week_announce+208 if year==2012
	
	by state, sort: egen week_announce=max(week_announce_tmp) 

	sort state
	by state: egen max_incentive=max(incentive_cfa)
	gen Dstate=1
	replace Dstate=0 if max_incentive==0
	
	gen Drebate_cfa_0_50=(max_incentive<=50)
	gen Drebate_cfa_51_100=(max_incentive>51 & max_incentive<=100)
	gen Drebate_cfa_101_200=(max_incentive>101 & max_incentive<=200)
	gen Drebate_cfa_201_plus=(max_incentive>200)
	
	gen Dmeantest_rebate_cfa_201_plus=Drebate_cfa_201_plus*Dmeantested_other_req
	
	gen Drecycle_rebate_cfa_0_50=Drebate_cfa_0_50*Drecycling
	gen Drecycle_rebate_cfa_51_100=Drebate_cfa_51_100*Drecycling
	gen Drecycle_rebate_cfa_101_200=Drebate_cfa_101_200*Drecycling
	gen Drecycle_rebate_cfa_201_plus=Drebate_cfa_201_plus*Drecycling	
	
	gen Donline_rebate_cfa_0_50=Drebate_cfa_0_50*online_cfa
	gen Donline_rebate_cfa_51_100=Drebate_cfa_51_100*online_cfa
	gen Donline_rebate_cfa_101_200=Drebate_cfa_101_200*online_cfa
	gen Donline_rebate_cfa_201_plus=Drebate_cfa_201_plus*online_cfa
	
	gen Dreservation_rebate_cfa_0_50=Drebate_cfa_0_50*reservations_cfa
	gen Dreservation_rebate_cfa_51_100=Drebate_cfa_51_100*reservations_cfa
	gen Dreservation_rebate_cfa_101_200=Drebate_cfa_101_200*reservations_cfa
	gen Dreservation_rebate_cfa_201_plus=Drebate_cfa_201_plus*reservations_cfa
	
	gen Duration_cfa_0_8=(duration_weeks_cfa<=8)
	gen Duration_cfa_0_12=(duration_weeks_cfa<13)
	gen Duration_cfa_8_34=(duration_weeks_cfa>8 & duration_weeks_cfa<=34)
	gen Duration_cfa_34_plus=(duration_weeks_cfa>34)
	
	gen Dduration_12_rebate_cfa_0_50=Drebate_cfa_0_50*Duration_cfa_0_12
	gen Dduration_12_rebate_cfa_51_100=Drebate_cfa_51_100*Duration_cfa_0_12
	gen Dduration_12_rebate_cfa_101_200=Drebate_cfa_101_200*Duration_cfa_0_12
	gen Dduration_12_rebate_cfa_201_plus=Drebate_cfa_201_plus*Duration_cfa_0_12
	
	 
	//sort state
	//by state: egen max_discount=max(avg_discount)
	//gen Dadvalorem=0
	//replace Dadvalorem=1 if max_discount!=.
	
	sort state merge_rebate week_num
	by state merge_rebate: egen id_w=seq()
	gen st_week_tmp=week_num if id_w==1 & merge_rebate==3
	by state: egen st_week=max(st_week)
	gen week_since=week_num-st_week
	gen period=-1 if week_since<0
	replace period=0 if week_since>=0 & incentive_cfa>0
	replace period=1 if week_since>=0 & incentive_cfa==0 & max_incentive>0
	replace period=-2 if week_since<0 & week_num<week_announce
	
	gen Dperiod_0=cond(period==-2,1,0)
	gen Dperiod_1=cond(period==-1,1,0)
	gen Dperiod_2=cond(period==0,1,0)
	gen Dperiod_3=cond(period==1,1,0)
	
	gen Dperiod_0_inc=Dperiod_0*max_incentive
	gen Dperiod_1_inc=Dperiod_1*max_incentive
	gen Dperiod_2_inc=Dperiod_2*max_incentive
	gen Dperiod_3_inc=Dperiod_3*max_incentive

	sort state period week_num
	by state period: egen id_tmp2=seq()
	gen week_end_tmp=week_since if id_tmp2==1 & period==1 
	sort state
	by state: egen week_end=min(week_end_tmp)
	replace week_since=week_since-week_end if period==1
	
	gen Dduring_cfa=0
	replace Dduring_cfa=1 if period==0 
	gen Dduring_cfa_inc=Dduring_cfa*max_incentive*s_estar
	
	gen D2Mbefore_cfa=0
	replace D2Mbefore_cfa=1 if (period==-1 & week_since>=-8)
	gen D2Mbefore_cfa_inc=D2Mbefore_cfa*max_incentive*s_estar
	
	gen D2Mafter_cfa=0
	replace D2Mafter_cfa=1 if (period==1 & week_since<=9)
	gen D2Mafter_cfa_inc=D2Mafter_cfa*max_incentive*s_estar
	
	gen Dduring_cfa_inc_req=Dduring_cfa_inc*Dmeantested_other_req
	gen Dduring_cfa_inc_recycling=Dduring_cfa_inc*Drecycling
	gen Dduring_cfa_inc_online=Dduring_cfa_inc*online_cfa
	gen Dduring_cfa_inc_reservation=Dduring_cfa_inc*reservations_cfa
	gen Dduring_cfa_inc_duration_12=Dduring_cfa_inc*Duration_cfa_0_12
	 
	gen D2Mbefore_cfa_inc_req=D2Mbefore_cfa_inc*Dmeantested_other_req
	gen D2Mbefore_cfa_inc_recycling=D2Mbefore_cfa_inc*Drecycling
	gen D2Mbefore_cfa_inc_online=D2Mbefore_cfa_inc*online_cfa    
	gen D2Mbefore_cfa_inc_reservation=D2Mbefore_cfa_inc*reservations_cfa
	gen D2Mbefore_cfa_inc_duration_12=D2Mbefore_cfa_inc*Duration_cfa_0_12
	
	gen D2Mafter_cfa_inc_req=D2Mafter_cfa_inc*Dmeantested_other_req
	gen D2Mafter_cfa_inc_recycling=D2Mafter_cfa_inc*Drecycling
	gen D2Mafter_cfa_inc_online=D2Mafter_cfa_inc*online_cfa
	gen D2Mafter_cfa_inc_reservation=D2Mafter_cfa_inc*reservations_cfa
	gen D2Mafter_cfa_inc_duration_12=D2Mafter_cfa_inc*Duration_cfa_0_12
	 	 

save $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready, replace

use $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready, clear
// Restrict to the most popular stores.	
	sort zipcode
	merge zipcode using $pathname\refrigerators\zip_storeAB_2007_2012_046
	tab _m
	keep if _m==3
	drop _m
 	drop if zip40==1

// Restrict to the most popular models: pids responsible for 80% of the sales in a given year.	
 	sort pid
 	merge pid using $pathname\refrigerators\sales_pid20_2007_2012_046_y
 	tab _m 
 	keep if _m==3
 	drop _m
save $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_zip40_pid20_reg_eegap_ready, replace
}


set seed `set_seed'

use $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready, clear
	 sample `sample_size'
save $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_`set_seed'_sample_`sample_size', replace 
	
use $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_zip40_pid20_reg_eegap_ready, clear
 	 sample `sample_size'
save $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_zip40_pid20_reg_eegap_ready_seed_`set_seed'_sample_`sample_size', replace


