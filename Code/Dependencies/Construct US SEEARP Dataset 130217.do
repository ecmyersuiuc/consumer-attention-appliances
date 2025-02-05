* CONSTRUCT US SEEARP DATASET 130217
* FEBRUARY 17, 2013
* SOURCE FILES: DEPARTMENT OF ENERGY VIA FOIA REQUEST
* CHANGES TO SOURCE FILES: 
* (1) RENAMED FILES TO EXCLUDE DOE ID NUMBER, THUS IDENTIFCATION ONLY ON STATE ABBREVIATION
* (2) CONVERT TO CSV FORMAT
* (3) CHANGED VARIABLE NAMES SO THEY ARE CONSISTENT ACROSS DATA SETS (NOTE: ERROR AND COMMENT VARIABLES ARE NOT MADE UNIFORM)
* (4) CONVERT DATA TYPES TO NUMBERS FOR ALL $-UNIT VARIABLES (PURCHASE PRICE, REBATE AMOUNT, RECYCLING REBATE, NON-SEEARP REBATE)

capture clear
capture clear matrix
capture log close
set mem 2500m
set more off
set matsize 4000

global pathname="C:\Users\erica.myers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Data\SEEARP Data"
cd "$pathname\"
log using "Construct US SEEARP Dataset 130217", replace 

local states "AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY"
foreach x of local states  {
  insheet using "SEEARP_`x'_FRR.csv", names
  describe
  sum
  save "SEEARP_`x'.dta", replace
  clear
  }

foreach x of local states {
  append using "SEEARP_`x'.dta", force
  }
  
* LABEL VARIABLES
la var state "State"
la var type "Product Type (Appliance)"
la var brand "Brand of Product"
la var brand2 "Brand of Product 2" 
la var model "Model Number"
la var ahri "AHRI Certified Reference Number"
la var srcc "SRCC Certification Number"
la var purchasedate "Date of Product Purchase"
la var retailer "Retailer"
la var applicationdate "Date of Application Receipt"
la var paymentdate "Date of Rebate Payment"
la var price "Purchase Price, $"
la var rebate "Amount of Rebate Payment, $"
la var zip_delivery "Zip Code of Product Delivery/Installation"
la var hauledaway "Replaced Product Hauled Away"
la var recycled "Replaced Product Recycled"
la var recyclingrebate_dv "Additional Recycling Rebate Paid"
la var rebate_recyc "Amount of Recycling Rebate Paid"
la var rebate_nonseearp "Non-SEEARP Rebate(s) Paid"
la var brand_repl "Brand of Product Replaced"
la var model_repl "Model Number of Replaced Product"
la var eff_repl "Efficiency Rating of Replaced Product"
la var claimid "Claim ID"

sort state

save "SEEARP US_check.dta", replace
