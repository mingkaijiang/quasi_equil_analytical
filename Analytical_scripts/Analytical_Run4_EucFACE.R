
#### Analytical script EucFACE parameters, fixed wood, P cycle off
####
#### Assumptions:
#### 1. P cycle off
#### 2. Fixed wood 
####
################################################################################

#### Functions
Perform_Analytical_Run4_EucFACE <- function(f.flag = 1, cDF, eDF) {
    #### Function to perform analytical run 1 simulations
    #### f.flag: = 1 simply plot analytical solution file
    #### f.flag: = 2 return a data list

    ######### Main program
    source("Parameters/Analytical_Run4_Parameters_EucFACE.R")
    
    # N:C ratios for x-axis
    nfseq <- seq(0.01,0.1,by=0.001)
    # need allocation fractions here
    a_vec <- allocn(nfseq)
    
    # plot photosynthetic constraints
    C350 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_1)
    C700 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_2)
    
    #plot very-long nutrient cycling constraint
    NC_VL <- VL_constraint_N(nfseq,a_vec)
    
    #solve very-long nutrient cycling constraint
    VL_eq <- solve_VL_full_cn(CO2=CO2_1)
    
    #get Cpassive from very-long nutrient cycling solution
    aequil <- allocn(VL_eq$equilnf)
    pass <- passive(df=VL_eq$equilnf, a=aequil)
    omegap <- aequil$af*pass$omegaf + aequil$ar*pass$omegar
    CpassVLong <- omegap*VL_eq$equilNPP/pass$decomp/(1-pass$qq)*1000.0
    NrelwoodVLong <- aequil$aw*aequil$nw*VL_eq$equilNPP*1000
    
    #now plot long-term constraint with this Cpassive
    NC_L <- L_constraint_N(nfseq,a_vec,Cpass=CpassVLong,Nin+NrelwoodVLong)
    
    # Solve longterm equilibrium
    L_eq_350 <- solve_L_full_cn(CO2=CO2_1, Cpass=CpassVLong, NinL = Nin+NrelwoodVLong)
    L_eq_700 <- solve_L_full_cn(CO2=CO2_2, Cpass=CpassVLong, NinL = Nin+NrelwoodVLong)
    
    ## locate the intersect between VL nutrient constraint and CO2 = 700
    VL_eq_700 <- solve_VL_full_cn(CO2=CO2_2)
    
    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(nfseq, C700))
    inst700 <- inst_NPP(VL_eq$equilnf, df700)
    
    out350DF <- data.frame(nfseq, C350, NC_VL, NC_L)
    colnames(out350DF) <- c("nc", "NPP_350", "NPP_VL",
                            "nleach_VL", "NPP_350_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    equil350DF <- data.frame(VL_eq, L_eq_350)
    colnames(equil350DF) <- c("nc_VL", "NPP_VL", 
                              "nc_L", "NPP_L")
    
    out700DF <- data.frame(nfseq, C700, NC_VL, NC_L)
    colnames(out700DF) <- c("nc", "NPP_700", "NPP_VL",
                            "nleach_VL", "NPP_700_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    
    equil700DF <- data.frame(VL_eq_700, L_eq_700)
    colnames(equil700DF) <- c("nc_VL", "NPP_VL", 
                              "nc_L", "NPP_L")
    if (f.flag ==1 ) {
        
        #### Library
        require(scatterplot3d)
        
        ######### Plotting
        
        tiff("Plots/Analytical_Run4_EucFACE.tiff",
             width = 10, height = 5, units = "in", res = 300)
        par(mfrow=c(1,2),mar=c(5.1,6.1,2.1,2.1))
        
        
        # Photosynthetic constraint CO2 = 350 ppm
        plot(nfseq,C350,axes=T,
             type='l',xlim=c(0.01,0.02),ylim=c(0.8,1.2), 
             ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
             xlab = "Shoot N:C ratio", lwd = 2.5, col="cyan", cex.lab = 1.5)
        #rect(0,0,0.05,8,border=NA, col=adjustcolor("lightgrey", 0.2))
        #axis(1)
        #axis(2)
        # add abline to show instantaneous effect of doubling CO2
        #abline(v=VLong$equilnf, lwd = 2, lty = 5, col = "gray73")
        
        # Photosynthetic constraint CO2 = 700 ppm
        points(nfseq,C700,type='l',col="green", lwd = 2.5)
        
        # VL nutrient constraint curve
        points(nfseq,NC_VL$NPP_N,type='l',col="tomato", lwd = 2.5)
        
        # L nutrient constraint curve
        points(nfseq,NC_L$NPP,type='l',col="violet", lwd = 2.5)
        
        # VL intersect with CO2 = 350 ppm
        points(VL_eq$equilnf,VL_eq$equilNPP, pch = 19, cex = 2.0, col = "blue")
        
        # L intersect with CO2 = 350 ppm
        #with(equil_long_350,points(equilnf,equilNPP,pch=19, cex = 2.0, col = "black"))
        
        # L intersect with CO2 = 700 ppm
        with(L_eq_700,points(equilnf,equilNPP,pch=19, cex = 2.0, col = "red"))
        
        # instantaneous NPP response to doubling CO2
        points(VL_eq$equilnf, inst700$equilNPP, cex = 2.0, col = "darkgreen", pch=19)
        
        # VL intersect with CO2 = 700 ppm
        points(VL_eq_700$equilnf, VL_eq_700$equilNPP, cex = 2.0, col = "orange", pch = 19)
        
#        legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
#                             expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
#                             "VL nutrient constraint", "L nutrient constraint",
#                             "A", "B"),
#               col=c("cyan","green", "tomato", "violet","blue", "darkgreen"), 
#               lwd=c(2,2,2,2,NA,NA), pch=c(NA,NA,NA,NA,19,19), cex = 1.0, 
#               bg = adjustcolor("grey", 0.8))
#        
#        legend(0.04, 3.55, c("C", "D"),
#               col=c("red", "orange"), 
#               lwd=c(NA,NA), pch=c(19,19), cex = 1.0, border=FALSE, bty="n",
#               bg = adjustcolor("grey", 0.8))  
#
        
        dev.off()
        
    } else if (f.flag == 2) {
        return()
    } 
}
