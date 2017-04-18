### This function implements photosynthetic constraint - solve by finding the root
solveNC <- function(nf, af, co2=350,
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
        fPC <- function(NPP) eqNC(nf[i], NPP, co2, LUE0, Nref, I0, kext, SLA, af[i], sf, w, cue) - NPP
        #ans[i] <- tryCatch(uniroot(fPC,interval=c(0.1,20), trace=T)$root, error=function(e) NULL)
        ans[i] <- uniroot(fPC,interval=c(0.1,20), trace=T)$root
    }
    return(ans)
}

### This function implements photosynthetic constraint - solve by finding the root
solveNC_respiration <- function(nf, adf, co2=350,
                                LUE0=1.4, I0=3, Nref=0.04, 
                                kext=0.5, SLA=5, sf=0.5, w = 0.45) {
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
        fPC <- function(NPP) eqNC_respiration(nf[i], NPP, co2, LUE0, Nref, I0, kext, SLA, adf[i,], sf, w) - NPP
        ans[i] <- uniroot(fPC,interval=c(0.1,20), trace=T)$root
    }
    return(ans)
}

### This function also implements photosynthetic constraint - solving by iteration
### Shown below that this gives same solution as finding root
solveNCiter_respiration <- function(nf, adf, co2=350,
                                    LUE0=1.4, I0=3, Nref=0.04, 
                                    kext=0.5, SLA=5, sf=0.5, w = 0.45, tol=0.01) {
    # parameters
    # nf is passed to the function
    # making it pass af (fractional allocation to foliage) because this may also be variable
    # co2 = co2 concentration 
    # LUE0 = maximum LUE in kg GJ-1
    # I0 = total incident radiation in GJ m-2 yr-1
    # Nref = leaf N:C for saturation of photosynthesis
    # kext = light extinction coeffciency
    # SLA = specific leaf area in m2 kg-1
    # sf = turnover rate of foliage in yr-1
    # w = C content of biomass
    
    ans <- c()
    len <- length(nf)
    oldNPP <- 1      # initial guess for NPP, in kg C m-2 yr-1
    # loop over supplied N concentrations
    for (i in 1:len) {
        repeat {
            newNPP <- eqNC_respiration(nf[i], oldNPP, co2, LUE0, Nref, I0, kext, SLA, adf[i,], sf, w)
            #print(newNPP)
            if (abs(newNPP - oldNPP) < tol) break
            oldNPP <- newNPP
        }
        ans[i] <- newNPP
    }
    return(ans)
}
