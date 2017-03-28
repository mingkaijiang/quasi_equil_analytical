
#### Implement quasi-equilibrium analysis into R .. or at least, try to!
#### Basic version using NPP function from Comins & McMurtrie (1993)
####
#### Nitrogen constraint functions
################################################################################


### Soil temperature response of decomposition 
Actsoil <- function(Tsoil) 0.0326 + 0.00351*Tsoil^1.652 - (Tsoil/41.748)^7.19

### Burial fractions from passive pool
passive <- function(df, a, Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16) {
    
    len <- length(df)
    
    decomp <- 0.00013*52*Actsoil(Tsoil)   # decomposition of passive pool per year without priming
    
    # re-burial fraction = fraction of C released from passive pool that is re-buried in it
    pas <- 0.996 - (0.85-0.68*Texture)
    psa <- 0.42
    ppa <- 0.45
    pap <- 0.004
    psp <- 0.03
    qq <-  ppa*(pap + psp*pas)/(1-pas*psa)   # re-burial fraction
    
    muf <- c()
    mur <- c()
    omegaf <- c()
    omegar <- c()
    transfer_fa <- c()
    transfer_ra <- c()
    
    
    # transfer coefficients among litter and soil pools
    cfrac <- 0.45
    for (i in 1:len) {
        muf[i] <- max(0,min(0.85 - 0.018*ligfl/cfrac/a[i, "nfl"],1))    
        mur[i] <- max(0,min(0.85 - 0.018*ligrl/cfrac/a[i, "nr"],1))
    }
    pma <- pna <- 0.45
    pua <- 0.55*(1-ligfl)
    pus <- 0.7*ligfl
    pva <- 0.45*(1-ligrl)
    pvs <- 0.7*ligrl
    
    # burial fractions for foliage (omegaf) and root (omegar) into passive pool
    det <- 1-psa*pas
    omegau <- (pap*(pua+pus*psa+psp*(pus+pua*pas)))/det
    omegav <- (pap*(pva+pus*psa+psp*(pvs+pva*pas)))/det
    omegam <- (pap*pma+psp*pma*pas)/det
    omegaf <- muf*omegam + (1-muf)*omegau
    omegar <- mur*omegam + (1-mur)*omegav  
    
    # fraction of foliage and root litter being transferred to active pool
    transfer_fa <- muf*pma + (1-muf)*psa
    transfer_ra <- mur*pma + (1-mur)*psa
    
    ret <- data.frame(decomp, qq, omegaf, omegar, transfer_fa, transfer_ra)
    
    return(ret)
}

### Function for nutrient N constraint in longterm ie passive, leaching, wood considered
NConsLong <- function(df, a, Nin=1.0, leachn=0.05, 
                      Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                      Cpass = 2680, ncp = 0.1) {
    # passed are df and a, the allocation and plant N:C ratios
    # parameters : 
    # Nin is fixed N inputs (N deposition annd fixation) in g m-2 yr-1 (could vary fixation)
    # nleach is the rate of n leaching of the mineral pool (per year)
    # Tsoil is effective soil temperature for decomposition
    # Texture is the fine soil fraction
    # ligfl and ligrl are the lignin:C fractions in the foliage and root litter
    # Cpass is the passive pool size in g C m-2
    # ncp is the NC ratio of the passive pool in g N g-1 C
    
    # passive pool burial 
    pass <- passive(df, a, Tsoil, Texture, ligfl, ligrl)
    omegap <- a$af*pass$omegaf + a$ar*pass$omegar 
    
    # equation for N constraint with passive, wood, and leaching
    U0 <- Nin + (1-pass$qq) * pass$decomp * Cpass * ncp   # will be a constant if decomp rate is constant
    nwood <- a$aw*a$nw
    nburial <- omegap*ncp
    nleach <- leachn/(1-leachn) * (a$nfl*a$af + a$nr*(a$ar) + a$nw*a$aw)
    
    NPP_NC <- U0 / (nwood + nburial + nleach)   # will be in g C m-2 yr-1
    NPP_N <- NPP_NC*10^-3 # returned in kg C m-2 yr-1
    
    df <- data.frame(NPP_N, nwood,nburial,nleach,a$aw)
    return(df)   
}


# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLongN <- function(co2=350,Cpass,Nin) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf)$af,co2=co2) - NConsLong(nf,allocn(nf),Cpass=Cpass,Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP <- solveNC(equilnf,af=allocn(equilnf)$af, co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}


### Calculate the very long term nutrient cycling constraint for N, i.e. passive pool equilibrated
# it is just Nin = Nleach
NConsVLong <- function(df, a, Nin=1.0, 
                       leachn=0.05) {
    # passed are bf and nf, the allocation and plant N:C ratios
    # parameters : 
    # Nin is fixed N inputs (N fixed and deposition) in g m-2 yr-1 (could vary fixation)
    # leachn is the rate of leaching of the mineral N pool (per year)
    
    # equation for N constraint with just leaching
    U0 <- Nin
    nleach <- leachn/(1-leachn) * (a$nfl*a$af + a$nr*(a$ar) + a$nw*a$aw)
    NPP_NC <- U0 / (nleach)   # will be in g C m-2 yr-1
    NPP_N <- NPP_NC*10^-3     # returned in kg C m-2 yr-1
    
    df <- data.frame(NPP_N,nleach)
    return(df)   
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLongN <- function(co2=350) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf)$af,co2=co2) - NConsVLong(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP_N <- solveNC(equilnf,af=allocn(equilnf)$af, co2=co2)
    
    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}