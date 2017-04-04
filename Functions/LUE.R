### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N & Ca
LUE <- function(df, co2, LUE0, Nref) {
    
    CaResp <- 1.632 * (co2-60.9) / (co2+121.8)    ##RCO2
    Nresp <- min(df/Nref, 1)                      ##Rate-limiting effect of low N
    
    return(LUE0 * CaResp * Nresp)
}