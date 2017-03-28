
#### Implement quasi-equilibrium analysis into R .. or at least, try to!
#### Basic version using NPP function from Comins & McMurtrie (1993)
####
#### Make inference for Phosphorus constraint based on N and photosynthetic constraints
################################################################################

### Make inference of pf based on nf
inferpfVL <- function(nf, a, Pin=0.04, Nin=1.0,
                      leachn=0.05, leachp=0.05,
                      k1=0.01, k2=0.01, k3=0.05,
                      nwood=0.005, pwood=0.0003, nwvar = FALSE,
                      pwvar = FALSE, nrho = 0.7, prho = 0.7,
                      nretrans = 0.5, pretrans = 0.6) {
    # allocation parameters
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # output nf, based on F(nf) = F(pf)
    pf <- c()
    
    Nleach <- (leachn/(1-leachn)) * (a$nfl * a$af + a$nr * a$ar +
                                         a$nw *a$aw)
    
    Pleach <- (leachp/(1-leachp-k1)) 
    Pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp)) 
    
    Pg <- ((Pin * Nleach)/Nin) / (Pocc + Pleach)
    
    if(pwvar == FALSE) {
        pf <- (Pg - pwood * aw) / ((1.0 - pretrans) * af + prho * ar)
    } else {
        pf <- Pg / ((1.0 - pretrans) * af + prho * ar + aw * pwood)
    }
    return(round(pf,8))
}

# Find very-long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
equilpVL <- function(equilNPP, Pin = 0.04, leachp=0.05,
                     pwvar = FALSE, pwood = 0.0003, prho = 0.7,
                     pretrans = 0.6, k1 = 0.01, k2 = 0.01, k3 = 0.05) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # prepare very long term phosphorus fluxes
    U0 = Pin
    pleach <- leachp/(1-leachp-k1)
    pocc <- (k3/(k2+k3))*(k1/(1-k1-pleach))
    
    # Convert NPP unit
    NPP_PC <- equilNPP*10^3     # convert to g C m-2 yr-1
    
    # Calculate equilnf, based on equilNPP_P
    Y <- U0/(NPP_PC*(pleach+pocc))
    if(pwvar == FALSE) {
        pf <- (Y - pwood * aw) / ((1.0 - pretrans) * af + prho * ar)
    } else {
        pf <- Y / ((1.0 - pretrans) * af + prho * ar + aw * pwood)
    }
    
    # obtain equilpf  
    return(pf)
}

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
equilpL <- function(equildf, Pin = 0.04, leachp = 0.05, Cpass=CpassVLong,
                    pwvar = FALSE, pwood = 0.0003, prho = 0.7, 
                    pretrans = 0.6, pcp = 0.005, Tsoil = 15,
                    Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                    k1 = 0.01, k2 = 0.01, k3 = 0.05) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    df <- equildf[1,1]
    equilNPP <- equildf[1,2]
    
    # passive pool burial 
    pass <- passive(df, allocn(df), Tsoil, Texture, ligfl, ligrl)
    omegap <- allocn(df)$af*pass$omegaf + allocn(df)$ar*pass$omegar 
    
    # prepare very long term nitrogen fluxes
    U0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omegap*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Convert NPP unit
    NPP_PC <- equilNPP*10^3     # convert to g C m-2 yr-1
    
    # Calculate equilnf, based on equilNPP_P
    Y1 <- U0/NPP_PC - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach+pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilnf  
    return(pf)
}

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
inferpfL <- function(nf, a, Pin = 0.04, Nin = 1.0,
                     leachn = 0.05, leachp = 0.05, Cpass=CpassVLong, 
                     pwvar = FALSE, pwood = 0.0003, prho = 0.7, 
                     pretrans = 0.6, pcp = 0.005, ncp = 0.1,
                     Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                     k1 = 0.01, k2 = 0.01, k3 = 0.05) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # passive pool burial 
    pass <- passive(nf, allocn(nf), Tsoil, Texture, ligfl, ligrl)
    omega <- allocn(nf)$af*pass$omegaf + allocn(nf)$ar*pass$omegar 
    
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

