# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong <- function(CO2, nwvar, pwvar) {
    fn <- function(nf) {
        photo_constraint(nf, inferpfVL(nf, allocn(nf, nwvar)), 
                         allocn(nf, nwvar),allocp(inferpfVL(nf, allocn(nf, nwvar)), pwvar), 
                         CO2) - VLong_constraint_N(nf,allocn(nf, nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf, nwvar))
    equilNPP <- photo_constraint(equilnf, equilpf, 
                                 allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
    
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}


# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong_full_cnp <- function(CO2, nwvar, pwvar) {
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, inferpfVL(nf, allocn(nf, nwvar)), 
                                  allocn(nf, nwvar),allocp(inferpfVL(nf, allocn(nf, nwvar)), pwvar), 
                                  CO2) - VLong_constraint_N(nf,allocn(nf, nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf, nwvar))
    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf, 
                                          allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
    
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong_full_cn <- function(CO2, nwvar) {
    fn <- function(nf) {
        photo_constraint_full_cn(nf, allocn(nf, nwvar),CO2) - VLong_constraint_N(nf,allocn(nf, nwvar))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP <- photo_constraint_full_cn(equilnf, allocn(equilnf, nwvar), CO2)
    equilpf <- "NA"
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}