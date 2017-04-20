
#### Copy and paste the R wrapper file into each subdirectory
#### At the same time changing the necessary parameter settings
#### Run 7
#### Copy Run 1 script (base line, variable wood stoichiometry, N and P cycles turned on),
#### and turn explicit mineral N and P pools
#### 
################################################################################
Run7_copy_paste <- function() {
    
    ### read in spin up file
    spinup <- readLines("GDAY/simulations/Run1/quasi_equil_annual_spin_up.R")
    
    # swap function
    out <- sub( "        \"nuptake_model\", \"0\",", 
                "        \"nuptake_model\", \"1\",",
                spinup)
    
    #out <- sub( "        \"puptake_model\", \"0\",", 
    #            "        \"puptake_model\", \"1\",",
    #            out)
    
    # swap parameter locations
    out[32] <- "    param_dir <- paste0(d, \"/params/Run7\")"
    
    # swap run folder locations
    out[33] <- "    run_dir <- paste0(d, \"/outputs/Run7\")" 

    # swap swp_fname locations
    out[44] <- "    swp_fname <- paste0(d, \"/simulations/Run7/replace_params.cfg\")"
        
    # write
    writeLines(out, "GDAY/simulations/Run7/quasi_equil_annual_spin_up.R")
    
    ### read in simulation file
    tran <- readLines("GDAY/simulations/Run1/quasi_equil_annual_simulations.R")
    
    # swap locations
    tran[30] <- "    param_dir <- paste0(d, \"/params/Run7\")"  
    tran[32] <- "    run_dir <- paste0(d, \"/outputs/Run7\")"
    
    # write
    writeLines(tran, "GDAY/simulations/Run7/quasi_equil_annual_simulations.R")

}

################################################################################
Run7_copy_paste()
