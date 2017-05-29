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
    
    PAR_MJ <- 2.0
    J_2_UMOL <- 4.57
    MJ_TO_J <- 1000000.0
    par <- MJ_TO_J * J_2_UMOL * PAR_MJ
    UMOL_TO_MOL <- 0.000001
    MOL_C_TO_GRAMS_C <- 12.0
    conv <- UMOL_TO_MOL * MOL_C_TO_GRAMS_C
    
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