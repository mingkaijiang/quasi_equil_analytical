#### Function to adjust residence time of the passive pool
adjust_passive_residence_time <- function(df, a, npp) {
    
    # define parameters
    prime_y <- 0.6
    prime_z <- 0.5
    
    # compute active out at daily timestep
    c_into_exud <- npp * a$ar * a$ariz
    
    # compute decomposition rate
    kdec7_new <- c_into_exud * 7.5
    
    # annual timestep
    kdec7 <- kdec7_new * 365.0
    
    return(kdec7)
}