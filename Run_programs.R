
#### Main program
####
#### Level 1 code: 
#### 1. To prepare GDAY runs
#### 2. To run the analytical solution code together with the GDAY program
#### 3. To generate manuscript figures
####

####
####
#### Author: Mingkai Jiang (m.jiang@westernsydney.edu.au)
#### 
####
######################## General system stuffs #################################
#### Get current date
date<-Sys.Date()


######################## Prepare GDAY stuffs ###################################
#### Create met data for gday simulations
source("GDAY/pre_processing/create_monthly_met_for_GDAY.R")

#### make gday and send to simulation folders
source("GDAY/pre_processing/Make_GDAY_and_Send_To_Folders.R")


#### Here need a script to modify the python scripts parameters for each simulations







######################## Run GDAY simulations ##################################
#### Run GDAY using the python wrapper file
source("GDAY/pre_processing/Run_GDAY.R")


################# Post-processing GDAY simulations #############################
#### Convert from monthly to annual data and save to analyses subfolders
source("GDAY/post_processing/Convert_GDAY_monthly_to_annual.R")

#### Mass balance QC check for each simulations
#### Plotting first 100 years and last 100 years
#### Only for spin-up files
source("GDAY/post_processing/mass_balance.R")


######################## Run analytical stuffs #################################

### To run analytical solution codes
source("R/Run_analytical_solutions.R")


##################### Generate manuscript figures ################################

#### To generate manuscript figures
source("Plots/Figure_generating.R")







