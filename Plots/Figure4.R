
#### Functions to generate Figure 4
#### Purpose: 
#### Shoot P:C vs. production under aCO2 and eCO2
#### In particular show eCO2 P:C line is modified by both VL and L constraints
####

################################################################################
######### Main program
source("Parameters/Analytical_Run1_Parameters.R")

# create a range of nc for shoot to initiate
nfseq <- round(seq(0.01, 0.1, by = 0.001),5)
a_nf <- as.data.frame(allocn(nfseq))

# using very long term relationship to calculate pf from nf
pfseq <- inferpfVL(nfseq, a_nf)
a_pf <- as.data.frame(allocp(pfseq))

# calculate photosynthetic constraint at CO2 = 350
Photo350 <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_1)

### calculate very long term NC and PC constraint on NPP, respectively
NCVLONG <- VLong_constraint_N(nf=nfseq, nfdf=a_nf)

### NPP derived from PCVLONG should match NPP from NCVLONG
PCVLONG <- VLong_constraint_P(pf=pfseq, pfdf=a_pf)

### finding the equilibrium point between photosynthesis and very long term nutrient constraints
VLong_equil <- solveVLong_full_cnp(CO2=CO2_1)

### Get Cpassive from very-long nutrient cycling solution
aequiln <- allocn(VLong_equil$equilnf)
aequilp <- allocp(VLong_equil$equilpf)
pass <- passive(df=VLong_equil$equilnf, a=aequiln)
omega <- aequiln$af*pass$omegaf + aequiln$ar*pass$omegar
CpassVLong <- omega*VLong_equil$equilNPP/pass$decomp/(1-pass$qq)*1000.0

### Calculate nutrient release from recalcitrant pools
PrelwoodVLong <- aequilp$aw*aequilp$pw*VLong_equil$equilNPP*1000.0
NrelwoodVLong <- aequiln$aw*aequiln$nw*VLong_equil$equilNPP*1000.0

# Calculate pf based on nf of long-term nutrient exchange
pfseqL <- inferpfL(nfseq, a_nf, PinL = Pin+PrelwoodVLong,
                   NinL = Nin+NrelwoodVLong,
                   Cpass=CpassVLong)

# Calculate long term nutrieng constraint
NCLONG <- Long_constraint_N(nfseq, a_nf, CpassVLong,
                            NinL = Nin+NrelwoodVLong)

PCLONG <- Long_constraint_P(nfseq, pfseqL, allocp(pfseqL),
                            CpassVLong, PinL=Pin+PrelwoodVLong)

# Find long term equilibrium point
Long_equil <- solveLong_full_cnp(CO2=CO2_1, Cpass=CpassVLong, NinL = Nin+NrelwoodVLong, 
                                 PinL=Pin+PrelwoodVLong)


out350DF <- data.frame(nfseq, pfseq, pfseqL, Photo350, NCVLONG, NCLONG)
colnames(out350DF) <- c("nc", "pc_VL", "pc_350_L", "NPP_350", "NPP_VL",
                        "nleach_VL", "NPP_350_L", "nwood_L", "nburial_L",
                        "nleach_L", "aw")
equil350DF <- data.frame(VLong_equil, Long_equil)
colnames(equil350DF) <- c("nc_VL", "pc_VL", "NPP_VL", 
                          "nc_L","pc_L", "NPP_L")

##### CO2 = 700

# N:C and P:C ratio
nfseq <- round(seq(0.01, 0.1, by = 0.001),5)
a_nf <- as.data.frame(allocn(nfseq))

# using very long term relationship to calculate pf from nf
pfseq <- inferpfVL(nfseq, a_nf)
a_pf <- as.data.frame(allocp(pfseq))

# calculate NC vs. NPP at CO2 = 350 respectively
Photo700 <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_2)

### calculate very long term NC and PC constraint on NPP, respectively
NCVLONG <- VLong_constraint_N(nf=nfseq, nfdf=a_nf)

### NPP derived from PCVLONG should match NPP from NCVLONG
PCVLONG <- VLong_constraint_P(pf=pfseq, pfdf=a_pf)

### finding the equilibrium point between photosynthesis and very long term nutrient constraints
VLong_equil <- solveVLong_full_cnp(CO2=CO2_2)

# Find long term equilibrium point
Long_equil <- solveLong_full_cnp(CO2=CO2_2, Cpass=CpassVLong, NinL = Nin+NrelwoodVLong, 
                                 PinL=Pin+PrelwoodVLong)

out700DF <- data.frame(nfseq, pfseq, pfseqL, Photo700, NCVLONG, NCLONG)
colnames(out700DF) <- c("nc", "pc_VL", "pc_700_L", "NPP_700", "NPP_VL",
                        "nleach_VL", "NPP_700_L", "nwood_L", "nburial_L",
                        "nleach_L", "aw")

equil700DF <- data.frame(VLong_equil, Long_equil)
colnames(equil700DF) <- c("nc_VL", "pc_VL", "NPP_VL", 
                          "nc_L","pc_L", "NPP_L")

# get the point instantaneous NPP response to doubling of CO2
df700 <- as.data.frame(cbind(round(nfseq,3), Photo700))
inst700 <- inst_NPP(equil350DF$nc_VL, df700)
inst_pc <- inferpfVL(inst700$nf, allocn(inst700$nf))
    
### plot 2-d plots of nf vs. npp and nf vs. pf
tiff("Plots/Figure4.tiff",
     width = 10, height = 5, units = "in", res = 300)
par(mfrow=c(1,2), mar=c(5.1,6.1,2.1,2.1))

# shoot nc vs. NPP
plot(out350DF$nc, out350DF$NPP_350, xlim=c(0.0, 0.05),
     ylim=c(0, 5), 
     type = "l", xlab = "Shoot N:C ratio", 
     ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
     col="cyan", lwd = 3, cex.lab=1.5)
points(out350DF$nc, out350DF$NPP_VL, type="l", col="tomato", lwd = 3)
points(equil350DF$nc_VL, equil350DF$NPP_VL, type="p", pch = 19, col = "blue", cex = 1.5)
points(out350DF$nc, out350DF$NPP_350_L, type='l',col="violet", lwd = 3)
points(out700DF$nc, out700DF$NPP_700, col="green", type="l", lwd = 3)
points(equil350DF$nc_VL, inst700$equilNPP, type="p", col = "darkgreen", pch=19, cex = 1.5)
points(equil700DF$nc_VL, equil700DF$NPP_VL, type="p", col="orange", pch = 19, cex = 1.5)
points(equil700DF$nc_L, equil700DF$NPP_L,type="p", col="red", pch = 19, cex = 1.5)

plot(out350DF$nc, out350DF$pc_VL, xlim=c(0.0, 0.05),
     ylim=c(0, 0.01), 
     type = "l", xlab = "Shoot N:C ratio", 
     ylab = "Shoot P:C ratio",
     col="cyan", lwd = 3,cex.lab=1.5)
points(out350DF$nc, out350DF$pc_VL, type="l", col="tomato", lwd = 3)

points(out350DF$nc, out350DF$pc_VL, type='l',col="violet", lwd = 3)

points(out700DF$nc, out700DF$pc_VL, col="green", type="l", lwd = 3)

points(equil350DF$nc_VL, equil350DF$pc_VL, type="p", pch = 19, col = "blue",cex=1.5)

points(equil350DF$nc_VL, inst_pc, type="p", col = "darkgreen", pch=19, cex = 1.5)

points(equil700DF$nc_L, equil700DF$pc_L, type="p", col="red", pch = 19,cex=1.5)

points(equil700DF$nc_VL, equil700DF$pc_VL, type="p", col="orange", pch = 19, cex = 1.5)


legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
                    expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
                    "VL nutrient constraint", "L nutrient constraint",
                    "A", "B", "C", "D"),
       col=c("cyan","green", "tomato", "violet","blue", "darkgreen","red", "orange"), 
       lwd=c(2,2,2,2,NA,NA,NA,NA), pch=c(NA,NA,NA,NA,19,19,19,19), cex = 0.8, 
       bg = adjustcolor("grey", 0.8))


dev.off()
