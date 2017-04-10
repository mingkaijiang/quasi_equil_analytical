
#### Copy and paste the R wrapper file into each subdirectory
#### At the same time changing the necessary parameter settings
#### Run 4
#### Copy Run 1 script (base line, variable wood stoichiometry, N and P cycles turned on),
#### and respiration depends on plant tissue N
#### 
################################################################################
Run4_copy_paste <- function() {
    
    ### read in spin up file
    spinup <- readLines("GDAY/simulations/Run1/quasi_equil_annual_spin_up.R")
    
    # swap function
    out <- sub( "        \"respiration_model\", \"fixed\",", 
                "        \"respiration_model\", \"leafn\",",
                spinup)
    
    # swap parameter locations
    out[32] <- "    param_dir <- paste0(d, \"/params/Run4\")"
    
    # swap run folder locations
    out[33] <- "    run_dir <- paste0(d, \"/outputs/Run4\")" 

    # swap swp_fname locations
    out[44] <- "    swp_fname <- paste0(d, \"/simulations/Run4/replace_params.cfg\")"
        
    # write
    writeLines(out, "GDAY/simulations/Run4/quasi_equil_annual_spin_up.R")
    
    ### read in simulation file
    tran <- readLines("GDAY/simulations/Run1/quasi_equil_annual_simulations.R")
    
    # swap locations
    tran[30] <- "    param_dir <- paste0(d, \"/params/Run4\")"  
    tran[32] <- "    run_dir <- paste0(d, \"/outputs/Run4\")"
    
    # write
    writeLines(tran, "GDAY/simulations/Run4/quasi_equil_annual_simulations.R")

}

################################################################################
Run4_copy_paste()
