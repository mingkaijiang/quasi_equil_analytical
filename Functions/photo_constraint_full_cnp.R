### This function implements photosynthetic constraint - solve by finding the root
### Based on the full photosynthesis model
photo_constraint_full_cnp <- function(nf, pf, nfdf, pfdf, CO2) {
    
    len <- length(nf)
    
    ans <- c()
    
    for (i in 1:len) {
        fPC <- function(NPP) eqPC_full_cnp(nf[i], pf[i], pfdf[i,], NPP, CO2) - NPP
        ans[i] <- uniroot(fPC,interval=c(0.1,20), trace=T)$root
        
    }
    
    return(ans)
}
