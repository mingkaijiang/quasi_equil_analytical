### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent
eqNC <- function(nf, NPP, CO2, af) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(nf, CO2) * I0 * (1 - exp(-kext*SLA*af*NPP/sf/cfrac)) * cue)
    
}


### NPP as function of nf and LAI (which is calculated from NPP),
### Autotrophic respiration as a function of plant tissue N content
eqNC_respiration <- function(df, NPP, co2, LUE0, Nref, I0, kext, SLA, ADF, sf, cfrac) {
    
    Ra <- Compute_Ra(a=ADF, NPP=NPP)
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(df, co2, LUE0, Nref) * I0 * (1 - exp(-kext*SLA*ADF$af*NPP/sf/cfrac)) - Ra)
    
}


### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent
eqPC <- function(nf, pf, pfdf, NPP, CO2) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE_np(nf, pf, CO2) * I0 * (1 - exp(-kext*SLA*pfdf*NPP/sf/cfrac)) * cue)
    
}

### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent and based on the full model
eqPC_full_cnp <- function(nf, pf, pfdf, NPP, CO2) {
    
    lue_yr <- LUE_full_cnp(nf, pfdf, pf, CO2, NPP*1000.0) * par * conv 
        
    ##Returns G: total C production (i.e. NPP)
    return( lue_yr * (1 - exp(-kext*SLA*pfdf$af*NPP/sf/cfrac)) * cue)
    
}

### NPP as function of nf, pf and LAI (which is calculated from NPP),
### Autotrophic respiration as a function of plant tissue N content
eqPC_respiration <- function(nf, pf, nfdf, pfdf, NPP, CO2) {
    
    Ra <- Compute_Ra(a=nfdf, NPP=NPP)
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE_np(nf, pf, CO2) * I0 * (1 - exp(-kext*SLA*pfdf$af*NPP/sf/cfrac)) - Ra)
    
}