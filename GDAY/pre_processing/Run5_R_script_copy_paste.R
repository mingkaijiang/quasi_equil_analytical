
#### Copy and paste the R wrapper file into each subdirectory
#### At the same time changing the necessary parameter settings
#### Run 5
#### Copy Run 4 script (respiration ~ plant N),
#### and Fix wood stoichiometry
#### 
################################################################################
Run5_copy_paste <- function() {
    
    ### read in spin up file
    spinup <- readLines("GDAY/simulations/Run4/quasi_equil_annual_spin_up.R")
    
    # swap function
    out <- sub( "        \"fixed_stem_nc\", \"false\",", 
                "        \"fixed_stem_nc\", \"true\"," ,
                spinup)
    out <- sub( "        \"fixed_stem_pc\", \"false\",", 
                "        \"fixed_stem_pc\", \"true\"," ,
                out)
    
    # swap parameter locations
    out[32] <- "    param_dir <- paste0(d, \"/params/Run5\")"
    
    # swap run folder locations
    out[33] <- "    run_dir <- paste0(d, \"/outputs/Run5\")" 

    # swap swp_fname locations
    out[44] <- "    swp_fname <- paste0(d, \"/simulations/Run5/replace_params.cfg\")"
        
    # write
    writeLines(out, "GDAY/simulations/Run5/quasi_equil_annual_spin_up.R")
    
    ### read in simulation file
    tran <- readLines("GDAY/simulations/Run4/quasi_equil_annual_simulations.R")
    
    # swap locations
    tran[30] <- "    param_dir <- paste0(d, \"/params/Run5\")"  
    tran[32] <- "    run_dir <- paste0(d, \"/outputs/Run5\")"
    
    # write
    writeLines(tran, "GDAY/simulations/Run5/quasi_equil_annual_simulations.R")

}

################################################################################
Run5_copy_paste()
