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
    nwood <- a$aw*a$nw

    NPP <- N0 / (nleach + nburial + nwood)
    
    # prepare long term phosphorus fluxes
    P0 = PinL + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
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

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
# specifically for CWD calculation
inferpfL_CWD <- function(nf, a, Pin = 0.02, Nin = 0.4,
                     leachn = 0.05, leachp = 0.05, Cpass=CpassVLong, 
                     pwvar = TRUE, nwvar = TRUE, pwood = 0.0003, prho = 0.7, 
                     pretrans = 0.6, pcp = 0.005, ncp = 0.1,
                     Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                     k1 = 0.01, k2 = 0.01, k3 = 0.05, sw=0.02) {
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
    ncwd <- nwood * sw

    NPP <- N0 / (nleach + nburial + ncwd)
    
    # prepare long term phosphorus fluxes
    P0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0/NPP - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw - pwood * aw * sw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + pwood * aw * sw + (pleach + pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilpf  
    return(pf)
}

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
# specifically for explicit mineral N and P pool 
inferpfL_expl_min <- function(nf, a, Pin = 0.02, Nin = 0.4,
                     leachn = 0.05, leachp = 0.05, Cpass=CpassVLong, 
                     pwvar = TRUE, nwvar = TRUE, pwood = 0.0003, prho = 0.7, 
                     pretrans = 0.6, pcp = 0.005, ncp = 0.1,
                     Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                     k1 = 0.01, k2 = 0.01, k3 = 0.05, nuptakerate = 0.96884,
                     puptakerate = 0.82395) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # passive pool burial 
    pass <- passive(nf, allocn(nf, nwvar=nwvar), Tsoil, Texture, ligfl, ligrl)
    omega <- allocn(nf, nwvar=nwvar)$af*pass$omegaf + allocn(nf, nwvar=nwvar)$ar*pass$omegar 
    
    # equation for N constraint with passive, wood, and leaching
    U0 <- Nin + (1-pass$qq) * pass$decomp * Cpass * ncp   
    nwood <- a$aw*a$nw
    nburial <- omega*ncp
    
    # NPP <- ((U0 - nwood - nburial) / leachn) * nuptakerate / (a$nfl*a$af + a$nr*a$ar + a$nw*a$aw)  
    NPP <- (nuptakerate * U0) / ((a$nfl*a$af + a$nr*a$ar + a$nw*a$aw) * leachn + nuptakerate * nwood + nuptakerate * nburial)
    
    # prepare long term phosphorus fluxes
    P0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0 / NPP - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach + pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilpf  
    return(pf)
}

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
# specifically for N uptake as a function of biomass - OCN approach
# i.e. N uptake as a saturating function of mineral N
inferpfL_root_ocn <- function(nf, a, Pin = 0.02, Nin = 0.4,
                              leachn = 0.05, leachp = 0.05, Cpass=CpassVLong, 
                              pwvar = F, nwvar = F, pwood = 0.0003, prho = 0.7, 
                              pretrans = 0.6, pcp = 0.005, ncp = 0.1,
                              Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                              k1 = 0.01, k2 = 0.01, k3 = 0.05, nuptakerate = 0.96884,
                              puptakerate = 0.82395, sr = 1.5, k = 0.08, vmax = 1.0) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # passive pool burial 
    pass <- passive(nf, allocn(nf, nwvar=nwvar), Tsoil, Texture, ligfl, ligrl)
    omega <- allocn(nf, nwvar=nwvar)$af*pass$omegaf + allocn(nf, nwvar=nwvar)$ar*pass$omegar 
    
    # prepare long term nitrogen fluxes
    N0 <- Nin  + (1-pass$qq) * pass$decomp * Cpass * ncp
    Nmin <- k * (a$nfl*a$af + a$nr*a$ar + a$nw*a$aw) / (a$ar / sr - (a$nfl*a$af + a$nr*a$ar + a$nw*a$aw))
    nleach <- leachn * Nmin
    nburial <- omega*ncp
    nwood <- a$aw*a$nw
    
    NPP <- N0 / (nleach + nburial + nwood)
    
    # prepare long term phosphorus fluxes
    P0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0 / NPP - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach + pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilpf  
    return(pf)
}

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
# specifically for N uptake as a function of biomass - GDAY approach
# i.e. N uptake as a saturating function of root biomass
inferpfL_root_gday <- function(nf, a, Pin = 0.02, Nin = 0.4,
                              leachn = 0.05, leachp = 0.05, Cpass=CpassVLong, 
                              pwvar = TRUE, nwvar = TRUE, pwood = 0.0003, prho = 0.7, 
                              pretrans = 0.6, pcp = 0.005, ncp = 0.1,
                              Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                              k1 = 0.01, k2 = 0.01, k3 = 0.05, nuptakerate = 0.96884,
                              puptakerate = 0.82395, sr = 1.5, kr = 0.5) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # passive pool burial 
    pass <- passive(nf, allocn(nf, nwvar=nwvar), Tsoil, Texture, ligfl, ligrl)
    omega <- allocn(nf, nwvar=nwvar)$af*pass$omegaf + allocn(nf, nwvar=nwvar)$ar*pass$omegar 
    
    # prepare long term nitrogen fluxes
    U0 <- Nin + (1-pass$qq) * pass$decomp * Cpass * ncp   # will be a constant if decomp rate is constant
    nwood <- a$aw*a$nw
    nburial <- omega*ncp
    
    A_NF <- a$nfl*a$af + a$nr*a$ar + a$nw*a$aw
    
    # equation for NPP
    NPP <- (U0 - A_NF * leachn * kr * (sr / a$ar)) / (nwood + nburial + A_NF*leachn)

    # prepare long term phosphorus fluxes
    P0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0 / NPP - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach + pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilpf  
    return(pf)
}

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
# specifically for variable passive pool stoichiometry
inferpfL_variable_pass <- function(nf, a, Pin = 0.02, Nin = 0.4, NPP,
                                   leachn = 0.05, leachp = 0.05, Cpass=CpassVLong, 
                                   pwvar = TRUE, nwvar = TRUE, pwood = 0.0003, prho = 0.7, 
                                   pretrans = 0.6, pcp = 0.005, 
                                   Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                                   k1 = 0.01, k2 = 0.01, k3 = 0.05, nuptakerate = 0.96884,
                                   puptakerate = 0.82395) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # calculate ncp (passive pool nc ratio) based on mineral N
    ncp <- calc_passive_nc(equilNPP = NPP, adf = a, nuptake = nuptakerate)
    
    # passive pool burial 
    pass <- passive(nf, allocn(nf, nwvar=nwvar), Tsoil, Texture, ligfl, ligrl)
    omega <- allocn(nf, nwvar=nwvar)$af*pass$omegaf + allocn(nf, nwvar=nwvar)$ar*pass$omegar 
    
    # prepare long term nitrogen fluxes
    N0 = Nin  + (1-pass$qq) * pass$decomp * Cpass * ncp
    nleach <- leachn/(1-leachn) * (a$af*a$nfl + a$aw*a$nw + a$ar*a$nr)
    nburial <- omega*ncp
    nwood <- a$aw*a$nw
    
    NPP <- N0 * nuptakerate / (nleach + nburial + nwood)
    
    # prepare long term phosphorus fluxes
    P0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0 / NPP - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach + pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilpf  
    return(pf)
}

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
# specifically for exudation
inferpfL_exudation <- function(nf, a, Pin = 0.02, Nin = 0.4,
                               leachn = 0.05, leachp = 0.05, Cpass=CpassVLong, 
                               pwvar = TRUE, nwvar = TRUE, pwood = 0.0003, prho = 0.7, 
                               pretrans = 0.6, pcp = 0.005, ncp = 0.1,
                               Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                               k1 = 0.01, k2 = 0.01, k3 = 0.05, vx = 0.0005) {
    # vx is the asymbiotic N fixation per unit root C exudation
    
    # prepare allocation partitioning
    ar <- 0.15
    af <- 0.2
    ae <- 0.05
    aw <- 1 - ar - af - ae
    
    # passive pool burial 
    pass <- passive_exudation(nf, allocn(nf, nwvar=nwvar), Tsoil, Texture, ligfl, ligrl)
    omega <- allocn_exudation(nf, nwvar=nwvar)$af*pass$omegaf + 
             allocn_exudation(nf, nwvar=nwvar)$ar*pass$omegar +
             allocn_exudation(nf, nwvar=nwvar)$aw*pass$omegaw + 
             allocn_exudation(nf, nwvar=nwvar)$ae*pass$omegae
    
    # prepare long term nitrogen fluxes
    N0 = Nin  + (1-pass$qq) * pass$decomp * Cpass * ncp
    nleach <- leachn/(1-leachn) * (a$af*a$nfl + a$aw*a$nw + a$ar*a$nr)
    nburial <- omega*ncp
    nwood <- a$aw*a$nw
    nexud <- vx * ncp
    
    NPP <- N0 / (nleach + nburial + nwood - nexud)
    
    # prepare long term phosphorus fluxes
    P0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    pexud <- vx * pcp
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0/NPP - pburial + pexud
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach + pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilpf  
    return(pf)
}