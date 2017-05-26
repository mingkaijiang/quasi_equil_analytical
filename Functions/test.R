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



