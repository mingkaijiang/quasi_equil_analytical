### Make inference of pf based on nf
inferpfVL <- function(nf, a) {
    
    # output nf, based on F(nf) = F(pf)
    pf <- c()
    
    Nleach <- (leachn/(1-leachn)) * (a$nfl * a$af + a$nr * a$ar +
                                         a$nw *a$aw)
    
    Pleach <- (leachp/(1-leachp-k1)) 
    Pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp)) 
    
    Pg <- ((Pin * Nleach)/Nin) / (Pocc + Pleach)
    
    if(pwvar == FALSE) {
        pf <- (Pg - pwood * a$aw) / ((1.0 - pretrans) * a$af + prho * a$ar)
    } else {
        pf <- Pg / ((1.0 - pretrans) * a$af + prho * a$ar + a$aw * pwood)
    }
    return(round(pf,8))
}

### Make inference of pf based on nf
# specifically for explicit mineral pools
inferpfVL_expl_min <- function(nf, a) {
    # allocation parameters
    ar <- aroot
    af <- aleaf
    aw <- 1 - ar - af
    
    # output nf, based on F(nf) = F(pf)
    pf <- c()
    # equation for N constraint with just leaching
    U0 <- Nin
    nleach <- leachn
    
    Nmin <- U0 / nleach
    NPP <- Nmin * nuptakerate / (a$nfl*a$af + a$nr*a$ar + a$nw*a$aw)
    
    pleach <- (leachp/(1-leachp-k1)) 
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp)) 
    
    Pg <- Pin / (NPP * (pleach + pocc))
    
    if(pwvar == FALSE) {
        pf <- (Pg - pwood * aw) / ((1.0 - pretrans) * af + prho * ar)
    } else {
        pf <- Pg / ((1.0 - pretrans) * af + prho * ar + aw * pwood)
    }
    return(round(pf,8))
}

### Make inference of pf based on nf
# specifically for N uptake as a function of biomass - OCN approach
# i.e. N uptake as a saturating function of mineral N
inferpfVL_root_ocn <- function(nf, a, Pin=0.02, Nin=0.4,
                               leachn=0.05, leachp=0.05,
                               k1=0.01, k2=0.01, k3=0.05,
                               nwood=0.005, pwood=0.0003, 
                               pwvar = F, nrho = 0.7, prho = 0.7,
                               nretrans = 0.5, pretrans = 0.6,
                               nuptakerate = 0.96884, puptakerate = 0.82395,
                               sr = 1.5, k = 0.08, vmax = 1.0) {
    # allocation parameters
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # output nf, based on F(nf) = F(pf)
    pf <- c()
    Nmin <- k * (a$nfl*a$af + a$nr*a$ar + a$nw*a$aw) / (a$ar / sr - (a$nfl*a$af + a$nr*a$ar + a$nw*a$aw))
    Nleach <- leachn * Nmin
    
    Pleach <- (leachp/(1-leachp-k1)) 
    Pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp)) 
    
    Pg <- (Pin * Nleach) / (Nin * (Pocc + Pleach))
    
    if(pwvar == FALSE) {
        pf <- (Pg - pwood * aw) / ((1.0 - pretrans) * af + prho * ar)
    } else {
        pf <- Pg / ((1.0 - pretrans) * af + prho * ar + aw * pwood)
    }
    return(round(pf,8))
}

### Make inference of pf based on nf
# specifically for N uptake as a function of biomass - GDAY approach
# i.e. N uptake as a saturating function of root biomass
inferpfVL_root_gday <- function(nf, a, Pin=0.02, Nin=0.4,
                               leachn=0.05, leachp=0.05,
                               k1=0.01, k2=0.01, k3=0.05,
                               nwood=0.005, pwood=0.0003, 
                               pwvar = TRUE, nrho = 0.7, prho = 0.7,
                               nretrans = 0.5, pretrans = 0.6,
                               nuptakerate = 0.96884, puptakerate = 0.82395,
                               sr = 1.5, kr = 0.5) {
    # allocation parameters
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # output nf, based on F(nf) = F(pf)
    pf <- c()
    # equation for N constraint with just leaching
    U0 <- Nin
    Nmin <- Nin / leachn
    A_NF <- a$nfl*a$af + a$nr*a$ar + a$nw*a$aw
    root_biomass <- a$ar / sr
    nleach <- Nmin * leachn
    
    # equation for NPP
    NPP <- (root_biomass * Nmin - (A_NF * kr)) / (A_NF * root_biomass)
    
    pleach <- (leachp/(1-leachp-k1)) 
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp)) 
    
    Pg <- Pin / (NPP * (pleach + pocc))
    
    if(pwvar == FALSE) {
        pf <- (Pg - pwood * aw) / ((1.0 - pretrans) * af + prho * ar)
    } else {
        pf <- Pg / ((1.0 - pretrans) * af + prho * ar + aw * pwood)
    }
    return(round(pf,8))
}

### Make inference of pf based on nf
inferpfVL_exudation <- function(nf, a, Pin=0.02, Nin=0.4,
                                leachn=0.05, leachp=0.05,
                                k1=0.01, k2=0.01, k3=0.05,
                                nwood=0.005, pwood=0.0003, 
                                pwvar = TRUE, nrho = 0.7, prho = 0.7,
                                nretrans = 0.5, pretrans = 0.6) {
    # allocation parameters
    ar <- 0.15
    af <- 0.2
    ae <- 0.05
    aw <- 1 - ar - af - ae
    
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
