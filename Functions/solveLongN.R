# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLongN <- function(CO2,Cpass,NinL) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf)$af,CO2) - NConsLong(nf,allocn(nf),Cpass=Cpass,NinL)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP <- solveNC(equilnf,af=allocn(equilnf)$af, CO2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}

