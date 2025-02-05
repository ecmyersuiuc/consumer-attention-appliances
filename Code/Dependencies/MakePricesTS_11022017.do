//do \\c3\rdat\SHoude\Research\sears\estar_scripts\MakePricesTS_11022017.do year_p

// This script is a modification of 
//   do \\c3\rdat\SHoude\Research\sears\estar_scripts\MakePricesTS.do year_p
//   The main modification is on lines 57 and 58. We should not divide by quantity for
//   these variables. 
//   It also replaces the merge merge pid using $pathname\refrigerators\create_agg_choice
//   with the merge: merge pid week using  $pathname\refrigerators\attributes_`year_p'_weekly

// Script needed 
// H:\Research\sears\estar_scripts\process_lcidemo_046_allyears

clear all  
set mem 12000m
pause on

local year `"`1'"'
//local year=2008


global pathname="\\c3\rdat\SHoude\Research\sears\estar_data"
global censuspath="\\c3\rdat\SHoude\Research\data_all\census"


//Create a daily time series at the store level
//Imputation works as follow:
//  1. Use the price ealier in the week or later, based on the assumption that promotions last a week.

  
// Duplicates
// use $pathname\refrigerators\lcidemo_046_jan`year'_dec`year', clear
// 	if year==2008{
// 	duplicates drop hd_id pid datenum  retail_p paid_p promo_p zipcode if pid=="04667872000P", force
// 	} 
// 	else if year==2009 { 
// 	duplicates drop hd_id pid datenum  retail_p paid_p promo_p zipcode if pid=="04668979000P", force 
// 	} 
// 	else if year==2010 {
// 	duplicates drop hd_id pid datenum  retail_p paid_p promo_p zipcode if pid=="04668802000P", force 
// 	}
// 	duplicates drop hd_id pid datenum  retail_p paid_p promo_p zipcode if hd_id!="", force
// save  $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_nodups, replace


//use $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_nodups, clear
use $pathname\refrigerators\lcidemo_046_jan`year'_dec`year', clear
	collapse(sum) count,by(online pid zipcode state)
	sort online pid zipcode state
	egen panel_id=seq()
save $pathname\refrigerators\lcidemo_046_ms_zip_`year', replace

//use $pathname\refrigerators\lcidemo_046_ms_zip_`year', clear
	sort panel_id
save $pathname\refrigerators\lcidemo_046_ms_zip_`year'_v2, replace

//use $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_nodups, clear
use $pathname\refrigerators\lcidemo_046_jan`year'_dec`year', clear
	keep if year==`year'	
	mvencode o_qty,mv(1) over
	//replace retail_p=retail_p/o_qty
	//replace promo_p=promo_p/o_qty
	replace paid_p=paid_p/o_qty
	sort online pid zipcode state datenum
	by online pid zipcode state datenum: egen retail_m=mode(retail_p), max  
	by online pid zipcode state datenum: egen promo_m=mode(promo_p), max  
	by online pid zipcode state datenum: egen paid_m=mode(paid_p), max  
	by online pid zipcode state datenum: egen pcode_m=mode(pcode), max  
	
	drop if retail_m<250
// 	drop if o_qty>1
// 
//     by hd_id, sort: egen nb_purchase=count(o_qty)
//     tab nb_purchase
// 	drop if nb_purchase>1 & hd_id!=.

	sort online pid zipcode state datenum
	by online pid zipcode state datenum: egen sales=sum(o_qty)  
	
	collapse(mean) retail_m promo_m paid_m retail_p promo_p paid_p sales pcode_m pcode, by(online pid zipcode state datenum year)  
	
//Merge with attribute info, keep only refrigerators
//      The goal here is to reduce the size of the file that we are dealing with.

    gen week=week(datenum)
    gen month=month(datenum)
    
	 // sort pid week year
 	 // merge pid using $pathname\refrigerators\create_agg_choice
	 sort pid week
	 merge pid week using  $pathname\refrigerators\attributes_`year'_weekly
	 keep if _m==3
	 drop _m
	    

    gen bad_pid=0
	//replace bad_pid=1 if nat_sll<280
	replace bad_pid=1 if type_id==0 | type_id==.
	replace bad_pid=1 if size_id==0 | size_id==.
	replace bad_pid=1 if standard_class=="unknown"	
	drop if bad_pid==1 
    	

// 	gen s_estar=0
// 	replace s_estar=1 if year==2007 & (standard_class=="15" | standard_class=="20"  |  standard_class=="25")
// 	replace s_estar=1 if year==2008 & week<=17 & (standard_class=="15" | standard_class=="20"  |  standard_class=="25")
// 	replace s_estar=1 if year==2008 & week>17  & (standard_class=="20"  |  standard_class=="25")
// 	replace s_estar=1 if year==2009 &  (standard_class=="20"  |  standard_class=="25")
// 	replace s_estar=1 if year==2010 &  (standard_class=="20"  |  standard_class=="25")
// 	replace s_estar=1 if year==2011 &  (standard_class=="20"  |  standard_class=="25")
// 	replace s_estar=1 if year==2012 &  (standard_class=="20"  |  standard_class=="25")

	
	keep pid model year month week datenum online state zipcode standard_class s_estar sales promo* retail* pcode*
	
    sort online pid zipcode state
	merge online pid zipcode state using $pathname\refrigerators\lcidemo_046_ms_zip_`year'
	tab _m
	
	keep if _m==3
	drop _m
	tsset  panel_id datenum 
	tsfill
	
	drop online pid zipcode state
	sort panel_id 
	merge panel_id using $pathname\refrigerators\lcidemo_046_ms_zip_`year'_v2
	tab _m 
	
	drop if _m==2
	drop _m	
	drop week year month
	gen week=week(datenum)
	gen month=month(datenum)
	gen year=year(datenum)
	gen dow=dow(datenum)
	
    compress
	
//Detect incidence of promotions for that day, in other markets
	sort pid week datenum online state zipcode 
	by  pid week datenum: egen pcode_day=mean(pcode_m)
//Detect incidence of promotions for that week, in other markets	
	by  pid week: egen pcode_week=mean(pcode_m)

  foreach x in retail_m promo_m{
	by pid week datenum online state: egen pid_state_day_`x'=mode(`x'), max
   } 
   
   gen promo_f=pid_state_day_promo_m 
   gen retail_f=pid_state_day_retail_m 
   drop pid_state_day*
   
  foreach x in retail_m promo_m{
	by pid week: egen pid_week_`x'=mode(`x'), max
   }  
   
  foreach x in  retail_m promo_m{
	by pid: egen tpid_`x'=mode(`x'), max
   } 

   	
//Detect incidence of promotions for that product-store, in the same week
	sort pid online  state zipcode week datenum
	by  pid online  state zipcode week: egen pcode_zip_week=mean(pcode_m)	
	by  pid online  state zipcode week: egen sale_count_week=count(sales)
	  
  foreach x in retail_m promo_m{
	by pid online  state zipcode week: egen pid_zip_week_`x'=mode(`x'), max
   } 
   
   replace promo_f= pid_zip_week_promo_m  if  promo_f==.
   replace retail_f= pid_zip_week_retail_m  if  retail_f==.
   drop pid_zip_week*
   
	sort pid state week 
  foreach x in retail_m promo_m{
	by pid state week: egen pid_state_week_`x'=mode(`x'), max
   } 
   
   replace promo_f= pid_state_week_promo_m  if  promo_f==.
   replace promo_f= pid_week_promo_m  if  promo_f==.
   replace retail_f= pid_state_week_retail_m  if  retail_f==.
   replace retail_f= pid_week_retail_m  if  retail_f==.
   drop pid_state_week* pid_week*	
   
  
   sort pid online month state
   foreach x in retail_m promo_m{
	by pid online month state: egen pid_state_month_`x'=mode(`x'), max
   }  
   
   replace promo_f= pid_state_month_promo_m   if  promo_f==.
   replace retail_f= pid_state_month_retail_m   if  retail_f==.
   drop pid_state_month*
   
   foreach x in retail_m promo_m{
	by pid online month: egen pid_month_`x'=mode(`x'), max
   } 
   
   replace promo_f= pid_month_promo_m  if  promo_f==.
   replace retail_f= pid_month_retail_m  if  retail_f==.
   drop pid_month*
   
   foreach x in retail_m promo_m{
	by pid online: egen pid_online_`x'=mode(`x'), max
   }
   
   replace promo_f= pid_online_promo_m  if  promo_f==.
   replace retail_f= pid_online_retail_m  if  retail_f==.
   drop pid_online*

	replace promo_f= tpid_promo_m if  promo_f==.
	replace retail_f= tpid_retail_m if  retail_f==.

	gen pcode_f=pcode_week 
	
	foreach x in promo_f{
		replace `x'=tpid_promo_m if abs((`x'-tpid_promo_m)/tpid_promo_m)>1.5
	}
	foreach x in retail_f{
		replace `x'=tpid_retail_m if abs((`x'-tpid_retail_m)/tpid_retail_m)>1.5
	}	
	mvencode sales,mv(0) over
	keep pid panel_id year month week dow datenum online state zipcode  sales standard s_estar promo_f retail_f pcode_f
	compress
save $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_day_store_ts_11022017, replace
	
//Aggregate

//use $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_day_store_ts, clear

//Create a weekly time series at the store level
	sort online year month week pid state zipcode
	by online year month week pid state zipcode: egen sales_tmp=sum(sales)
//collapse(mean) sales_tmp retail_f promo_f pcode_f,by(online year month week pid state zipcode standard s_estar)  
collapse(mean) sales_tmp retail_f promo_f pcode_f,by(online year month week pid state zipcode)    
	ren sales_tmp sales
	compress
save $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_week_store_ts_11022017, replace

//use  $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_week_store_ts, clear

//Aggregate
//Create a weekly time series at the county level
    ren state state_str
	sort zipcode
	merge zipcode using $censuspath\mapping_zip_county_nov99
	tab _m
	drop if _m==2
	drop _m 
	
	ren county5 county_FIPS
	sort online year month week pid state_str county_FIPS
  	by online year month week pid state_str county_FIPS: egen sales_tmp=sum(sales)

collapse(mean) sales_tmp retail promo pcode,by(online year month week pid state_str county_FIPS)  
 	ren state_str state
	ren sales_tmp sales
	compress
save $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_week_county_ts_11022017, replace 	

//Create a weekly time series at the state level	
	sort online year month week pid state
	by online year month week pid state: egen sales_tmp=sum(sales)
collapse(mean) sales_tmp retail promo pcode,by(online year month  week pid state)   
 	ren sales_tmp sales	
 	compress
save $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_week_state_ts_11022017, replace 	
	


//Create a monthly time series at the state level
use $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_day_store_ts_11022017, clear

	sort online year month pid state
	by online year month pid state: egen sales_tmp=sum(sales)
collapse(mean) sales_tmp retail promo pcode,by(online year month pid state)   
 	ren sales_tmp sales	
 	compress
save $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_month_state_ts_11022017, replace 


//Create a monthly time series at the store level

use $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_week_store_ts_11022017, clear
	sort online year month pid state zip
  	by online year month pid state zip: egen sales_tmp=sum(sales)
	
collapse(mean) sales_tmp retail promo pcode,by(online year month pid state zip)  
	ren sales_tmp sales
	compress
save $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_month_store_ts_11022017, replace 


//Create a monthly time series at the county level

use $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_week_county_ts_11022017, clear
	sort online year month pid state county_FIPS
  	by online year month pid state county_FIPS: egen sales_tmp=sum(sales)
	
collapse(mean) sales_tmp retail promo pcode,by(online year month pid state county_FIPS)  
	ren sales_tmp sales
	compress
save $pathname\refrigerators\lcidemo_046_jan`year'_dec`year'_month_county_ts_11022017, replace 	





