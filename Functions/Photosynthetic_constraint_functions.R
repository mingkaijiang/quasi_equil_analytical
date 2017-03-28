
#### Implement quasi-equilibrium analysis into R .. or at least, try to!
#### Basic version using NPP function from Comins & McMurtrie (1993)
####
#### Photosynthetic constraint functions
################################################################################

### Allocation and plant P concentrations - required for both PS constraint and PC constraint
allocp <- function(pf,  pwvar = FALSE,
                   pwood = 0.0003, prho = 0.7,
                   pretrans = 0.6) {
    # parameters
    # pf is the PC ratio of foliage
    # pw is the PC ratio of wood if fixed; otherwise the ratio of wood P:C to foliage P:C
    # pwvar is whether or not to allow wood PC to vary
    # prho is the ratio of root P:C to foliage P:C
    # pretrans is the fraction of foliage P:C retranslocated  
    
    len <- length(pf)
    ar <- af <- aw <- pw <- pr <- rep(0,len)  # initialise
    for (i in 1:len) {
        ar[i] <- 0.2
        af[i] <- 0.2
        aw[i] <- 1 - ar[i] - af[i]
    }
    
    # P concentrations of rest of plant   # in g P g-1 C
    if (pwvar == FALSE) {
        pw <- pwood
    } else {
        pw <- pwood*pf 
    }
    prho <- 0.7
    pr <- prho*pf
    pfl <- (1.0-pretrans)*pf
    
    ret <- data.frame(pf,pfl,pw,pr,af,aw,ar)
    return(ret)
}

### Allocation and plant N concentrations - required for both PS constraint and NC constraint
allocn <- function(nf,  nwvar = FALSE,
                   nwood = 0.005, nrho = 0.7,
                   nretrans = 0.5) {
    # parameters
    # nf is the NC ratio of foliage
    # nw is the NC ratio of wood if fixed; otherwise the ratio of wood N:C to foliage N:C
    # nwvar is whether or not to allow wood NC to vary
    # nrho is the ratio of root N:C to foliage N:C
    # nretrans is the fraction of foliage N:C retranslocated  
    
    len <- length(nf)
    ar <- af <- aw <- nw <- nr <- rep(0,len)  # initialise
    for (i in 1:len) {
        ar[i] <- 0.2
        af[i] <- 0.2
        aw[i] <- 1 - ar[i] - af[i]
    }
    
    # N concentrations of rest of plant   # in g N g-1 C
    if (nwvar == FALSE) {
        nw <- nwood
    } else {
        nw <- nwood*nf 
    }
    nrho <- 0.7
    nr <- nrho*nf
    nfl <- (1.0-nretrans)*nf     
    
    ret <- data.frame(nf,nfl,nw,nr,af,aw,ar)
    return(ret)
}

### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N & Ca
LUE <- function(df, co2, LUE0, Nref) {
    
    CaResp <- 1.632 * (co2-60.9) / (co2+121.8)    ##RCO2
    Nresp <- min(df/Nref, 1)                      ##Rate-limiting effect of low N
    
    return(LUE0 * CaResp * Nresp)
}

### NPP as function of nf and LAI (which is calculated from NPP)
eqNC <- function(df, NPP, co2, LUE0, Nref, I0, kext, SLA, af, sf, cfrac, CUE) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(df, co2, LUE0, Nref) * I0 * (1 - exp(-kext*SLA*af*NPP/sf/cfrac)) * CUE)
    
}

### This function implements photosynthetic constraint - solve by finding the root
solveNC <- function(nf, af, co2=350,
                    LUE0=2.8, I0=3, Nref=0.04, 
                    kext=0.5, SLA=5, sf=0.5, w = 0.45, cue = 0.5) {
    # parameters
    # nf is variable
    # making it pass af (fractional allocation to foliage) because this may also be variable
    # co2 = co2 concentration 
    # LUE0 = maximum gross LUE in kg C GJ-1
    # I0 = total incident radiation in GJ m-2 yr-1
    # Nref = leaf N:C for saturation of photosynthesis
    # kext = light extinction coeffciency
    # SLA = specific leaf area in m2 kg-1 DM
    # sf = turnover rate of foliage in yr-1
    # w = C content of biomass - needed to convert SLA from DM to C
    # cue = carbon use efficiency
    
    # solve implicit equation
    ans <- c()
    len <- length(nf)
    for (i in 1:len) {
        fPC <- function(NPP) eqNC(nf[i], NPP, co2, LUE0, Nref, I0, kext, SLA, af[i], sf, w, cue) - NPP
        ans[i] <- uniroot(fPC,interval=c(0.1,20), trace=T)$root
    }
    return(ans)
}