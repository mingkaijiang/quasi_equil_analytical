

### Calculate the very long term nutrient cycling constraint for N, i.e. passive pool equilibrated
# it is just Nin = Nleach
VLong_constraint_N <- function(nf, nfdf) {
    # passed are bf and nf, the allocation and plant N:C ratios
    # parameters : 
    # Nin is fixed N inputs (N fixed and deposition) in g m-2 yr-1 (could vary fixation)
    # leachn is the rate of leaching of the mineral N pool (per year)
    
    # equation for N constraint with just leaching
    U0 <- Nin
    nleach <- leachn/(1-leachn) * (nfdf$nfl*nfdf$af + nfdf$nr*nfdf$ar + nfdf$nw*nfdf$aw)
    NPP_NC <- U0 / (nleach)   # will be in g C m-2 yr-1
    NPP_N <- NPP_NC*10^-3     # returned in kg C m-2 yr-1
    
    df <- data.frame(NPP_N,nleach)
    return(df)   
}


### Calculate the very long term nutrient cycling constraint for P, i.e. passive pool equilibrated
# it is just Pin = Pleach + Pocc
VLong_constraint_P <- function(pf, pfdf) {
    # parameters : 
    # Pin is P deposition inputs in g m-2 yr-1 (could vary fixation)
    # leachp is the rate of leaching of the labile P pool (per year)
    # k1 is the transfer rate from labile to secondary P pool
    # k2 is the transfer rate from secondary to labile P pool
    # k3 is the transfer rate from secondary to occluded P pool
    
    U0 = Pin
    pleach <- (leachp/(1-leachp-k1)) * (pfdf$pfl*pfdf$af + pfdf$pr*pfdf$ar + pfdf$pw*pfdf$aw)
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp)) * (pfdf$pfl*pfdf$af + pfdf$pr*pfdf$ar + pfdf$pw*pfdf$aw)
    
    NPP_PC <- U0 / (pleach + pocc)   # will be in g C m-2 yr-1
    NPP_P <- NPP_PC*10^-3     # returned in kg C m-2 yr-1
    
    df <- data.frame(NPP_P,pleach, pocc)
    return(df)   
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong <- function(CO2, nwvar, pwvar) {
    fn <- function(nf) {
        photo_constraint(nf, inferpfVL(nf, allocn(nf, nwvar)), 
                         allocn(nf, nwvar),allocp(inferpfVL(nf, allocn(nf, nwvar)), pwvar), 
                         CO2) - VLong_constraint_N(nf,allocn(nf, nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf, nwvar))
    equilNPP <- photo_constraint(equilnf, equilpf, 
                                 allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
    
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}



### Function for nutrient N constraint in longterm ie passive, leaching, wood considered
Long_constraint_N <- function(df, a, Cpass, NinL) {
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
    pass <- passive(df, a)
    omegap <- a$af*pass$omegaf + a$ar*pass$omegar 
    
    # equation for N constraint with passive, wood, and leaching
    U0 <- NinL + (1-pass$qq) * pass$decomp * Cpass * ncp   # will be a constant if decomp rate is constant
    nwood <- a$aw*a$nw
    nburial <- omegap*ncp
    nleach <- leachn/(1-leachn) * (a$nfl*a$af + a$nr*(a$ar) + a$nw*a$aw)
    
    NPP_NC <- U0 / (nwood + nburial + nleach)   # will be in g C m-2 yr-1
    NPP <- NPP_NC*10^-3 # returned in kg C m-2 yr-1
    
    df <- data.frame(NPP, nwood,nburial,nleach,a$aw)
    return(df)   
}

### Function for nutrient P constraint in longterm ie passive, leaching, wood considered
Long_constraint_P <- function(df, a, Cpass, PinL) {
    # parameters : 

    
    # passive pool burial 
    pass <- passive(nfseq, allocn(nfseq, nwvar=nwvar))
    omegap <- a$af*pass$omegaf + a$ar*pass$omegar 
    
    # equation for P constraint with passive, wood, and leaching
    U0 <- PinL + (1-pass$qq) * pass$decomp * Cpass * pcp   # will be a constant if decomp rate is constant
    pwood <- a$aw*a$pw
    pburial <- omegap*pcp
    pleach <- leachp/(1-leachp-k1) * (a$pfl*a$af + a$pr*a$ar + a$pw*a$aw)
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp)) * (a$pfl*a$af + a$pr*a$ar + a$pw*a$aw)
    
    
    NPP_PC <- U0 / (pwood + pburial + pleach + pocc)   # will be in g C m-2 yr-1
    NPP <- NPP_PC*10^-3 # returned in kg C m-2 yr-1
    
    df <- data.frame(NPP, pwood,pburial,pleach, pocc, a$aw)
    return(df)   
}


# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLong <- function(CO2,Cpass,NinL, PinL, nwvar, pwvar) {
    fn <- function(nf) {
        photo_constraint(nf, inferpfL(nf, allocn(nf, nwvar=nwvar), PinL = PinL,
                                      NinL = NinL, Cpass=Cpass, nwvar=nwvar, pwvar=pwvar), 
                         allocn(nf,nwvar=nwvar), 
                         allocp(inferpfL(nf, allocn(nf, nwvar=nwvar), PinL = PinL,
                                         NinL = NinL, Cpass=Cpass, nwvar=nwvar, pwvar=pwvar), pwvar=pwvar), 
                         CO2) - Long_constraint_N(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilpf <- inferpfL(equilnf, allocn(equilnf, nwvar=nwvar), PinL = PinL,
                        NinL = NinL, Cpass=Cpass, nwvar=nwvar, pwvar=pwvar)
    equilNPP <- photo_constraint(equilnf, equilpf, 
                                  allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}


