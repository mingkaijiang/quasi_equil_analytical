
#### Main program
####
#### Level 1 code: to run the analytical solution code and the manuscript figure generating codes
####
#### Author: Mingkai Jiang (m.jiang@westernsydney.edu.au)
#### 
####
################################################################################

#### Prepare GDAY stuffs

### Create met data for gday simulations
#source("R/create_monthly_met_for_GDAY.R")


### To run analytical solution codes
source("R/Run_analytical_solutions.R")



#### To generate manuscript figures
source("Plots/Figure_generating.R")