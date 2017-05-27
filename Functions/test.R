### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N & Ca
LUE <- function(nf, pf, CO2) {
    
    CaResp <- 1.632 * (CO2-60.9) / (CO2+121.8)    ##RCO2
    # Nresp <- min(df/Nref, 1)                      ##Rate-limiting effect of low N
    
    assim <- 16.848 + 178.664 * nf + 1418.722 * pf
    assim_max <- 16.848 + 178.664 * 0.1 + 1418.722 * 0.004
    
    Nresp <- assim/assim_max
    
    return(LUE0 * CaResp * Nresp)
}

### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent
eqPC <- function(nf, pf, pfdf, NPP, CO2) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(nf, pf, CO2) * I0 * (1 - exp(-kext*SLA*pfdf*NPP/sf/cfrac)) * cue)
    
}

### This function implements photosynthetic constraint - solve by finding the root
photo_constraint <- function(nf, pf, nfdf, pfdf, CO2) {
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
    
    len <- length(nf)
    
    ans <- matrix(ncol=len, nrow=len)
    
    for (i in 1:len) {
        nf_sub <- nf[i]
        for (j in 1:len) {
            fPC <- function(NPP) eqPC(nf_sub, pf[j], pfdf$af[j], NPP, CO2) - NPP
            ans[i,j] <- uniroot(fPC,interval=c(0.1,20), trace=T)$root
        }
    }
    
    return(ans)
}

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
solveVLongN <- function(CO2, nwvar) {
    fn <- function(nf) {
        photo_constraint(nf, pf, allocn(nf, nwvar),allocp(pf, pwvar), CO2) - VLong_constraint_N(nf,allocn(nf, nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP_N <- solvePC(equilnf,af=allocn(equilnf, nwvar=nwvar)$af, CO2)
    
    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}
