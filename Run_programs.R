
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

source("R/prepare_R.R")
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
#### WARNING: TAKES VERY LONG TO RUN!!!!!!!!!!!
#source("GDAY/post_processing/mass_balance.R")

#### Plot time series spin up files for each simulations
source("GDAY/post_processing/Transient_spin_up_plot.R")

#### Check spin-up and transient continuity
#### co2_amb and co2_ele only pools, starting from last 10 years of equilibration
source("GDAY/post_processing/Check_continuity.R")

#### plot continuity starting from transient year 1 and specify endyear for pools and flxues
#### Only for elevated CO2 runs
source("GDAY/post_processing/Check_continuity_transient.R")

#### plot gday simulated quasi-equil points under aCO2 and eCO2
#### Note: need to specify years when L and VL equilibrates
####       better to consider an automatic process to pick these years
source("GDAY/post_processing/Plot_GDAY_quasi_equil_constraints.R")


######################## Run analytical stuffs #################################

### To run analytical solution codes
source("R/Run_analytical_solutions.R")


############ Checking GDAY matches with analytical results #####################
####



################# Generate manuscript figures and tables #######################

#### To generate manuscript figures
source("Plots/Figure_generating.R")

#### To generate manuscript tables (or statistics used for generating the tables)
source("Tables/Table_generating.R")
