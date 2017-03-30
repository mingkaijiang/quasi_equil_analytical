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
script_path <- paste(d, "/code/scripts", sep="")
adjust_gday_param_file <- source(paste(script_path, "/adjust_gday_params_file.py", sep=""))

################################ Main functions #########################################

Run_GDAY_spinup <- function(site, SPIN_UP = TRUE) {
    
    #### Setting executive commands
    GDAY_SPIN <- "./gday -s -p"
    GDAY <- "./gday -p"
    
    #### setting directory names
    base_dir <- getwd()
    base_param_name <- "base_start_with_P.cfg"
    base_param_dir <- paste(d, "/code/example/params",sep="")
    param_dir <- paste(d, "/params/Run1", sep="")
    run_dir <- paste(d, "/outputs/Run1", sep="")
    
    if (SPIN_UP == TRUE) {
        #### Copy and paste the initial parameter cfg file
        sys_com1 <- paste("cp ", base_param_dir, "/", base_param_name, " ",
                          param_dir, "/", site, "_model_spinup.cfg",
                          sep="")
        system(paste(sys_com1))
        
        #### setting up the output file names and locations
        itag <- paste(site, "_model_spinup", sep="")
        otag <- paste(site, "_model_spunup", sep="")
        # mtag = paste(site, "_met_forcing_transient_co2_amb.csv", sep="")
        out_fn <- paste(itag, "_equilib.csv", sep="")
        out_param_fname <- paste(param_dir, "/", otag, ".cfg", sep="")
        cfg_fname <- paste(param_dir, "/", itag, ".cfg", sep="")
        # met_fname <- paste(met_dir, mtag, sep="")
        out_fname <- paste(run_dir, "/", out_fn, sep="")
        
        #### set up the replacement list
        replace_dict <- c(
            ############## FILES ############
            "out_param_fname", out_param_fname,
            "cfg_fname", cfg_fname,
            # "met_fname", met_fname,
            "out_fname", out_fname,
            ############## STATE ############
            "shoot", "11.0",              # assuming total 10 g plant, 2 in leaf 
            "shootn", "0.3",              # 0.0008 C:N = 25 
            "shootp", "0.01",             # 0.00003 C:P = 680 
            "stem", "1700.0",             # assuming total 10 g plant, 6 in stem
            "stemn", "0.2",               # 0.0003 C:N = 200 
            "stemp", "0.0005",            # 0.000018 C:P = 3333.33
            "root", "3.0",                # assuming total 10 g plant, 2 in root
            "rootn", "0.07",              # 0.00056 Root CN = leaf * 0.7 
            "rootp", "0.002",             # 0.000021 Root CP = leaf * 0.7
            "activesoil", "11.0",         # guess
            "activesoiln", "0.7",         # C:N = 15
            "activesoilp", "0.01",        # C:P = 800
            "slowsoil", "170.0",          # guess
            "slowsoiln", "8.0",           # C:N = 20
            "slowsoilp", "0.08",          # C:P = 2000
            "passivesoil", "180.0",       # analytical
            "passivesoiln", "18.0",       # C:N = 10
            "passivesoilp", "0.9",        # C:P = 200
            "metabsoil", "0.00",          #
            "metabsoiln", "0.0",          # C:N = 10 <-> 25
            "metabsoilp", "0.0",          # C:P = 80 <-> 150
            "metabsurf", "0.00",          #
            "metabsurfn", "0.0",          # C:N = 10 <-> 25
            "metabsurfp", "0.0",          # C:P = 80 <-> 150
            "structsoil", "0.00",         # 
            "structsoiln", "0.00000",     # C:N = 150 
            "structsoilp", "0.000000",    # C:P = 500
            "structsurf", "0.00",         # 
            "structsurfn", "0.00000",     # C:N = 150
            "structsurfp", "0.000000",    # C:P = 500
            "inorgn", "0.016",            # annual input = 0.01 t/ha, monthly rate 
            "inorgavlp", "0.0005",        # annual input = 0.0004 t/ha, monthly rate 
            "inorgssorbp", "0.00009",     # 
            "inorgoccp", "1.2",           # 
            "inorgparp", "0.00003",       # annual input = 0.0004 t/ha, monthly rate 
            "canht", "30.0",              # 
            "sapwood", "0.01",            # initialize value, needed it for initialize alloc_stuffs
             ############## STATE ############
            "co2_in", "350.0",                    # spin-up value
            "I0", "3000.0",                       # spin-up value, annual rate, unit MJ/m2/yr
            "ndep_in", "0.005",                   # spin-up value, annual rate, unit t/ha/yr
            "nfix_in", "0.005",                   # spin-up value, annual rate, unit t/ha/yr 
            "pdep_in", "0.0004",                  # spin-up value, annual rate, unit t/ha/yr
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
            "pcwnewz", "0.0003",                  # C:P = 3333.33 match analytical
            "pcrfac", "0.7",                      # match against analytical
            "rateuptake", "0.96884",              # 0.96884 
            "rateloss", "0.05",                   # match against analytical
            "prateuptake", "1.9",                 # 0.82395
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
            "root_exu_CUE", "-999.99",
            "prime_y", "0.0",
            "prime_z", "0.0",
            "nmin0", "0.0",                       # for variable som NC depend on inorgN
            "nmincrit", "2.0",                    # for variable som NC depend on inorgN 
            "pmin0", "0.0",                       # for variable som PC depend on inorgavlp
            "pmincrit", "2.0",                    # for variable som PC depend on inorgavlp 
             ############## CONTROL ############
            "adjust_rtslow", "false",             # goes together with exudation
            "alloc_model", "fixed",               # fixed and variable allocation pattern
            "diagnosis", "false",
            "exudation", "false",
            "fixed_stem_nc", "false",
            "fixed_stem_pc", "false",
            "fixleafnc", "false",
            "fixleafpc", "false",
            "ncycle", "true",
            "pcycle", "true",
            "nuptake_model", "0",
            "puptake_model", "0",
            "print_options", "end",                # during spin up, set to end
            "passiveconst", "false",
            "respiration_model", "fixed",
            "som_nc_calc", "fixed",
            "som_pc_calc", "fixed")
        
        #### Transform into dataframe
        even <- seq(2, length(replace_dict), by=2)
        odd <- seq(1, length(replace_dict)-1, by=2)
        replace_dict2 <- cbind(replace_dict[odd], replace_dict[even])
        replace_dict2 <- as.data.frame(replace_dict2)
        
        ad.adjust_param_file(cfg_fname, replace_dict)
        os.system(GDAY_SPIN + cfg_fname)
        
        # add this directory to python search path so we can find the scripts!
        sys.path.append(os.path.join(d, "code/scripts"))
        import translate_GDAY_output_to_NCEAS_format as tr
        
    } # if SPIN_UP ends
    
}


################################ Program #########################################
site = "Quasi_equil"
Run_GDAY_spinup(site, SPIN_UP=True)
