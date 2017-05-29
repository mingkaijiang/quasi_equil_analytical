### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N & Ca
LUE <- function(nf, CO2) {
    
    CaResp <- 1.632 * (CO2-60.9) / (CO2+121.8)    ##RCO2
    Nresp <- min(nf/Nref, 1)                      ##Rate-limiting effect of low N
    
    #assim <- 16.848 + 178.664 * nf + 1418.722 * pf
    #assim_max <- 16.848 + 178.664 * 0.1 + 1418.722 * 0.004
    #Nresp <- assim/assim_max
    
    return(LUE0 * CaResp * Nresp)
}

### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N, P & Ca
LUE_np <- function(nf, pf, CO2) {
    
    CaResp <- 1.632 * (CO2-60.9) / (CO2+121.8)    ##RCO2
    # Nresp <- min(df/Nref, 1)                      ##Rate-limiting effect of low N
    
    assim <- 16.848 + 178.664 * nf + 1418.722 * pf
    assim_max <- 16.848 + 178.664 * 0.1 + 1418.722 * 0.004
    
    Nresp <- assim/assim_max
    
    return(LUE0 * CaResp * Nresp)
}

### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N, P & Ca, based on full photosynthesis model
LUE_full_cnp <- function(nf, pf, CO2) {
    
    gamma_star = calculate_co2_compensation_point(tk, mt)
    
    km = calculate_michaelis_menten_parameter(tk, mt)
    
    log_vcmax = 3.946 + 0.921 * log(N0) + 0.121 * log(P0) + 0.282 * log(N0) * log(P0)
    vcmax = exp(log_vcmax)
    
    log_jmax = 1.246 + 0.886 * log_vcmax + 0.089 * log(P0)
    jmax = exp(log_jmax)
    
    
    ci = calculate_ci(vpd, CO2)
    
    alpha = calculate_quantum_efficiency(ci, gamma_star)
    
    ac = assim(ci, gamma_star, vcmax, km)
    
    aj = assim(ci, gamma_star, jmax/4.0, 2.0*gamma_star)
    
    asat <- min(aj, ac)
    
    lue_calc <- epsilon(asat, par, alpha, daylen)
    
    return(LUE0 * CaResp * Nresp)
}