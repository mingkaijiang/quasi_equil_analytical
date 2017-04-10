#### Quasi-equilibrium Simulations

#### Model simulation: using hypothetical annual met forcing data and hypothetical parameters
#### to run sensitivity tests.


#### Author: Mingkai Jiang (m.jiang@westernsydney.edu.au)
#### Date Created: Mar-30-2017
##########################################################################################

############################# Sourcing outside functions #################################

### get the parent directory of the current working directory
d <- dirname(dirname(getwd()))   

### sourcing the adjust_gday_param_file.py code    # Note: need to change to R
script_path <- paste0(d, "/code/scripts")
source(paste0(script_path, "/adjust_gday_param_file.R"))

################################ Main functions #########################################
Run_GDAY_transient <- function(site, treatment) {
    
    #### Setting executive commands
    GDAY_SPIN <- "./gday -s -p"
    GDAY <- "./gday -p"
    
    
    #### setting directory names
    base_dir <- getwd()
    param_dir <- paste0(d, "/params/Run5")
    met_dir <- paste0(d, "/met_data")
    run_dir <- paste0(d, "/outputs/Run5")
    
    
    #### setting up the output file names and locations
    itag <- paste0(site, "_model_transient")
    otag <- paste0(site, "_model_simulation_", treatment)
    mtag = paste0(site, "_met_forcing_transient_", treatment, ".csv")
    out_fn <- paste0(site, "_transient_", toupper(treatment), ".csv")   
    out_param_fname <- paste0(param_dir, "/", otag, ".cfg")
    cfg_fname <- paste0(param_dir, "/", itag, ".cfg")
    met_fname <- paste0(met_dir, "/", mtag)
    out_fname <- paste0(run_dir, "/", out_fn)
    
    #### Copy and paste the initial parameter cfg file
    sys_com1 <- paste0("cp ", param_dir, "/", site, "_model_spunup.cfg ",
                       cfg_fname)
    system(paste(sys_com1))
 
    
    #### set up the replacement list
    replace_dict <- c(
        ############## FILES ############
        "out_param_fname", out_param_fname,
        "cfg_fname", cfg_fname,
        "met_fname", met_fname,
        "out_fname", out_fname,
        ############## CONTROL ############
        "print_options", "annual")
    
    #### make a df out from replacement dictionary
    rDF <- make_df(replace_dict)
    
    #### call function to conduct the parameter replacement
    adjust_gday_params(cfg_fname, rDF)
    
    #### Run the spin up model
    system(paste0(GDAY, " ", cfg_fname))

}


################################ Program #########################################
site = "Quasi_equil"

# Ambient
Run_GDAY_transient(site, treatment="co2_amb")

# Elevated
Run_GDAY_transient(site, treatment="co2_ele")
