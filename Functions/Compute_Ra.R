#### To compute autotrophic respiration
Compute_Ra <- function(a, a1=0.753, b1=1.411, a2=1.053, b2=1.315,
                       a3=0.915, b3=1.597, sf=0.5, ss = 0.01, sr = 1.5, NPP) {
    
    # parameters
    # a is variable
    # a1 = intercept for Rleaf and Leaf N;
    # b1 = exponent for Rleaf and Leaf N;
    # a2 = intercept for Rstem and Stem N;
    # b2 = exponent for Rstem and Stem N;
    # a3 = intercept for Rroot and Root N;
    # b3 = exponent for Rroot and Root N;
    # rleaf: leaf respiration, kg m-2 yr-1
    # rstem: stem respiration, kg m-2 yr-1
    # rroot: root respiration, kg m-2 yr-1
    # conv: unit conversion for MOL_N_TO_GRAMS_N * MOL_2_MMOL;
    # sf: leaf turnover time yr-1
    # ss: stem turnover time yr-1
    # sr: root turnover time yr-1
    
    ## Set unit conversion factor;
    MOL_N_TO_GRAMS_N  <- 14.0
    MOL_2_MMOL <- 1000.0
    
    ## Use shoot and root nc ratio to obtain mmol [N] g-1
    leafn <- a$nf / MOL_N_TO_GRAMS_N * MOL_2_MMOL
    stemn <- a$nw / MOL_N_TO_GRAMS_N * MOL_2_MMOL
    rootn <- a$nr / MOL_N_TO_GRAMS_N * MOL_2_MMOL
    
    ## calculate dark respiration for leaf, stem and root, (nmol g-1 s-1)
    respl <- a1 * (leafn^b1)
    resps <- a2 * (stemn^b2)
    respr <- a3 * (rootn^b3)
    
    ## unit conversion - per kg C allocated to leaf, stem and root (nmol m-2 s-1)
    respl <- respl * (NPP * 1000.0 * a$af / sf) # need to multiple by biomass, not npp
    resps <- resps * (NPP * 1000.0 * a$aw / ss)
    respr <- respr * (NPP * 1000.0 * a$ar / sr)
    
    ## unit conversion, to kg C m-2 yr-1
    rleaf <- respl * 3600.0 * 24.0 * 365.0 * 10^-9 * 0.012
    rstem <- resps * 3600.0 * 24.0 * 365.0 * 10^-9 * 0.012
    rroot <- respr * 3600.0 * 24.0 * 365.0 * 10^-9 * 0.012
    
    ## Compute autotrophic respiration
    r_autotrophic <- rleaf + rstem + rroot
    
    return(r_autotrophic)
    
    
}


