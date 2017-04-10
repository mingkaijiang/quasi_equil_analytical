
#### Functions to generate Figure 4
#### Purpose: 
#### Shoot P:C vs. production under aCO2 and eCO2
#### In particular show eCO2 P:C line is modified by both VL and L constraints
####

################################################################################

#### setting CO2 concentrations
CO2_1 <- 350.0
CO2_2 <- 700.0

# plot photosynthetic constraints
# N:C and P:C ratio
nfseq <- round(seq(0.01, 0.05, by = 0.001),5)
a_nf <- as.data.frame(allocn(nfseq, nwvar=F))

pfseq <- inferpfVL(nfseq, a_nf, Pin=0.02, Nin=0.4, pwvar=F)
a_pf <- as.data.frame(allocp(pfseq, pwvar=F))

##### CO2 = 350
# calculate NC vs. NPP at CO2 = 350 respectively
NC350 <- solveNC(nfseq, a_nf$af, co2=CO2_1)

# calculate very long term NC and PC constraint on NPP, respectively
NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=0.4)

# solve very-long nutrient cycling constraint
VLongN <- solveVLongN(co2=CO2_1, nwvar=F)
equilNPP <- VLongN$equilNPP_N   
equilpf <- equilpVL(equilNPP,Pin=0.02, pwvar=F)   
VLongNP <- data.frame(VLongN, equilpf)

# Get Cpassive from very-long nutrient cycling solution
aequiln <- allocn(VLongNP$equilnf, nwvar=F)
aequilp <- allocp(VLongNP$equilpf, pwvar=F)
pass <- passive(df=VLongNP$equilnf, a=aequiln)
omega <- aequiln$af*pass$omegaf + aequiln$ar*pass$omegar
CpassVLong <- omega*VLongNP$equilNPP/pass$decomp/(1-pass$qq)*1000.0

# Calculate nutrient release from recalcitrant pools
PrelwoodVLong <- aequilp$aw*aequilp$pw*VLongNP$equilNPP_N*1000.0
NrelwoodVLong <- aequiln$aw*aequiln$nw*VLongNP$equilNPP_N*1000.0

# Calculate pf based on nf of long-term nutrient exchange
pfseqL <- inferpfL(nfseq, a_nf, Pin=0.02+PrelwoodVLong,
                   Nin=0.4+NrelwoodVLong,Cpass=CpassVLong,
                   nwvar=F, pwvar=F)

# Calculate long term nutrieng constraint
NCHUGH <- NConsLong(df=nfseq, a=a_nf,Cpass=CpassVLong,
                    Nin=0.4+NrelwoodVLong)

# Find equilibrate intersection and plot
LongN <- solveLongN(co2=CO2_1, Cpass=CpassVLong, Nin=0.4+NrelwoodVLong, nwvar=F)
equilpf <- equilpL(LongN, Pin=0.02+PrelwoodVLong, Cpass=CpassVLong,
                   nwvar=F,pwvar=F)   
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
nfseq <- round(seq(0.01, 0.05, by = 0.001),5)
a_nf <- as.data.frame(allocn(nfseq, nwvar=F))

# P:C ratio infered by VL constraint
pfseq <- inferpfVL(nfseq, a_nf,Pin=0.02, Nin=0.4, pwvar=F)
a_pf <- as.data.frame(allocp(pfseq, pwvar=F))

# calculate NC vs. NPP at CO2 = 700 respectively
NC700 <- solveNC(nfseq, a_nf$af, co2=CO2_2)

# calculate very long term NC and PC constraint on NPP, respectively
NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=0.4)

# solve very-long nutrient cycling constraint
VLongN <- solveVLongN(co2=CO2_2,nwvar=F)
equilNPP <- VLongN$equilNPP_N   
equilpf <- equilpVL(equilNPP,Pin=0.02,pwvar=F)   
VLongNP <- data.frame(VLongN, equilpf)

out700DF <- data.frame(nfseq, pfseq, pfseqL, NC700, NCVLONG)
colnames(out700DF) <- c("nc", "pc_VL", "pc_700_L", "NPP_700", "NPP_VL",
                        "nleach_VL")

# N:C ratio inferred by L constraint
NCLONG <- NConsLong(df=nfseq,a=a_nf,Nin=0.4+NrelwoodVLong,Cpass=CpassVLong)

# Find equilibrate intersection and plot
LongN <- solveLongN(co2=CO2_2, Cpass=CpassVLong, Nin=0.4+NrelwoodVLong, nwvar=F)
equilNPP <- LongN$equilNPP

a_new <- allocn(LongN$equilnf, nwvar=F)
equilpf <- equilpL(LongN, Pin=0.02+PrelwoodVLong, Cpass=CpassVLong,
                   nwvar=F, pwvar=F)

LongNP <- data.frame(LongN, equilpf)

equil700DF <- data.frame(VLongNP, LongNP)
colnames(equil700DF) <- c("nc_VL", "NPP_VL", "pc_VL",
                          "nc_L", "NPP_L", "pc_L")

# get the point instantaneous NPP response to doubling of CO2
df700 <- as.data.frame(cbind(round(nfseq,3), NC700))
inst700 <- inst_NPP(equil350DF$nc_VL, df700)

##### Main program

### Plotting
tiff("Plots/Figure4.tiff",
     width = 8, height = 7, units = "in", res = 300)
par(mar=c(5.1,5.1,2.1,2.1))

### only plot pf and npp
#
## Photosynthetic constraint CO2 = 350 ppm
plot(out350DF$pc_VL, out350DF$NPP_350,axes=F,
     type='l',xlim=c(0,0.0015),ylim=c(0,4), 
     ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]"))
     , xlab = "Shoot P:C ratio", lwd = 2.5, col="cyan", cex = 2.0, bg = "black")
rect(-2,-2,0.002,8,border=NA, col=adjustcolor("lightgrey", 0.2))
axis(1)
axis(2)
# add abline to show instantaneous effect of doubling CO2
abline(v=equil350DF$pc_VL, lwd = 2, lty = 5, col = "gray73")

# Photosynthetic constraint CO2 = 700 ppm, VL term
points(out700DF$pc_VL, out700DF$NPP_700,type='l',col="green", lwd = 2.5)

# Photosynthetic constraint CO2 = 700 ppm, Long term
points(out700DF$pc_700_L, out700DF$NPP_700, type = "l", col = "darkgreen", lwd = 2.5,
       lty = 3)

# VL nutrient constraint curve
points(out350DF$pc_VL, out350DF$NPP_VL,type='l',col="tomato", lwd = 2.5)

# VL intersect with CO2 = 350 ppm
points(equil350DF$pc_VL,equil350DF$NPP_VL, pch = 19, cex = 2.0, col = "blue")

# L nutrient constraint curve   changed from pc_350_L to pc_VL
points(out350DF$pc_VL, out350DF$NPP_350_L,type='l',col="violet", lwd = 2.5)


# Instantaneous intersect with CO2 = 700 ppm
points(equil350DF$pc_VL, inst700$equilNPP, cex = 2.0, col = "darkgreen", pch=19)

# VL intersect with CO2 = 700 ppm
points(equil700DF$pc_VL, equil700DF$NPP_VL, cex = 2.0, col = "orange", pch = 19)

points(equil700DF$pc_L, equil700DF$NPP_L, cex = 2.0, pch = 19, col = "red")

legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
                     expression(paste("Photo constraint at ", CO[2]," = 700 ppm, VL")),
                     expression(paste("Photo constraint at ", CO[2]," = 700 ppm, L")), 
                     "VL nutrient constraint", "L nutrient constraint",
                     "A", "B"),
       col=c("cyan","green", "darkgreen", "tomato", "violet","blue", "darkgreen"), 
       lwd=c(2,2,2,2,2,NA,NA), pch=c(NA,NA,NA,NA,NA,19,19), lty=c(1,1,3,1,1,NA,NA),cex = 1.0, 
       bg = adjustcolor("grey", 0.8))

legend(0.001, 6.75, c("C", "D"),
       col=c("red", "orange"), 
       lwd=c(NA,NA), pch=c(19,19), cex = 1.0, border=FALSE, bty="n",
       bg = adjustcolor("grey", 0.8))    
       
dev.off()
