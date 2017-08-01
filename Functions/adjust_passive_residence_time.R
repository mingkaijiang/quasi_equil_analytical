#### Function to adjust residence time of the passive pool
adjust_passive_residence_time <- function(df, a) {
    
    # define parameters
    prime_y <- 0.6
    prime_z <- 0.5
    
    # compute active out at daily timestep
    factive <- myDF2$active_to_slow + myDF2$active_to_passive + myDF2$co2_rel_from_active_pool + myDF2$co2_released_exud
    
    # compute residence time
    rt_slow_pool = (1.0 / prime_y) / (factive / (factive + prime_z))
    kdec7_new <- 1 / rt_slow_pool
    
    # annual timestep
    kdec7 <- kdec7_new * 365.0
    
    return(kdec7)
}