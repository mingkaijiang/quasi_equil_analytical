### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N, P & Ca
LUE <- function(nf, pf, CO2) {
    
    CaResp <- 1.632 * (CO2-60.9) / (CO2+121.8)    ##RCO2
    # Nresp <- min(df/Nref, 1)                      ##Rate-limiting effect of low N
    
    assim <- 16.848 + 178.664 * nf + 1418.722 * pf
    assim_max <- 16.848 + 178.664 * 0.1 + 1418.722 * 0.004
    
    Nresp <- assim/assim_max
    
    return(LUE0 * CaResp * Nresp)
}