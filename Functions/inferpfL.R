# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
inferpfL <- function(nf, a, PinL, NinL,
                     Cpass) {
    
    # passive pool burial 
    pass <- passive(nf, allocn(nf))
    omega <- allocn(nf)$af*pass$omegaf + allocn(nf)$ar*pass$omegar 
    
    # prepare long term nitrogen fluxes
    N0 = NinL  + (1-pass$qq) * pass$decomp * Cpass * ncp
    nleach <- leachn/(1-leachn) * (a$af*a$nfl + a$aw*a$nw + a$ar*a$nr)
    nburial <- omega*ncp
    nwood <- 0 # a$aw*a$nw

    NPP <- N0 / (nleach + nburial + nwood)
    
    # prepare long term phosphorus fluxes
    P0 = PinL + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0/NPP - pburial
    
    #if(pwvar == FALSE) {
    #    pf <- (((Y1 - pwood * a$aw) / (pleach+pocc)) - pwood * a$aw) / ((1.0-pretrans)*a$af + prho * a$ar)
    #} else {
    #    pf <- Y1 / (pwood * a$aw + (pleach + pocc) * ((1.0-pretrans)*a$af + prho * a$ar + pwood * a$aw))
    #}
    
    if(pwvar == FALSE) {
        pf <- (((Y1) / (pleach+pocc)) - pwood * a$aw) / ((1.0-pretrans)*a$af + prho * a$ar)
    } else {
        pf <- Y1 / ((pleach + pocc) * ((1.0-pretrans)*a$af + prho * a$ar + pwood * a$aw))
    }
    
    # obtain equilpf  
    return(pf)
}

# Find medium term equilibrated pf based on equilibrated NPP calculated from equilnf profile
inferpfM <- function(nf, a, PinM, NinM,
                     CpassL, CpassM) {
    
    #browser()
    # passive pool burial 
    pass <- slow_pool(nf, allocn(nf))
    omegap <- allocn(nf)$af*pass$omegafp + allocn(nf)$ar*pass$omegarp 
    omegas <- allocn(nf)$af*pass$omegafs + allocn(nf)$ar*pass$omegars 
    
    # prepare long term nitrogen fluxes
    N0 = NinM  + (1-pass$qpq) * pass$decomp_p * CpassL * ncp + (1-pass$qsq) * pass$decomp_s * CpassM * ncs
    nleach <- leachn/(1-leachn) * (a$af*a$nfl + a$aw*a$nw + a$ar*a$nr)
    nburial <- omegap*ncp + omegas*ncs
    nwood <- a$aw*a$nw
    
    NPP <- N0 / (nleach + nburial + nwood)
    
    # prepare long term phosphorus fluxes
    P0 = PinM + (1-pass$qpq) * pass$decomp_p * CpassL * pcp + (1-pass$qsq) * pass$decomp_s * CpassM * pcs 
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omegap*pcp + omegas*pcs
    pocc <- (k1/(1-k1-leachp))
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0/NPP - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * a$aw) / (pleach+pocc)) - pwood * a$aw) / ((1.0-pretrans)*a$af + prho * a$ar)
    } else {
        pf <- Y1 / (pwood * a$aw + (pleach + pocc) * ((1.0-pretrans)*a$af + prho * a$ar + pwood * a$aw))
    }
    
    # obtain equilpf  
    return(pf)
}
