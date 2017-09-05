
# Find the medium term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for exudation model, without considering exudation
solveMedium <- function(CO2,Cpass,Cslow,NinL) {
    fn <- function(nf) {
        photo_constraint_full_cn(nf, allocn(nf),
                                 CO2) - NConsMedium(nf,allocn(nf),Cpass,Cslow,NinL)$NPP
        
    }
    equilnf <- uniroot(fn,interval=c(0.001,0.1))$root
    equilNPP <- photo_constraint_full_cn(equilnf, 
                                         allocn(equilnf), CO2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}


# Find the medium term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for exudation model, turning exudation on
solveMedium_exudation <- function(CO2,Cpass,Cslow,NinL) {
    fn <- function(nf) {
        photo_constraint_full_cn(nf, allocn_exudation(nf),
                                 CO2) - NConsMedium_exudation(nf,allocn_exudation(nf),Cpass,Cslow,NinL)$NPP
        
    }
    equilnf <- uniroot(fn,interval=c(0.004,0.1))$root
    equilNPP <- photo_constraint_full_cn(equilnf, 
                                         allocn_exudation(equilnf), CO2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}

# Find the medium term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for exudation model, without considering exudation
#solveMedium_full_cnp <- function(CO2,Cpass,Cslow,NinL,PinL) {
#    
#    #browser()
#    fn <- function(nf) {
#        photo_constraint_full_cnp(nf, inferpfM(nf, allocn(nf), PinL, NinL,
#                                               Cpass, Cslow), allocn(nf), 
#                                  allocp(inferpfM(nf, allocn(nf), PinL, NinL,Cpass, Cslow)), CO2) - NConsMedium(nf,allocn(nf),Cpass,Cslow,NinL)$NPP
#    }
#    equilnf <- uniroot(fn,interval=c(0.01,0.1))$root
#    equilpf <- inferpfM(equilnf, allocn(equilnf), PinL, NinL, Cpass, Cslow)
#    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf,
#                                         allocn(equilnf), allocp(equilpf), CO2)
#    ans <- data.frame(equilnf,equilpf,equilNPP)
#    return(ans)
#}

solveMedium_full_cnp <- function(CO2,Cpass,Cslow,NinL,PinL) {
    
    #browser()
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, inferpfVL(nf, allocn(nf)), 
                                  allocn(nf), allocp(inferpfVL(nf, allocn(nf))), 
                                  CO2) - NConsMedium(nf,allocn(nf),Cpass,Cslow,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.1))$root
    equilpf <- inferpfVL(equilnf, allocn(equilnf))
    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf,
                                          allocn(equilnf), allocp(equilpf), CO2)
    ans <- data.frame(equilnf,equilpf,equilNPP)
    return(ans)
}
