
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

##### MAIN PROGRAM
source("Parameters/Analytical_Figure1_Parameters.R")
# plot photosynthetic constraints - not quite same as Hugh's, not sure why? 
# N:C ratios for x-axis
nfseq <- seq(0.01,0.05,by=0.001)
# need allocation fractions here
a_vec <- allocn(nfseq)

# plot photosynthetic constraints
PC350 <- solveNC(nfseq,a_vec$af,CO2=350)
PC700 <- solveNC(nfseq,a_vec$af,CO2=700)

#plot very-long nutrient cycling constraint
NCVLONG <- NConsVLong(df=nfseq,a=a_vec)

#solve very-long nutrient cycling constraint
VLong <- solveVLongN(CO2=350)
#get Cpassive from very-long nutrient cycling solution
aequil <- allocn(VLong$equilnf)
pass <- passive(df=VLong$equilnf, a=aequil)
omegap <- aequil$af*pass$omegaf + aequil$ar*pass$omegar
CpassVLong <- omegap*VLong$equilNPP/pass$decomp/(1-pass$qq)*1000.0
NrelwoodVLong <- aequil$aw*aequil$nw*VLong$equilNPP*1000

#now plot long-term constraint with this Cpassive
NCHUGH <- NConsLong(df = nfseq,a = a_vec, Cpass=CpassVLong, NinL = 0.4+NrelwoodVLong)

# Solve longterm equilibrium
equil_long_350 <- solveLongN(CO2=350, Cpass=CpassVLong, NinL = 0.4+NrelwoodVLong)
equil_long_700 <- solveLongN(CO2=700, Cpass=CpassVLong, NinL = 0.4+NrelwoodVLong)

# get the point instantaneous NPP response to doubling of CO2
df700 <- as.data.frame(cbind(round(nfseq,3), PC700))
inst700 <- inst_NPP(VLong$equilnf, df700)

## locate the intersect between VL nutrient constraint and CO2 = 700
VLong700 <- solveVLongN(CO2=700)

#### Plotting
tiff("Plots/Figure1.tiff",
     width = 8, height = 7, units = "in", res = 300)
par(mar=c(5.1,5.1,2.1,2.1))

# Photosynthetic constraint CO2 = 350 ppm
plot(nfseq,PC350,axes=F,
     type='l',xlim=c(0,0.05),ylim=c(0,4.0), 
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
points(nfseq,NCVLONG$NPP_N,type='l',col="tomato", lwd = 2.5)

# L nutrient constraint curve
points(nfseq,NCHUGH$NPP_N,type='l',col="violet", lwd = 2.5)

# VL intersect with CO2 = 350 ppm
points(VLong$equilnf,VLong$equilNPP, pch = 19, cex = 2.0, col = "blue")

# L intersect with CO2 = 350 ppm
#with(equil_long_350,points(equilnf,equilNPP,pch=19, cex = 2.0, col = "black"))

# L intersect with CO2 = 700 ppm
with(equil_long_700,points(equilnf,equilNPP,pch=19, cex = 2.0, col = "red"))

# instantaneous NPP response to doubling CO2
points(inst700$nf, inst700$equilNPP, cex = 2.0, col = "darkgreen", pch=19)

# VL intersect with CO2 = 700 ppm
points(VLong700$equilnf, VLong700$equilNPP, cex = 2.0, col = "orange", pch = 19)

legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
                     expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
                     "VL nutrient constraint", "L nutrient constraint",
                     "A", "B"),
       col=c("cyan","green", "tomato", "violet","blue", "darkgreen"), 
       lwd=c(2,2,2,2,NA,NA), pch=c(NA,NA,NA,NA,19,19), cex = 1.0, 
       bg = adjustcolor("grey", 0.8))

legend(0.04, 3.505, c("C", "D"),
       col=c("red", "orange"), 
       lwd=c(NA,NA), pch=c(19,19), cex = 1.0, border=FALSE, bty="n",
       bg = adjustcolor("grey", 0.8))      

dev.off()
