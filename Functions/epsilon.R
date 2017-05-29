epsilon <- function(asat, par, alpha, daylen) {
    # Canopy scale LUE using method from Sands 1995, 1996;
    # Parameters
    # ----------
    # asat: light-saturated photosynthetic rate at the top of the canopy
    # par: photosynthetically active radiation (umol m-2 d-1)
    # theta: curvature of photosynthetic light response curve
    # alpha: quantum yield of photosynthesis (mol mol-1)
    # Returns:
    # --------
    # LUE: integrated light use efficiency over the canopy (umol C umol -1 PAR)
    
    # asat should be modified by the factor (0-1) of leaf N and Leaf P

    lue = asat * leafn * leafp
    
    return (lue)
}