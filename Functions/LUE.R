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
LUE_full_cnp <- function(nf, pfdf, pf, CO2, NPP) {
    
    mt <- 25.0 + 273.5  # degree to kelvin
    tk <- 20.0 + 273.5  # air temperature
    gamstar25 <- 42.75
    eag <- 37830.0
    eac <- 79430.0
    eao <- 36380.0
    kc25 <- 404.9
    ko25 <- 278400.0
    oi <- 210000.0
    vpd <- 2.4
    PA_2_KPA <- 0.001
    wtfac_root <- 1.0
    g1 <- 3.8667
    alpha_j <- 0.308
    daylen <- 12.0
    PAR_MJ <- 12.0
    J_2_UMOL <- 4.57
    MJ_TO_J <- 1000000.0
    par <- MJ_TO_J * J_2_UMOL * PAR_MJ
    UMOL_TO_MOL <- 0.000001
    MOL_C_TO_GRAMS_C <- 12.0
    conv <- UMOL_TO_MOL * MOL_C_TO_GRAMS_C

    N0 <- nf * NPP * pfdf$af / sf / cfrac
    P0 <- pf * NPP * pfdf$af / sf / cfrac
    
    gamma_star <- arrh(mt, gamstar25, eag, tk)
    
    # Michaelis-Menten coefficents for carboxylation by Rubisco 
    Kc <- arrh(mt, kc25, eac, tk);
    
    # Michaelis-Menten coefficents for oxygenation by Rubisco 
    Ko <- arrh(mt, ko25, eao, tk);
    
    # return effective Michaelis-Menten coefficient for CO2 
    km <- ( Kc * (1.0 + oi / Ko) ) ;

    log_vcmax <- 3.946 + 0.921 * log(N0) + 0.121 * log(P0) + 0.282 * log(N0) * log(P0)
    vcmax <- exp(log_vcmax)
    
    log_jmax <- 1.246 + 0.886 * log_vcmax + 0.089 * log(P0)
    jmax <- exp(log_jmax)
    
    # calculate ci
    g1w <- g1 * wtfac_root
    cica <- g1w / (g1w + sqrt(vpd * PA_2_KPA))
    ci <- cica * CO2
    
    # calculate alpha: quantum efficiency
    alpha <- assim(ci, gamma_star, alpha_j/4.0, 2.0*gamma_star)

    ac = assim(ci, gamma_star, vcmax, km)
    
    aj = assim(ci, gamma_star, jmax/4.0, 2.0*gamma_star)
    
    asat <- min(aj, ac)
    
    lue_calc <- 365.0 * epsilon(asat, par, alpha, daylen) / 1000.0
    
    return(lue_calc)
}