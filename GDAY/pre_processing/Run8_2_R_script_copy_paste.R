
#### Copy and paste the R wrapper file into each subdirectory
#### At the same time changing the necessary parameter settings
#### Run 8_2
#### Copy Run 1 script (base line, variable wood stoichiometry, N and P cycles turned on),
#### and turn explicit mineral N on, and nuptake is a function of root biomass
#### O-CN approach
################################################################################
Run8_2_copy_paste <- function() {
    
    ### read in spin up file
    spinup <- readLines("GDAY/simulations/Run1/quasi_equil_annual_spin_up.R")
    
    # swap function
    out <- sub( "        \"nuptake_model\", \"0\",", 
                "        \"nuptake_model\", \"3\",",
                spinup)
    
    
    # swap parameter locations
    out[32] <- "    param_dir <- paste0(d, \"/params/Run8_2\")"
    
    # swap run folder locations
    out[33] <- "    run_dir <- paste0(d, \"/outputs/Run8_2\")" 

    # swap swp_fname locations
    out[44] <- "    swp_fname <- paste0(d, \"/simulations/Run8_2/replace_params.cfg\")"
    
    # turn P cycle off
    out[193] <-  "        \"pcycle\", \"false\"," 
    
    # P uptake mode
    out[195] <- "        \"puptake_model\", \"3\","
        
    # write
    writeLines(out, "GDAY/simulations/Run8_2/quasi_equil_annual_spin_up.R")
    
    ### read in simulation file
    tran <- readLines("GDAY/simulations/Run1/quasi_equil_annual_simulations.R")
    
    # swap locations
    tran[30] <- "    param_dir <- paste0(d, \"/params/Run8_2\")"  
    tran[32] <- "    run_dir <- paste0(d, \"/outputs/Run8_2\")"
    
    # write
    writeLines(tran, "GDAY/simulations/Run8_2/quasi_equil_annual_simulations.R")

}

################################################################################
Run8_2_copy_paste()
