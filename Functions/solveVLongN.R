# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLongN <- function(CO2, nwvar) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf)$af,CO2) - NConsVLong(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP_N <- solveNC(equilnf,af=allocn(equilnf)$af, CO2)

    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}
