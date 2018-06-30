# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solve_VL_full_cnp <- function(CO2) {
    fn <- function(nf) {
        photo_constraint_full_cnp(nf, infer_pf_VL(nf, allocn(nf)), 
                                  allocn(nf),allocp(infer_pf_VL(nf, allocn(nf))), 
                                  CO2) - VL_constraint_N(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.001,0.1))$root
    equilpf <- infer_pf_VL(equilnf, allocn(equilnf))
    equilNPP <- photo_constraint_full_cnp(equilnf, equilpf, 
                                          allocn(equilnf), allocp(equilpf), CO2)
    
    ans <- data.frame(equilnf, equilpf, equilNPP)
    return(ans)
}