

### This function implements photosynthetic constraint - solve by finding the root
### Based on the full photosynthesis model for c and n only
photo_constraint_full_cn <- function(nf, nfdf, CO2) {

    len <- length(nf)
    
    ans <- c()
    
    for (i in 1:len) {
        fPC <- function(NPP) eqPC_full_cn(nf[i], nfdf[i,], NPP, CO2) - NPP
        ans[i] <- uniroot(fPC,interval=c(0.1,20), trace=T)$root
    }
    
    return(ans)
}