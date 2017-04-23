# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLongN <- function(co2=350, nwvar=TRUE) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf, nwvar=nwvar)$af,co2=co2) - NConsVLong(nf,allocn(nf, nwvar=nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP_N <- solveNC(equilnf,af=allocn(equilnf, nwvar=nwvar)$af, co2=co2)

    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
# respiration specific function
solveVLongN_respiration <- function(co2=350, nwvar=TRUE, nw = 0.0005) {
    fn <- function(nf) {
        solveNC_respiration(nf,allocn(nf, nwvar=nwvar, nwood = nw),co2=co2) - NConsVLong(nf,allocn(nf, nwvar=nwvar, nwood = nw))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP_N <- solveNC_respiration(equilnf,adf=allocn(equilnf, nwvar=nwvar, nwood = nw), co2=co2)
    
    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for explicit mineral pools
solveVLongN_expl_min <- function(co2=350, nwvar=TRUE) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf, nwvar=nwvar)$af,co2=co2) - NConsVLong_expl_min(nf,allocn(nf, nwvar=nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP_N <- solveNC(equilnf,af=allocn(equilnf, nwvar=nwvar)$af, co2=co2)
    
    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for nuptake ~ root biomass  - O-CN approach
# i.e. N uptake as a saturating function of mineral N
solveVLongN_root_ocn <- function(co2=350, nwvar=TRUE) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf, nwvar=nwvar)$af,co2=co2) - NConsVLong_root_ocn(nf,allocn(nf, nwvar=nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP_N <- solveNC(equilnf,af=allocn(equilnf, nwvar=nwvar)$af, co2=co2)
    
    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for nuptake ~ root biomass - GDAY approach
# i.e. N uptake as a saturating function of root biomass
solveVLongN_root_gday <- function(co2=350, nwvar=TRUE) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf, nwvar=nwvar)$af,co2=co2) - NConsVLong_root_gday(nf,allocn(nf, nwvar=nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP_N <- solveNC(equilnf,af=allocn(equilnf, nwvar=nwvar)$af, co2=co2)
    
    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}

