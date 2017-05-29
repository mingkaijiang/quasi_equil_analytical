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

    ncontent <- NPP * pfdf$af / sf * nf
    pcontent <- NPP * pfdf$af / sf * pf
    
    N0 <- ncontent * kn / (1.0 - exp(-kn * SLA*pfdf$af*NPP/sf/cfrac))
    P0 <- pcontent * kn / (1.0 - exp(-kn * SLA*pfdf$af*NPP/sf/cfrac))
    
    gamma_star <- arrh(mt, gamstar25, eag, tk)
    
    # Michaelis-Menten coefficents for carboxylation by Rubisco 
    Kc <- arrh(mt, kc25, eac, tk)
    
    # Michaelis-Menten coefficents for oxygenation by Rubisco 
    Ko <- arrh(mt, ko25, eao, tk)
    
    # return effective Michaelis-Menten coefficient for CO2 
    km <- (Kc * (1.0 + oi / Ko))

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

### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N, SLA & Ca, based on full photosynthesis model
LUE_full_cn <- function(nf, nfdf, CO2, NPP) {
    
    ncontent <- NPP * nfdf$af / sf * nf

    N0 <- ncontent * kn / (1.0 - exp(-kn * SLA*nfdf$af*NPP/sf/cfrac))

    gamma_star <- arrh(mt, gamstar25, eag, tk)
    
    # Michaelis-Menten coefficents for carboxylation by Rubisco 
    Kc <- arrh(mt, kc25, eac, tk)
    
    # Michaelis-Menten coefficents for oxygenation by Rubisco 
    Ko <- arrh(mt, ko25, eao, tk)
    
    # return effective Michaelis-Menten coefficient for CO2 
    km <- (Kc * (1.0 + oi / Ko))
    
    # sla unit conversion: from m2 kg-1 DW to m2 g-1
    sla_m2_per_g <- SLA / 1000.0
    
    log_vcmax <- 1.993 + 2.555 * log(N0) - 0.372 * log(sla_m2_per_g) + 0.422 * log(N0) * log(sla_m2_per_g)
    vcmax <- exp(log_vcmax)
    
    log_jmax <- 1.197 * log_vcmax
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