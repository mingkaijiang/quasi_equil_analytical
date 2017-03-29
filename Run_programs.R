
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
######################## General system stuffs #################################
#### Get current date
date<-Sys.Date()

source("R/prepare_R.R")

######################## Prepare GDAY stuffs ###################################
#### Create met data for gday simulations
source("GDAY/pre_processing/create_monthly_met_for_GDAY.R")

#### make gday and send to simulation folders
source("GDAY/pre_processing/Make_GDAY_and_Send_To_Folders.R")

######################## Run GDAY simulations ##################################
#### Run GDAY using the python wrapper file
source("GDAY/pre_processing/Run_GDAY.R")



######################## Run analytical stuffs #################################

### To run analytical solution codes
source("R/Run_analytical_solutions.R")


##################### Generate manuscript figures ################################

#### To generate manuscript figures
source("Plots/Figure_generating.R")



