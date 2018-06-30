### NPP as function of nf and LAI (which is calculated from NPP)
### basic function: CUE dependent and based on the full model
eqPC_full_cnp <- function(nf, pf, pfdf, NPP, CO2) {
    
    # in umol C m-2 d-1
    lue_yr <- LUE_full_cnp_walker(nf, pfdf, pf, CO2, NPP*1000.0) * par 
    
    # return gpp as kg m-2 yr-1
    gpp <- lue_yr * (1 - exp(-kext*SLA*pfdf$af*NPP/sf/cfrac)) * conv * 365 / 1000.0
    
    #browser()
    ##Returns G: total C production (i.e. NPP)
    return( gpp * cue)
    
}
