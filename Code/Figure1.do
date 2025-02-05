//do /Users/shoude/Dropbox/eegap/Replication_JPube_RR/Figure1.do

clear all
set more off
set mem 10000m
pause on

//Sebastien's server
global  datapath = "[Put your path to the replication folder here]/Replication_JPubE_RR/Data"
global  resultspath  = "[Put your path to the replication folder here]/Replication_JPubE_RR/Results"


use "$datapath/lcidemo_046_2008_2012_Dhd_complete_sample_reg_eegap_ready_seed_1_sample_50", clear


gen estarxeleccost_county = estar*eleccost_county
gen log_sales = ln(sales+1)
egen brand_group = group(brand)
egen brand_id_group = group(brand_id)


gen brand_id_sht=""
replace brand_id_sht="A" if  brand_id=="Kenmore_High" | brand_id=="Kenmore_Low"
replace brand_id_sht="B" if  brand_id=="Whirlpool_High" | brand_id=="Whirlpool_Low"
replace brand_id_sht="C" if  brand_id=="Frigidaire_High" | brand_id=="Frigidaire_Low"
replace brand_id_sht="D" if  brand_id=="GE_High" | brand_id=="GE_Low"
replace brand_id_sht="E" if  brand_id=="Others_High" | brand_id=="Others_Low"


preserve
	collapse(sum) sales, by(pid_id brand_id_sht)
	rename sales tot_sales
	gsort brand_id_sht -tot_sales
	bys brand_id_sht: egen rank_brand_id=seq()
	sort pid_id
save "$datapath/pid_id_complete_sample_reg_eegap_ready_seed_1_sample_50", replace
restore

sort pid_id
merge pid_id using "$datapath/pid_id_complete_sample_reg_eegap_ready_seed_1_sample_50"
tab _m
drop _m

//Regressions of Table 2 to obtain residuals:

gen lg_promo_f = ln(promo_f)
eststo t_var_1: reghdfe lg_promo_f, absorb(pid_id) residuals(res_pid_only)
bys pid_id: egen sd_res_pid_only  = sd(res_pid_only)
bys pid_id: egen min_res_pid_only = min(res_pid_only)
bys pid_id: egen max_res_pid_only = sd(res_pid_only)

eststo t_var_3: reghdfe lg_promo_f, absorb(pid_id brand_week_num) residuals(res_pid_brandweek)
bys pid_id: egen sd_res_pid_brandweek  = sd(res_pid_brandweek)
bys pid_id: egen min_res_pid_brandweek = min(res_pid_brandweek)
bys pid_id: egen max_res_pid_brandweek = sd(res_pid_brandweek)

sort pid_id week_num
by pid_id week_num: egen promo_n_50 = median(res_pid_only)
by pid_id week_num: egen promo_n_25 = pctile(res_pid_only), p(25)
by pid_id week_num: egen promo_n_75 = pctile(res_pid_only), p(75)
by pid_id week_num: egen promo_n_weekFE_50 = median(res_pid_brandweek)

gen week_str=yw(year, week)
format week_str %tw

//Figure for the main text
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==1 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==1 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==1 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank1_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 1",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==2 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==2 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==2 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank2_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 2",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==1 & brand_id_sht=="B",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==1 & brand_id_sht=="B",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==1 & brand_id_sht=="B",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank1_tmpB_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand B: Sales Rank 1",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==2 & brand_id_sht=="B",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==2 & brand_id_sht=="B",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==2 & brand_id_sht=="B",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank2_tmpB_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand B: Sales Rank 2",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)

		
	graph combine rank1_tmpA_weekFE.gph rank2_tmpA_weekFE.gph rank1_tmpB_weekFE.gph rank2_tmpB_weekFE.gph , graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none))    xsize(7)
cd 	$resultspath	
	graph export "Plot_Promo_n_weekFE_2008-2012_A_B_SalesRank_1_2.eps", as(eps) preview(on) replace
	graph export "Plot_Promo_n_weekFE_2008-2012_A_B_SalesRank_1_2.pdf", as(pdf) replace	
    graph export "Plot_Promo_n_weekFE_2008-2012_A_B_SalesRank_1_2.png", as(png) replace	

//Figures for the appendix
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==1 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==1 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==1 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank1_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 1",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==2 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==2 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==2 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank2_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 2",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==1 & brand_id_sht=="B",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==1 & brand_id_sht=="B",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==1 & brand_id_sht=="B",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank1_tmpB_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand B: Sales Rank 1",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==2 & brand_id_sht=="B",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==2 & brand_id_sht=="B",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==2 & brand_id_sht=="B",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank2_tmpB_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand B: Sales Rank 2",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==1 & brand_id_sht=="C",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==1 & brand_id_sht=="C",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==1 & brand_id_sht=="C",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank1_tmpC_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand C: Sales Rank 1",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==2 & brand_id_sht=="C",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==2 & brand_id_sht=="C",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==2 & brand_id_sht=="C",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank2_tmpC_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand C: Sales Rank 2",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==1 & brand_id_sht=="D",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==1 & brand_id_sht=="D",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==1 & brand_id_sht=="D",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank1_tmpD_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand D: Sales Rank 1",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==2 & brand_id_sht=="D",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==2 & brand_id_sht=="D",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==2 & brand_id_sht=="D",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank2_tmpD_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand D: Sales Rank 2",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==1 & brand_id_sht=="E",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==1 & brand_id_sht=="E",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==1 & brand_id_sht=="E",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank1_tmpE_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand E: Sales Rank 1",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==2 & brand_id_sht=="E",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==2 & brand_id_sht=="E",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==2 & brand_id_sht=="E",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank2_tmpE_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand E: Sales Rank 2",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)

		
	graph combine rank1_tmpA_weekFE.gph rank2_tmpA_weekFE.gph rank1_tmpB_weekFE.gph rank2_tmpB_weekFE.gph rank1_tmpC_weekFE.gph rank2_tmpC_weekFE.gph rank1_tmpD_weekFE.gph rank2_tmpD_weekFE.gph rank1_tmpE_weekFE.gph rank2_tmpE_weekFE.gph, graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none))    xsize(7)
cd 	$resultspath	
	graph export "Plot_Promo_n_weekFE_2008-2012_A_B_C_D_E_SalesRank_1_2.eps", as(eps) preview(on) replace
	graph export "Plot_Promo_n_weekFE_2008-2012_A_B_C_D_E_SalesRank_1_2.pdf", as(pdf) replace	
    graph export "Plot_Promo_n_weekFE_2008-2012_A_B_C_D_E_SalesRank_1_2.png", as(png) replace	

//Figure for the main text
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==1 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==1 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==1 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank1_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 1",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==2 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==2 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==2 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank2_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 2",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==3 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==3 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==3 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank3_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 3",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==4 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==4 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==4 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank4_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 4",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==5 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==5 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==5 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank5_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 5",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==6 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==6 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==6 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank6_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 6",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==7 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==7 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==7 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank7_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 7",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==8 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==8 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==8 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank8_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 8",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==9 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==9 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==9 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank9_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 9",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
  twoway (rarea promo_n_25 promo_n_75 week_str if rank_brand_id==10 & brand_id_sht=="A",sort color(gs8)) (line promo_n_50 week_str if rank_brand_id==10 & brand_id_sht=="A",lcolor(red) lwidth(medthick)) (line promo_n_weekFE_50 week_str if rank_brand_id==10 & brand_id_sht=="A",lcolor(navy) lpattern(dash) lwidth(medthick)), saving(rank10_tmpA_weekFE, replace) graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none)) title("Brand A: Sales Rank 10",color(black) size(medium)) ytitle("Normalized Price ($)") ylabel(,grid) xtitle("Weeks") legend(off)  xlabel(#4)
    
		
	graph combine rank1_tmpA_weekFE.gph rank2_tmpA_weekFE.gph rank3_tmpA_weekFE.gph rank4_tmpA_weekFE.gph rank5_tmpA_weekFE.gph rank6_tmpA_weekFE.gph rank7_tmpA_weekFE.gph rank8_tmpA_weekFE.gph rank9_tmpA_weekFE.gph rank10_tmpA_weekFE.gph , graphregion(color(white) fcolor(white) ifcolor(none) lcolor(none))    xsize(7)
cd 	$resultspath	
	graph export "Plot_Promo_n_weekFE_2008-2012_A_SalesRank_1_10.eps", as(eps) preview(on) replace
	graph export "Plot_Promo_n_weekFE_2008-2012_A_SalesRank_1_10.pdf", as(pdf) replace	
    graph export "Plot_Promo_n_weekFE_2008-2012_A_SalesRank_1_10.png", as(png) replace	





