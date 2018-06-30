
# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solve_L_full_cnp <- function(CO2,Cpass,NinL,PinL) {
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, infer_pf_L(nf, allocn(nf), PinL=PinL,
                                                 NinL=NinL,Cpass=Cpass), 
                                  allocn(nf), 
                                  allocp(infer_pf_L(nf, allocn(nf), PinL=PinL,
                                                    NinL=NinL,Cpass=Cpass)), 
                                  CO2) - L_constraint_N(nf,allocn(nf),
                                                        Cpass=Cpass,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.001,0.1))$root
    equilpf <- infer_pf_L(equilnf, allocn(equilnf),PinL=PinL,
                           NinL=NinL,Cpass=Cpass)
    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf, 
                                          allocn(equilnf), allocp(equilpf), CO2)
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}
