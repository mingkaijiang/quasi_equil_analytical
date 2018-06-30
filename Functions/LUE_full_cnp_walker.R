### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N, P & Ca, based on full photosynthesis model
LUE_full_cnp_walker <- function(nf, pfdf, pf, CO2, NPP) {
    
    ncontent <- NPP * pfdf$af / sf * nf  # g N m-2
    pcontent <- NPP * pfdf$af / sf * pf
    
    # update sla unit from m2 kg-1 DM to m2 g-1
    sla <- SLA / 1000.0
    
    # compute LAI m2 m-2
    lai <- sla * NPP * pfdf$af / sf / cfrac
    
    N0 <- ncontent * kn / (1.0 - exp(-kn * lai))
    P0 <- pcontent * kn / (1.0 - exp(-kn * lai))
    
    #gamma_star <- arrh(mt, gamstar25, eag, tk)
    gamma_star <- 32.97
    
    # Michaelis-Menten coefficents for carboxylation by Rubisco 
    Kc <- arrh(mt, kc25, eac, tk)
    #Kc <- 234.72
    
    # Michaelis-Menten coefficents for oxygenation by Rubisco 
    Ko <- arrh(mt, ko25, eao, tk)
    #Ko <- 216876.747
    
    # return effective Michaelis-Menten coefficient for CO2 
    km <- (Kc * (1.0 + oi / Ko))
    #km <- 461.998
    
    # Walker relationship
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
    
    asat <- pmin(aj, ac)
    
    #lue_calc <- epsilon_simplified(asat, PAR_MJ, alpha, daylen)
    lue_calc <- epsilon(asat, par, alpha, daylen)
    
    return(lue_calc)
}