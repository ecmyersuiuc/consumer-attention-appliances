//do \\c3\rdat\SHoude\Research\sears\estar_scripts\create_choice_set_struct_rd_byHD_2008_2012.do

// This script takes raw transaction data and creates a panel of sales
// agreggated at the pid-zip-week(or month) level

// Dependencies: 
//   Creating weekly sales tax at the zip code level
// 		-do \\c3\rdat\SHoude\Research\Sears\rebate_scipts_2\Create_SalesTax_zip_v3_2007_2012.do 
//		-do \\c3\rdat\SHoude\Research\sears\estar_scripts\MakePricesTS_11022017.do year_p

// First created: 2/19/2013

// Modified: 3/25/2017
//  Changes relative to create_choice_set_struct_rd.do
//  -the year 2012 added
//  -create a robust choice set w.r.t. to ES
//  -identify households using # of purchases and quantity bought
//  -keep any type of housing
//  -keep if price>280 (used to be 250)
//  -only select Dhd
//  -replace sales so that we have only the count form Dhd. Before that we were taking the sales from MakePricesTS
//  -the file MakePricesTS has been modified so missing o_qty is set to one instead of zeros. 
//     Before making that change:

// Modified: 11/02/2017
// Change in MakePriceTS.do -> MakePriceTS_11022017.do
// Sales are also differentiated for Hd and non-Hd. 
// Renters are included in Dhd=0: replace Dhd=0 if rent=="R"

clear all
set more off
global pathname="\\c3\rdat\SHoude\Research\sears\estar_data"
global censuspath="\\c3\rdat\SHoude\Research\data_all\census"
global sales_tax_path="\\c3\rdat\SHoude\Research\Sears\rebate_scipts_2\SalesTax"
pause on

//Create files for the structural and reduced-form estimation

//Part I. Identify models to keep
local clean=1
local create_ts=1
local doall=1



use "$pathname/rebate/Cash4Appliances/cash4appliance_refrigerators_weekly_vf", clear
	keep  state year week incentive
	sort state year week
save "$pathname/rebate/Cash4Appliances/cash4appliance_refrigerators_weekly_vf_tmp", replace



if `doall'==1 {

//=============================================================================
//Part 1. Clean raw data
//=============================================================================
// We exclude territories, focus on main stores  (i.e., not outlets),
// We exclude very expansive models and cheap ones (most are refrigerator parts)
// We then use attribute data to flag refrigerators
// We exclude decertified models several weeks after decertification
// We exclude renters
// We flag transactions with no more than one purchase 

if `clean'==1{
	forvalues year_p=2008(1)2012 {
	
	use $pathname\refrigerators\lcidemo_046_jan`year_p'_dec`year_p', clear
		drop if state=="PR" | state=="VI" | state=="GU"
		keep if year==`year_p'
	    drop if online==1
	    keep if store=="A" | store=="B"
	    sort pid week
		merge pid week using  $pathname\refrigerators\attributes_`year_p'_weekly
		keep if _m==3
		drop _m
	    
		drop if retail_p<280
	    drop if retail_p>4100
	    
	    sum retail
	    
	    gen bad_pid=0
		replace bad_pid=1 if type_id==0 | type_id==.
		replace bad_pid=1 if size_id==0 | size_id==.
		replace bad_pid=1 if standard_class=="unknown"	
		drop if bad_pid==1 
		sort state zip 
		
		gen trimester=cond(week>=1 & week<=17,1,cond(week>=18 & week<=34,2,3))
	
	//Select household that made one purchase, live in single family housing and do not rent.		
		/*
		drop if o_qty>1 & o_qty!=. 
		//drop if housing==""
		drop if housing=="M"
		drop if rent=="R"
	    */
	//Demographic information			
		destring age adult children income education, replace
		/*
		drop if income==.
		drop if age==.
		drop if adult==.
		drop if children==.
		drop if education==.
		*/
		//drop if education==4
	    replace education=1 if education==4
		gen income_sub=cond(income<=3,1,cond(income>=4 & income<=6,2,3))
		gen income_tert=cond(income<=5,1,cond(income>=6 & income<=7,2,3))
		gen income_six=cond(income<=3,1,cond(income>=4 & income<=5,2,cond(income==6,3,cond(income==7,4,cond(income==8,5,6)))))
		replace income_sub=.  if income==.
		replace income_tert=.  if income==.
		replace income_six=.  if income==.
		
	    //drop if political==""
	    gen political_id=cond(political=="R",1,cond(political=="D",2,3))
		capture destring hd_id, replace
		//drop if hd_id==.
		drop v1* 
	save $pathname\refrigerators\lcidemo_all_046_jan`year_p'_dec`year_p'_struct_nocensor, replace
	}

}

  
use $pathname\refrigerators\lcidemo_all_046_jan2008_dec2008_struct_nocensor, clear
	append using $pathname\refrigerators\lcidemo_all_046_jan2009_dec2009_struct_nocensor 
	append using $pathname\refrigerators\lcidemo_all_046_jan2010_dec2010_struct_nocensor 
	append using $pathname\refrigerators\lcidemo_all_046_jan2011_dec2011_struct_nocensor 
	append using $pathname\refrigerators\lcidemo_all_046_jan2012_dec2012_struct_nocensor 		
save $pathname\refrigerators\lcidemo_all_046_2008_2012_tmp, replace
	
	replace tri=tri+3 if year==2009
    replace tri=tri+6 if year==2010
    replace tri=tri+9 if year==2011
    replace tri=tri+12 if year==2012
    
    
    gen month_num=month
    replace month_num=month_num+12 if year==2009
    replace month_num=month_num+24 if year==2010
    replace month_num=month_num+36 if year==2011
    replace month_num=month_num+48 if year==2012
    
    gen week_num=week
    replace week_num=week_num+52  if year==2009
    replace week_num=week_num+104 if year==2010
    replace week_num=week_num+156 if year==2011
    replace week_num=week_num+208 if year==2012
    
// Construction of a robust choice set w.r.t. to ES:
   
    // For the 2008 decertification, we are being conservative and drop observations if the pid disappeared ///
    // during the second trimester 
    // We drop all delisted models after 2010.
 	sort pid week_num
	by pid: egen max_week=max(week_num)
	drop if max_week<31 & trimester==2 & year==2008
 
	
	 //For the 2010 decertification, we keep the delisted models for a few months after ///
	 // the decertification
    drop if month_num>=30 & delisted2010==1
    drop if month_num>=25 & delisted==1
	
// Select households

	//drop if housing==""
	//drop if housing=="M"
	//drop if rent=="R"
	destring age adult children income education, replace
	//drop if income==.
	
 	 by hd_id, sort: egen nb_purchase=count(count)
    tab nb_purchase
    mvencode o_qty,mv(1) over
    by hd_id, sort: egen total_qty=sum(o_qty) 
    tab total_qty
    gen Dhd=1
    replace Dhd=0 if total_qty>1 | nb_purchase>1	
	replace Dhd=0 if rent=="R"
save $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_robust, replace

//=============================================================================
//Part 2. Create aggregate sales
//=============================================================================

//zip month
use $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_robust, clear	
	collapse(sum) o_qty,by(pid Dhd zip year month month_num )
    gen sales_hd_tmp=o_qty if Dhd==1
    gen sales_non_hd_tmp=o_qty if Dhd==0
    sort pid zip year month month_num
    by pid zip year month month_num: egen sales_hd=sum(sales_hd_tmp)
    by pid zip year month month_num: egen sales_non_hd=sum(sales_non_hd_tmp)
	collapse(sum) o_qty (mean) sales_hd sales_non_hd,by(pid zip year month month_num ) 
	ren o_qty sales
save $pathname\refrigerators\sales_jmz_hd_046_2008_2012, replace

//zip week
use $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_robust, clear
	collapse(sum) o_qty,by(pid Dhd zip year week )
    gen sales_hd_tmp=o_qty if Dhd==1
    gen sales_non_hd_tmp=o_qty if Dhd==0
    sort pid zip year week
    by pid zip year week: egen sales_hd=sum(sales_hd_tmp)
    by pid zip year week: egen sales_non_hd=sum(sales_non_hd_tmp)
	collapse(sum) o_qty (mean) sales_hd sales_non_hd,by(pid zipcode week year)
	ren o_qty sales
	sort  pid zip week year
save $pathname\refrigerators\sales_jzw_hd_046_2008_2012, replace


//=============================================================================
//Part 3. Create indicator of popular stores
//=============================================================================

use $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_robust, clear
	collapse(sum) o_qty,by(zip store)
	gen count=1
	sort zip
	by zip: egen storeByzip=sum(count)
	tab storeByzip
	drop count
	sort zip
save $pathname\refrigerators\zip_store_2008_2012_046, replace

use $pathname\refrigerators\zip_store_2008_2012_046, clear
	keep if store=="A" | store=="B"
	drop storeByzip
	gen count=1
	sort zip
	by zip: egen storeByzip=sum(count)
	tab storeByzip
	drop count
	sort o_qty
	gen cum_sales_all=sum(o_qty)
	egen sales_all=sum(o_qty)
	gen cum_dist_all=cum_sales_all/sales_all
	gen  zip5=cond(cum_dist_all<=0.05,1,0) 
	gen  zip10=cond(cum_dist_all<=0.1,1,0) 
	gen  zip20=cond(cum_dist_all<=0.2,1,0) 
	gen  zip30=cond(cum_dist_all<=0.3,1,0) 
	gen  zip40=cond(cum_dist_all<=0.4,1,0)
	sort zipcode 
save $pathname\refrigerators\zip_storeAB_2008_2012_046, replace


//=============================================================================
//Part 4. Create indicator of popular pid
//=============================================================================

use $pathname\refrigerators\sales_jmz_hd_046_2008_2012, clear
collapse(sum) sales,by(pid year)
	sort year sales
	by year: gen cum_sales_y=sum(sales)
	by year: egen sales_y=sum(sales)
	gen cum_dist_y=cum_sales_y/sales_y
	gen  pid5=cond(cum_dist_y<=0.05,1,0) 
	gen  pid10=cond(cum_dist_y<=0.1,1,0) 
	gen  pid20=cond(cum_dist_y<=0.2,1,0) 
	gen  pid30=cond(cum_dist_y<=0.3,1,0) 
	gen  pid40=cond(cum_dist_y<=0.4,1,0) 
	sort pid year
save $pathname\refrigerators\sales_jy_2008_2012_046_tmp, replace


use $pathname\refrigerators\sales_jmz_hd_046_2008_2012, clear
collapse(sum) sales,by(pid zip)
	sort zip sales
	by zipcode: gen cum_sales_z=sum(sales)
	by zipcode: egen sales_z=sum(sales)
	gen cum_dist_z=cum_sales_z/sales_z
	gen  pid5=cond(cum_dist_z<=0.05,1,0) 
	gen  pid10=cond(cum_dist_z<=0.1,1,0) 
	gen  pid20=cond(cum_dist_z<=0.2,1,0) 
	gen  pid30=cond(cum_dist_z<=0.3,1,0) 
	gen  pid40=cond(cum_dist_z<=0.4,1,0) 
save $pathname\refrigerators\sales_jz_2008_2012_046_tmp, replace


use $pathname\refrigerators\sales_jmz_hd_046_2008_2012, clear
collapse(sum) sales,by(zip)
	sort sales
	gen cum_sales_all=sum(sales)
	egen sales_all=sum(sales)
	gen cum_dist_all=cum_sales_all/sales_all
	gen  zip5=cond(cum_dist_all<=0.05,1,0) 
	gen  zip10=cond(cum_dist_all<=0.1,1,0) 
	gen  zip20=cond(cum_dist_all<=0.2,1,0) 
	gen  zip30=cond(cum_dist_all<=0.3,1,0) 
	gen  zip40=cond(cum_dist_all<=0.4,1,0)
	sort zipcode 
save $pathname\refrigerators\sales_z_2008_2012_046, replace


use $pathname\refrigerators\sales_jy_2008_2012_046_tmp, clear
	drop if pid10==1
	collapse(sum) sales,by(pid)
	ren sales sales_pid
	sort pid
save $pathname\refrigerators\sales_pid10_2008_2012_046_y, replace


use $pathname\refrigerators\sales_jy_2008_2012_046_tmp, clear
	drop if pid20==1
	collapse(sum) sales,by(pid)
	ren sales sales_pid
	sort pid
save $pathname\refrigerators\sales_pid20_2008_2012_046_y, replace


use $pathname\refrigerators\sales_jy_2008_2012_046_tmp, clear
	drop if pid30==1
	collapse(sum) sales,by(pid)
	ren sales sales_pid
	sort pid
save $pathname\refrigerators\sales_pid30_2008_2012_046_y, replace



//=============================================================================
//Part 5. Create a file with the first and last month for each pid-store
//        Very important for having robust choice sets
//=============================================================================

use $pathname\refrigerators\sales_jmz_hd_046_2008_2012, clear
	
	sort pid zipcode year month
	by pid zipcode: egen month_id=seq()
	by pid zipcode: egen max_month_id=max(month_id)
	gen max_month_tmp=month_num if max_month_id==month_id
	gen min_month_tmp=month_num if month_id==1
	sort pid zipcode
	by pid zipcode: egen max_month=mean(max_month_tmp) 
	by pid zipcode: egen min_month=mean(min_month_tmp) 
	
	collapse(mean) max_month min_month,by(pid zipcode)
	sort pid zipcode
save $pathname\refrigerators\pidzip_2008_2012_046_start_end, replace

//Create a more sophisticated file where the first and last month are ///
// identified if the sales occured between the first or second half

use $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_robust, clear

	collapse(sum) o_qty,by(pid zipcode month year month_num datenum)
	sort pid zipcode
	merge pid zipcode using $pathname\refrigerators\pidzip_2008_2012_046_start_end
	tab _m
	keep if _m==3
	drop _m
	
	sort pid zipcode month_num datenum
	by pid zipcode month_num: egen dom_id=seq()
	gen do1m_tmp=datenum if dom_id==1
	sort pid zipcode month_num
	by pid zipcode month_num: egen do1m=mean(do1m_tmp)
	gen dom=datenum-do1m
	
	gen biweek=cond(dom<=15,0,1)
	sort pid zipcode month_num biweek datenum
	by pid zipcode month_num biweek: egen sales_biweek=sum(o_qty)
	gen sales_biweek2_tmp=sales_biweek if biweek==1
	sort pid zipcode month_num 
	by pid zipcode month_num:  egen sales_biweek2=mean(sales_biweek2_tmp)
	
	gen sales_biweek1_tmp=sales_biweek if biweek==0
	sort pid zipcode month_num 
	by pid zipcode month_num:  egen sales_biweek1=mean(sales_biweek1_tmp)
	
	gen sales_biweek2_max_tmp=sales_biweek2 if max_month==month_num
	gen sales_biweek1_min_tmp=sales_biweek1 if min_month==month_num
	sort pid zipcode
	by pid zipcode: egen sales_biweek2_max=mean(sales_biweek2_max_tmp)
	by pid zipcode: egen sales_biweek1_min=mean(sales_biweek1_min_tmp)
	
	mvencode sales_biweek2 sales_biweek1,mv(0) over
	
	gen max_month2=max_month
	gen min_month2=min_month  
	
	replace max_month2=max_month-1 if sales_biweek2_max==0 & max_month>min_month
	replace min_month2=min_month+1 if sales_biweek1_min==0 & min_month<max_month
	
	collapse(mean) max_month2 max_month min_month min_month2,by(pid zipcode)
	sort pid zipcode
save $pathname\refrigerators\pidzip_2008_2012_046_start_end_vrobust, replace  

//=============================================================================
//Part 6. Create time series, and the unbalanced panel
//=============================================================================

if `create_ts'==1 {
	forvalues year_a=2008(1)2012{
		do \\c3\rdat\SHoude\Research\sears\estar_scripts\MakePricesTS_11022017.do `year_a'
	}
}

use $censuspath\mapping_zip_county_nov99, clear
	keep zipcode county5
	sort zipcode
save $censuspath\mapping_zip_county_nov99_short, replace 



forvalues year_p=2008(1)2012 {
	use $pathname\refrigerators\lcidemo_046_jan`year_p'_dec`year_p'_week_store_ts_11022017, clear
	keep state zipcode online pid week month year sales retail_f promo_f pcode_f
		gen month_num=month
    	replace month_num=month_num+12 if year==2009
    	replace month_num=month_num+24 if year==2010
    	replace month_num=month_num+36 if year==2011
    	replace month_num=month_num+48 if year==2012
    	
    //This step is very important to have a robust choice set	
		sort pid zipcode
		merge pid zipcode using $pathname\refrigerators\pidzip_2008_2012_046_start_end_vrobust
		tab _m
		keep if _m==3
		drop _m
		drop if month_num>max_month2
		drop if month_num<min_month2
		
		//Add attributes
		sort pid week
		merge pid week using $pathname\refrigerators\attributes_`year_p'_weekly
		tab _m
		keep if _m==3
		drop _m
		
		//Add electricity prices
		//To create files, see placeholder below
		
		
		//Add utilities-rebates: county level
		
		sort zipcode
		merge zipcode using $censuspath\mapping_zip_county_nov99_short
		tab _m
		drop if _m==2
		drop _m
		ren county5 county_utility
		
save $pathname\refrigerators\lcidemo_046_jan`year_p'_dec`year_p'_week_store_ts_11022017_cleaned, replace
}


}


//=============================================================================
//Part 7. Add aggregate sales for "selected" sample
//        and merge with price time series data.
//        Note that the panel created has a lot of zeros.
//        
//=============================================================================

use $pathname\refrigerators\lcidemo_046_jan2008_dec2008_week_store_ts_11022017_cleaned, clear
	append using $pathname\refrigerators\lcidemo_046_jan2009_dec2009_week_store_ts_11022017_cleaned
	append using $pathname\refrigerators\lcidemo_046_jan2010_dec2010_week_store_ts_11022017_cleaned
	append using $pathname\refrigerators\lcidemo_046_jan2011_dec2011_week_store_ts_11022017_cleaned
	append using $pathname\refrigerators\lcidemo_046_jan2012_dec2012_week_store_ts_11022017_cleaned

	gen week_num=week
    replace week_num=week_num+52  if year==2009
    replace week_num=week_num+104 if year==2010
    replace week_num=week_num+156 if year==2011
    replace week_num=week_num+208 if year==2012
	
  	//The sales from MakePricesTS_11022017.do includes all sales
	ren sales all_sales
	  
	sort pid zip week year
	merge pid zip week year using $pathname\refrigerators\sales_jzw_hd_046_2008_2012
	tab _m
	drop if _m==2 
	ren _m merge_sales_jzw

	mvencode sales sales_hd sales_non_hd, mv(0) over
	
	bys pid zip: egen obs_jz=count(sales)
	drop if obs_jz==1
	
	//Electricity
		sort state year
  		merge state year using $pathname\electricity\electricity_price_state_2007_2012
  		tab _m
  		tab state if _m==1
		tab year if _m==1
  		drop if _m==2
  		drop _m
  		
  	//Electricity County	
		sort county_utility year
		//merge county_utility year using "$pathname\electricity\county_price_tmp"  
		merge county_utility year using $pathname\electricity\county_elec_price_2007_2012
  		tab _m
  		drop if _m==2
  		drop _m
  		replace pcount=p_elec if pcount==.
  		
  		
	//Rebates Utility
		sort state week
 		sort county_utility year week
		merge county_utility year week using "$pathname\rebate\DSIRE_rebate_week_county_2007_2013"  
		tab _m
		drop if _m==2
		drop _m
		ren incentive incentive_utility
		mvencode incentive_utility,mv(0) over 
		
		
	//Rebates CFA	
		sort state year week
		merge state year week using "$pathname/rebate/Cash4Appliances/cash4appliance_refrigerators_weekly_vf_tmp"
		tab _m
		drop if _m==2
		ren _m merge_rebate
		ren incentive incentive_cfa
		mvencode incentive_cfa,mv(0) over 
		gen amount=incentive_utility+incentive_cfa
		
	//Sales Tax
	sort zipcode year week
	merge zipcode year week using $pathname\tax_rate_estar_avg_month_zip_week_2007_2012
	tab _m 
	drop if _m==2
	drop _m

	gen non_estar=-1*s_estar+1 
	gen tax_zip_mode=promo_f*(tax_rate_mode_0461*s_estar+tax_rate_mode_0460*non_estar)
	gen real_price_zip_mode=promo_f+tax_zip_mode
	
	gen tax_zip_holidays=promo_f*(tax_rate_holidays_0461*s_estar+tax_rate_holidays_0460*non_estar)
	gen real_price_zip_holidays=promo_f+tax_zip_holidays
	
	ren tax_rate_mode_0461 tax_rate_zip_mode_0461
	ren tax_rate_mode_0460 tax_rate_zip_mode_0460
	ren tax_rate_holidays_0461 tax_rate_zip_holidays_0461
	ren tax_rate_holidays_0460 tax_rate_zip_holidays_0460	
	
	//Variation in sales tax due to tax holiday/exemption
	sort state year week
	merge state year week using $sales_tax_path\sales_tax_holiday_week
	tab _m
	drop if _m==2
	drop _m
	gen Dtax_holiday=(fridge==1 & policy=="sales tax holiday")
	gen Dtax_exemption=(fridge==1 & policy=="sales tax exemption")

	gen Dtax_holiday_tax_zip=Dtax_holiday*tax_zip_mode 
	gen pid_id=substr(pid,1,11)
	destring pid_id, replace	
save $pathname\refrigerators\lcidemo_046_2008_2012_Dhd_week_store_ts_cleaned, replace


  collapse(median) promo_f retail_f pcode,by(pid_id week_num) 
  tsset pid_id week_num
  
  gen delta_retail=retail_f-L.retail_f
  mvencode delta_retail, mv(0) over
  gen Ddelta_retail=cond(delta_retail!=0 & delta_retail!=., 1,0)
  ren retail_f retail_median
  
  gen delta_promo=promo_f-L.promo_f
  mvencode delta_promo, mv(0) over
  gen Ddelta_promo=cond(delta_promo!=0 & delta_promo!=., 1,0)
  ren promo_f promo_median
  
  ren pcode pcode_median
  
  gen delta_retail_promo=retail_median-promo_median
  
  sort pid_id week_num
save $pathname\refrigerators\IVretail_046_2008_2012_Dhd_week_store_ts_cleaned, replace	



