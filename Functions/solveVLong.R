# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong <- function(CO2) {
    fn <- function(nf) {
        photo_constraint(nf, inferpfVL(nf, allocn(nf)), 
                         allocn(nf),allocp(inferpfVL(nf, allocn(nf))), 
                         CO2) - VLong_constraint_N(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.1))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf))
    equilNPP <- photo_constraint(equilnf, equilpf, 
                                 allocn(equilnf), allocp(equilpf), CO2)
    
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}


# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong_full_cnp <- function(CO2) {
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, inferpfVL(nf, allocn(nf)), 
                                  allocn(nf),allocp(inferpfVL(nf, allocn(nf))), 
                                  CO2) - VLong_constraint_N(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.1))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf))
    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf, 
                                          allocn(equilnf), allocp(equilpf), CO2)
    
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for explicit mineral pools
solveVLong_expl_min <- function(CO2) {
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, inferpfVL_expl_min(nf, allocn(nf)), 
                                  allocn(nf),allocp(inferpfVL_expl_min(nf, allocn(nf))), 
                                  CO2) - NConsVLong_expl_min(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.1))$root
    equilpf <- inferpfVL_expl_min(equilnf, allocn(equilnf))
    equilNPP_N <- photo_constraint_full_cnp(equilnf, equilpf, 
                                            allocn(equilnf), allocp(equilpf), CO2)
    
    ans <- data.frame(equilnf,equilpf,equilNPP_N)
    return(ans)
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong_full_cnp_fix_wood <- function(CO2) {
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, inferpfVL(nf, allocn(nf)), 
                                  allocn(nf),allocp(inferpfVL(nf, allocn(nf))), 
                                  CO2) - VLong_constraint_N(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.1))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf))
    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf, 
                                          allocn(equilnf), allocp(equilpf), CO2)
    
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong_full_cn <- function(CO2) {
    fn <- function(nf) {
        photo_constraint_full_cn(nf, allocn(nf),CO2) - VLong_constraint_N(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.1))$root
    equilNPP <- photo_constraint_full_cn(equilnf, allocn(equilnf), CO2)
    equilpf <- "NA"
    ans <- data.frame(equilnf, "NA", equilNPP)
    return(ans)
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong_respiration <- function(CO2) {
    fn <- function(nf) {
        photo_constraint_respiration(nf, inferpfVL(nf, allocn(nf)), 
                                     allocn(nf),allocp(inferpfVL(nf, allocn(nf))), 
                                     CO2) - VLong_constraint_N(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.04))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf))
    equilNPP <- photo_constraint_respiration(equilnf, equilpf, 
                                          allocn(equilnf), allocp(equilpf), CO2)
    
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}

# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for nuptake ~ root biomass  - O-CN approach
# i.e. N uptake as a saturating function of mineral N
solveVLong_root_ocn <- function(co2=350) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf,nwvar=nwvar)$af,co2=co2) - NConsVLong_root_ocn(nf,allocn(nf,nwvar=nwvar),Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP <- solveNC(equilnf,af=allocn(equilnf,nwvar=nwvar)$af, co2=co2)
    ans <- data.frame(equilnf,equilpf,equilNPP)
    return(ans)
}


# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for nuptake ~ root biomass  - O-CN approach
# i.e. N uptake as a saturating function of mineral N
solveVLong_root_gday <- function(CO2) {
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, inferpfVL_root_gday(nf, allocn(nf)), 
                                  allocn(nf),allocp(inferpfVL_root_gday(nf, allocn(nf))), 
                                  CO2) - NConsVLong_root_gday(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.1))$root
    equilpf <- inferpfVL_root_gday(equilnf, allocn(equilnf))
    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf, 
                                            allocn(equilnf), allocp(equilpf), CO2)
    
    ans <- data.frame(equilnf,equilpf,equilNPP)
    return(ans)
}