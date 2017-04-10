
#### Copy and paste the R wrapper file into each subdirectory
#### At the same time changing the necessary parameter settings
#### Run 2
#### Copy Run 1 script (base line, variable wood stoichiometry, N and P cycles turned on),
#### and Turn P cycle off
#### 
################################################################################
Run2_copy_paste <- function() {
    
    ### read in spin up file
    spinup <- readLines("GDAY/simulations/Run1/quasi_equil_annual_spin_up.R")
    
    # swap function
    out <- sub( "        \"pcycle\", \"true\",", 
                "        \"pcycle\", \"false\",",
                spinup)
    
    # swap parameter locations
    out[32] <- "    param_dir <- paste0(d, \"/params/Run2\")"
    
    # swap run folder locations
    out[33] <- "    run_dir <- paste0(d, \"/outputs/Run2\")" 

    # swap swp_fname locations
    out[44] <- "    swp_fname <- paste0(d, \"/simulations/Run2/replace_params.cfg\")"
        
    # write
    writeLines(out, "GDAY/simulations/Run2/quasi_equil_annual_spin_up.R")
    
    ### read in simulation file
    tran <- readLines("GDAY/simulations/Run1/quasi_equil_annual_simulations.R")
    
    # swap locations
    tran[30] <- "    param_dir <- paste0(d, \"/params/Run2\")"  
    tran[32] <- "    run_dir <- paste0(d, \"/outputs/Run2\")"
    
    # write
    writeLines(tran, "GDAY/simulations/Run2/quasi_equil_annual_simulations.R")

}

################################################################################
Run2_copy_paste()
