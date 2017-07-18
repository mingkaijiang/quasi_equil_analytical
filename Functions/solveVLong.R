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
solveVLong_respiration <- function(CO2, nwvar, pwvar) {
    fn <- function(nf) {
        photo_constraint_respiration(nf, inferpfVL(nf, allocn(nf, nwvar)), 
                                  allocn(nf, nwvar),allocp(inferpfVL(nf, allocn(nf, nwvar)), pwvar), 
                                  CO2) - VLong_constraint_N(nf,allocn(nf, nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.001,0.041))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf, nwvar))
    equilNPP <- photo_constraint_respiration(equilnf, equilpf, 
                                          allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
    
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}
