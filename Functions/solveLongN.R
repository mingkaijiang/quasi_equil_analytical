# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLongN <- function(co2=350,Cpass,Nin, nwvar=T) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf,nwvar=nwvar)$af,co2=co2) - NConsLong(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP <- solveNC(equilnf,af=allocn(equilnf,nwvar=nwvar)$af, co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}

# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
# Specifically for respiration related calculations
solveLongN_respiration <- function(co2=350,Cpass,Nin, nwvar=T) {
    fn <- function(nf) {
        solveNC_respiration(nf,allocn(nf,nwvar=nwvar),co2=co2) - NConsLong(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP <- solveNC_respiration(equilnf,adf=allocn(equilnf,nwvar=nwvar), co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}