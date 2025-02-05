
clear all
set more off
set maxvar 15000
set matsize 9000
pause on

global dirpath = "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\bootstrap SE's"
cd "$dirpath"

use boot1a, clear
append using boot1b
append using boot1c
append using boot1d
gen ratio = b_eleccost_county/(b_real_price_zip_mode*8.86325164)

collapse (sd) b* ratio

use boot4a, clear
append using boot4b
append using boot4c
append using boot4d
gen ratio = b_eleccost_county/(b_real_price_zip_mode*8.86325164)

collapse (sd) b* ratio

use boot3a, clear
append using boot3b
append using boot3c
append using boot3d

gen ratio = b_eleccost_county/(b_real_price_zip_mode*8.86325164)

collapse (sd) b* ratio

use boot5a, clear
append using boot5b
append using boot5c
append using boot5d

gen ratio = b_eleccost_county/(b_real_price_zip_mode*8.86325164)

collapse (sd) b* ratio

use boot6a, clear
append using boot6b
append using boot6c
append using boot6d

gen ratio = b_eleccost_county/(b_real_price_zip_mode*8.86325164)

collapse (sd) b* ratio

