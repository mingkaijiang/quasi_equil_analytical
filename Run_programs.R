
#### Main program
###
### Summary:
### 1. To prepare GDAY met forcing data and parameter files
### 2. To run GDAY and output each simulations into the corresponding folders
### 3. To quality check GDAY simulation results and post-processing them
### 4. To generate analytical solutions for each gday simulation
### 5. To prepare manuscript figures and tables 
###
### Author: Mingkai Jiang (m.jiang@westernsydney.edu.au)
### 
#### Warning: needs at least 8 GB disk space because the simulation creates many large files
#### ------------------------ General system stuffs ------------------------ #####
### Make sure everything is clear
rm(list=ls(all=TRUE))

### Get current date
date<-Sys.Date()

### read in all R packages
source("R/prepare_R.R")


#### ------------------------ Prepare GDAY stuffs ------------------------ #####
#### Create met data for gday simulations
source("GDAY/pre_processing/create_monthly_met_for_GDAY.R")

#### compile gday program and send to simulation folders
source("GDAY/pre_processing/Make_GDAY_and_Send_To_Folders.R")

#### Here need a script to modify the R scripts parameters for each simulations
#source("GDAY/pre_processing/Paste_R_script_to_folders.R")



#### ------------------------ Run GDAY simulations ------------------------ #####
### Run GDAY simulations, using either the python or R wrapper file
### Current setting use R, but is quite slow
source("GDAY/pre_processing/Run_GDAY.R")


#### ------------------------ Post-processing GDAY simulations ------------------------ #####
### Convert from monthly to annual data and save to analyses subfolders
### This step is the only "must-run" step for post-processing purpose
source("GDAY/post_processing/Convert_GDAY_monthly_to_annual.R")


### Consider add a script to delete all the raw GDAY simulation outputs as they are LARGE!!!


### Mass balance QC check for each simulations
### Plotting first 100 years and last 100 years
### Only for spin-up files
### WARNING: TAKES VERY LONG TO RUN!!!!!!!!!!!
# source("GDAY/post_processing/mass_balance.R")

### Plot time series spin up files for each simulations
source("GDAY/post_processing/Transient_spin_up_plot.R")

### Check spin-up and transient continuity
### co2_amb and co2_ele only pools, starting from last 10 years of equilibration
source("GDAY/post_processing/Check_continuity.R")

### plot continuity starting from transient year 1 and specify endyear for pools and flxues
### Only for elevated CO2 runs
source("GDAY/post_processing/Check_continuity_transient.R")

### plot gday simulated quasi-equil points under aCO2 and eCO2
### Note: need to specify years when L and VL equilibrates
###       better to consider an automatic process to pick these years
source("GDAY/post_processing/Plot_GDAY_quasi_equil_constraints.R")

#### ------------------------ Run analytical stuffs ------------------------ #####
### To run analytical solution codes for each gday simulations
source("R/Run_analytical_solutions.R")
### Need to store all the dataframe and outputs separately

#### ------------------------ Checking GDAY matches with analytical results ------------------------ #####
###







#### ------------------------ Perform the necessary plottings and statistics ------------------------ #####
### Need to be run specific, e.g. Run 4 - respiration as a function of tissue N, needs gday CUE and analytical CUE

### Run 4 CUE output, save into a table
source("R/CUE_check.R")




#### ------------------------ Generate manuscript figures and tables ------------------------ #####

### To generate manuscript figures
source("Plots/Figure_generating.R")

### To generate manuscript tables (or statistics used for generating the tables)
source("Tables/Table_generating.R")
