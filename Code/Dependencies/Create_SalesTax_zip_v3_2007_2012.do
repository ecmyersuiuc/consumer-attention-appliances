//do \\c3\rdat\SHoude\Research\Sears\rebate_scipts_2\Create_SalesTax_zip_v3_2007_2012.do 

pause on
set more off
global pathname="\\c3\rdat\SHoude\Research\sears\estar_data"
global censuspath="\\c3\rdat\SHoude\Research\data_all\census"
global sales_tax_path="\\c3\rdat\SHoude\Research\Sears\rebate_scipts_2\SalesTax"

/*
use $sales_tax_path\sales_tax.dta , clear  
	//gen day_start = week(start_date) 
	//gen day_end = week(end_date) 
	gen holiday_duration=end_date-start_date
	expand holiday_duration
	sort state year 
	by state year: egen day_of_program=seq()
	gen datenum=start_date+day_of_program-1
	sort state datenum
save $sales_tax_path\sales_tax_holiday.dta, replace


use $pathname\refrigerators\lcidemo_046_jan2008_dec2008, clear	
	append using $pathname\refrigerators\lcidemo_046_jan2009_dec2009, force
	append using $pathname\refrigerators\lcidemo_046_jan2010_dec2010, force
	append using $pathname\refrigerators\lcidemo_046_jan2011_dec2011, force
	append using $pathname\refrigerators\lcidemo_046_jan2012_dec2012, force
	
	append using $pathname\topload\lcidemo_026_jan2009_dec2009, force
	append using $pathname\topload\lcidemo_026_jan2010_dec2010, force
	append using $pathname\topload\lcidemo_026_jan2011_dec2011, force
	append using $pathname\topload\lcidemo_026_jan2012_dec2012, force

	append using $pathname\dishwashers\lcidemo_022_jan2009_dec2009, force
	append using $pathname\dishwashers\lcidemo_022_jan2010_dec2010, force
	append using $pathname\dishwashers\lcidemo_022_jan2011_dec2011, force
	append using $pathname\dishwashers\lcidemo_022_jan2012_dec2012, force
	
	append using $pathname\watherheaters\lcidemo_042_jan2009_dec2009, force
	append using $pathname\watherheaters\lcidemo_042_jan2010_dec2010, force
	append using $pathname\watherheaters\lcidemo_042_jan2011_dec2011, force
	append using $pathname\watherheaters\lcidemo_042_jan2012_dec2012, force
	
	collapse(count)o_qty,by(state zipcode)
	drop if state==""
	sort zipcode
save $pathname\refrigerators\state_id, replace
*/

//Sales tax rates by zipcode
forvalues year_p=2007/2012 {
use $pathname\refrigerators\lcidemo_046_jan`year_p'_dec`year_p', clear	
	keep if year==`year_p'
	gen tax_rate=tax/(paid+tax)
	gen tax_rate_round=round(10000*tax_rate)/10000
	gen tax_rate_round_nZ=tax_rate_round if tax_rate_round>0	
	bys zipcode month: egen tax_rate_mz=mode(tax_rate_round_nZ), maxmode
	gen tax_rate_mode=tax_rate_mz
	
	sort pid week
	merge pid week using $pathname\refrigerators\attributes_`year_p'_weekly
	tab _m	
	keep if _m==3
	drop _m
	bys s_estar zipcode datenum: egen tax_rate_edz=mode(tax_rate_round),maxmode 
	
	collapse(mean)tax_rate_round tax_rate tax_rate_edz tax_rate_mode tax_rate_mz (sum) o_qty,by(s_estar zipcode datenum week month year)
     sort zipcode
	 merge zipcode using $pathname\refrigerators\state_id
	 tab _m
	 keep if _m==3
	 drop _m
	sort state datenum
	merge state datenum using $sales_tax_path\sales_tax_holiday
	tab _m
	gen Dtax_holidays=0 
	replace  Dtax_holidays=1 if _m==3
	drop if _m==2
	drop _m
	
	replace tax_rate_mode=tax_rate_edz if Dtax_holidays==1 & fridge==1
	gen tax_rate_holidays=tax_rate_mz
	replace tax_rate_holidays=tax_rate_holidays-sales_tax_rate if Dtax_holidays==1 & fridge==1 & s_estar==1 & ee_req==1
	replace tax_rate_holidays=tax_rate_holidays-sales_tax_rate if Dtax_holidays==1 & fridge==1 & s_estar==0 & ee_req==0
	replace tax_rate_holidays=0 if Dtax_holidays==1 & fridge==1 & tax_rate_holidays<0
	gen category=046
	
save $pathname\refrigerators\tax_rate_estar_avg_month_zip_date_046_`year_p', replace 
}

use $pathname\refrigerators\tax_rate_estar_avg_month_zip_date_046_2007, clear
	append using $pathname\refrigerators\tax_rate_estar_avg_month_zip_date_046_2008	
	append using $pathname\refrigerators\tax_rate_estar_avg_month_zip_date_046_2009	
	append using $pathname\refrigerators\tax_rate_estar_avg_month_zip_date_046_2010
	append using $pathname\refrigerators\tax_rate_estar_avg_month_zip_date_046_2011
	append using $pathname\refrigerators\tax_rate_estar_avg_month_zip_date_046_2012
	sort category datenum s_estar
save $pathname\refrigerators\tax_rate_estar_avg_month_zip_date_046_2007_2012, replace  	

pause
	

forvalues year_p=2007/2012 {
use $pathname\topload\lcidemo_026_jan`year_p'_dec`year_p', clear	
	keep if year==`year_p'
	gen tax_rate=tax/(paid+tax)
	gen tax_rate_round=round(10000*tax_rate)/10000
	gen tax_rate_round_nZ=tax_rate_round if tax_rate_round>0	
	bys zipcode month: egen tax_rate_mz=mode(tax_rate_round_nZ), maxmode
	gen tax_rate_mode=tax_rate_mz
	
	sort pid week
	merge pid week using $pathname\topload\attributes_026_`year_p'
	tab _m	
	keep if _m==3
	drop _m
	bys s_estar zipcode datenum: egen tax_rate_edz=mode(tax_rate_round),maxmode 
	
	collapse(mean)tax_rate_round tax_rate tax_rate_edz tax_rate_mode tax_rate_mz (sum) o_qty,by(s_estar zipcode datenum week month year)
     sort zipcode
	 merge zipcode using $pathname\refrigerators\state_id
	 tab _m
	 keep if _m==3
	 drop _m
	sort state datenum
	merge state datenum using $sales_tax_path\sales_tax_holiday
	tab _m
	gen Dtax_holidays=0 
	replace  Dtax_holidays=1 if _m==3
	drop if _m==2
	drop _m
	
	replace tax_rate_mode=tax_rate_edz if Dtax_holidays==1 & washer==1
	gen tax_rate_holidays=tax_rate_mz
	replace tax_rate_holidays=tax_rate_holidays-sales_tax_rate if Dtax_holidays==1 & washer==1 & s_estar==1 & ee_req==1
	replace tax_rate_holidays=tax_rate_holidays-sales_tax_rate if Dtax_holidays==1 & washer==1 & s_estar==0 & ee_req==0
	replace tax_rate_holidays=0 if Dtax_holidays==1 & washer==1 & tax_rate_holidays<0
	gen category=026

save $pathname\topload\tax_rate_estar_avg_month_zip_date_026_`year_p', replace 
}

use $pathname\topload\tax_rate_estar_avg_month_zip_date_026_2007, clear
	append using $pathname\topload\tax_rate_estar_avg_month_zip_date_026_2008
	append using $pathname\topload\tax_rate_estar_avg_month_zip_date_026_2009	
	append using $pathname\topload\tax_rate_estar_avg_month_zip_date_026_2010
	append using $pathname\topload\tax_rate_estar_avg_month_zip_date_026_2011
	append using $pathname\topload\tax_rate_estar_avg_month_zip_date_026_2012
	sort category datenum s_estar
save $pathname\topload\tax_rate_estar_avg_month_zip_date_026_2007_2012, replace  	
	

forvalues year_p=2007/2012 {
use $pathname\dishwashers\lcidemo_022_jan`year_p'_dec`year_p', clear	
	keep if year==`year_p'
	gen tax_rate=tax/(paid+tax)
	gen tax_rate_round=round(10000*tax_rate)/10000
	gen tax_rate_round_nZ=tax_rate_round if tax_rate_round>0	
	bys zipcode month: egen tax_rate_mz=mode(tax_rate_round_nZ), maxmode
	gen tax_rate_mode=tax_rate_mz
	
	sort pid week
	merge pid week using $pathname\dishwashers\attributes_022_`year_p'
	tab _m	
	keep if _m==3
	drop _m
	bys s_estar zipcode datenum: egen tax_rate_edz=mode(tax_rate_round),maxmode 
	
	collapse(mean)tax_rate_round tax_rate tax_rate_edz tax_rate_mode tax_rate_mz (sum) o_qty,by(s_estar zipcode datenum week month year)
     sort zipcode
	 merge zipcode using $pathname\refrigerators\state_id
	 tab _m
	  keep if _m==3
	 drop _m
	sort state datenum
	merge state datenum using $sales_tax_path\sales_tax_holiday
	tab _m
	gen Dtax_holidays=0 
	replace  Dtax_holidays=1 if _m==3
	drop if _m==2
	drop _m
	
	replace tax_rate_mode=tax_rate_edz if Dtax_holidays==1 & dishwasher==1
	gen tax_rate_holidays=tax_rate_mz
	replace tax_rate_holidays=tax_rate_holidays-sales_tax_rate if Dtax_holidays==1 & dishwasher==1 & s_estar==1 & ee_req==1
	replace tax_rate_holidays=tax_rate_holidays-sales_tax_rate if Dtax_holidays==1 & dishwasher==1 & s_estar==0 & ee_req==0
	replace tax_rate_holidays=0 if Dtax_holidays==1 & dishwasher==1 & tax_rate_holidays<0
	gen category=022
	
save $pathname\dishwashers\tax_rate_estar_avg_month_zip_date_022_`year_p', replace 
}

use $pathname\dishwashers\tax_rate_estar_avg_month_zip_date_022_2007, clear
	append using $pathname\dishwashers\tax_rate_estar_avg_month_zip_date_022_2008	
	append using $pathname\dishwashers\tax_rate_estar_avg_month_zip_date_022_2009	
	append using $pathname\dishwashers\tax_rate_estar_avg_month_zip_date_022_2010
	append using $pathname\dishwashers\tax_rate_estar_avg_month_zip_date_022_2011
	append using $pathname\dishwashers\tax_rate_estar_avg_month_zip_date_022_2012
	sort category datenum s_estar
save $pathname\dishwashers\tax_rate_estar_avg_month_zip_date_022_2007_2012, replace  


forvalues year_p=2007/2012 {
use $pathname\watherheaters\lcidemo_042_jan`year_p'_dec`year_p', clear	
	
	keep if year==`year_p'
	gen tax_rate=tax/(paid+tax)
	gen tax_rate_round=round(10000*tax_rate)/10000
	
	
	gen tax_rate_round_nZ=tax_rate_round if tax_rate_round>0	
	bys zipcode month: egen tax_rate_mz=mode(tax_rate_round_nZ), maxmode
	gen tax_rate_mode=tax_rate_mz
	
	sort pid 
	merge pid using $pathname\watherheaters\attributes_waterheaters_12132012
	tab _m	
	keep if _m==3
	drop _m
	gen s_estar=0
	replace s_estar=1 if estar=="Yes"
	bys s_estar zipcode datenum: egen tax_rate_edz=mode(tax_rate_round),maxmode 
	
	collapse(mean)tax_rate_round tax_rate tax_rate_edz tax_rate_mode tax_rate_mz (sum) o_qty,by(s_estar zipcode datenum week month year)
     sort zipcode
	 merge zipcode using $pathname\refrigerators\state_id
	 tab _m
	 keep if _m==3
	 drop _m
	sort state datenum
	merge state datenum using $sales_tax_path\sales_tax_holiday
	tab _m
	gen Dtax_holidays=0 
	replace  Dtax_holidays=1 if _m==3
	drop if _m==2
	drop _m
	
	replace tax_rate_mode=tax_rate_edz if Dtax_holidays==1 & water_heater==1
	gen tax_rate_holidays=tax_rate_mz
	replace tax_rate_holidays=tax_rate_holidays-sales_tax_rate if Dtax_holidays==1 & water_heater==1 & s_estar==1 & ee_req==1
	replace tax_rate_holidays=tax_rate_holidays-sales_tax_rate if Dtax_holidays==1 & water_heater==1 & s_estar==0 & ee_req==0
	replace tax_rate_holidays=0 if Dtax_holidays==1 & water_heater==1 & tax_rate_holidays<0
	gen category=042
	
save $pathname\watherheaters\tax_rate_estar_avg_month_zip_date_042_`year_p', replace 
}

use $pathname\watherheaters\tax_rate_estar_avg_month_zip_date_042_2007, clear
	append using $pathname\watherheaters\tax_rate_estar_avg_month_zip_date_042_2008	
	append using $pathname\watherheaters\tax_rate_estar_avg_month_zip_date_042_2009	
	append using $pathname\watherheaters\tax_rate_estar_avg_month_zip_date_042_2010
	append using $pathname\watherheaters\tax_rate_estar_avg_month_zip_date_042_2011
	append using $pathname\watherheaters\tax_rate_estar_avg_month_zip_date_042_2012
	sort category datenum s_estar
save $pathname\watherheaters\tax_rate_estar_avg_month_zip_date_042_2007_2012, replace  


use $pathname\watherheaters\tax_rate_estar_avg_month_zip_date_042_2007_2012, replace
	append using $pathname\dishwashers\tax_rate_estar_avg_month_zip_date_022_2007_2012
	append using $pathname\topload\tax_rate_estar_avg_month_zip_date_026_2007_2012
	append using $pathname\refrigerators\tax_rate_estar_avg_month_zip_date_046_2007_2012
save $pathname\tax_rate_estar_avg_month_zip_date_042_022_026_046_2007_2012, replace

    gen tax_rate_mode_046=tax_rate_mode if category==046
    gen tax_rate_holidays_046=tax_rate_holidays if category==046
    
    gen tax_rate_mode_026=tax_rate_mode if category==026
    gen tax_rate_holidays_026=tax_rate_holidays if category==026
    
    gen tax_rate_mode_022=tax_rate_mode if category==022
    gen tax_rate_holidays_022=tax_rate_holidays if category==022
    
    gen tax_rate_mode_042=tax_rate_mode if category==042
    gen tax_rate_holidays_042=tax_rate_holidays if category==042
    
	bys s_estar zipcode datenum: egen tax_rate_mode_cat=mode(tax_rate_mode),maxmode 
	collapse(median) tax_rate_mode (mean)tax_rate_mode_* tax_rate_holidays*,by(s_estar zipcode datenum state)
	replace tax_rate_mode_046=tax_rate_mode_026 if tax_rate_mode_046==.
	replace tax_rate_mode_046=tax_rate_mode_022 if tax_rate_mode_046==.
	replace tax_rate_mode_046=tax_rate_mode_042 if tax_rate_mode_046==.
	
	replace tax_rate_holidays_046=tax_rate_holidays_026 if tax_rate_holidays_046==.
	replace tax_rate_holidays_046=tax_rate_holidays_022 if tax_rate_holidays_046==.
	replace tax_rate_holidays_046=tax_rate_holidays_042 if tax_rate_holidays_046==.
	
	sort zipcode datenum s_estar
	by 	zipcode datenum: egen nb_tax_rate=count(s_estar)
	tab nb_tax_rate
	by 	zipcode datenum: egen mean_estar=mean(s_estar)
	expand 2 if nb_tax_rate==1, gen(expanded)
	tab nb_tax_rate if expanded==1
	replace s_estar=1 if expanded==1 & mean_estar==0 & nb_tax_rate==1
	replace s_estar=0 if expanded==1 & mean_estar==1 & nb_tax_rate==1

	keep tax_rate_holidays* tax_rate_mode* zipcode state datenum s_estar
	reshape wide tax_rate_holidays* tax_rate_mode*, i(zipcode state datenum) j(s_estar)
	
	replace tax_rate_mode_0461=tax_rate_mode_0460 if tax_rate_mode_0461==.
	replace tax_rate_holidays_0461=tax_rate_holidays_0460 if tax_rate_holidays_0461==.
	
	replace tax_rate_mode_0460=tax_rate_mode_0461 if tax_rate_mode_0460==.
	replace tax_rate_holidays_0460=tax_rate_holidays_0461 if tax_rate_holidays_0460==.
	
	replace tax_rate_mode_0461=0 if tax_rate_mode_0461==. & (state=="AK" | state=="MT" | state=="OR" | state=="WV" | state=="DE")
	replace tax_rate_mode_0460=0 if tax_rate_mode_0460==. & (state=="AK" | state=="MT" | state=="OR" | state=="WV" | state=="DE")
	replace tax_rate_holidays_0461=0 if tax_rate_holidays_0461==. & (state=="AK" | state=="MT" | state=="OR" | state=="WV" | state=="DE")
	replace tax_rate_holidays_0460=0 if tax_rate_holidays_0460==. & (state=="AK" | state=="MT" | state=="OR" | state=="WV" | state=="DE")
	
	sort zipcode datenum
save $pathname\tax_rate_estar_avg_month_zip_date_2007_2012, replace
	
	gen week=week(datenum)
	gen year=year(datenum)
	collapse(mean) tax_rate_mode_0461 tax_rate_mode_0460 tax_rate_holidays_0461 tax_rate_holidays_0460, by(zipcode year week)
	
	sort zipcode year week
save $pathname\tax_rate_estar_avg_month_zip_week_2007_2012, replace
	
	
use $sales_tax_path\sales_tax.dta , clear  
	gen holiday_duration=end_date-start_date
	expand holiday_duration
	sort state year 
	by state year: egen day_of_program=seq()
	gen datenum=start_date+day_of_program-1
	gen week=week(datenum)
	collapse(firstnm) policy fridge, by(state year week)
	sort state year week
save $sales_tax_path\sales_tax_holiday_week.dta, replace
	