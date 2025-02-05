# consumer-attention-appliances
Replication code and data for "Are consumers attentive to local energy costs? Evidence from the appliance market"

Sébastien Houde
HEC Lausanne

Erica Myers
University of Calgary

**Data**

Confidential data

1.	Appliance retailer’s data
Raw transaction-level data of appliance purchase for one large U.S. appliance retailer.  Detailed attributes data on individual appliances.

2.	 Utility rebate data
We use the DSIRE database to construct a measure of utility-level financial incentives for refrigerators. Raw data were downloaded in 2013. The DSIRE organization does not provide their data freely anymore. They can be contacted directly to have access to the data. 

https://www.dsireusa.org/


Non-confidential data

3.	Electricity price data
We use data from the Energy Information Administration (EIA), in particular Form-861, to construct local electricity prices. We use the Form-861 covering the period 2007 to 2012. These data can be found (accessed on December 9, 2020) at:

https://www.eia.gov/electricity/data/eia861/

We map utility-level electricity price data to county using the Service Territory file of the EIA 861 survey database.

4.	SEEARP’s rebate data
We use data from the State Energy Efficiency Appliance Rebate Program (SEEARP) that were originally collected by Houde and Aldy (2017). These data were collected by scrapping the program’ website of each state at the time the program was active between 2009 and 2011. 

5.	Census data: cross-walk zip code to county
We use a cross-walk from the Census bureau to map zip code to county. This cross-walk was downloaded in 2010. The file for the 2010 census can be downloaded at (accessed on December 9, 2020):

https://www2.census.gov/geo/docs/maps-data/data/rel/zcta_county_rel_10.txt

We also use the Federal Information Processing System (FIPS) code of the Census Bureau to map county and state. We use the 2009 FIPS code:

https://www.census.gov/programs-surveys/popest/geographies/reference-files.2009.html

6.	Electric capacity and coal, oil, and natural gas prices for constructing electricity price IV

*Coal imports prices*:

Import price from total world of All coal

http://www.eia.gov/beta/coal/data/browser/#/topic/40?agg=2,1,0&rank=ok&map=COAL.EXPORT_QTY.TOT-TOT-TOT.A&freq=A&start=2001&end=2012&ctype=map&ltype=pin&rtype=s&pin=&rse=0&maptype=0

Accessed: Thu Oct 29 2015 09:50:02 GMT-0500 (Central Daylight Time)

Source: U.S. Energy Information Administration

Units: $/short ton

Raw file: coal_imports_prices_2001-2012.csv

*Power plant capacity data for calculating fuel shares*

Form EIA-860 is a survey conducted by the U.S. Energy Information Administration (EIA) that collects detailed information about the generating capacity and fuel source of electricity plants in the United States.

Source: U.S. Energy Information Administration

Accessed: October 29, 2015

Raw file: Form860_2007.xls

*Power plant state and county of operation*

EIA Form 861 is a survey conducted by the U.S. Energy Information Administration (EIA) to collect data on the operations of electric utilities and other electricity providers in the United States.  It contains the state and county of the plants

Source: U.S. Energy Information Administration

Accessed: December 8, 2015

Raw file: Form861_2007.csv

*Plant level fuel data*

EIA Form 923 is a U.S. Energy Information Administration (EIA) survey that collects detailed data on the operation of electric power plants including fuel use and generation by plant.

Source: U.S. Energy Information Administration

Accessed: October and November, 2015

Raw files: Form923_2008.csv, Form923_2009.csv, Form923_2010.csv, Form923_2011.csv, Form923_2012.csv

*Henry Hub Natural Gas Prices*

http://tonto.eia.gov/dnav/ng/hist/rngwhhda.htm

Source: U.S. Energy Information Administration

Accessed: September 29, 2015

Raw files: hh_ng_price.csv

*Coal shipments to the electric power sector: price, by mine state*

http://www.eia.gov/beta/coal/data/browser/#/topic/44?agg=1,0&geo=vvvvvvvvvvvvo&rank=g&linechart=COAL.SHIP_MINE_PRICE.US-TOT.A&columnchart=COAL.SHIP_MINE_PRICE.US-TOT.A&map=COAL.SHIP_MINE_PRICE.US-TOT.A&freq=A&start=2008&end=2013&ctype=linechart&ltype=pin&rtype=s&pin=&rse=0&maptype=0

Source: U.S. Energy Information Administration

Accessed: Tue Sep 29 2015 12:21:34 GMT-0500 (Central Daylight Time)

Raw files: mine_state_prices.csv

*Coal shipments to the electric power sector price by plant state Annual*

http://www.eia.gov/beta/coal/data/browser/#/topic/45?agg=1

Source: U.S. Energy Information Administration

Accessed: 12:28:13 GMT-0600 (Central Standard Time)

Raw files: national_price_2008_2013.csv

*Cushing, OK WTI Spot Price FOB (Dollars per Barrel)*

http://tonto.eia.gov/dnav/pet/hist/LeafHandler.ashx?n=PET&s=RWTC&f=A

Source: U.S. Energy Information Administration

Accessed 12/8/2015

Raw files: wti_oil_price.csv


**Code**

1. Process Raw Data
   
1.1.	Electricity prices
   
ElectricityPrice_State_ProcessEIA861.do

Input: 
 - Census Bureau’s FIPS code: counties_FIPS.dta
 - EIA’s mapping of utility to county: utility_county_`year’.csv for the years 2007 to 2012
 - EIA consumption and revenue data for each utility: cons_`year’.csv for the years 2007 to 2012
   
Output:
 - state_elec_price_2007_2012.dta

ElectricityPrice_County_ProcessEIA861_v2.do

Input: 
 - Census Bureau’s FIPS code: counties_FIPS.dta
 - EIA’s mapping of utility to county: utility_county_`year’.csv for the years 2007 to 2012
 - EIA consumption and revenue data for each utility: cons_`year’.csv for the years 2007 to 2012
   
Output:
 - county_elec_price_2007_2012.dta
 - counties_FIPS_Wdup.dta
 - utility_county_2007_2012.dta

Make_p_elec_social_BorensteinBushnell.do

Description: This .do file takes the average utility-level social marginal costs and average marginal costs from B&B and maps them to counties by taking the residential consumers-weighted average across utilities that serve a given county

Input:
 - retail_final_Borenstein_Bushnell.dta	provided directly by Severin Borenstein
 - calc_annual: social marginal costs provided by Borenstein and Bushnell for the years 2014-2016
 - cons_2012.csv
 - counties_FIPS_Wdup.dta
 - utility_county_2007_2012.dta

Output:
 - county_elec_price_social_2007_2012.dta

Construct_IV_2008-2012

Description: Create a version of the Kahn-Mansur instrument for electricity price.  This is the quote from their paper describing the IV. Our data span 2008-2012.  We use 2007 for the share data so that it is pre-determined.  See word document “instrument build” for details on approach

Input:
 - Form860_2007.xls
 - Form861_2007.csv
 - Form923_`year'.csv
 - mine_state_prices.csv
 - coal_imports_prices_2001-2012.csv
 - wti_oil_price.csv
 - hh_ng_price.csv
 - national_price_2008_2013.csv
 - county_income.dta
 - state_table.csv 

Output:
 - first_stage.dta

1.2.	Refrigerator attribute data

The data files mareked in **bold** used for this section are not publicly available

attributes_wcs_tera.do: 

Description: clean the raw attribute data from the retailer

Input:
 - **Sears_w_EPA_CEC_FTC.dta** 
 - standards_refrigerators2014.dta
 - standards_refrigerators.dta

Output:
 - **create_agg_choice**
 - **attributes_`year_p'_weekly**

1.3.	 Retailer’s transaction level data 
The data files in **bold** used for this section are not publicly available. 

MakePricesTS_11022017.do

Description Use the raw transaction data to create time series of prices for each product-week-zip code tuple.  

Input: 
 - Raw data: **lcidemo_046_jan*year*_dec*year*.dta** for years 2007 to 2012
 - Detailed attribute information: **attributes_`year_p'_weekly.dta** for the years 2007 to 2012.

Output:
 - **lcidemo_046_jan*year*_dec*year*_week_store_ts_11022017.dta** for the years 2007 to 2012.dta

Create_SalesTax_zip_v3_2007_2012.do

Description: Extract sales tax rates from transaction level data. Data from several appliance categories are used to have a better coverage of all the regions and time period. The sales tax is the one realized at the retailer for each transaction. To compute the average sales tax at the zip code and week level, the sales tax paid for each transaction is extracted. The average is then taken across zip codes and weeks.  

Input: 
 - Raw data for different appliance categories: **lcidemo_046_jan*year*_dec*year*.dta** for years 2007 to 2012
 - Tax holidays for Energy Star manually collected from DSIRE: **sales_tax_holiday.dta**
 - Detailed attribute information for multiple appliance categories: **attributes_*year_p*_weekly.dta** (refrigerators), **attributes_026_*year*_p'** (clotheswashers), **attributes_022_*year*_p** (dishwashers), attributes_waterheaters_12132012 (waterheaters), for the years 2007 to 2012.

Output:
 - **tax_rate_estar_avg_month_zip_week_2007_2012.dta**
 - **sales_tax_holiday_week.dta**

create_choice_set_struct_rd_byHD_2008_2012.do

Description: Append the raw transaction-level data of refrigerator sales (one file per year) to create a panel of sales at the product-zip code-week level. Merge price time series, local electricity prices (state and county), rebate data (utility-level and state), and detailed attribute information.

Input: 
 - Raw data: **lcidemo_046_jan*year*_dec*year*.dta** for years 2007 to 2012
 - Price time series: **lcidemo_046_jan*year*_dec*year*_week_store_ts_11022017.dta** for years 2007 to 2012
 - State electricity prices: electricity_price_state_2007_2012.dta
 - County electricity prices: county_elec_price_2007_2012.dta
 - Utility-level rebates: **DSIRE_rebate_week_county_2007_2013.dta**
 - SEEARP rebates: cash4appliance_refrigerators_weekly_vf_tmp.dta
 - Census mapping from zip code to county: mapping_zip_county_nov99.dta
 - Detailed attribute information: **attributes_*year_p*_weekly.dta for the years 2007 to 2012**.
 - Sales tax data: **sales_tax_holiday_week.dta** and **tax_rate_estar_avg_month_zip_week_2007_2012.dta**

Output: 
 - **lcidemo_046_2008_2012_Dhd_week_store_ts_cleaned.dta**
 - **IVretail_046_2008_2012_Dhd_week_store_ts_cleaned.dta**

Create_Sales_Indicator.do 

Description: Create a sales indicator using the transaction data. We use this indicator in one robustness check.

Input: 
 - **lcidemo_046_2008_2012_struct_v11_11022017_robustb_nocensor_11022017** (this is a file that was created using an early version of create_choice_set_struct_rd_byHD_2008_2012.do)

Output: 
 - promo_price_code_national_week

prepare_reducedform_reg.do

Description: Create the main estimation sample at the week-store level. A random sample is draw. We need to select a stata seed (always choose 1 for replication) and the size of the subsample (50% for the paper).
 - Create regressors
 - Bring instrumental variables
 - Bring MEA electricity price data
 - Bring Cash For Appliances data
 - Restrict the sample to the most popular stores
 - Restrict the sample to the most popular models: pids responsible for 80% of the sales in a given year.	

Input: 
 - **lcidemo_046_2008_2012_Dhd_week_store_ts_cleaned.dta**
 - **IVretail_046_2007_2012_Dhd_week_store_ts_cleaned.dta**
 - **zip_storeAB_2007_2012_046.dta (for most popular stores)**
 - **sales_pid20_2007_2012_046_y (products responsible for 80% of sales in a given year)**
 - ProgramCharacteristics_Ref_CFA.dta
 - Cash4Appliances_announcement.dta

The data in these input files, in the “MEA”, folder are not used in the analysis, but are in the files we use for the main regression in the paper, therefore, we have included them for completeness
 - zip_placename_utility.dta
 - Standard_Prices.dta
 - mea_rates.dta

Output:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50.dta
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_10.dta

Final_data_build.do

Description: Create the final files with all the regressors, IVs, and additional robusteness checks that were requested in the review process.

Input: 
 - first_stage.dta
 - promo_price_code_national_week.dta
 - demo_046_2008_2012_by_zip_week.dta
 - utility_count.dta

Output:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final


1.4.	Utility rebates
The files in **bold** used for this section are not publicly available. 

Process_Dsire_2007_2013.do 

Input: 
 - **DSIRE_rebate_week_county_2007.dta** 
 - **DSIRE_rebate_week_county_2008**
 - **DSIRE_rebate_week_county_2009**
 - **DSIRE_rebate_week_county_2010**
 - **DSIRE_rebate_week_county_2011_2013**
 - **DSIRE_rebate_week_state_2007**
 - **DSIRE_rebate_week_state_2008**
 - **DSIRE_rebate_week_state_2009**
 - **DSIRE_rebate_week_state_2010**
 - **DSIRE_rebate_week_state_2011_2013**
 - **DSIRE_rebate_week_state_2007_2013**

Output: 
 - **DSIRE_rebate_week_county_2007_2013.dta**

1.5.	Cash for appliances

Construct US SEEARP Dataset 130217.do

Clean_SEEARP_US.do

cash4appliances_v2.do  
	
Input: cash4appliance_refrigerators_11212012.csv

Output: cash4appliance_refrigerators_weekly_vf_tmp.dta


2. Tables: Main Text

The files in **bold** used for this section are not publicly available

Table 1: Summary Statistics: Main Sample

Description: This script computes the main summary statistics of the estimation sample.

Script: Table1.do

Data: 
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50.dta

Table 2: Idiosyncratic Variation in Retail Prices. 

Description: This script shows how much idiosyncratic variation there is in the refrigerator price variable.

Script: Table2.do

Data: 
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50.dta

Table 3: Estimation of the Effect of Price and Energy Costs on Demand.

Description: Main regressions of the paper with Poisson regressions.

Script: Table3.do

Data: 
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table 4: Robustness Tests.

Description: Robustness tests for the main regressions.

Script: Table4.do

Data: 
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table 5: Control Function and 2SLS Estimation of the Effect of Price and Energy Costs on Demand.

Description: IV regressions

Script: Table5.do

Data: 
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table 6: Sensitivity of Energy Cost Responsiveness Estimates to Parameter Assumptions.

Description: BOE calculations

Script: Excel calculations in Table6.xlsx
	 
Table 7: Heterogeneity in the Effects of Price and Energy Costs on Demand.

Description: Additional regressions with heterogeneity

Script: Table7.do

Data: 
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table 8: Policy Analysis.

Description: Use the Borenstein and Bushnell’s data to simulate the demand with different pricing schemes. The goal is to show how tariff redesign could move the demand. 

Script: Tables_8_I1.do

Data:
 - first_stage.dta
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50.dta
 - county_elec_price_2007_2012.dta
 - county_elec_price_social_2007_2012.dta


3. Figures: Main Text

Figure 1: Price Variation Due to Retailer’s National Pricing Algorithm. 
	
 Description: Plot the model-specific variation in refrigerator price for four different models. 
	
 Script: Figure1.do
	
 Data:
- lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50.dta


Figure 2: Average Electricity Prices for Each State in a Census Division.

Description: Investigate variation in electricity prices across time and regions

Script: Figure2+3.do

Data:
 - **lcidemo_046_2008_2012_allsales.dta**
 - mapping_zip_county_nov99.dta
 - county_elec_price_2007_2012.dta

Figure 3: Distributions of Prices and Lifetime Energy Costs.

Description: Investigate variation in electricity prices across time and regions

Script: Figure2+3.do

Data:
 - **lcidemo_046_2008_2012_allsales.dta**
 - mapping_zip_county_nov99.dta
 - county_elec_price_2007_2012.dta

Figure 4: Binned Scatter Plots of Weekly Sales by Annual Energy Cost ($/Year) and Purchase Price ($).

Description: Present the correlation between the outcome variable and the two main regressors: annual energy costs and purchase price.

Script: Figure4a.do and Figure4b.do

Data: 
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

4. Tables: Appendix

Table A.1: Correlation Between Annual Energy Consumption and Attributes--

Description: Show how much of the variation in kWh/y is explained by a few attributes.

Script: TableA.1.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_10.dta

Table C.1: Additional Robustness Checks 

Description: Additional Poisson regressions

Script: TableC1.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table C.2: Summary Statistics within Store

Description: This script creates Table C.2, which looks at variation within store. Table C.2 complements Table 1 in the main text. Table C.2 was created to present raw data patterns that speak to identifying variation.

Script: TableC2.do

Data:
 - **lcidemo_046_2008_2012_struct_v11_11022017_robustb_nocensor_11022017.dta** (We use the raw data, so we can have variation within store instead of zip code, which is what one referee asked for.)
 - elec_price_state_2007_2012.dta
 - mapping_zip_county_nov99_short.dta
 - county_elec_price_2007_2012.dta

Table C.3: Correlation: Product Assortment and Local Electricity Prices

Description: This looks at how the composition of the choice set is correlated by local electricity prices and various controls. 

Dependency: Table_C3_prepare_choice_set.do

Inputs: 
 - **lcidemo_046_2008_2012_struct_v11_11022017_robustb_nocensor_11022017.dta**
 - elec_price_state_2007_2012.dta
 - mapping_zip_county_nov99_short.dta
 - county_elec_price_2007_2012.dta
Outputs:
 - **sum_stats_store_trimester.dta**

Table C.4: Robustness to Assortment Size, Promotional Price, and Subsidy Availability
	
Description: Additional robustness checks

Script: TableC4.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta	

Table D.1: Estimation of the Effect of Price and Energy Costs on Demand

Description: Table D.1 displays the results using the exact same specifications as in Table 3, except that we include zip code fixed effects (rather than county fixed effects) interacted with various controls, i.e., time dummies or attributes.

Script: TableD1.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table E.1: First Stage: IV Regression

Description: Table E.1 displays the results for the first stages of our instrumental variables regressions in Table 5.

Script: TableE1.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table F.1: Control Function and 2SLS Estimation of the Effect of Price and Energy Costs on Demand: Different Grouping Estimators

Description: Table F.1 displays results with grouping estimator instruments constructed using three and four efficiency groupings for each refrigerator type, rather than two.

Script: TableF1.do

Data:

 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table G.1: Robustness to Zip Code-by-Week Controls

Description: In Table G.1, we investigate the robustness of our preferred specification to the inclusion of finer grained area-by-time fixed effects.

Script: TableG1.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table G.2: Robustness: Lags of Product Price

Description: In Table G.2 we show that there is little affect of lagged prices on current purchases.

Script: TableG2.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table G.3: Control Function and 2SLS Estimation of the Effect of Price and Energy Costs on Demand

Description: In Table G.3, we instrument for both annual energy costs and purchase price.

Script: TableG3.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table H.1: Heterogeneity in the Effect of Price and Energy Costs on Demand by Efficiency and Electricity Price

Description: We explore heterogeneous effects.

Script: TableH1.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table H.2: Heterogeneity in the Effect of Price and Energy Costs on Demand by Year

Description: We explore additional heterogeneous effects.

Script: TableH2.do

Data:
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Table I.1: Policy Analysis: Additional Scenarios

Description: Additional policy scenarios

Script: Tables_8_I1.do

Data:
 - first_stage.dta
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50.dta	
 - county_elec_price_2007_2012.dta
 - county_elec_price_social_2007_2012.dta

Table I.2: Policy Analysis: Additional Scenarios

Description: Additional policy scenarios

Script: Tables_8_I1.do

Data:
 - first_stage.dta
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50.dta	
 - county_elec_price_2007_2012.dta
 - county_elec_price_social_2007_2012.dta

Figure B.1: Binned Scatter Plot of Purchase Share Above Median Efficiency and Electricity Price

Description: Figure B.1 is a binned scatter plot of the variation displayed in the maps in Figure B.2.

Script: FigureB1+B2.do

Data:
 - gz_2010_us_050_00_500k.dta
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta

Figure B.2: County-Level Maps of Electricity Price and Purchase Share Above Median
Efficiency

Description: Figure B.1 is a binned scatter plot of the variation displayed in the maps in Figure B.2.

Script: FigureB1+B2.do

Data:
 - gz_2010_us_050_00_500k.dta (coordinates for making US maps)
 - lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50_final.dta










