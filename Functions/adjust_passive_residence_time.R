#### Function to adjust residence time of the passive pool
adjust_passive_residence_time <- function(df, a, npp) {
    
    # define parameters
    prime_y <- 0.6
    prime_z <- 0.5
    
    # compute active out at daily timestep
    c_into_exud <- npp * a$ar * a$ariz
    
    factive = (active_to_slow + active_to_passive + 
               co2_to_air + co2_released_exud)
    
    # residence time
    rt_slow_pool = (1.0 / prime_y) / 
    pmax(0.01, (factive / (factive + prime_z)))
    
    # compute decomposition rate
    kdec7_new = 1.0 / rt_slow_pool;
    
    # annual timestep
    kdec7 <- kdec7_new * 365.0
    
    return(kdec7)
}