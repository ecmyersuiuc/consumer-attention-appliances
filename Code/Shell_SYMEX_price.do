#do "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Shell_symex_price.do"

local set_seed   `"`1'"'
local init_rep   `"`2'"'
local nb_rep     `"`3'"'
local a_var      `"`4'"'


do "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Table_symex.do" 100 1 15 0.001
do "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Table_symex.do" 100 1 15 0.01
do "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Table_symex.do" 100 1 15 0.05
do "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Table_symex.do" 100 1 15 0.1
do "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Table_symex.do" 100 1 15 0.15
do "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Table_symex.do" 100 1 15 0.2
do "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Table_symex.do" 100 1 15 0.25
do "C:\Users\ecmyers\Dropbox\Appliance_EnergyPrice\Replication_JPubE_RR\Table_symex.do" 100 1 15 0.3
