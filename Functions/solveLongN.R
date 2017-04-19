# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLongN <- function(co2=350,Cpass,Nin, nwvar=T) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf,nwvar=nwvar)$af,co2=co2) - NConsLong(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP <- solveNC(equilnf,af=allocn(equilnf,nwvar=nwvar)$af, co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}

# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
# Specifically for respiration related calculations
solveLongN_respiration <- function(co2=350,Cpass,Nin, nwvar=T, nw=0.0005) {
    fn <- function(nf) {
        solveNC_respiration(nf,allocn(nf,nwvar=nwvar, nwood = nw),co2=co2) - NConsLong(nf,allocn(nf,nwvar=nwvar, nwood = nw),Cpass=Cpass,Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP <- solveNC_respiration(equilnf,adf=allocn(equilnf,nwvar=nwvar, nwood = nw), co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}

# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
# specifically for CWD related calculuations
solveLongN_CWD <- function(co2=350,Cpass,Nin, nwvar=T) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf,nwvar=nwvar)$af,co2=co2) - NConsLong_CWD(nf,allocn(nf,nwvar=nwvar),Cpass=Cpass,Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.01,0.05))$root
    equilNPP <- solveNC(equilnf,af=allocn(equilnf,nwvar=nwvar)$af, co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}