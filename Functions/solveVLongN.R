# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLongN <- function(co2=350, nwvar=nwvar) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf)$af,co2=co2) - NConsVLong(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP_N <- solveNC(equilnf,af=allocn(equilnf)$af, co2=co2, nwvar=nwvar)
    
    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}
