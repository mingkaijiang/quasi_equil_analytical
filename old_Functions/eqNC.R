### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent
eqNC <- function(nf, NPP, CO2, af) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(nf, CO2) * I0 * (1 - exp(-kext*SLA*af*NPP/sf/cfrac)) * cue)
    
}


### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent
eqPC <- function(nf, pf, pfdf, NPP, CO2) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(nf, CO2) * I0 * (1 - exp(-kext*SLA*pfdf*NPP/sf/cfrac)) * cue)
    
}


### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent and based on the full model
eqPC_simple_cnp <- function(nf, pf, pfdf, NPP, CO2) {
    
    # in umol C m-2 d-1
    #lue_yr <- exp((-3.85 + -1.25 * log(nf) - 0.15 * log(nf) * log(pf))) * par
    lue_yr <- exp(-5.06 + 0.21 * log(CO2) - 1.24 * log(nf) - 0.15 * log(nf) * log(pf)) * par
    # return gpp as kg m-2 yr-1
    gpp <- lue_yr * (1 - exp(-kext*SLA*pfdf$af*NPP/sf/cfrac)) * conv * 365 / 1000.0
    
    #browser()
    ##Returns G: total C production (i.e. NPP)
    return( gpp * cue)
    
}

### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent and based on the full model
### for cn model only
eqPC_simple_cn <- function(nf, nfdf, NPP, CO2) {
    
    # in umol C m-2 d-1
    # lue_yr <- exp((-2.76 + 0.09 * log(nf))) * par
    lue_yr <- exp(-4.23 + 0.25 * log(CO2) + 0.08 * log(nf)) * par
        
    # return gpp as kg m-2 yr-1
    gpp <- lue_yr * (1 - exp(-kext*SLA*nfdf$af*NPP/sf/cfrac)) * conv * 365 / 1000.0
    
    ##Returns G: total C production (i.e. NPP)
    return( gpp * cue)
    
}