### NPP as function of nf and LAI (which is calculated from NPP)
eqNC <- function(df, NPP, co2, LUE0, Nref, I0, kext, SLA, af, sf, cfrac, CUE) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(df, co2, LUE0, Nref) * I0 * (1 - exp(-kext*SLA*af*NPP/sf/cfrac)) * CUE)
    
}
