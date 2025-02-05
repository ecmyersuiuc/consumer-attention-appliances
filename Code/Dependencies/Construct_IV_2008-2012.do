*We recreate a version of the Kahn-Mansur instrument for electricity price.  This is the quote from their paper describing the IV

*"We construct instruments using the product of the local utility's capacity shares of coal, oil and gas-fired power plants and the respective annual 
*average fuel price.  The shares data are from the EIA form 860 data for 1995. The fuel prices are from the EIA: coal prices are quantity-weighted annual 
*averages from EIA form 423; oil prices are the spot WTI; and natural gas prices are the annual Henry Hub contract 1 prices."

*Our data span 2008-2012.  We use 2007 for the share data so that it is pre-determined.

global dirpath="[Put your path to the replication folder here]\Replication_JPubE_RR"

******************************************************************************************************************************************************
*STEP 1: CREATE A SHARE VARIABLE FOR COAL (1), GAS (2) AND PETROLEUM (3)
******************************************************************************************************************************************************

*BRING IN EIA FORM 860 2007 AND CREATE COAL, OIL AND NATURAL GAS CATEGORIES:
*1 = COAL: BIT,LIG,SUB,WC,SC
*2 = NG: NG,WH
*3 = PETROLEUM: DFO, RFO, WO,JF,KER,PC

import excel "$dirpath\Data\IV_data\Form860_2007.xls", first clear
gen fuel = ENERGY_SOURCE_1=="BIT"|ENERGY_SOURCE_1=="LIG"|ENERGY_SOURCE_1=="SUB"|ENERGY_SOURCE_1=="WC"|ENERGY_SOURCE_1=="SC"
replace fuel = 2 if ENERGY_SOURCE_1=="NG"|ENERGY_SOURCE_1=="WH"
replace fuel = 3 if ENERGY_SOURCE_1=="DFO"|ENERGY_SOURCE_1=="RFO"|ENERGY_SOURCE_1=="WO"|ENERGY_SOURCE_1=="JF"|ENERGY_SOURCE_1=="KER"|ENERGY_SOURCE_1=="PC"

*Sum up the capacity by utility and energy source

collapse (sum) NAMEPLATE SUMMER_CAPACITY WINTER_CAPACITY, by(UTILCODE UTILNAME fuel)
ren NAMEPLATE capacity
gen capacity2 = .5*SUMMER_CAPACITY+.5*WINTER_CAPACITY

*Create a share variable
bysort UTILCODE: egen fossil = total(capacity) if fuel>0
bysort UTILCODE: egen fossil2 = total(capacity2) if fuel>0
gen share = capacity/fossil if fuel>0
gen share2 = capacity2/fossil2 if fuel>0
ren UTILCODE operatorid
save "$dirpath\Data\IV_data\temp", replace

*same shares for every year in the sample
forval x = 2008/2012 {
use "$dirpath\Data\IV_data\temp", clear
gen year = `x'
if `x'==2008 {
		save "$dirpath\Data\IV_data\share", replace
	}
	else {
		append using "$dirpath\Data\IV_data\share"
		save "$dirpath\Data\IV_data\share", replace
	}
}

save "$dirpath\Data\IV_data\share", replace

******************************************************************************************************************************************************
*STEP 2: CREATE A QUANTITY WEIGHTED COAL PRICE BY UTILCODE
*Un-regulated utilities do not have prices in 923 data.  
*Create one instrument with state level prices of coalmine states for un-regulated and recorded price for regulated.  Also bring in average import price for imported coal
*Create another instrument with state level prices of coalmine states for both regulated and un-regulated
******************************************************************************************************************************************************

*BRING IN FORM 923 FOR PLANT LEVEL FUEL DATA (2008-2012)

forval x = 2008/2012 {
	insheet using "$dirpath\Data\IV_data\Form923_`x'.csv", clear
	keep if fuel_group=="Coal"
	if `x'==2008 {
		save "$dirpath\Data\IV_data\elec_priceIV", replace
	}
	else {
		append using "$dirpath\Data\IV_data\elec_priceIV", force
		save "$dirpath\Data\IV_data\elec_priceIV", replace
	}
}
replace coalmine_state = "IM" if coalmine_county=="IMP"|coalmine_state=="CL"|coalmine_state=="VZ"
save "$dirpath\Data\IV_data\elec_priceIV", replace

*BRING IN PRICES BY MINE STATE
insheet using "$dirpath\Data\IV_data\mine_state_prices.csv", names clear
forval x = 4/9 {
	local y = 2004+`x'
	ren v`x' coal_price`y'
	destring(coal_price`y'), ignore("--") replace
}

gen name = substr(description, strpos(description, ":")+2,.)
save "$dirpath\Data\IV_data\temp", replace

*give each state a 2 letter code
insheet using "$dirpath\Data\IV_data\state_table.csv", names clear
keep name abbreviation
ren abbreviation coalmine_state
merge 1:1 name using "$dirpath\Data\IV_data\temp"
drop if _merge==1
drop _merge

*reshape long

reshape long coal_price, i(name) j(year)

*convert $/short ton into $/MMBTU (19,210,000 BTU/short ton)

replace coal_price = coal_price*(1/19.21)
save "$dirpath\Data\IV_data\temp", replace

*bring in import prices
insheet using "$dirpath\Data\IV_data\coal_imports_prices_2001-2012.csv", names clear
keep if _n==1
forval x = 2001/2012 {
	local y = `x'-1997
	ren v`y' coal_price`x'
	destring(coal_price`x'), replace
}

reshape long coal_price, i(description) j(year)
gen coalmine_state = "IM"
keep coalmine_state coal_price year
order year coal_price coalmine_state
replace coal_price = coal_price*(1/19.21)
append using "$dirpath\Data\IV_data\temp"
keep if coalmine_state~=""
keep year coal*
save "$dirpath\Data\IV_data\temp", replace

use "$dirpath\Data\IV_data\elec_priceIV", clear
merge m:1 coalmine_state year using "$dirpath\Data\IV_data\temp"
drop if _merge==2
drop _merge

*put fuel prices from form 923 for regulated plants from cents/MMBTU to dollars/mmbtu
*There is one very high outlier price of $16.937
replace fuel_cost = "" if fuel_cost=="."
destring(fuel_cost), ignore(",") replace
replace fuel_cost = fuel_cost/100
replace fuel_cost = . if fuel_cost>15

*use mine state for fuel cost
gen fuel_cost2 = fuel_cost
*assign import state coal prices to unregulated plants
replace fuel_cost = coal_price if regulate=="UNR"

*create MMBTU measure: This is quantity*heat content (heat content is described as millions of btu/physical unit)
destring(quantity), ignore("," ".") replace
gen mmbtu = quantity*average_heat_content

*get proportion of total quantity by MMBTU
bysort operatorid year: egen total = total(mmbtu)
gen prop = mmbtu/total
gen prop_price = prop*fuel_cost
gen prop_price2 = prop*fuel_cost2

collapse(sum) prop_price prop_price2, by(operatorid year)
ren prop_price coal_price
ren prop_price2 coal_price2
merge 1:m operatorid year using "$dirpath\Data\IV_data\share"

*5.8% of 860 coal capacity doesn't merge with 923 prices
drop if _merge==1
drop _merge

save "$dirpath\Data\IV_data\elec_priceIV", replace

******************************************************************************************************************************************************
*STEP 3: BRING IN NATIONAL OIL, GAS, AND COAL PRICES AND CONVERT TO $/KWH
*Oil prices are in $/barrel According to EIA .00175 barrels/kwh
*Gas prices are in $/MMBTU According to EIA Natural gas = 10,354 Btu/kWh
*Coal prices are now in $/MMBTU According to EIA Coal = 10,089 Btu/kWh
*Source: http://www.eia.gov/tools/faqs/faq.cfm?id=667&t=8
******************************************************************************************************************************************************

insheet using "$dirpath\Data\IV_data\wti_oil_price.csv", clear
ren date year
ren cushing oil_price
replace oil_price = oil_price*.00175
merge 1:m year using "$dirpath\Data\IV_data\elec_priceIV"
keep if _merge==3
drop _merge

save "$dirpath\Data\IV_data\elec_priceIV", replace

insheet using "$dirpath\Data\IV_data\hh_ng_price.csv", clear
ren date year
ren henry ng_price
replace ng_price = ng_price*.010354
merge 1:m year using "$dirpath\Data\IV_data\elec_priceIV"
keep if _merge==3
drop _merge

replace coal_price = coal_price*.010089
replace coal_price2 = coal_price2*.010089
save "$dirpath\Data\IV_data\elec_priceIV", replace

insheet using "$dirpath\Data\IV_data\national_price_2008_2013.csv", clear
rename allcoal coal_price3
replace coal_price3 = coal_price3*(1/19.21)*(.010089)
merge 1:m year using "$dirpath\Data\IV_data\elec_priceIV"
keep if _merge==3
drop _merge

******************************************************************************************************************************************************
*STEP 4: CREATE IV PRICE BASED ON SHARES AND FUEL PRICES
******************************************************************************************************************************************************
gen missing = fuel==1&coal_price==.
bysort operatorid year: egen drop = total(missing)

gen elec_priceIV = share*coal_price if fuel==1
replace elec_priceIV = share*ng_price if fuel==2
replace elec_priceIV = share*oil_price if fuel==3

gen elec_priceIV2 = share*coal_price2 if fuel==1
replace elec_priceIV2 = share*ng_price if fuel==2
replace elec_priceIV2 = share2*oil_price if fuel==3

gen elec_priceIV3 = share*coal_price3 if fuel==1
replace elec_priceIV3 = share*ng_price if fuel==2
replace elec_priceIV3 = share2*oil_price if fuel==3

unique(operatorid year fuel)
drop if fuel==0
collapse (sum) elec_priceIV elec_priceIV2 elec_priceIV3 missing, by(operatorid year UTILNAME) 
replace elec_priceIV = . if missing>0
replace elec_priceIV2 = . if missing>0

save "$dirpath\Data\IV_data\elec_priceIV", replace

******************************************************************************************************************************************************
*STEP 5: MAP UTILITIES TO COUNTIES
******************************************************************************************************************************************************

*merge with utility-county matching
insheet using  "$dirpath\Data\IV_data\Form861_2007.csv", clear
ren utility_id operatorid 
ren county county_name
replace county_name = upper(county_name)
replace county_name = substr(county_name, 1, strpos(county_name, " BOROUGH")-1) if strmatch(county_name, "*BOROUGH*")==1
replace county_name = "SAINT FRANCIS" if state=="AR"&(county_name=="SAINT FRANCI"|county_name=="ST FRANCIS")
replace county_name = "SAN BERNARDINO" if state=="CA"&(county_name=="SAN BERNADINO")
replace county_name = "KENT" if state=="DE"&(strmatch(county_name, "*& NEW*")==1)
replace county_name = "DESOTO" if state=="FL"&county_name=="DE SOTO"
replace county_name = "SAINT JOHNS" if state=="FL"&county_name=="ST. JOHNS"
replace county_name = "SAINT LUCIE" if state=="FL"&county_name=="ST. LUCIE"
replace county_name = "CHATTAHOOCHEE" if state=="GA"&county_name=="CHATTAHOOCHE"
replace county_name = "GLASCOCK" if state=="GA"&county_name=="GLASSCOCK"
replace county_name = subinstr(county_name, "DEKALB", "DE KALB",.)
replace county_name = "O'BRIEN" if state=="IA"&county_name=="OBRIEN"
replace county_name = "DE WITT" if state=="IL"&county_name=="DEWITT"
replace county_name = "HUMBOLDT" if state=="IA"&county_name=="HUMBOLT"
replace county_name = "KOSSUTH" if state=="IA"&county_name=="KOSSUH"
replace county_name = "SAINT JOSEPH" if state=="IN"&(county_name=="ST. JOSEPH"|county_name=="ST JOSEPH")
replace county_name = "LAPORTE" if state=="IN"&county_name=="LA PORTE"
replace county_name = "CASSIA" if state=="ID"&county_name=="MARSHALL"
replace county_name = "CARROLL" if state=="IL"&county_name=="CAROL"
replace county_name = "DUPAGE" if state=="IL"&county_name=="DU PAGE"
replace county_name = "GREENE" if state=="IL"&county_name=="GREEN"
replace county_name = "JO DAVIESS" if state=="IL"&county_name=="JODAVIES"
replace county_name = "LASALLE" if state=="IL"&county_name=="LA SALLE"
replace county_name = "MACOUPIN" if state=="IL"&county_name=="MCCOUPIN"
replace county_name = "SAINT CLAIR" if state=="IL"&county_name=="ST CLAIR"
replace county_name = "LASALLE" if state=="LA"&county_name=="LA SALLE"
replace county_name = "EAST FELICIANA" if state=="LA"&county_name=="EAST FELICIA"
replace county_name = "SAINT HELENA" if state=="LA"&(county_name=="SAINT HELINA"|county_name=="ST. HELENA")
replace county_name = "SAINT BERNARD" if state=="LA"&county_name=="ST. BERNARD"
replace county_name = "SAINT CHARLES" if state=="LA"&county_name=="ST. CHARLES"
replace county_name = "SAINT JAMES" if state=="LA"&county_name=="ST. JAMES"
replace county_name = "SAINT JOHN THE BAPTIST" if state=="LA"&county_name=="ST JOHN THE BAPTIST"
replace county_name = "SAINT LANDRY" if state=="LA"&county_name=="ST LANDRY"
replace county_name = "SAINT MARTIN" if state=="LA"&county_name=="ST. MARTIN"
replace county_name = "SAINT TAMMANY" if state=="LA"&county_name=="ST. TAMMANY"
replace county_name = "BALTIMORE CITY" if state=="MD"&county_name=="BALTO. CITY"
replace county_name = "MONTGOMERY" if state=="MD"&county_name=="MONTGOMERY COUNTY"
replace county_name = "PRINCE GEORGE'S" if state=="MD"&county_name=="PRINCE GEORGES"
replace county_name = "QUEEN ANNE'S" if state=="MD"&county_name=="QUEEN ANNES"
replace county_name = "SAINT MARY'S" if state=="MD"&county_name=="SAINT MARYS"
replace county_name = "WORCESTER" if state=="MD"&county_name=="WORCHESTER"
replace county_name = "GRAND TRAVERSE" if state=="MI"&county_name=="GRAND TRAVER"
replace county_name = "STE. GENEVIEVE" if state=="MO"&county_name=="SAINTE GENEVIEVE"
replace county_name = "SAINT JOSEPH" if state=="MI"&(county_name=="ST JOSEPH"|county_name=="ST. JOSEPH")
replace county_name = "SAINT CLAIR" if state=="MO"&county_name=="ST. CLAIR"
replace county_name = "FARIBAULT" if state=="MN"&county_name=="FAIRBAULT"
replace county_name = "OTTER TAIL" if state=="MN"&county_name=="OTTERTAIL"
replace county_name = "YELLOW MEDICINE" if state=="MN"&county_name=="YELLOW MEDIC"
replace county_name = "DEER LODGE" if state=="MT"&county_name=="ANACONDA-DEE"
replace county_name = "SILVER BOW" if state=="MT"&county_name=="BUTTE-SILVER"
replace county_name = "GUILFORD" if state=="NC"&county_name=="GILFORD"
replace county_name = "NORTHAMPTON" if state=="NC"&county_name=="NORTH HAMPTON"
replace county_name = "SAINT LAWRENCE" if state=="NY"&(county_name=="ST LAWRENCE"|county_name=="ST. LAWRENCE")
replace county_name = "CARSON" if state=="NV"&county_name=="CARSON CITY"
replace county_name = "DESOTO" if state=="MS"&county_name=="DE SOTO"
replace county_name = "STANLY" if state=="NC"&county_name=="STANLEY"
replace county_name = "NEWPORT" if state=="RI"&county_name=="PORTSMOUTH"
replace county_name = "DEWITT" if state=="TX"&county_name=="DE WITT"
replace county_name = "SAN AUGUSTINE" if state=="TX"&county_name=="SAN AUGUSTIN"
replace county_name = "ALEXANDRIA" if state=="VA"&county_name=="ALEXANDRIA C"
replace county_name = subinstr(county_name, "CITY OF ","" ,1) if state=="VA"
replace county_name = subinstr(county_name, " CITY","" ,1) if state=="VA"&strmatch(county_name, "*FRANKLIN*")==0&strmatch(county_name, "*FAIRFAX*")==0&strmatch(county_name, "*RICHMOND*")==0&strmatch(county_name, "*ROANOKE*")==0
replace county_name = "SAINT CROIX" if state=="WI"&county_name=="ST. CROIX"
replace county_name = "ALLEGHANY" if state=="VA"&county_name=="CLIFTON FORG"
replace county_name = "WAHKIAKUM" if state=="WA"&county_name=="WAHKIAKURN"

replace county_name = "HOONAH-ANGOON" if state=="AK"&county_name=="HOONAH"
replace county_name = "MATANUSKA-SUSITNA" if state=="AK"&county_name=="MATANUSKA SUSITNA"
replace county_name = "PRINCE OF WALES-HYDER" if state=="AK"&county_name=="PRINCE OF WALES"
replace county_name = "SKAGWAY MUNICIPALITY, AK" if state=="AK"&county_name=="SKAGWAY YAKU"
replace county_name = "VALDEZ-CORDOVA" if state=="AK"&county_name=="VALDEZ CORDO"
replace county_name = "WRANGELL-PETERSBURG" if state=="AK"&county_name=="WRANGELL PET"
replace county_name = "YUKON-KOYUKUK" if state=="AK"&county_name=="YUKON KOYUKU"
drop year

merge m:1 state county_name using  "$dirpath\Data\IV_data\county_income"
drop if _merge==2 
drop _merge

joinby operatorid using "$dirpath\Data\IV_data\elec_priceIV", unmatched(both)
tab _merge

*a lot do not merge (~40%)
keep if _merge==3
drop _merge

**********************************************************************************************************************************************************
*TAKE THE AVERAGE
collapse (mean) elec_priceIV elec_priceIV2 elec_priceIV3 missing, by(county_name year state statecode countycode zcta5)
keep county_name state year elec* statecode countycode zcta5 missing 

**********************************************************************************************************************************************************

replace elec_priceIV = . if missing>0
replace elec_priceIV2 = . if missing>0
drop if county_name==""
ren statecode STATE
ren countycode COUNTY
drop if zcta5==""
save "$dirpath\Data\IV_data\first_stage", replace

erase "$dirpath\Data\IV_data\temp.dta"
erase "$dirpath\Data\IV_data\share.dta"

