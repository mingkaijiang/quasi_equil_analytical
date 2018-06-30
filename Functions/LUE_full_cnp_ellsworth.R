### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N, P & Ca, based on full photosynthesis model
LUE_full_cnp_ellsworth <- function(nf, pfdf, pf, CO2, NPP) {
    
    ncontent <- NPP * pfdf$af / sf * nf  # g N m-2
    pcontent <- NPP * pfdf$af / sf * pf
    
    # update sla unit from m2 kg-1 DM to m2 g-1
    sla <- SLA / 1000.0
    
    N0 <- ncontent * kn / (1.0 - exp(-kn * sla*pfdf$af*NPP/sf/cfrac))
    P0 <- pcontent * kn / (1.0 - exp(-kn * sla*pfdf$af*NPP/sf/cfrac))
    
    gamma_star <- arrh(mt, gamstar25, eag, tk)
    
    # Michaelis-Menten coefficents for carboxylation by Rubisco 
    Kc <- arrh(mt, kc25, eac, tk)
    
    # Michaelis-Menten coefficents for oxygenation by Rubisco 
    Ko <- arrh(mt, ko25, eao, tk)
    
    # return effective Michaelis-Menten coefficient for CO2 
    km <- (Kc * (1.0 + oi / Ko))
    
    # Walker relationship
    #log_vcmax <- 3.946 + 0.921 * log(N0) + 0.121 * log(P0) + 0.282 * log(N0) * log(P0)
    #vcmax <- exp(log_vcmax)
    #log_jmax <- 1.246 + 0.886 * log_vcmax + 0.089 * log(P0)
    #jmax <- exp(log_jmax)
    
    # Ellsworth relationship
    vcmaxn = 27.808 * N0
    jmaxn = 49.93 * N0
    
    vcmaxp = 516.83 * P0
    jmaxp = 933.9 * P0
    
    jmax = pmin(jmaxn, jmaxp)
    vcmax = pmin(vcmaxn, vcmaxp)
    
    # calculate ci
    g1w <- g1 * wtfac_root
    cica <- g1w / (g1w + sqrt(vpd * PA_2_KPA))
    ci <- cica * CO2
    
    # calculate alpha: quantum efficiency
    alpha <- assim(ci, gamma_star, alpha_j/4.0, 2.0*gamma_star)
    
    ac = assim(ci, gamma_star, vcmax, km)
    
    aj = assim(ci, gamma_star, jmax/4.0, 2.0*gamma_star)
    
    asat <- pmin(aj, ac)
    
    lue_calc <- epsilon_simplified(asat, PAR_MJ, alpha, daylen)
    
    return(lue_calc)
}