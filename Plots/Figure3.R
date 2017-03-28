
#### Functions to generate Figure 3
####
#### 
################################################################################

######### Libraries
#require(plot3D)
require(scatterplot3d)


######### PHOTOSYNTHETIC CONSTRAINT FUNCTIONS

### Allocation and plant P concentrations - required for both PS constraint and PC constraint
allocp <- function(pf,  pwvar = FALSE,
                   pwood = 0.0003, prho = 0.7,
                   pretrans = 0.6) {
    # parameters
    # pf is the PC ratio of foliage
    # pw is the PC ratio of wood if fixed; otherwise the ratio of wood P:C to foliage P:C
    # pwvar is whether or not to allow wood PC to vary
    # prho is the ratio of root P:C to foliage P:C
    # pretrans is the fraction of foliage P:C retranslocated  
    
    len <- length(pf)
    ar <- af <- aw <- pw <- pr <- rep(0,len)  # initialise
    for (i in 1:len) {
        ar[i] <- 0.2
        af[i] <- 0.2
        aw[i] <- 1 - ar[i] - af[i]
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
    
    ret <- data.frame(pf,pfl,pw,pr,af,aw,ar)
    return(ret)
}

### Allocation and plant N concentrations - required for both PS constraint and NC constraint
allocn <- function(nf,  nwvar = FALSE,
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

### Make inference of pf based on nf
inferpfVL <- function(nf, a, Pin=0.04, Nin=1.0,
                      leachn=0.05, leachp=0.05,
                      k1=0.01, k2=0.01, k3=0.05,
                      nwood=0.005, pwood=0.0003, nwvar = FALSE,
                      pwvar = FALSE, nrho = 0.7, prho = 0.7,
                      nretrans = 0.5, pretrans = 0.6) {
    # allocation parameters
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # output nf, based on F(nf) = F(pf)
    pf <- c()
    
    Nleach <- (leachn/(1-leachn)) * (a$nfl * a$af + a$nr * a$ar +
                                         a$nw *a$aw)
    
    Pleach <- (leachp/(1-leachp-k1)) 
    Pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp)) 
    
    Pg <- ((Pin * Nleach)/Nin) / (Pocc + Pleach)
    
    if(pwvar == FALSE) {
        pf <- (Pg - pwood * aw) / ((1.0 - pretrans) * af + prho * ar)
    } else {
        pf <- Pg / ((1.0 - pretrans) * af + prho * ar + aw * pwood)
    }
    return(round(pf,8))
}

### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N & Ca
LUE <- function(df, co2, LUE0, Nref) {
    
    CaResp <- 1.632 * (co2-60.9) / (co2+121.8)    ##RCO2
    Nresp <- min(df/Nref, 1)                      ##Rate-limiting effect of low N
    
    return(LUE0 * CaResp * Nresp)
}

### NPP as function of nf and LAI (which is calculated from NPP)
eqNC <- function(df, NPP, co2, LUE0, Nref, I0, kext, SLA, af, sf, cfrac, CUE) {
    
    ##Returns G: total C production (i.e. NPP)
    return(LUE(df, co2, LUE0, Nref) * I0 * (1 - exp(-kext*SLA*af*NPP/sf/cfrac)) * CUE)
    
}


### This function implements photosynthetic constraint - solve by finding the root
solveNC <- function(nf, af, co2=350,
                    LUE0=2.8, I0=3, Nref=0.04, 
                    kext=0.5, SLA=5, sf=0.5, w = 0.45, cue = 0.5) {
    # parameters
    # nf is variable
    # making it pass af (fractional allocation to foliage) because this may also be variable
    # co2 = co2 concentration 
    # LUE0 = maximum gross LUE in kg C GJ-1
    # I0 = total incident radiation in GJ m-2 yr-1
    # Nref = leaf N:C for saturation of photosynthesis
    # kext = light extinction coeffciency
    # SLA = specific leaf area in m2 kg-1 DM
    # sf = turnover rate of foliage in yr-1
    # w = C content of biomass - needed to convert SLA from DM to C
    # cue = carbon use efficiency
    
    # solve implicit equation
    ans <- c()
    len <- length(nf)
    for (i in 1:len) {
        fPC <- function(NPP) eqNC(nf[i], NPP, co2, LUE0, Nref, I0, kext, SLA, af[i], sf, w, cue) - NPP
        ans[i] <- uniroot(fPC,interval=c(0.1,20), trace=T)$root
    }
    return(ans)
}


####### FUNCTIONS FOR P CYCLING CONSTRAINT

### Soil temperature response of decomposition 
Actsoil <- function(Tsoil) 0.0326 + 0.00351*Tsoil^1.652 - (Tsoil/41.748)^7.19

### Burial fractions from passive pool
passive <- function(df, a, Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16) {
    
    len <- length(df)
    
    decomp <- 0.00013*52*Actsoil(Tsoil)   # decomposition of passive pool per year without priming
    
    # re-burial fraction = fraction of C released from passive pool that is re-buried in it
    pas <- 0.996 - (0.85-0.68*Texture)
    psa <- 0.42
    ppa <- 0.45
    pap <- 0.004
    psp <- 0.03
    qq <-  ppa*(pap + psp*pas)/(1-pas*psa)   # re-burial fraction
    
    muf <- c()
    mur <- c()
    omegaf <- c()
    omegar <- c()
    transfer_fa <- c()
    transfer_ra <- c()
    
    
    # transfer coefficients among litter and soil pools
    cfrac <- 0.45
    for (i in 1:len) {
        muf[i] <- max(0,min(0.85 - 0.018*ligfl/cfrac/a[i, "nfl"],1))    
        mur[i] <- max(0,min(0.85 - 0.018*ligrl/cfrac/a[i, "nr"],1))
    }
    pma <- pna <- 0.45
    pua <- 0.55*(1-ligfl)
    pus <- 0.7*ligfl
    pva <- 0.45*(1-ligrl)
    pvs <- 0.7*ligrl
    
    # burial fractions for foliage (omegaf) and root (omegar) into passive pool
    det <- 1-psa*pas
    omegau <- (pap*(pua+pus*psa+psp*(pus+pua*pas)))/det
    omegav <- (pap*(pva+pus*psa+psp*(pvs+pva*pas)))/det
    omegam <- (pap*pma+psp*pma*pas)/det
    omegaf <- muf*omegam + (1-muf)*omegau
    omegar <- mur*omegam + (1-mur)*omegav  
    
    # fraction of foliage and root litter being transferred to active pool
    transfer_fa <- muf*pma + (1-muf)*psa
    transfer_ra <- mur*pma + (1-mur)*psa
    
    ret <- data.frame(decomp, qq, omegaf, omegar, transfer_fa, transfer_ra)
    
    return(ret)
}

### Function for nutrient N constraint in longterm ie passive, leaching, wood considered
NConsLong <- function(df, a, Nin=1.0, leachn=0.05, 
                      Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                      Cpass = 2680, ncp = 0.1) {
    # passed are df and a, the allocation and plant N:C ratios
    # parameters : 
    # Nin is fixed N inputs (N deposition annd fixation) in g m-2 yr-1 (could vary fixation)
    # nleach is the rate of n leaching of the mineral pool (per year)
    # Tsoil is effective soil temperature for decomposition
    # Texture is the fine soil fraction
    # ligfl and ligrl are the lignin:C fractions in the foliage and root litter
    # Cpass is the passive pool size in g C m-2
    # ncp is the NC ratio of the passive pool in g N g-1 C
    
    # passive pool burial 
    pass <- passive(df, a, Tsoil, Texture, ligfl, ligrl)
    omegap <- a$af*pass$omegaf + a$ar*pass$omegar 
    
    # equation for N constraint with passive, wood, and leaching
    U0 <- Nin + (1-pass$qq) * pass$decomp * Cpass * ncp   # will be a constant if decomp rate is constant
    nwood <- a$aw*a$nw
    nburial <- omegap*ncp
    nleach <- leachn/(1-leachn) * (a$nfl*a$af + a$nr*(a$ar) + a$nw*a$aw)
    
    NPP_NC <- U0 / (nwood + nburial + nleach)   # will be in g C m-2 yr-1
    NPP_N <- NPP_NC*10^-3 # returned in kg C m-2 yr-1
    
    df <- data.frame(NPP_N, nwood,nburial,nleach,a$aw)
    return(df)   
}


# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLongN <- function(co2=350,Cpass,Nin) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf)$af,co2=co2) - NConsLong(nf,allocn(nf),Cpass=Cpass,Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP <- solveNC(equilnf,af=allocn(equilnf)$af, co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
}


### Calculate the very long term nutrient cycling constraint for N, i.e. passive pool equilibrated
# it is just Nin = Nleach
NConsVLong <- function(df, a, Nin=1.0, 
                       leachn=0.05) {
    # passed are bf and nf, the allocation and plant N:C ratios
    # parameters : 
    # Nin is fixed N inputs (N fixed and deposition) in g m-2 yr-1 (could vary fixation)
    # leachn is the rate of leaching of the mineral N pool (per year)
    
    # equation for N constraint with just leaching
    U0 <- Nin
    nleach <- leachn/(1-leachn) * (a$nfl*a$af + a$nr*(a$ar) + a$nw*a$aw)
    NPP_NC <- U0 / (nleach)   # will be in g C m-2 yr-1
    NPP_N <- NPP_NC*10^-3     # returned in kg C m-2 yr-1
    
    df <- data.frame(NPP_N,nleach)
    return(df)   
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLongN <- function(co2=350) {
    fn <- function(nf) {
        solveNC(nf,allocn(nf)$af,co2=co2) - NConsVLong(nf,allocn(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP_N <- solveNC(equilnf,af=allocn(equilnf)$af, co2=co2)
    
    ans <- data.frame(equilnf,equilNPP_N)
    return(ans)
}

# Find very-long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
equilpVL <- function(equilNPP, Pin = 0.04, leachp=0.05,
                     pwvar = FALSE, pwood = 0.0003, prho = 0.7,
                     pretrans = 0.6, k1 = 0.01, k2 = 0.01, k3 = 0.05) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # prepare very long term phosphorus fluxes
    U0 = Pin
    pleach <- leachp/(1-leachp-k1)
    pocc <- (k3/(k2+k3))*(k1/(1-k1-pleach))
    
    # Convert NPP unit
    NPP_PC <- equilNPP*10^3     # convert to g C m-2 yr-1
    
    # Calculate equilnf, based on equilNPP_P
    Y <- U0/(NPP_PC*(pleach+pocc))
    if(pwvar == FALSE) {
        pf <- (Y - pwood * aw) / ((1.0 - pretrans) * af + prho * ar)
    } else {
        pf <- Y / ((1.0 - pretrans) * af + prho * ar + aw * pwood)
    }
    
    # obtain equilpf  
    return(pf)
}

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
equilpL <- function(equildf, Pin = 0.04, leachp = 0.05, Cpass=CpassVLong,
                    pwvar = FALSE, pwood = 0.0003, prho = 0.7, 
                    pretrans = 0.6, pcp = 0.005, Tsoil = 15,
                    Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                    k1 = 0.01, k2 = 0.01, k3 = 0.05) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    df <- equildf[1,1]
    equilNPP <- equildf[1,2]
    
    # passive pool burial 
    pass <- passive(df, allocn(df), Tsoil, Texture, ligfl, ligrl)
    omegap <- allocn(df)$af*pass$omegaf + allocn(df)$ar*pass$omegar 
    
    # prepare very long term nitrogen fluxes
    U0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omegap*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Convert NPP unit
    NPP_PC <- equilNPP*10^3     # convert to g C m-2 yr-1
    
    # Calculate equilnf, based on equilNPP_P
    Y1 <- U0/NPP_PC - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach+pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilnf  
    return(pf)
}

# Find long term equilibrated pf based on equilibrated NPP calculated from equilnf profile
inferpfL <- function(nf, a, Pin = 0.04, Nin = 1.0,
                     leachn = 0.05, leachp = 0.05, Cpass=CpassVLong, 
                     pwvar = FALSE, pwood = 0.0003, prho = 0.7, 
                     pretrans = 0.6, pcp = 0.005, ncp = 0.1,
                     Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                     k1 = 0.01, k2 = 0.01, k3 = 0.05) {
    # prepare allocation partitioning
    ar <- 0.2
    af <- 0.2
    aw <- 1 - ar - af
    
    # passive pool burial 
    pass <- passive(nf, allocn(nf), Tsoil, Texture, ligfl, ligrl)
    omega <- allocn(nf)$af*pass$omegaf + allocn(nf)$ar*pass$omegar 
    
    # prepare long term nitrogen fluxes
    N0 = Nin  + (1-pass$qq) * pass$decomp * Cpass * ncp
    nleach <- leachn/(1-leachn) * (a$af*a$nfl + a$aw*a$nw + a$ar*a$nr)
    nburial <- omega*ncp
    nwood <- a$aw*a$nw
    
    NPP <- N0 / (nleach + nburial + nwood)
    
    # prepare long term phosphorus fluxes
    P0 = Pin + (1-pass$qq) * pass$decomp * Cpass * pcp
    pleach <- leachp/(1-leachp-k1) 
    pburial <- omega*pcp
    pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp))
    
    # Calculate pf, based on NPP from nf
    Y1 <- P0/NPP - pburial
    
    if(pwvar == FALSE) {
        pf <- (((Y1 - pwood * aw) / (pleach+pocc)) - pwood * aw) / ((1.0-pretrans)*af + prho * ar)
    } else {
        pf <- Y1 / (pwood * aw + (pleach + pocc) * ((1.0-pretrans)*af + prho * ar + pwood * aw))
    }
    
    # obtain equilpf  
    return(pf)
}

#### setting CO2 concentrations
CO2_1 <- 350.0
CO2_2 <- 700.0

# plot photosynthetic constraints - not quite same as Hugh's, not sure why? 
# N:C and P:C ratio
nfseq <- round(seq(0.005, 0.05, by = 0.001),5)
a_nf <- as.data.frame(allocn(nfseq))

pfseq <- inferpfVL(nfseq, a_nf, Pin=0.04, Nin=1.0)
a_pf <- as.data.frame(allocp(pfseq))

##### CO2 = 350
# calculate NC vs. NPP at CO2 = 350 respectively
NC350 <- solveNC(nfseq, a_nf$af, co2=CO2_1)

# calculate very long term NC and PC constraint on NPP, respectively
NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=1.0)

# solve very-long nutrient cycling constraint
VLongN <- solveVLongN(co2=CO2_1)
equilNPP <- VLongN$equilNPP_N   
equilpf <- equilpVL(equilNPP,Pin = 0.04)   
VLongNP <- data.frame(VLongN, equilpf)

# Get Cpassive from very-long nutrient cycling solution
aequiln <- allocn(VLongNP$equilnf)
aequilp <- allocp(VLongNP$equilpf)
pass <- passive(df=VLongNP$equilnf, a=aequiln)
omega <- aequiln$af*pass$omegaf + aequiln$ar*pass$omegar
CpassVLong <- omega*VLongNP$equilNPP/pass$decomp/(1-pass$qq)*1000.0

# Calculate nutrient release from recalcitrant pools
PrelwoodVLong <- aequilp$aw*aequilp$pw*VLongNP$equilNPP_N*1000.0
NrelwoodVLong <- aequiln$aw*aequiln$nw*VLongNP$equilNPP_N*1000.0

# Calculate pf based on nf of long-term nutrient exchange
pfseqL <- inferpfL(nfseq, a_nf, Pin = 0.04+PrelwoodVLong,
                   Nin = 1.0+NrelwoodVLong,Cpass=CpassVLong)

# Calculate long term nutrieng constraint
NCHUGH <- NConsLong(df=nfseq, a=a_nf,Cpass=CpassVLong,
                    Nin = 1.0+NrelwoodVLong)

# Find equilibrate intersection and plot
LongN <- solveLongN(co2=CO2_1, Cpass=CpassVLong, Nin= 1.0+NrelwoodVLong)
equilpf <- equilpL(LongN, Pin = 0.04+PrelwoodVLong, Cpass=CpassVLong)   
LongNP <- data.frame(LongN, equilpf)

out350DF <- data.frame(nfseq, pfseq, pfseqL, NC350, NCVLONG, NCHUGH)
colnames(out350DF) <- c("nc", "pc_VL", "pc_350_L", "NPP_350", "NPP_VL",
                        "nleach_VL", "NPP_350_L", "nwood_L", "nburial_L",
                        "nleach_L", "aw")
equil350DF <- data.frame(VLongNP, LongNP)
colnames(equil350DF) <- c("nc_VL", "NPP_VL", "pc_VL",
                          "nc_L", "NPP_L", "pc_L")

##### CO2 = 700

# N:C and P:C ratio
nfseq <- round(seq(0.005, 0.05, by = 0.001),5)
a_nf <- as.data.frame(allocn(nfseq))

pfseq <- inferpfVL(nfseq, a_nf,Pin=0.04, Nin=1.0)
a_pf <- as.data.frame(allocp(pfseq))

# calculate NC vs. NPP at CO2 = 350 respectively
NC700 <- solveNC(nfseq, a_nf$af, co2=CO2_2)

# calculate very long term NC and PC constraint on NPP, respectively
NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=1.0)

# solve very-long nutrient cycling constraint
VLongN <- solveVLongN(co2=CO2_2)
equilNPP <- VLongN$equilNPP_N   
equilpf <- equilpVL(equilNPP,Pin = 0.04)   
VLongNP <- data.frame(VLongN, equilpf)

out700DF <- data.frame(nfseq, pfseq, pfseqL, NC700, NCVLONG, NCHUGH)
colnames(out700DF) <- c("nc", "pc_VL", "pc_700_L", "NPP_700", "NPP_VL",
                        "nleach_VL", "NPP_700_L", "nwood_L", "nburial_L",
                        "nleach_L", "aw")

# Find equilibrate intersection and plot
LongN <- solveLongN(co2=CO2_2, Cpass=CpassVLong, Nin=1.0+NrelwoodVLong)
equilNPP <- LongN$equilNPP

a_new <- allocn(LongN$equilnf)
equilpf <- inferpfVL(LongN$equilnf, a_new)

LongNP <- data.frame(LongN, equilpf)

equil700DF <- data.frame(VLongNP, LongNP)
colnames(equil700DF) <- c("nc_VL", "NPP_VL", "pc_VL",
                          "nc_L", "NPP_L", "pc_L")


##### Main program

### Plotting
tiff("Plots/Figure3.tiff",
     width = 8, height = 7, units = "in", res = 300)
par(mar=c(5.1,5.1,2.1,2.1))


# NPP constraint by CO2 = 350
s3d <- scatterplot3d(out350DF$nc, out350DF$pc_VL, out350DF$NPP_350, xlim=c(0.0, 0.05),
                     ylim = c(0.0, 0.002), zlim=c(0, 8), 
                     type = "l", xlab = "Shoot N:C ratio", ylab = "Shoot P:C ratio", 
                     zlab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
                     color="cyan", lwd = 3, angle=24)

# NPP constraint by very long term nutrient availability
s3d$points3d(out350DF$nc, out350DF$pc_VL, out350DF$NPP_VL, type="l", col="tomato", lwd = 3)

# equilibrated NPP for very long term nutrient and CO2 = 350
s3d$points3d(equil350DF$nc_VL, equil350DF$pc_VL, equil350DF$NPP_VL,
             type="h", pch = 19, col = "blue")

# NPP constraint by long term nutrient availability
s3d$points3d(out350DF$nc, out350DF$pc_VL, out350DF$NPP_350_L, type='l',col="violet", lwd = 3)
#s3d$points3d(out700DF$nc, out700DF$pc_700_L, out700DF$NPP_700_L, type='l',col="grey", lwd = 3)


# equilibrated NPP for long term nutrient and CO2 = 350
#s3d$points3d(equil350DF$nc_L, equil350DF$pc_L, equil350DF$NPP_L,
#             type="h", col="lightblue", pch = 19)

# NPP constraint by CO2 = 700
s3d$points3d(out700DF$nc, out700DF$pc_VL, out700DF$NPP_700, col="green", type="l", lwd = 3)

s3d$points3d(equil350DF$nc_VL, equil350DF$pc_VL, 
             out700DF[18, "NPP_700"], type="h", col = "darkgreen", pch=19)

# equilibrated NPP for very long term nutrient and CO2 = 700
s3d$points3d(equil700DF$nc_VL, equil700DF$pc_VL, equil700DF$NPP_VL, 
             type="h", col="orange", pch = 19)

# equilibrated NPP for long term nutrient and CO2 = 700
s3d$points3d(equil700DF$nc_L, equil700DF$pc_VL, equil700DF$NPP_L,
             type="h", col="red", pch = 19)


legend("topleft", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
                     expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
                     "VL nutrient constraint", "L nutrient constraint",
                     "A", "B", "C", "D"),
       col=c("cyan","green", "tomato", "violet","blue", "darkgreen","red", "orange"), 
       lwd=c(2,2,2,2,NA,NA,NA,NA), pch=c(NA,NA,NA,NA,19,19,19,19), cex = 1.0, 
       bg = adjustcolor("grey", 0.8))

dev.off()



### only plot pf and npp
#
## Photosynthetic constraint CO2 = 350 ppm
#plot(out350DF$pc_VL, out350DF$NPP_350,axes=F,
#     type='l',xlim=c(0,0.001),ylim=c(0,8), 
#     ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]"))
#     , xlab = "Shoot P:C ratio", lwd = 2.5, col="cyan", cex = 2.0, bg = "black")
#rect(-2,-2,0.002,8,border=NA, col=adjustcolor("lightgrey", 0.2))
#axis(1)
#axis(2)
## add abline to show instantaneous effect of doubling CO2
#abline(v=equil350DF$pc_VL, lwd = 2, lty = 5, col = "gray73")
#
## Photosynthetic constraint CO2 = 700 ppm
#points(out700DF$pc_VL, out700DF$NPP_700,type='l',col="green", lwd = 2.5)
#
## VL nutrient constraint curve
#points(out350DF$pc_VL, out350DF$NPP_VL,type='l',col="tomato", lwd = 2.5)
#
## L nutrient constraint curve   changed from pc_350_L to pc_VL
#points(out350DF$pc_VL, out350DF$NPP_350_L,type='l',col="violet", lwd = 2.5)
#
## VL intersect with CO2 = 350 ppm
#points(equil350DF$pc_VL,equil350DF$NPP_VL, pch = 19, cex = 2.0, col = "blue")
#
## L intersect with CO2 = 350 ppm      
#with(equil350DF,points(pc_L,NPP_L,pch=19, cex = 2.0, col = "black"))
#
## L intersect with CO2 = 700 ppm
#with(equil700DF,points(pc_L,NPP_L,pch=19, cex = 2.0, col = "red"))
#
## VL intersect with CO2 = 700 ppm
#points(equil700DF$pc_VL, equil700DF$NPP_VL, cex = 2.0, col = "orange", pch = 19)
#
#legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
#                     expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
#                     "VL nutrient constraint", "L nutrient constraint",
#                     "A", "B"),
#       col=c("cyan","green", "tomato", "violet","blue", "darkgreen"), 
#       lwd=c(2,2,2,2,NA,NA), pch=c(NA,NA,NA,NA,19,19), cex = 1.0, 
#       bg = adjustcolor("grey", 0.8))
#
#legend(0.0008, 7.05, c("C", "D"),
#       col=c("red", "orange"), 
#       lwd=c(NA,NA), pch=c(19,19), cex = 1.0, border=FALSE, bty="n",
#       bg = adjustcolor("grey", 0.8))      
#
#
#
## only plot nf and NPP
#
## Photosynthetic constraint CO2 = 350 ppm
#plot(out350DF$nc, out350DF$NPP_350,axes=F,
#     type='l',xlim=c(0,0.05),ylim=c(0,8), 
#     ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]"))
#     , xlab = "Shoot P:C ratio", lwd = 2.5, col="cyan", cex = 2.0, bg = "black")
#rect(-2,-2,0.05,8,border=NA, col=adjustcolor("lightgrey", 0.2))
#axis(1)
#axis(2)
## add abline to show instantaneous effect of doubling CO2
#abline(v=equil350DF$nc_VL, lwd = 2, lty = 5, col = "gray73")
#
## Photosynthetic constraint CO2 = 700 ppm
#points(out700DF$nc, out700DF$NPP_700,type='l',col="green", lwd = 2.5)
#
## VL nutrient constraint curve
#points(out350DF$nc, out350DF$NPP_VL,type='l',col="tomato", lwd = 2.5)
#
## L nutrient constraint curve
#points(out350DF$nc, out350DF$NPP_350_L,type='l',col="violet", lwd = 2.5)
#
## VL intersect with CO2 = 350 ppm
#points(equil350DF$nc_VL,equil350DF$NPP_VL, pch = 19, cex = 2.0, col = "blue")
#
## L intersect with CO2 = 350 ppm
##with(equil350DF,points(nc_L,NPP_L,pch=19, cex = 2.0, col = "black"))
#
## L intersect with CO2 = 700 ppm
#with(equil700DF,points(nc_L,NPP_L,pch=19, cex = 2.0, col = "red"))
#
## VL intersect with CO2 = 700 ppm
#points(equil700DF$nc_VL, equil700DF$NPP_VL, cex = 2.0, col = "orange", pch = 19)
#
#legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
#                     expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
#                     "VL nutrient constraint", "L nutrient constraint",
#                     "A", "B"),
#       col=c("cyan","green", "tomato", "violet","blue", "darkgreen"), 
#       lwd=c(2,2,2,2,NA,NA), pch=c(NA,NA,NA,NA,19,19), cex = 1.0, 
#       bg = adjustcolor("grey", 0.8))
#
#legend(0.04, 7.05, c("C", "D"),
#       col=c("red", "orange"), 
#       lwd=c(NA,NA), pch=c(19,19), cex = 1.0, border=FALSE, bty="n",
#       bg = adjustcolor("grey", 0.8))     
#