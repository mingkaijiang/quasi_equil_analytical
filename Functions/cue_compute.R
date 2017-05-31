### Compute CUE at various timesteps
cue_compute <- function(nf, pf, nfdf, pfdf, NPP, CO2) {
    
    lue_yr <-  LUE_full_cnp(nf, pfdf, pf, CO2, NPP*1000.0) * par * conv 
    
    Ra <- Compute_Rdark(nfdf, pfdf, NPP*1000.0)
    
    gpp <- lue_yr * (1 - exp(-kext*SLA*nfdf$af*NPP/sf/cfrac))
    
    ##Returns G: total C production (i.e. NPP)
    return((gpp - Ra)/gpp)
    
}