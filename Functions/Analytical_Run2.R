
#### Analytical script to match GDAY Run 2 settings
####
#### Assumptions:
#### Same as Run 1, except:
#### 1. P cycle off
####
################################################################################

#### Functions
Perform_Analytical_Run2 <- function(f.flag = 1, cDF, eDF) {
    #### Function to perform analytical run 2 simulations
    #### eDF: stores equilibrium points
    #### cDF: stores constraint points (curves)
    #### f.flag: = 1 simply plot analytical solution file
    #### f.flag: = 2 return cDF
    #### f.flag: = 3 return eDF

    ######### Main program
    source("Parameters/Analytical_Run2_Parameters.R")
    
    # N:C ratios for x-axis
    nfseq <- seq(0.01,0.05,by=0.001)
    # need allocation fractions here
    a_vec <- allocn(nfseq,nwvar=nwvar)
    
    # plot photosynthetic constraints
    PC350 <- solveNC(nfseq,a_vec$af,CO2=CO2_1)
    PC700 <- solveNC(nfseq,a_vec$af,CO2=CO2_2)
    
    #plot very-long nutrient cycling constraint
    NCVLONG <- NConsVLong(df=nfseq,a=a_vec,Nin=Nin)
    
    #solve very-long nutrient cycling constraint
    VLong <- solveVLongN(CO2=CO2_1, nwvar=nwvar)
    #get Cpassive from very-long nutrient cycling solution
    aequil <- allocn(VLong$equilnf, nwvar=nwvar)
    pass <- passive(df=VLong$equilnf, a=aequil)
    omegap <- aequil$af*pass$omegaf + aequil$ar*pass$omegar
    CpassVLong <- omegap*VLong$equilNPP/pass$decomp/(1-pass$qq)*1000.0
    NrelwoodVLong <- aequil$aw*aequil$nw*VLong$equilNPP*1000
    
    #now plot long-term constraint with this Cpassive
    NCHUGH <- NConsLong(df = nfseq,a = a_vec, Cpass=CpassVLong, NinL = Nin+NrelwoodVLong)
    
    # Solve longterm equilibrium
    equil_long_350 <- solveLongN(CO2=CO2_1, Cpass=CpassVLong, NinL = Nin+NrelwoodVLong,nwvar=nwvar)
    equil_long_700 <- solveLongN(CO2=CO2_2, Cpass=CpassVLong, NinL = Nin+NrelwoodVLong,nwvar=nwvar)
    
    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(round(nfseq,3), PC700))
    inst700 <- inst_NPP(VLong$equilnf, df700)
    
    ## locate the intersect between VL nutrient constraint and CO2 = 700
    VLong700 <- solveVLongN(CO2=CO2_2,nwvar=nwvar)
    
    # store constraint and equil DF onto their respective output df
    cDF[cDF$Run == 2 & cDF$CO2 == 350, 3:13] <- cbind(nfseq, 0, 0, PC350, NCVLONG, NCHUGH)
    eDF[eDF$Run == 2 & eDF$CO2 == 350, 3:8] <- cbind(VLong, 0, equil_long_350, 0)
    cDF[cDF$Run == 2 & cDF$CO2 == 700, 3:13] <- cbind(nfseq, 0, 0, PC700, NCVLONG, NCHUGH)
    eDF[eDF$Run == 2 & eDF$CO2 == 700, 3:8] <- cbind(VLong700, 0, equil_long_700, 0)
    
    if (f.flag ==1 ) {
        
        #### Library
        require(scatterplot3d)
        
        ######### Plotting
        
        tiff("Plots/Analytical_Run2.tiff",
             width = 8, height = 7, units = "in", res = 300)
        par(mar=c(5.1,5.1,2.1,2.1))
        
        
        # Photosynthetic constraint CO2 = 350 ppm
        plot(nfseq,PC350,axes=F,
             type='l',xlim=c(0,0.05),ylim=c(0,4), 
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
        points(VLong$equilnf, inst700$equilNPP, cex = 2.0, col = "darkgreen", pch=19)
        
        # VL intersect with CO2 = 700 ppm
        points(VLong700$equilnf, VLong700$equilNPP, cex = 2.0, col = "orange", pch = 19)
        
        legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
                             expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
                             "VL nutrient constraint", "L nutrient constraint",
                             "A", "B"),
               col=c("cyan","green", "tomato", "violet","blue", "darkgreen"), 
               lwd=c(2,2,2,2,NA,NA), pch=c(NA,NA,NA,NA,19,19), cex = 1.0, 
               bg = adjustcolor("grey", 0.8))
        
        legend(0.04, 3.55, c("C", "D"),
               col=c("red", "orange"), 
               lwd=c(NA,NA), pch=c(19,19), cex = 1.0, border=FALSE, bty="n",
               bg = adjustcolor("grey", 0.8))  

        
        dev.off()
        
    } else if (f.flag == 2) {
        return(cDF)
    } else if (f.flag == 3) {
        return(eDF)
    }
}
