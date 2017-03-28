
#### Main program
####
#### Level 1 code: 
#### 1. To prepare GDAY runs
#### 2. To run the analytical solution code together with the GDAY program
#### 3. To generate manuscript figures
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