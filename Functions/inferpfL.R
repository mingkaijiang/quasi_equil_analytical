# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
inferpfL <- function(nf, a, Pin = 0.04, Nin = 1.0,
                     leachn = 0.05, leachp = 0.05, Cpass=CpassVLong, 
                     pwvar = TRUE, nwvar = TRUE, pwood = 0.0003, prho = 0.7, 
                     pretrans = 0.6, pcp = 0.005, ncp = 0.1,
                     Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                     k1 = 0.01, k2 = 0.01, k3 = 0.05) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # passive pool burial 
    pass <- passive(nf, allocn(nf, nwvar=nwvar), Tsoil, Texture, ligfl, ligrl)
    omega <- allocn(nf, nwvar=nwvar)$af*pass$omegaf + allocn(nf, nwvar=nwvar)$ar*pass$omegar 
    
    # prepare long term nitrogen fluxes
    N0 = Nin  + (1-pass$qq) * pass$decomp * Cpass * ncp
    nleach <- leachn/(1-leachn) * (a$af*a$nfl + a$aw*a$nw + a$ar*a$nr)
    nburial <- omega*ncp
    nwood <- a$aw*a$nw
    
    NPP <- N0 / (nleach + nburial + nwood)
    
    # prepare long term phosphorus fluxes
    P0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0/NPP - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach + pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilpf  
    return(pf)
}