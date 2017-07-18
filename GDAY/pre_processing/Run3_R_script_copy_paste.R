
#### Copy and paste the R wrapper file into each subdirectory
#### At the same time changing the necessary parameter settings
#### Run 3
#### Copy Run 1 script (base line, variable wood stoichiometry, N and P cycles turned on),
#### and Fix wood stoichiometry
#### 
################################################################################
Run3_copy_paste <- function() {
    
    ### read in spin up file
    spinup <- readLines("GDAY/simulations/Run1/quasi_equil_annual_spin_up.R")
    
    # swap function
    out <- sub( "        \"fixed_stem_nc\", \"false\",", 
                "        \"fixed_stem_nc\", \"true\"," ,
                spinup)
    out <- sub( "        \"fixed_stem_pc\", \"false\",", 
                "        \"fixed_stem_pc\", \"true\"," ,
                out)
    
    # swap parameter locations
    out[32] <- "    param_dir <- paste0(d, \"/params/Run3\")"
    
    # swap run folder locations
    out[33] <- "    run_dir <- paste0(d, \"/outputs/Run3\")" 

    # swap swp_fname locations
    out[44] <- "    swp_fname <- paste0(d, \"/simulations/Run3/replace_params.cfg\")"
    
    # update nwood value to match with analytical
    out[154] <- "        \"ncwnewz\", \"0.0005\",                   # C:N = 2000, match analytical "
    
    # update nwood value to match with analytical
    out[158] <- "        \"pcwnewz\", \"0.000003\",                  # C:P\", \"333333.33 match analytical"
        
    # write
    writeLines(out, "GDAY/simulations/Run3/quasi_equil_annual_spin_up.R")
    
    ### read in simulation file
    tran <- readLines("GDAY/simulations/Run1/quasi_equil_annual_simulations.R")
    
    # swap locations
    tran[30] <- "    param_dir <- paste0(d, \"/params/Run3\")"  
    tran[32] <- "    run_dir <- paste0(d, \"/outputs/Run3\")"
    
    # write
    writeLines(tran, "GDAY/simulations/Run3/quasi_equil_annual_simulations.R")

}

################################################################################
Run3_copy_paste()
