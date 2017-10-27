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
    with(myDF[1:1000,], plot(factive, rtslow))
    with(myDF[1:1000,], plot(root_exn, rtslow))
    with(myDF[1:1000,], plot(root_exc, rtslow))
    
    ### or output into csv and compute relationship mannually
    write.csv(myDF[1:1000, ], "GDAY/outputs/Run9/rlt_simplified.csv", row.names=F)
    
    testDF <- myDF[1:1000,]
    
    ### define parameters
    cn_ref <- 25
    a0 <- 0.05
    a1 <- 0.6
    rhizo_cue <- 0.3
    prime_y <- 0.6
    prime_z <- 0.001
    
    # checking predicted rtslow based on factive matches with simulated result
    testDF$pred_rtslow <- (1.0 / prime_y) / pmax(0.01, (testDF$factive / (testDF$factive + prime_z)))
    with(testDF, plot(pred_rtslow~rtslow))
    
    # checking predicted rtslow vs. co2 released due to exudation
    with(testDF, plot(co2_released_exud, rtslow))
    testDF$co2_exud_pred <- testDF$root_exc * (1 - rhizo_cue)
    with(testDF, plot(co2_exud_pred~co2_released_exud))
    
    # checking predicted rtslow and root_exc
    with(testDF, plot(co2_released_exud~root_exc))
    
    # checking predicted rtslow and cproot
    testDF$cproot_pred <- testDF$npp * 0.2
    with(testDF, plot(co2_released_exud~cproot_pred))
    with(testDF, plot(pred_rtslow~cproot_pred))
    
    # checking root_exc and cproot
    with(testDF, plot(root_exc~cproot_pred))
    
    # checking root_exc and frac of root allocated to root exc
    testDF$arg <- pmax((testDF$shoot/testDF$shootn - cn_ref) / cn_ref, 0)
    testDF$fract_root_to_exc <- pmin(0.5, a0 + a1 * testDF$arg)
    testDF$pred_exc <- testDF$fract_root_to_exc * testDF$cproot_pred  
    with(testDF, plot(pred_exc~root_exc))
    
    # checking important relationships
    testDF$shootnc <- testDF$shootn / testDF$shoot

    with(testDF, plot(shootnc, pred_rtslow))    
    with(testDF, plot(pred_rtslow~factive))
    
    
}


priming_simplified()
