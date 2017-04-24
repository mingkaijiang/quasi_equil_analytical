### Allocation and plant N concentrations - required for both PS constraint and NC constraint
allocn <- function(nf,  nwvar = TRUE,
                   nwood = 0.005, nrho = 0.7,
                   nretrans = 0.5) {
    # parameters
    # nf is the NC ratio of foliage
    # nw is the NC ratio of wood if fixed; otherwise the ratio of wood N:C to foliage N:C
    # nwvar is whether or not to allow wood NC to vary
    # nrho is the ratio of root N:C to foliage N:C
    # nretrans is the fraction of foliage N:C retranslocated  
    
    len <- length(nf)
    ar <- af <- aw <- nw <- nr <- rep(0,len)  # initialise
    for (i in 1:len) {
        ar[i] <- 0.2
        af[i] <- 0.2
        aw[i] <- 1 - ar[i] - af[i]
    }
    
    # N concentrations of rest of plant   # in g N g-1 C
    if (nwvar == FALSE) {
        nw <- nwood
    } else {
        nw <- nwood*nf 
    }
    nrho <- 0.7
    nr <- nrho*nf
    nfl <- (1.0-nretrans)*nf     
    
    ret <- data.frame(nf,nfl,nw,nr,af,aw,ar)
    return(ret)
}

### Allocation and plant N concentrations - required for both PS constraint and NC constraint
# specifically for exudation 
allocn_exudation <- function(nf,  nwvar = TRUE,
                             nwood = 0.005, nrho = 0.7,
                             nretrans = 0.5) {
    # parameters
    # nf is the NC ratio of foliage
    # nw is the NC ratio of wood if fixed; otherwise the ratio of wood N:C to foliage N:C
    # nwvar is whether or not to allow wood NC to vary
    # nrho is the ratio of root N:C to foliage N:C
    # nretrans is the fraction of foliage N:C retranslocated  
    # 
    
    len <- length(nf)
    ar <- af <- aw <- ae <- nw <- nr <- rep(0,len)  # initialise
    for (i in 1:len) {
        ar[i] <- 0.15
        af[i] <- 0.2
        ae[i] <- 0.05
        aw[i] <- 1 - ar[i] - af[i] - ae[i]
    }
    
    # N concentrations of rest of plant   # in g N g-1 C
    if (nwvar == FALSE) {
        nw <- nwood
    } else {
        nw <- nwood*nf 
    }
    nrho <- 0.7
    nr <- nrho*nf
    nfl <- (1.0-nretrans)*nf     
    
    ret <- data.frame(nf,nfl,nw,nr,af,aw,ar,ae)
    return(ret)
}
