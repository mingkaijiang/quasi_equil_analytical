### Allocation and plant P concentrations - required for both PS constraint and PC constraint
allocp <- function(pf, pwvar) {
    # parameters
    # pf is the PC ratio of foliage
    # pw is the PC ratio of wood if fixed; otherwise the ratio of wood P:C to foliage P:C
    # pwvar is whether or not to allow wood PC to vary
    # prho is the ratio of root P:C to foliage P:C
    # pretrans is the fraction of foliage P:C retranslocated  
    
    len <- length(pf)
    ar <- af <- aw <- pw <- pr <- rep(0,len)  # initialise
    for (i in 1:len) {
        ar[i] <- 0.15
        af[i] <- 0.15
        aw[i] <- 1 - ar[i] - af[i]
    }
    
    # P concentrations of rest of plant   # in g P g-1 C
    if (pwvar == FALSE) {
        pw <- pwood
    } else {
        pw <- pwood*pf 
    }
    #prho <- 0.7
    pr <- prho*pf
    pfl <- (1.0-pretrans)*pf
    
    ret <- data.frame(pf,pfl,pw,pr,af,aw,ar)
    return(ret)
}

### Allocation and plant P concentrations - required for both PS constraint and PC constraint
allocp_exudation <- function(pf,  pwvar = TRUE,
                             pwood = 0.0003, prho = 0.7,
                             pretrans = 0.6) {
    # parameters
    # pf is the PC ratio of foliage
    # pw is the PC ratio of wood if fixed; otherwise the ratio of wood P:C to foliage P:C
    # pwvar is whether or not to allow wood PC to vary
    # prho is the ratio of root P:C to foliage P:C
    # pretrans is the fraction of foliage P:C retranslocated  
    
    len <- length(pf)
    ar <- af <- aw <- ae <- pw <- pr <- rep(0,len)  # initialise
    for (i in 1:len) {
        ar[i] <- 0.15
        af[i] <- 0.2
        ae[i] <- 0.05
        aw[i] <- 1 - ar[i] - af[i] - ae[i]
    }
    
    # P concentrations of rest of plant   # in g P g-1 C
    if (pwvar == FALSE) {
        pw <- pwood
    } else {
        pw <- pwood*pf 
    }
    prho <- 0.7
    pr <- prho*pf
    pfl <- (1.0-pretrans)*pf
    
    ret <- data.frame(pf,pfl,pw,pr,af,aw,ar,ae)
    return(ret)
}