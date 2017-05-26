### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent
eqNC <- function(nf, pf, NPP, co2, LUE0, Nref, I0, kext, SLA, af, sf, cfrac, CUE) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(nf, pf, co2, LUE0, Nref) * I0 * (1 - exp(-kext*SLA*af*NPP/sf/cfrac)) * CUE)
    
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
eqPC <- function(df, NPP, co2, LUE0, Nref, I0, kext, SLA, af, sf, cfrac) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(df, co2, LUE0, Nref) * I0 * (1 - exp(-kext*SLA*af*NPP/sf/cfrac)))
    
}