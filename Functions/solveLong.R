# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLong <- function(CO2,Cpass,NinL, PinL, nwvar, pwvar) {
    fn <- function(nf) {
        photo_constraint(nf, inferpfL(nf, allocn(nf, nwvar=nwvar), PinL = PinL,
                                      NinL = NinL, Cpass=Cpass, nwvar=nwvar, pwvar=pwvar), 
                         allocn(nf,nwvar=nwvar), 
                         allocp(inferpfL(nf, allocn(nf, nwvar=nwvar), PinL = PinL,
                                         NinL = NinL, Cpass=Cpass, nwvar=nwvar, pwvar=pwvar), pwvar=pwvar), 
                         CO2) - Long_constraint_N(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.001,0.05))$root
    equilpf <- inferpfL(equilnf, allocn(equilnf, nwvar=nwvar), PinL = PinL,
                        NinL = NinL, Cpass=Cpass, nwvar=nwvar, pwvar=pwvar)
    equilNPP <- photo_constraint(equilnf, equilpf, 
                                 allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}

# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
#solveLong <- function(CO2,Cpass,NinL, PinL, nwvar, pwvar) {
#    fn <- function(nf) {
#        photo_constraint(nf, inferpfL(nf, allocn(nf, nwvar=nwvar), PinL = PinL,
#                                       NinL = NinL, Cpass=Cpass, nwvar=nwvar, pwvar=pwvar), 
#                         allocn(nf,nwvar=nwvar), 
#                         allocp(inferpfL(nf, allocn(nf, nwvar=nwvar), PinL = PinL,
#                                         NinL = NinL, Cpass=Cpass, nwvar=nwvar, pwvar=pwvar), pwvar=pwvar), 
#                         CO2) - Long_constraint_N(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,NinL)$NPP
#    }
#    equilnf <- uniroot(fn,interval=c(0.001,0.05))$root
#    equilpf <- inferpfL(equilnf, allocn(equilnf, nwvar=nwvar), PinL = PinL,
#                        NinL = NinL, Cpass=Cpass, nwvar=nwvar, pwvar=pwvar)
#    equilNPP <- photo_constraint(equilnf, equilpf, 
#                                 allocn(equilnf, nwvar), allocp(equilpf, pwvar), CO2)
#    ans <- data.frame(equilnf, equilpf, equilNPP)
#    return(ans)
#}