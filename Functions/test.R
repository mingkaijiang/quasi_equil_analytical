### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N & Ca
LUE <- function(nf, pf, co2, LUE0, Nref) {
    
    CaResp <- 1.632 * (co2-60.9) / (co2+121.8)    ##RCO2
    # Nresp <- min(df/Nref, 1)                      ##Rate-limiting effect of low N
    
    assim <- 16.848 + 178.664 * nf + 1418.722 * pf
    assim_max <- 16.848 + 178.664 * 0.1 + 1418.722 * 0.004
    
    Nresp <- assim/assim_max
    
    return(LUE0 * CaResp * Nresp)
}

### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent
eqNC <- function(nf, pf, NPP, co2, LUE0, Nref, I0, kext, SLA, af, sf, cfrac, CUE) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(nf, pf, co2, LUE0, Nref) * I0 * (1 - exp(-kext*SLA*af*NPP/sf/cfrac)) * CUE)
    
}

### This function implements photosynthetic constraint - solve by finding the root
solveNC <- function(nf, pf, af, co2=350,
                    LUE0=1.4, I0=3, Nref=0.04, 
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
        fPC <- function(NPP) eqNC(nf[i], pf[i], NPP, co2, LUE0, Nref, I0, kext, SLA, af[i], sf, w, cue) - NPP
        #ans[i] <- tryCatch(uniroot(fPC,interval=c(0.1,20), trace=T)$root, error=function(e) NULL)
        ans[i] <- uniroot(fPC,interval=c(0.1,20), trace=T)$root
    }
    return(ans)
}