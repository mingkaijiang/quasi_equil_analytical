# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solve_VL_full_cn <- function(CO2) {
    fn <- function(nf) {
        photo_constraint_full_cn(nf, allocn(nf),CO2) - VL_constraint_N(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.001,0.1))$root
    equilNPP <- photo_constraint_full_cn(equilnf, allocn(equilnf), CO2)
    equilpf <- "NA"
    ans <- data.frame(equilnf, "NA", equilNPP)
    return(ans)
}
