# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
infer_pf_L <- function(nf, a, PinL, NinL,
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

