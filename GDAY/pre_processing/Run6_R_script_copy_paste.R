
#### Copy and paste the R wrapper file into each subdirectory
#### At the same time changing the necessary parameter settings
#### Run 6
#### Copy Run 1 script (base line, variable wood stoichiometry, N and P cycles turned on),
#### and turn coarse woody debris pool turn
#### 
################################################################################
Run6_copy_paste <- function() {
    
    ### read in spin up file
    spinup <- readLines("GDAY/simulations/Run1/quasi_equil_annual_spin_up.R")
    
    # swap function
    out <- sub( "        \"cwd_pool\", \"false\",", 
                "        \"cwd_pool\", \"true\",",
                spinup)
    
    # swap parameter locations
    out[32] <- "    param_dir <- paste0(d, \"/params/Run6\")"
    
    # swap run folder locations
    out[33] <- "    run_dir <- paste0(d, \"/outputs/Run6\")" 

    # swap swp_fname locations
    out[44] <- "    swp_fname <- paste0(d, \"/simulations/Run6/replace_params.cfg\")"
        
    # write
    writeLines(out, "GDAY/simulations/Run6/quasi_equil_annual_spin_up.R")
    
    ### read in simulation file
    tran <- readLines("GDAY/simulations/Run1/quasi_equil_annual_simulations.R")
    
    # swap locations
    tran[30] <- "    param_dir <- paste0(d, \"/params/Run6\")"  
    tran[32] <- "    run_dir <- paste0(d, \"/outputs/Run6\")"
    
    # write
    writeLines(tran, "GDAY/simulations/Run6/quasi_equil_annual_simulations.R")

}

################################################################################
Run6_copy_paste()
