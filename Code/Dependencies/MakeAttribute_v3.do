// do ...\estar_scripts\MakeAttribute_v3.do


//Preliminary Processing to get energy information
//do "...\Merge_Sears_FTC_EPA_CEC.do"

clear
set mem 3000m
set more off
global  pathname="\\c3\rdat\SHoude\Research\sears\estar_data"


//Standards
insheet using "$pathname\standards\standards_refrigerators.csv", clear
	gen refrigclass=refrigstyle+"-"+refrigdef
	sort  sizestyle refrigstyle refrigdefrosttype 
save "$pathname\standards\standards_refrigerators", replace

insheet using "$pathname\standards\standards_refrigerators2014.csv", clear
	gen refrigclass=refrigstyle+"-"+refrigdef
	sort  sizestyle refrigstyle refrigdefrosttype builtin icemaker
save "$pathname\standards\standards_refrigerators2014", replace


//--------------------------------------------------------------------------------------------------------------------------------------

use $pathname\refrigerators\Sears_w_EPA_CEC_FTC, clear

//Summary Statistics


//Create Quality Score

	gen airfilt_sc=0
		replace airfilt_sc=1 if airfiltration!="No"  & airfiltration!="" 
	gen advcooling_sc=0
		replace advcooling_sc=1 if advcooling_wcs!="No" &  advcooling_wcs!=""
	gen advfreezer_sc=0
		replace advfreezer_sc=1 if advfreezer_wcs!="No" & advfreezer_wcs!="N/A" &   advfreezer_wcs!=""
	gen advtech_sc=0
		replace  advtech_sc=1 if advtech_wcs=="Yes"
	gen dispenser_sc=0
		replace dispenser_sc=1 if dispenser_wcs!="No" & dispenser_wcs!="N/A" &   dispenser_wcs!=""
	gen intlight_sc=0
		replace intlight_sc=1 if intlight_wcs!="Standard" & intlight_wcs!="Yes, 40 watt" &  intlight_wcs!="1x 40W" & intlight_wcs!="2 x 60W in fridge, 1 x 60W in freezer" & intlight_wcs!="2x 40 Watts" & intlight_wcs!="2x 60 Watts" & intlight_wcs!="3 bulbs 40W, 1 bulb 30W" &  intlight_wcs!=""

//Create Stainless Score
		
	gen stainless_sc=0
	replace stainless_sc=1 if doorcolor_wcs=="Black Stainless"
	replace stainless_sc=1 if doorcolor_wcs=="Stainless"
	replace stainless_sc=1 if doorcolor_wcs=="Stainless Steel"	
	replace stainless_sc=1 if doorcolor_wcs=="Stainless Steel w/Black"
	replace stainless_sc=1 if doorcolor_wcs=="Stainless finish"
	replace stainless_sc=1 if doorcolor_wcs=="Stainless platinum"
	replace stainless_sc=1 if doorcolor_wcs=="Titanium"
	replace stainless_sc=1 if doorcolor_tera=="STAINLESS"
	replace stainless_sc=1 if doorcolor_tera=="TITANIUM"

//Create Color Score		
	gen doorcolor=doorcolor_wcs
	replace doorcolor=doorcolor_tera if doorcolor==""

	replace doorcolor="Stainless finish" if doorcolor_wcs=="Stainless look"
	replace doorcolor="Stainless Steel" if doorcolor_wcs=="Stainless"
	replace doorcolor="Stainless finish" if doorcolor_wcs=="Stainless Steel look"
	
	replace doorcolor="Bisque" if doorcolor=="BISQUE"
	replace doorcolor="Bisque" if doorcolor=="BISQUE ON BISQUE"
	replace doorcolor="Bisque" if doorcolor=="BISQUE/BISCUIT"
	replace doorcolor="Bisque" if doorcolor=="Biscuit"
	replace doorcolor="Bisque" if doorcolor_wcs=="Off-White (Biscuit, Bisque)"
	replace doorcolor="Bisque" if doorcolor_wcs=="Cream"
	
	replace doorcolor="ALMOND" if doorcolor=="ALMOND ON ALMOND"
		
	replace doorcolor="Black" if doorcolor=="BLACK"
	replace doorcolor="Black" if doorcolor=="BLACK DIAMOND"
	replace doorcolor="Black" if doorcolor=="BLACK ON BLACK"
	replace doorcolor="Black" if doorcolor=="Black (panel ready)"
	replace doorcolor="Black" if doorcolor=="Black frame"
	
	replace doorcolor="Black Stainless" if doorcolor=="Stainless Steel w/Black"
	
	replace doorcolor="Stainless" if doorcolor=="Stainless Steel"	
	replace doorcolor="Stainless" if doorcolor=="Stainless finish"
	replace doorcolor="Stainless" if doorcolor=="STAINLESS"
	replace doorcolor="Stainless" if doorcolor=="Stainless steel w/ Easy Care&trade;"
	replace doorcolor="Stainless" if doorcolor=="Brushed aluminum"
	replace doorcolor="Stainless" if doorcolor=="CLEAN STEEL"
	replace doorcolor="Stainless" if doorcolor=="Cleansteel&trade; finish"
	replace doorcolor="Stainless" if doorcolor=="EasySteel&trade;"
	replace doorcolor="Stainless" if doorcolor=="Ultra Steel"
	 
	replace doorcolor="Titanium" if doorcolor=="TITANIUM"
	
	replace doorcolor="Panel ready" if doorcolor=="PANEL READY"
	
	replace doorcolor="Platinum" if doorcolor=="Platinum finish" 
                                      
	replace doorcolor="Silver" if doorcolor=="SILVER" 
	replace doorcolor="Silver" if doorcolor=="SILVER TONE" 
	replace doorcolor="Silver" if doorcolor=="Silver Mist" 
	replace doorcolor="Silver" if doorcolor=="Silver Ultra Finish" 
	replace doorcolor="Silver" if doorcolor=="Ultra SilverSteel&trade;" 
	replace doorcolor="Silver" if doorcolor=="Ultra silver" 
						
    replace doorcolor="Stainless look" if doorcolor=="Stainless Steel look" 
	replace doorcolor="Stainless look" if doorcolor=="STAINLESS LOOK"                
       
	replace doorcolor="SATINA" if doorcolor=="Satina&trade;" 
	replace doorcolor="SATINA" if doorcolor=="Ultra Satin&trade;"                   
          
	replace doorcolor="White" if doorcolor=="WHITE" 
	replace doorcolor="White" if doorcolor=="WHITE ON WHITE"      
  

//Ideally, we should define price thresholds based on type. 
	gen quality_sc=0
	replace quality_sc=1 if nat_sll<1200  & nat_sll>250   & nat_sll!=.
	replace quality_sc=2 if nat_sll<2100  & nat_sll>=1200 & nat_sll!=.
	replace quality_sc=3 if nat_sll>=2100 & nat_sll!=.


//gen quality_sc=doorcolor_sc+intlight_sc+dispenser_sc+advtech_sc+advfreezer_sc+advcooling_sc+airfilt_sc+defrost_sc+ice_sc


//-------------------------------------------------------------------------------------------------------------------------------------------
//Create Size Identifier
//-------------------------------------------------------------------------------------------------------------------------------------------

/*
hist AV if type_id==1 & overall>7.5
hist AV if type_id==2 & overall>7.5
hist AV if type_id==3 & overall>7.5
kdensity AV if type_id==1 & overall>7.5
*/

	gen size_id=0
	replace size_id=1 if type_id==1 & (overall_tera=="14.6-17.9 CU FT" | overall_tera=="16 CU. FT.-19 CU. FT BF" |  overall_tera=="16 CU. FT.-19 CU. FT TF" |  overall_tera=="18.0-20.0 CU FT" | overall_tera=="9.1-14.5 CU FT")
	replace size_id=1 if type_id==1 & AV>=12 & AV<23.5 & AV!=.
	replace size_id=2 if type_id==1 & AV>=23.5 & AV!=.

	replace size_id=1 if type_id==2 & (overall_tera=="14.6-17.9 CU FT" | overall_tera=="18.0-20.0 CU FT" |  overall_tera=="20 CU. FT.-23 CU. FT BF" |  overall_tera=="20 CU. FT.-23 CU. FT SS" |  overall_tera=="20.1-23.5 CU FT" )
	replace size_id=1 if type_id==2 & AV>=12 & AV<29.2 & AV!=.
	replace size_id=2 if type_id==2 & AV>=29.2 & AV!=.

	replace size_id=1 if type_id==3 & (overall_tera=="14.6-17.9 CU FT" | overall_tera=="16 CU. FT.-19 CU. FT BF" |  overall_tera=="18.0-20.0 CU FT" |  overall_tera=="20 CU. FT.-23 CU. FT BF" |  overall_tera=="20.1-23.5 CU FT" )
	replace size_id=1 if type_id==3 & AV>=12 & AV<28 & AV!=.
	replace size_id=2 if type_id==3 & AV>=28 & AV!=.



/*
. tab overall_tera if type_id==1

                PRD_CHR_ATR_DS |      Freq.     Percent        Cum.
-------------------------------+-----------------------------------
               14.6-17.9 CU FT |        167       24.96       24.96
       16 CU. FT.-19 CU. FT BF |          3        0.45       25.41
       16 CU. FT.-19 CU. FT TF |          2        0.30       25.71
               18.0-20.0 CU FT |        332       49.63       75.34
       20 CU. FT.-23 CU. FT BF |          4        0.60       75.93
       20 CU. FT.-23 CU. FT TF |          1        0.15       76.08
               20.1-23.5 CU FT |        112       16.74       92.83
                 23.6-27 CU FT |          1        0.15       92.97
       24 CU. FT.-26 CU. FT BF |          6        0.90       93.87
       24 CU. FT.-26 CU. FT TF |          1        0.15       94.02
                9.1-14.5 CU FT |         40        5.98      100.00
-------------------------------+-----------------------------------
                         Total |        669      100.00

. tab overall_tera if type_id==2

                PRD_CHR_ATR_DS |      Freq.     Percent        Cum.
-------------------------------+-----------------------------------
               14.6-17.9 CU FT |         13        2.35        2.35
               18.0-20.0 CU FT |          6        1.08        3.43
       20 CU. FT.-23 CU. FT BF |          8        1.44        4.87
       20 CU. FT.-23 CU. FT SS |          2        0.36        5.23
               20.1-23.5 CU FT |        168       30.32       35.56
                 23.6-27 CU FT |        311       56.14       91.70
       24 CU. FT.-26 CU. FT BF |          2        0.36       92.06
       24 CU. FT.-26 CU. FT SS |          5        0.90       92.96
       27 CU. FT.-31 CU. FT SS |          1        0.18       93.14
                 OVER 27 CU FT |         38        6.86      100.00
-------------------------------+-----------------------------------
                         Total |        554      100.00

. tab overall_tera if type_id==3

                PRD_CHR_ATR_DS |      Freq.     Percent        Cum.
-------------------------------+-----------------------------------
               14.6-17.9 CU FT |          5        0.93        0.93
       16 CU. FT.-19 CU. FT BF |          2        0.37        1.30
               18.0-20.0 CU FT |        120       22.30       23.61
       20 CU. FT.-23 CU. FT BF |          8        1.49       25.09
               20.1-23.5 CU FT |        161       29.93       55.02
                 23.6-27 CU FT |        147       27.32       82.34
                9.1-14.5 CU FT |         11        2.04       84.39
                 OVER 27 CU FT |         83       15.43       99.81
                 UP TO 9 CU FT |          1        0.19      100.00
-------------------------------+-----------------------------------
                         Total |        538      100.00

*/


//--------------------------------------------------------------------------------------------
//Create Brand Identifier
//--------------------------------------------------------------------------------------------

/*
gen brand_id="Others" 
replace brand_id="Frigidaire" 	if brand=="ELECTROLUX" | brand=="Electrolux" | brand=="Electrolux ICON"  | brand=="FRIGDAIRE" | brand=="FRIGIDAIRE" | brand=="Frigidaire" | brand=="Frigidaire Gallery" | brand=="Frigidaire Professional Series"
replace brand_id="GE" 			if brand=="GE" | brand=="GE Appliances" | brand=="Ge Cafe" | brand=="GE Monogram" | brand=="GE PROFILE" | brand=="GE Profile" | brand=="GE/MONOGRAM" | brand=="GENERAL ELECTRIC"
replace brand_id="Whirlpool" 	if brand=="AMANA" | brand=="AMANA/MAYTAG" | brand=="Amana" | brand=="JENN-AIR" ///
									| brand=="JENNAIR" | brand=="JENNAIR/KITCHENAID" | brand=="Jenn-Air" | brand=="KITCHENAID" ///
									| brand=="MAYTAG" | brand=="Maytag" | brand=="VIKING" | brand=="Viking" ///
									| brand=="WHIRLPOOL" | brand=="WHR" | brand=="Whirlpool" | brand=="Whirlpool Gold"
replace brand_id="Kenmore" 	if brand=="KENMORE"  | brand=="KENMORE ELITE" | brand=="KENMORE PRO" | brand=="Kenmore" ///
							   | brand=="Kenmore Elite" | brand=="Kenmore PRO"
*/

gen brand_id="Others_Low"
replace brand_id="Others_High" if brand=="BOSCH" | brand=="Bosch" | brand=="DACOR" | brand=="Dacor" | brand=="FISHER & PAYKEL" | brand=="LIEBHERR MIELE" | brand=="THERMADOR"
replace brand_id="Frigidaire_Low" 	if brand=="ELECTROLUX" | brand=="Electrolux" | brand=="FRIGDAIRE" | brand=="FRIGIDAIRE" | brand=="Frigidaire" 
replace brand_id="Frigidaire_High" 	if brand=="Frigidaire Gallery" | brand=="Frigidaire Professional Series" | brand=="Electrolux ICON" | brand=="ICON BY ELECTROLUX" 
replace brand_id="GE_Low" 			if brand=="GE" | brand=="GE Appliances" | brand=="GENERAL ELECTRIC"
replace brand_id="GE_High" 			if brand=="Ge Cafe" | brand=="GE Monogram" | brand=="GE PROFILE" | brand=="GE Profile" | brand=="GE/MONOGRAM" 
replace brand_id="Whirlpool_Low" 	if brand=="AMANA" | brand=="AMANA/MAYTAG" | brand=="Amana" | brand=="MAYTAG" | brand=="Maytag" | brand=="WHIRLPOOL" | brand=="WHR" | brand=="Whirlpool" 
replace brand_id="Whirlpool_High" 	if  brand=="JENN-AIR" | brand=="JENNAIR" | brand=="JENNAIR/KITCHENAID" | brand=="Jenn-Air" | brand=="KITCHENAID" | brand=="VIKING" | brand=="Viking" | brand=="Whirlpool Gold"									
replace brand_id="Kenmore_Low" 		if brand=="KENMORE"  | brand=="Kenmore" 
replace brand_id="Kenmore_High" 	if brand=="KENMORE ELITE" | brand=="KENMORE PRO"  | brand=="Kenmore Elite" | brand=="Kenmore PRO"

//Create Icemaker Identifier



//--------------------------------------------------------------------------------------------
//Create Energy Consumption Identifier
//--------------------------------------------------------------------------------------------
/*
MEF / -10 / -15 / -20 / -25
*/


gen refrigeratortype="Refrigerator-freezer"
gen sizestyle="non-compact"
foreach x in sizestyle {
	replace `x'="compact" if overall<7.75
}

// gen refrigstyle="" 
// replace refrigstyle="Bottom Freezer w/Ice thru door" 	if type_id==3 & ice_sc==1
// replace refrigstyle="Bottom Freezer w/o Ice thru door" 	if type_id==3 & ice_sc==0
// replace refrigstyle="Side-by-Side w/Ice thru door" 		if type_id==2 & ice_sc==1
// replace refrigstyle="Side-by-Side w/o Ice thru door" 	if type_id==2 & ice_sc==0
// replace refrigstyle="Top Freezer w/Ice thru door" 		if type_id==1 & ice_sc==1
// replace refrigstyle="Top Freezer w/o Ice thru door" 	if type_id==1 & ice_sc==0

gen refrigstyle="" 
replace refrigstyle="Bottom Freezer w/Ice thru door" 	if type_id==3 & icemaker=="door"
replace refrigstyle="Bottom Freezer w/o Ice thru door" 	if type_id==3 & icemaker!="door"
replace refrigstyle="Side-by-Side w/Ice thru door" 		if type_id==2 & icemaker=="door"
replace refrigstyle="Side-by-Side w/o Ice thru door" 	if type_id==2 & icemaker!="door"
replace refrigstyle="Top Freezer w/Ice thru door" 		if type_id==1 & icemaker=="door"
replace refrigstyle="Top Freezer w/o Ice thru door" 	if type_id==1 & icemaker!="door"

gen refrigdefrosttype="Automatic" if (defrost!="Manual" & defrost!="Partial")
replace refrigdefrosttype="Manual" if (defrost=="Manual" | defrost=="0")
replace refrigdefrosttype="Partial" if defrost=="Partial" 


//refrigstyle 	refrigdefrosttype	sizestyle	built-in 	icemaker

// sort sizestyle refrigstyle refrigdefrosttype
// 
// merge sizestyle refrigstyle refrigdefrosttype using "$pathname\standards\standards_refrigerators"
// ren _m merge_standard

sort sizestyle refrigstyle refrigdefrosttype builtin icemaker
 
merge sizestyle refrigstyle refrigdefrosttype builtin icemaker using "$pathname\standards\standards_refrigerators2014"
ren _m merge_standard


gen mef_1993=mef_b_1993*AV+mef_a_1993
gen mef_2001=mef_b_2001*AV+mef_a_2001
gen mef_2014=mef_b_2014*AV+mef_a_2014
gen es_1997=es_b_1997*AV+es_a_1997
gen es_2001=es_b_2001*AV+es_a_2001
gen es_2003=es_b_2003*AV+es_a_2003
gen es_2004=es_b_2004*AV+es_a_2004
gen es_2008=es_b_2008*AV+es_a_2008

pause on
pause

gen mef=mef_2001  
replace mef=naeca if naeca!=. & bad_match_EPA==0
replace mef=mef_1993  if year_add<2001 
gen percentbetter_sears=(mef-kwh)/mef 

gen problem_standard=.
replace problem_standard=0 if naeca!=. & mef_2001!=.
replace problem_standard=1 if abs(naeca-mef_2001)>10 & naeca!=. & mef_2001!=. & bad_match_EPA==0

gen mef_rel=percentbetter_sears
replace mef_rel=percentbetter if mef_rel==. & bad_match_EPA==0
replace mef_rel=percentbetter if kwh==kwh_EPA & kwh_EPA!=. & percentbetter!=.  & bad_match_EPA==0  & mef_rel<=-0.08


gen standard_class="unknown"
replace standard_class="mef" 	if  mef_rel>=-0.08 & mef_rel<0.05            //Note that here we are taking care of pid with crazy mef-kwh differences    
replace standard_class="10" 	if  mef_rel>=0.05 & mef_rel<0.13
replace standard_class="15" 	if  mef_rel>=0.13 & mef_rel<0.18
replace standard_class="20" 	if  mef_rel>=0.18 & mef_rel<0.22
replace standard_class="25" 	if  mef_rel>=0.22 & mef_rel!=.


sort pid
save $pathname\refrigerators\create_agg_choice_long, replace

keep model_Sears pid*  nat* brand_id brand AV overall size_id type_id type kwh kwh_EPA standard_class  mef mef_rel estar estar_EPA bad_match_EPA oldestar stainless_sc doorcolor quality_sc defrost_sc ice_sc year_add delisted airfilt_sc  advcooling_sc  advfreezer_sc advtech_sc dispenser_sc intlight_sc  mef_2014
order model_Sears pid*  nat* brand_id brand AV overall size_id type_id type kwh kwh_EPA standard_class  mef mef_rel estar estar_EPA bad_match_EPA oldestar stainless_sc doorcolor quality_sc defrost_sc ice_sc year_add delisted airfilt_sc  advcooling_sc  advfreezer_sc advtech_sc dispenser_sc intlight_sc  mef_2014


sort pid
save $pathname\refrigerators\create_agg_choice, replace

pause on
pause


use $pathname\refrigerators\create_agg_choice, replace
	
	expand 12
	sort pid
	by pid: egen month=seq()
	gen year=2007
    
	gen s_estar=0
	replace s_estar=1 if (standard=="15" | standard=="20" | standard=="25") 

	compress
  sort pid month
save  $pathname\refrigerators\attributes_2007_monthly, replace


use $pathname\refrigerators\create_agg_choice, replace
	
	expand 52
	sort pid
	by pid: egen week=seq()
	gen year=2007
    
	gen s_estar=0
	replace s_estar=1 if (standard=="15" | standard=="20" | standard=="25") 
	
	compress
  sort pid week 
save  $pathname\refrigerators\attributes_2007_weekly, replace



use $pathname\refrigerators\create_agg_choice, replace
	
	expand 12
	sort pid
	by pid: egen month=seq()
	gen year=2008
    
	gen s_estar=0
	replace s_estar=1 if (standard=="15" | standard=="20" | standard=="25") & month<=4	
	replace s_estar=1 if (standard=="20" | standard=="25") & month>4

	compress
  sort pid month
save  $pathname\refrigerators\attributes_2008_monthly, replace


use $pathname\refrigerators\create_agg_choice, replace
	
	expand 52
	sort pid
	by pid: egen week=seq()
	gen year=2008
    
	gen s_estar=0
	replace s_estar=1 if (standard=="15" | standard=="20" | standard=="25") & week<=17	
	replace s_estar=1 if (standard=="20" | standard=="25") & week>17

	compress
  sort pid week 
save  $pathname\refrigerators\attributes_2008_weekly, replace

use $pathname\refrigerators\create_agg_choice, replace
 
	expand 366
	sort pid
	by pid: egen datenum=seq()
	replace datenum=datenum+td(31Dec2007)
	gen year=2008

	gen s_estar=0
	replace s_estar=1 if (standard=="15" | standard=="20" | standard=="25") & datenum<=td(28April2008)
	replace s_estar=1 if (standard=="20" | standard=="25") & datenum>td(28April2008)
	
	
	compress
  sort pid datenum
save  $pathname\refrigerators\attributes_2008_daily, replace

use $pathname\refrigerators\create_agg_choice, replace

	expand 12
	sort pid
	by pid: egen month=seq()
	gen year=2009

	gen s_estar=0
	replace s_estar=1 if (standard=="20" | standard=="25")
	
	compress
  sort pid month 
save  $pathname\refrigerators\attributes_2009_monthly, replace


use $pathname\refrigerators\create_agg_choice, replace

	expand 52
	sort pid
	by pid: egen week=seq()
	gen year=2009

	gen s_estar=0
	replace s_estar=1 if (standard=="20" | standard=="25")
	
	compress
  sort pid week 
save  $pathname\refrigerators\attributes_2009_weekly, replace

use $pathname\refrigerators\create_agg_choice, replace

	expand 365
	sort pid
	by pid: egen datenum=seq()
	replace datenum=datenum+td(31Dec2008)
	gen year=2009

	gen s_estar=0
	replace s_estar=1 if (standard=="20" | standard=="25")
	compress
  sort pid datenum
save  $pathname\refrigerators\attributes_2009_daily, replace



use $pathname\refrigerators\create_agg_choice, replace

	expand 12
	sort pid
	by pid: egen month=seq()
	gen year=2010

	gen s_estar=0
	replace s_estar=1 if (standard=="20" | standard=="25") 
	replace s_estar=1 if month<3 & (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977")
	replace s_estar=0 if month>=3 & (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977")
	gen delisted2010=0
	replace delisted2010=1 if  (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977")

	compress
  sort pid month 
save  $pathname\refrigerators\attributes_2010_monthly, replace

use $pathname\refrigerators\create_agg_choice, replace

	expand 52
	sort pid
	by pid: egen week=seq()
	gen year=2010

	gen s_estar=0
	replace s_estar=1 if (standard=="20" | standard=="25") 
	replace s_estar=1 if week<5 & (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977")
	replace s_estar=0 if week>=5 & (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977")
	gen delisted2010=0
	replace delisted2010=1 if  (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977")

	compress
  sort pid week 
save  $pathname\refrigerators\attributes_2010_weekly, replace



use $pathname\refrigerators\create_agg_choice, replace

	expand 365
	sort pid
	by pid: egen datenum=seq()
	replace datenum=datenum+td(31Dec2009)
	gen year=2010

	gen s_estar=0
	replace s_estar=1 if (standard=="20" | standard=="25")
	replace s_estar=1 if datenum<td(5Feb2010) & (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977")
	replace s_estar=0 if datenum>=td(5Feb2010) & (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977")
	gen delisted2010=0
	replace delisted2010=1 if  (substr(model,1,4)=="7973" | substr(model,1,4)=="7975" | substr(model,1,4)=="7978" | substr(model,1,8)=="LFX21975" | substr(model,1,8)=="LFX25975" | substr(model,1,8)=="LFX28977")

	compress
  sort pid datenum 
save  $pathname\refrigerators\attributes_2010_daily, replace



use $pathname\refrigerators\create_agg_choice, replace

	expand 52
	sort pid
	by pid: egen week=seq()
	gen year=2011

	gen s_estar=0
	replace s_estar=1 if (standard=="20" | standard=="25")
	
	compress
  sort pid week 
save  $pathname\refrigerators\attributes_2011_weekly, replace


use $pathname\refrigerators\create_agg_choice, replace

	expand 52
	sort pid
	by pid: egen week=seq()
	gen year=2012

	gen s_estar=0
	replace s_estar=1 if (standard=="20" | standard=="25")
	
	compress
  sort pid week 
save  $pathname\refrigerators\attributes_2012_weekly, replace
