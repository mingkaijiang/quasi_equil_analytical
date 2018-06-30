# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
equilpL <- function(equildf, Cpass=CpassVLong) {
    
    ar <- aroot
    af <- aleaf
    aw <- 1 - ar - af
    
    df <- equildf[1,1]
    equilNPP <- equildf[1,2]
    
    # passive pool burial 
    pass <- passive(df, allocn(df), Tsoil, Texture, ligfl, ligrl)
    omegap <- allocn(df)$af*pass$omegaf + allocn(df)$ar*pass$omegar 
    
    # prepare very long term nitrogen fluxes
    U0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omegap*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Convert NPP unit
    NPP_PC <- equilNPP*10^3     # convert to g C m-2 yr-1
    
    # Calculate equilnf, based on equilNPP_P
    Y1 <- U0/NPP_PC - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach+pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilnf  
    return(pf)
}
