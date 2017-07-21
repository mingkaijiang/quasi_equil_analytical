
#### Copy and paste the R wrapper file into each subdirectory
#### At the same time changing the necessary parameter settings
#### Run 9
#### Copy Run 1 script (base line, variable wood stoichiometry, N and P cycles turned on),
#### and turn exudation on (not yet to turn on change slow pool residence time)
#### 
################################################################################
Run9_copy_paste <- function() {
    
    ### read in spin up file
    spinup <- readLines("GDAY/simulations/Run1/quasi_equil_annual_spin_up.R")
    
    # swap function
    out <- sub("        \"exudation\", \"false\",",
               "        \"exudation\", \"true\","   ,
                spinup)
    
    #out[183] <-  "        \"adjust_rtslow\", \"true\",             # goes together with exudation" 
    
    # swap parameter locations
    out[32] <- "    param_dir <- paste0(d, \"/params/Run9\")"
    
    # swap run folder locations
    out[33] <- "    run_dir <- paste0(d, \"/outputs/Run9\")" 

    # swap swp_fname locations
    out[44] <- "    swp_fname <- paste0(d, \"/simulations/Run9/replace_params.cfg\")"
        
    # write
    writeLines(out, "GDAY/simulations/Run9/quasi_equil_annual_spin_up.R")
    
    ### read in simulation file
    tran <- readLines("GDAY/simulations/Run1/quasi_equil_annual_simulations.R")
    
    # swap locations
    tran[30] <- "    param_dir <- paste0(d, \"/params/Run9\")"  
    tran[32] <- "    run_dir <- paste0(d, \"/outputs/Run9\")"
    
    # write
    writeLines(tran, "GDAY/simulations/Run9/quasi_equil_annual_simulations.R")

}

################################################################################
Run9_copy_paste()
