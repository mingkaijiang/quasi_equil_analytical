#### Run GDAY based on priming effect script and 
#### Compute relationship between root exudation and turnover time of slow pool

priming_simplified <- function() {
    
    #### Run GDAY
    cwd <- getwd()
    setwd("GDAY/simulations/Run9")
    source("quasi_equil_annual_spin_up.R")
    # source("quasi_equil_annual_simulations.R")
    setwd(cwd)
    
    require(data.table)
    set.seed(1)
    
    #### Read output
    myDF <- fread("GDAY/outputs/Run9/Quasi_equil_model_spinup_equilib.csv",
                     skip=1)
    
    ### visual inspection
    with(myDF[sample(nrow(myDF), 1000), ], plot(co2_released_exud, kdec7))
    
    with(myDF[sample(nrow(myDF), 1000), ], plot(V63~V61))
    
    
    
    
    
    
    
}


priming_simplified()
