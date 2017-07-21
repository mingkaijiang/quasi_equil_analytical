#### Quasi-equilibrium Simulations

#### Model spin-up: using hypothetical annual met forcing data and hypothetical parameters
####  to get quasi-equilibrium state.

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

Run_GDAY_spinup <- function(site) {
    
    #### Setting executive commands
    GDAY_SPIN <- "./gday -s -p"
    GDAY <- "./gday -p"
    
    #### setting directory names
    base_dir <- getwd()
    base_param_name <- "base_start_with_P.cfg"
    base_param_dir <- paste0(d, "/code/example/params")
    param_dir <- paste0(d, "/params/Run8_1")
    run_dir <- paste0(d, "/outputs/Run8_1")

    #### setting up the output file names and locations
    itag <- paste0(site, "_model_spinup")
    otag <- paste0(site, "_model_spunup")
    # mtag = paste0(site, "_met_forcing_transient_co2_amb.csv")
    out_fn <- paste0(itag, "_equilib.csv")
    out_param_fname <- paste0(param_dir, "/", otag, ".cfg")
    cfg_fname <- paste0(param_dir, "/", itag, ".cfg")
    # met_fname <- paste0(met_dir, mtag)
    out_fname <- paste0(run_dir, "/", out_fn)
    swp_fname <- paste0(d, "/simulations/Run8_1/replace_params.cfg")
    
    #### Copy and paste the initial parameter cfg file
    sys_com1 <- paste0("cp ", base_param_dir, "/", base_param_name, " ",
                       cfg_fname)
    system(paste(sys_com1))
    
    
    #### set up the replacement list
    replace_dict <- c(
        ############## FILES ############
        "out_param_fname", out_param_fname,
        "cfg_fname", cfg_fname,
        # "met_fname", met_fname,
        "out_fname", out_fname,
        ############## STATE ############
        "shoot", "0.02",              # assuming total 10 g plant, 2 in leaf 
        "shootn", "0.0008",              # 0.0008 C:N = 25 
        "shootp", "0.00003",             # 0.00003 C:P = 680 
        "stem", "0.06",             # assuming total 10 g plant, 6 in stem
        "stemn", "0.0003",               # 0.0003 C:N = 200 
        "stemp", "0.000018",            # 0.000018 C:P = 3333.33
        "root", "0.02",                # assuming total 10 g plant, 2 in root
        "rootn", "0.00056",              # 0.00056 Root CN = leaf * 0.7 
        "rootp", "0.000021",             # 0.000021 Root CP = leaf * 0.7
        "activesoil", "0.0",    
        "activesoiln", "0.0",      # C:N = 15
        "activesoilp", "0.0",      # C:P = 800
        "slowsoil", "0.0",          # guess
        "slowsoiln", "0.0",           # C:N = 20
        "slowsoilp", "0.0",          # C:P = 2000
        "passivesoil", "0.0",       # analytical
        "passivesoiln", "0.0",       # C:N = 10
        "passivesoilp", "0.0",        # C:P = 200
        "metabsoil", "0.0",          #
        "metabsoiln", "0.0",        # C:N = 10 <-> 25
        "metabsoilp", "0.0",       # C:P = 80 <-> 150
        "metabsurf", "0.0",          #
        "metabsurfn", "0.0",          # C:N = 10 <-> 25
        "metabsurfp", "0.0",          # C:P = 80 <-> 150
        "structsoil", "0.0",          # 
        "structsoiln", "0.0",       # C:N = 150 
        "structsoilp", "0.0",      # C:P = 500
        "structsurf", "0.0",         # 
        "structsurfn", "0.0",         # C:N = 150
        "structsurfp", "0.0",       # C:P = 500
        "inorgn", "1.0",           # annual input = 0.01 t/ha
        "inorgavlp", "0.04",       # annual input = 0.0004 t/ha 
        "inorgssorbp", "0.0",    # 
        "inorgoccp", "0.0",        # 
        "inorgparp", "0.04",      # annual input = 0.0004 t/ha, monthly rate 
        "canht", "30.0",              # 
        "sapwood", "0.0",         # initialize value, needed it for initialize alloc_stuffs
        "lai", "0.1",
        ############## PARAMETERS ############
        "co2_in", "350.0",                    # spin-up value
        "I0", "1440.0",                       # spin-up value, annual rate, unit MJ/m2/yr
        "ndep_in", "0.002",                   # spin-up value, annual rate, unit t/ha/yr
        "nfix_in", "0.002",                   # spin-up value, annual rate, unit t/ha/yr 
        "pdep_in", "0.0002",                  # spin-up value, annual rate, unit t/ha/yr
        "tsoil_in", "15.0",                   # spin-up value
        "k1", "0.01",                         # rate from inorgavlp to inorgssorbp, adjustable    
        "k2", "0.01",                         # rate from inorgssorbp to inorgavlp, adjustable
        "k3", "0.05",                         # rate from inorgssorbp to inorgoccp, adjustable
        "finesoil", "0.5",                    # match against analytical
        "sla", "5.0",                         # match against analytical
        "cfracts", "0.45",                    # match against analytical
        "c_alloc_fmax", "0.2",                   # allocation to leaf, fixed
        "c_alloc_fmin", "0.2",                   # allocation to leaf, fixed
        "c_alloc_rmax", "0.2",                   # allocation to root, fixed
        "c_alloc_rmin", "0.2",                   # allocation to root, fixed
        "fdecay", "0.5",                      # /yr
        "rdecay", "1.5",                      # /yr
        "wdecay", "0.01",                     # /yr
        "sapturnover", "0.1",                 # /yr
        "fretransn", "0.5",                   # match against analytical
        "fretransp", "0.6",                   # match against analytical
        "rretrans", "0.0",                    #
        "wretrans", "0.0",                    # 
        "structcn", "200.0",                  # Commins and MCM uses 150
        "structcp", "3333.33",                  # Literature suggests 500:62500
        "metabcnmax", "25.0",                 # 
        "metabcnmin", "10.0",                 # 
        "metabcpmax", "150.0",                # 
        "metabcpmin", "80.0",                 #
        "ligshoot", "0.2",                    # match against analytical
        "ligroot", "0.16",                    # match against analytical
        "height0", "5.0",
        "height1", "30.0",
        "heighto", "4.826",
        "htpower", "0.35",
        "density", "420.0",
        "leafsap0", "8000.0",
        "leafsap1", "3060.0",
        "targ_sens", "0.5",
        "actncmax", "0.066667",               # C:N = 15 
        "actncmin", "0.066667",               # C:N = 15
        "actpcmax", "0.00125",                # C:P = 800
        "actpcmin", "0.00125",                # C:P = 800
        "slowncmax", "0.05",                  # C:N = 20
        "slowncmin", "0.05",                  # C:N = 20
        "slowpcmin", "0.0005",                # C:P = 2000
        "slowpcmax", "0.0005",                # C:P = 2000
        "passncmax", "0.1",                   # C:N = 10
        "passncmin", "0.1",                   # C:N = 10
        "passpcmin", "0.005",                 # C:P = 200
        "passpcmax", "0.005",                 # C:P = 200
        "lue0", "2.8",                        # 2.8 for GPP, 1.4 for NPP
        "cue", "0.5",                         # 
        "ncmaxf", "0.05",                     # 0.05
        "ncwnewz", "0.005",                   # C:N = 200, match analytical 
        "ncrfac", "0.7",                      # match against analytical
        "nref", "0.04",                       # N saturation threshold for photosynthesis
        "pcmaxf", "0.005",                    # 
        "pcwnewz", "0.00003",                  # C:P", "33333.33 match analytical
        "pcrfac", "0.7",                      # match against analytical
        "rateuptake", "1.0",              # 0.96884 
        "rateloss", "0.05",                   # match against analytical
        "prateuptake", "1.0",                 # 0.82395
        "prateloss", "0.05",                  # match against analytical
        "p_rate_par_weather", "1.0",          # Assumes all p_atm_dep into parent pool transfers into inorgavlp
        "nuptakez", "0.01",                   #
        "puptakez", "0.0004",                 # 
        "passivesoilz", "26.8",               # 26.8 match against analytical
        "passivesoilnz", "2.68",              # 2.68 match against analytical
        "passivesoilpz", "0.134",             # 0.134 match against analytical
        "num_years", "1",                     # no need to change 
        "kr", "3.0",                          # 0.5 t/ha in Dewar and McMurtrie 1996; the value of root carbon at which 50% of available N is taken up
        "krp", "3.0",                         # 0.00001; can set krp equals kr for consistency
        "a0rhizo", "0.05",
        "a1rhizo", "0.6",
        "root_exu_CUE", "0.3",
        "prime_y", "0.0025",
        "prime_z", "2.0",
        "nmin0", "0.0",                       # for variable som NC depend on inorgN
        "nmincrit", "2.0",                    # for variable som NC depend on inorgN 
        "pmin0", "0.0",                       # for variable som PC depend on inorgavlp
        "pmincrit", "2.0",                    # for variable som PC depend on inorgavlp 
        ############## CONTROL ############
        "adjust_rtslow", "false",             # goes together with exudation
        "alloc_model", "fixed",               # fixed and variable allocation pattern
        "cwd_pool", "false",  
        "diagnosis", "false",
        "exudation", "false",
        "fixed_stem_nc", "false",
        "fixed_stem_pc", "false",
        "fixleafnc", "false",
        "fixleafpc", "false",
        "ncycle", "true",
        "pcycle", "true",
        "nuptake_model", "2",
        "puptake_model", "2",
        "print_options", "end",                # during spin up, set to end
        "passiveconst", "false",
        "respiration_model", "fixed",
        "som_nc_calc", "fixed",
        "som_pc_calc", "fixed")
    
    #### make a df out from replacement dictionary
    rDF <- make_df(replace_dict)
    
    #### call function to conduct the parameter replacement
    #adjust_param_file(cfg_fname, out_param_fname, replace_dict)
    adjust_gday_params(cfg_fname, rDF)

    #### Run the spin up model
    system(paste0(GDAY_SPIN, " ", cfg_fname), ignore.stderr=T)
    
    #### Call external function to transform the raw GDAY output into something more readable, NOT NEEDED
    #source(paste0(script_path, "/translate_GDAY_output_to_NCEAS_format.R"))
    #translate_output(out_fname,run_dir)
    
        
}


################################ Program #########################################
site = "Quasi_equil"
Run_GDAY_spinup(site)
