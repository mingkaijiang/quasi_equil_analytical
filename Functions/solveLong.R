# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLong <- function(CO2,Cpass,NinL, PinL, nwvar, pwvar) {
    fn <- function(nf) {
        photo_constraint(nf, inferpfVL(nf, allocn(nf, nwvar=nwvar)), 
                         allocn(nf,nwvar=nwvar), 
                         allocp(inferpfVL(nf, allocn(nf, nwvar=nwvar)), pwvar=pwvar), 
                         CO2) - Long_constraint_N(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf, nwvar=nwvar))
    equilNPP <- photo_constraint(equilnf, equilpf, 
                                 allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}

# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLong_full_cnp <- function(CO2,Cpass,NinL, PinL, nwvar, pwvar) {
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, inferpfVL(nf, allocn(nf, nwvar=nwvar)), 
                                  allocn(nf,nwvar=nwvar), 
                                  allocp(inferpfVL(nf, allocn(nf, nwvar=nwvar)), pwvar=pwvar), 
                                  CO2) - Long_constraint_N(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf, nwvar=nwvar))
    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf, 
                                          allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}

# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLong_full_cnp_fix_wood <- function(CO2,Cpass,NinL, PinL, nwvar, pwvar) {
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, inferpfVL(nf, allocn(nf, nwvar=nwvar)), 
                                  allocn(nf,nwvar=nwvar), 
                                  allocp(inferpfVL(nf, allocn(nf, nwvar=nwvar)), pwvar=pwvar), 
                                  CO2) - Long_constraint_N(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.001,0.041))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf, nwvar=nwvar))
    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf, 
                                          allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}

# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLong_full_cn <- function(CO2,Cpass,NinL, nwvar) {
    fn <- function(nf) {
        photo_constraint_full_cn(nf, allocn(nf,nwvar=nwvar), 
                                 CO2) - Long_constraint_N(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP <- photo_constraint_full_cn(equilnf, 
                                          allocn(equilnf, nwvar), CO2)
    equilpf <- "NA"
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}