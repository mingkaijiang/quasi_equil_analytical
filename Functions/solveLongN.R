# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLongN <- function(co2=350,Cpass,Nin) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf)$af,co2=co2) - NConsLong(nf,allocn(nf),Cpass=Cpass,Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP <- solveNC(equilnf,af=allocn(equilnf)$af, co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}