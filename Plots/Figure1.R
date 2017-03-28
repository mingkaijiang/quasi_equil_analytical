
#### Functions to generate Figure 1
#### Purpose:
#### Attempted to regenerate the classic photosynthetic and N constraint equilibrium points,
#### under aCO2 (350ppm) and eCO2 (700 ppm) conditions
####
#### Assumptions:
#### 1. Fixed wood NC ratio
#### 2. Implicit inorganic N pool
#### 3. VL and L constraints under aCO2 intersect with photosynthetic constraint at the same point
#### 4. Photosynthesis is an empirical function
################################################################################

######### PHOTOSYNTHETIC CONSTRAINT FUNCTIONS

### Allocation and plant N concentrations - required for both PS constraint and NC constraint
alloc <- function(nf,  nwvar = FALSE, nwood = 0.005, rho = 0.7, retrans = 0.5) {
    # parameters
    # nf is the NC ratio of foliage
    # nw is the NC ratio of wood if fixed; otherwise the ratio of wood N:C to foliage N:C
    # nwvar is whether or not to allow wood NC to vary
    # rho is the ratio of root N:C to foliage N:C
    # retrans is the fraction of foliage N:C retranslocated  
    
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
    rho <- 0.7
    nr <- rho*nf
    nfl <- (1-retrans)*nf
    ret <- data.frame(nf,nfl,nw,nr,af,aw,ar)
    return(ret)
}

### Following two functions calculate NPP - will later need to be replaced by full model
### LUE function of N & Ca
LUE <- function(nf, co2, LUE0, Nref) {
    
    CaResp <- 1.632 * (co2-60.9) / (co2+121.8)
    Nresp <- min(nf/Nref, 1)
    return(LUE0 * CaResp * Nresp)
}

### NPP as function of nf and LAI (which is calculated from NPP)
eqPC <- function(nf, NPP, co2, LUE0, Nref, I0, kext, SLA, af, sf, cfrac) {
    
    return(LUE(nf, co2, LUE0, Nref) * I0 * (1 - exp(-kext*SLA*af*NPP/sf/cfrac)))
    
}

### This function implements photosynthetic constraint - solve by finding the root
solvePC <- function(nf, af, co2=350,
                    LUE0=1.4, I0=3, Nref=0.04, 
                    kext=0.5, SLA=5, sf=0.5, w = 0.45) {
    # parameters
    # nf is variable
    # making it pass af (fractional allocation to foliage) because this may also be variable
    # co2 = co2 concentration 
    # LUE0 = maximum LUE in kg C GJ-1
    # I0 = total incident radiation in GJ m-2 yr-1
    # Nref = leaf N:C for saturation of photosynthesis
    # kext = light extinction coeffciency
    # SLA = specific leaf area in m2 kg-1 DM
    # sf = turnover rate of foliage in yr-1
    # w = C content of biomass - needed to convert SLA from DM to C
    
    # solve implicit equation
    ans <- c()
    len <- length(nf)
    for (i in 1:len) {
        fPC <- function(NPP) eqPC(nf[i], NPP, co2, LUE0, Nref, I0, kext, SLA, af[i], sf, w) - NPP
        ans[i] <- uniroot(fPC,interval=c(0.1,20))$root
    }
    return(ans)
}

### This function also implements photosynthetic constraint - solving by iteration
### Shown below that this gives same solution as finding root
solvePCiter <- function(nf, af, co2=350,
                        LUE0=1.4, I0=3, Nref=0.04, 
                        kext=0.5, SLA=5, sf=0.5, w = 0.45, tol=0.01) {
    # parameters
    # nf is passed to the function
    # making it pass af (fractional allocation to foliage) because this may also be variable
    # co2 = co2 concentration 
    # LUE0 = maximum LUE in kg GJ-1
    # I0 = total incident radiation in GJ m-2 yr-1
    # Nref = leaf N:C for saturation of photosynthesis
    # kext = light extinction coeffciency
    # SLA = specific leaf area in m2 kg-1
    # sf = turnover rate of foliage in yr-1
    # w = C content of biomass
    
    ans <- c()
    len <- length(nf)
    oldNPP <- 1      # initial guess for NPP, in kg C m-2 yr-1
    
    # loop over supplied N concentrations
    for (i in 1:len) {
        repeat {
            newNPP <- eqPC(nf[i], oldNPP, co2, LUE0, Nref, I0, kext, SLA, af[i], sf, w)
            print(newNPP)
            if (abs(newNPP - oldNPP) < tol) break
            oldNPP <- newNPP
        }
        ans[i] <- newNPP
    }
    return(ans)
}



####### FUNCTIONS FOR N CYCLING CONSTRAINT

### Soil temperature response of decomposition 
Actsoil <- function(Tsoil) 0.0326 + 0.00351*Tsoil^1.652 - (Tsoil/41.748)^7.19

### Solve quadratic - plus and minus versions
quadp <- function(a,b,c) (-b + sqrt(b^2 - 4*a*c))/(2*a)
quadm <- function(a,b,c) (-b - sqrt(b^2 - 4*a*c))/(2*a)

### Burial fractions from passive pool
passive <- function(nf, a, Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16) {
    
    decomp <- 0.00013*52*Actsoil(Tsoil)   # decomposition of passive pool per year without priming
    
    # re-burial fraction = fraction of C released from passive pool that is re-buried in it
    pas <- 0.996 - (0.85-0.68*Texture)
    psa <- 0.42
    ppa <- 0.45
    pap <- 0.004
    psp <- 0.03
    qq <-  ppa*(pap + psp*pas)/(1-pas*psa)   # re-burial fraction
    
    # transfer coefficients among litter and soil pools
    cfrac <- 0.45
    
    muf <- c()
    mur <- c()
    
    for (i in 1:length(a$nfl)) {
        muf[i] <- max(0,min(0.85 - 0.018*ligfl/cfrac/a$nfl[i],1))   
        mur[i] <- max(0,min(0.85 - 0.018*ligrl/cfrac/a$nr[i],1))    
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



### Function for nutrient constraint in longterm ie passive, leaching, wood considered
NConsLong <- function(nf, a, Nin=1.0, leach=0.05, 
                      Tsoil = 15, Texture = 0.5, ligfl = 0.2, ligrl = 0.16,
                      Cpass = 2680, ncp = 0.1) {
    # passed are nf and a, the allocation and plant N:C ratios
    # parameters : 
    # Nin is fixed N inputs (N deposition, N fixation) in g m-2 yr-1 (could vary fixation)
    # leach is the rate of leaching of the mineral pool (per year)
    # Tsoil is effective soil temperature for decomposition
    # Texture is the fine soil fraction
    # ligfl and ligrl are the lignin:C fractions in the foliage and root litter
    # Cpass is the passive pool size in g C m-2
    # ncp is the NC ratio of the passive pool in g N g-1 C
    
    # passive pool burial 
    pass <- passive(nf, a, Tsoil, Texture, ligfl, ligrl)
    omegap <- a$af*pass$omegaf + a$ar*pass$omegar 
    
    # equation for N constraint with passive, wood, and leaching
    U0 <- Nin + (1-pass$qq) * pass$decomp * Cpass * ncp   # will be a constant if decomp rate is constant
    nwood <- a$aw*a$nw
    nburial <- omegap*ncp
    nleach <- leach/(1-leach) * (a$nfl*a$af + a$nr*(a$ar) + a$nw*a$aw)
    
    NPP_NC <- U0 / (nwood + nburial + nleach)   # will be in g C m-2 yr-1
    NPP <- NPP_NC*10^-3 # returned in kg C m-2 yr-1
    df <- data.frame(NPP,nwood,nburial,nleach,a$aw)
    return(df)   
    
}

### Calculate the very long term nutrient cycling constraint, i.e. passive pool equilibrated
# it is just Nin = Nleach
NConsVLong <- function(nf, a, Nin=1.0, leach=0.05) {
    # passed are nf and a, the allocation and plant N:C ratios
    # parameters : 
    # Nin is fixed N inputs (N deposition, N fixation) in g m-2 yr-1 (could vary fixation)
    # leach is the rate of leaching of the mineral pool (per year)
    
    # equation for N constraint with just leaching
    U0 <- Nin
    nleach <- leach/(1-leach) * (a$nfl*a$af + a$nr*(a$ar) + a$nw*a$aw)
    NPP_NC <- U0 / (nleach)   # will be in g C m-2 yr-1
    NPP <- NPP_NC*10^-3 # returned in kg C m-2 yr-1
    df <- data.frame(NPP,nleach)
    return(df)   
}

# Find the long term equilibrium nf and NPP under standard conditions - by finding the root
solveLong <- function(co2=350,Cpass,Nin) {
    
    fn <- function(nf) {
        solvePC(nf,alloc(nf)$af,co2=co2) - NConsLong(nf,alloc(nf),Cpass=Cpass,Nin=Nin)$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP <- solvePC(equilnf,af=alloc(equilnf)$af, co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
    
}

# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solveVLong <- function(co2=350) {
    
    fn <- function(nf) {
        solvePC(nf,alloc(nf)$af,co2=co2) - NConsVLong(nf,alloc(nf))$NPP
    }
    equilnf <- uniroot(fn,interval=c(0.005,0.05))$root
    equilNPP <- solvePC(equilnf,af=alloc(equilnf)$af, co2=co2)
    ans <- data.frame(equilnf,equilNPP)
    return(ans)
    
}


##### MAIN PROGRAM
# plot photosynthetic constraints - not quite same as Hugh's, not sure why? 
# N:C ratios for x-axis
nfseq <- seq(0.005,0.05,by=0.001)
# need allocation fractions here
a_vec <- alloc(nfseq)

# plot photosynthetic constraints
PC350 <- solvePC(nfseq,a_vec$af,co2=350)
PC700 <- solvePC(nfseq,a_vec$af,co2=700)
PC350iter <- solvePCiter(nfseq,a_vec$af,co2=350)   # values are identical to PC350

#plot very-long nutrient cycling constraint
NCVLONG <- NConsVLong(nf=nfseq,a=a_vec,Nin=1.0)

#solve very-long nutrient cycling constraint
VLong <- solveVLong(co2=350)
#get Cpassive from very-long nutrient cycling solution
aequil <- alloc(VLong$equilnf)
pass <- passive(nf=VLong$equilnf, a=aequil)
omegap <- aequil$af*pass$omegaf + aequil$ar*pass$omegar
CpassVLong <- omegap*VLong$equilNPP/pass$decomp/(1-pass$qq)*1000.0
NrelwoodVLong <- aequil$aw*aequil$nw*VLong$equilNPP*1000

#now plot long-term constraint with this Cpassive
NCHUGH <- NConsLong(nf = nfseq,a = a_vec, Cpass=CpassVLong, Nin = 1.0+NrelwoodVLong)

# Solve longterm equilibrium
equil_long_350 <- solveLong(co2=350, Cpass=CpassVLong, Nin = 1.0+NrelwoodVLong)
equil_long_700 <- solveLong(co2=700, Cpass=CpassVLong, Nin = 1.0+NrelwoodVLong)

# get the point instantaneous NPP response to doubling of CO2
df700 <- as.data.frame(cbind(round(nfseq,3), PC700))
ncref <- round(VLong$equilnf,3)


## locate the intersect between VL nutrient constraint and CO2 = 700
VLong700 <- solveVLong(co2=700)

## Plotting
tiff("Plots/Figure1.tiff",
     width = 8, height = 7, units = "in", res = 300)
par(mar=c(5.1,5.1,2.1,2.1))

# Photosynthetic constraint CO2 = 350 ppm
plot(nfseq,PC350,axes=F,
     type='l',xlim=c(0,0.05),ylim=c(0,8), 
     ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]"))
     , xlab = "Shoot N:C ratio", lwd = 2.5, col="cyan", cex = 2.0, bg = "black")
rect(0,0,0.05,8,border=NA, col=adjustcolor("lightgrey", 0.2))
axis(1)
axis(2)
# add abline to show instantaneous effect of doubling CO2
abline(v=VLong$equilnf, lwd = 2, lty = 5, col = "gray73")

# Photosynthetic constraint CO2 = 700 ppm
points(nfseq,PC700,type='l',col="green", lwd = 2.5)

# VL nutrient constraint curve
points(nfseq,NCVLONG$NPP,type='l',col="tomato", lwd = 2.5)

# L nutrient constraint curve
points(nfseq,NCHUGH$NPP,type='l',col="violet", lwd = 2.5)

# VL intersect with CO2 = 350 ppm
points(VLong$equilnf,VLong$equilNPP, pch = 19, cex = 2.0, col = "blue")

# L intersect with CO2 = 350 ppm
#with(equil_long_350,points(equilnf,equilNPP,pch=19, cex = 2.0, col = "black"))

# L intersect with CO2 = 700 ppm
with(equil_long_700,points(equilnf,equilNPP,pch=19, cex = 2.0, col = "red"))

# instantaneous NPP response to doubling CO2
points(VLong$equilnf, df700[18, "PC700"], cex = 2.0, col = "darkgreen", pch=19)

# VL intersect with CO2 = 700 ppm
points(VLong700$equilnf, VLong700$equilNPP, cex = 2.0, col = "orange", pch = 19)

legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
                     expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
                     "VL nutrient constraint", "L nutrient constraint",
                     "A", "B"),
       col=c("cyan","green", "tomato", "violet","blue", "darkgreen"), 
       lwd=c(2,2,2,2,NA,NA), pch=c(NA,NA,NA,NA,19,19), cex = 1.0, 
       bg = adjustcolor("grey", 0.8))

legend(0.04, 7.05, c("C", "D"),
       col=c("red", "orange"), 
       lwd=c(NA,NA), pch=c(19,19), cex = 1.0, border=FALSE, bty="n",
       bg = adjustcolor("grey", 0.8))      

dev.off()
