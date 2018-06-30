# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solve_L_full_cn <- function(CO2,Cpass,NinL) {
    fn <- function(nf) {
        photo_constraint_full_cn(nf, allocn(nf), 
                                 CO2) - L_constraint_N(nf,allocn(nf),Cpass=Cpass,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.001,0.1))$root
    equilNPP <- photo_constraint_full_cn(equilnf, 
                                         allocn(equilnf), CO2)

    ans <- data.frame(equilnf, equilNPP)
    return(ans)
}
