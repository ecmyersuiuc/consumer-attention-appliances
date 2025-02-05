//do H:\Research\sears\rebate_script\process_SEEARP_02232013.do
clear 

set mem 5000m
pause on

global  pathSEEARP="H:\Research\sears\estar_data\rebate\Cash4Appliances"

use "$pathSEEARP\SEEARP US.dta", clear

gen date_pur=date( purchasedate,"MDY")
gen date_app=date( applicationdate,"MDY") 
gen date_pay=date( paymentdate,"MDY") 
 

ren model model_original
gen model=substr(model_original,1,15)


replace type="Air Conditioners (Central)" if type=="Air conditioners (central)"
replace type="Air Conditioners (Room)" if type=="Air conditioners (room)"
replace type="Boilers (Gas)" if type=="Boiler Reset Controls (GAS)"
replace type="Boilers (Oil)" if type=="Boiler Reset Controls (OIL)"
replace type="Boilers (Oil)" if type=="Boilers (oil)"
replace type="Boilers (Propane)" if type=="Boilers (propane)"
replace type="Clothes Washers" if type=="CLOTHES WASHERS"
replace type="Clothes Washers" if type=="Clothes washers"
replace type="Dishwashers" if type=="DISHWASHERS"
replace type="Furnaces (Oil)" if type=="Furnace (oil)"
replace type="Furnaces (Oil)" if type=="Furnace (oil)"
replace type="Furnaces (Oil)" if type=="Furnaces (OIL)"
replace type="Furnaces (Gas)" if type=="Furnaces (GAS)"
replace type="Furnaces (Gas)" if type=="Furnace (gas)"
replace type="Furnaces (Propane)" if type=="Furnaces (PROPANE)"
replace type="Furnaces (Gas)" if type=="Furnaces (propane)"
replace type="Heat Pumps (Air Source)" if type=="Heat Pumps (air source)"
replace type="Heat Pumps (Ground Source)" if type=="Heat Pumps (ground source)"
replace type="Water Heaters (Electric Heat Pump)" if type=="Water Heaters (electric heat pump)"
replace type="Water Heaters (Gas Storage)" if type=="Water Heaters (gas or propane storage)"
replace type="Water Heaters (Gas Storage)" if type=="Water Heaters (gas storage)"
replace type="Water Heaters (Gas Tankless)" if type=="Water Heaters (gas tankless)"
replace type="Freezers" if type=="FREEZERS"
replace type="Dishwashers" if type=="DISHWASHERS"
replace type="Refrigerators" if type=="REFRIGERATORS"

gen type2=type
replace type2="Air Conditioners" if type2=="Air Conditioners (Central)"
replace type2="Air Conditioners" if type2=="Air Conditioners (Room)"
replace type2="Air Conditioners" if type2=="Air Conditioners (central)"
replace type2="Air Conditioners" if type2=="Air Conditioners (room)"

replace type2="Boilers" if type2=="Boiler Reset Controls (Gas)"
replace type2="Boilers" if type2=="Boiler Reset Controls (Oil)"
replace type2="Boilers" if type2=="Boilers (Gas)"
replace type2="Boilers" if type2=="Boilers (Oil)"
replace type2="Boilers" if type2=="Boilers (Propane)"
replace type2="Boilers" if type2=="Boilers (gas)"

replace type2="Furnaces" if type2=="Furnaces (Gas)" 
replace type2="Furnaces" if type2=="Furnaces (Oil)"
replace type2="Furnaces" if type2=="Furnaces (Propane)"
replace type2="Furnaces" if type2=="Furnaces (gas)"
replace type2="Furnaces" if type2=="Furnaces (oil)"

replace type2="Heat Pumps" if type2=="Heat Pumps (Air Source)" 
replace type2="Furnaces" if type2=="Heat Pumps (Ground Source)"
replace type2="Furnaces" if type2=="Heat pumps (air source)"
replace type2="Furnaces" if type2=="Heat pumps (ground source)"

replace type2="Electric Water Heaters" if type2=="Water Heaters (Electric Heat Pump)" 
replace type2="Electric Water Heaters" if type2=="Water heaters (electric heat pump)" 
replace type2="Gas/Propane Water Heaters" if type2=="Water Heaters (Gas Storage)" 
replace type2="Gas/Propane Water Heaters" if type2=="Water heaters (gas storage)" 
replace type2="Gas/Propane Water Heaters (Tankless)" if type2=="Water Heaters (Gas Tankless)" 
replace type2="Gas/Propane Water Heaters (Tankless)" if type2=="Water heaters (gas tankless)"
replace type2="Gas/Propane Water Heaters" if type2=="Water Heaters (propane storage)" 
replace type2="Gas/Propane Water Heaters (Tankless)" if type2=="Water Heaters (propane tankless)"  
replace type2="Gas/Propane Water Heaters" if type2=="Water Heaters (Propane Storage)" 
replace type2="Gas/Propane Water Heaters (Tankless)" if type2=="Water Heaters (Propane Tankless)"  
replace type2="Solar Water Heaters" if type2=="Water Heaters (Solar, Electric Backup)" 
replace type2="Solar Water Heaters" if type2=="Water Heaters (Solar, Gas Backup)" 
replace type2="Solar Water Heaters" if type2=="Water Heaters (Solar, electric backup)" 
replace type2="Solar Water Heaters" if type2=="Water Heaters (solar, electric backup)" 
replace type2="Solar Water Heaters" if type2=="Water Heaters (solar, gas backup)" 
replace type2="Solar Water Heaters" if type2=="Water Heaters (solar, indirect backup)" 

save   "$pathSEEARP\SEEARP_US_cleaned", replace 