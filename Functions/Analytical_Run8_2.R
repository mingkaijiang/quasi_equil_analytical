
#### Analytical script to match GDAY Run 8 settings
####
#### Same as Run 8.1, except
#### 1. fixed wood stoichiometry
#### 2. N uptake rates as a function of root biomass - O-CN approach: saturaing function of mineral N
#### 3. Fixed passive SOM stoichiometry
####
################################################################################


#### Functions
Perform_Analytical_Run8_2 <- function() {
    #### Function to perform analytical run 8.2 simulations

    ######### Main program
    source("Parameters/Analytical_Run8_2_Parameters.R")
    
    # create nc and pc for shoot to initiate
    nfseq <- round(seq(0.01, 0.1, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq))
    
    pfseq <- inferpfVL_root_ocn(nfseq, a_nf)
    a_pf <- as.data.frame(allocp(pfseq))
    
    ##### CO2 = 350
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC350 <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_1)

    # calculate very long term NC and PC constraint on NPP, respectively
    VLongN <- NConsVLong_root_ocn(CO2_1)
    
    # Get Cpassive from very-long nutrient cycling solution
    aequiln <- allocn(VLongN$equilnf)
    aequilp <- allocp(VLongN$equilpf)
    pass <- passive(df=VLongN$equilnf, a=aequiln)
    omega <- aequiln$af*pass$omegaf + aequiln$ar*pass$omegar
    CpassVLong <- omega*VLongN$equilNPP/pass$decomp/(1-pass$qq)*1000.0
    
    # Calculate nutrient release from recalcitrant pools
    PrelwoodVLong <- aequilp$aw*aequilp$pw*VLongN$equilNPP*1000.0
    NrelwoodVLong <- aequiln$aw*aequiln$nw*VLongN$equilNPP*1000.0
    
    # Calculate pf based on nf of long-term nutrient exchange
    pfseqL <- inferpfL_root_ocn(nfseq, a_nf, PinL = Pin+PrelwoodVLong,
                                 NinL = Nin+NrelwoodVLong,Cpass=CpassVLong)
    
    # Calculate long term nutrieng constraint
    NCHUGH <- NConsLong_root_ocn(df=nfseq, a=a_nf, Cpass=CpassVLong,
                                  NinL = Nin+NrelwoodVLong)
    
    # Find equilibrate intersection and plot
    LongN <- solveLong_root_ocn(CO2_1, Cpass=CpassVLong, NinL= Nin+NrelwoodVLong)
    
    out350DF <- data.frame(nfseq, pfseq, pfseqL, NC350, NCHUGH)
    colnames(out350DF) <- c("nc", "pc_VL", "pc_350_L", "NPP_350", "NPP_350_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    equil350DF <- data.frame(VLongN, LongN)
    colnames(equil350DF) <- c("nc_VL", "pc_VL","NPP_VL", 
                              "nc_L", "pc_L", "NPP_L")
    
    ##### CO2 = 700
    
    # N:C and P:C ratio
    nfseq <- round(seq(0.01, 0.1, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq))
    
    pfseq <- inferpfVL_root_ocn(nfseq, a_nf)
    a_pf <- as.data.frame(allocp(pfseq))
    
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC700 <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_2)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    VLongN <- NConsVLong_root_ocn(CO2_2)
    
    out700DF <- data.frame(nfseq, pfseq, pfseqL, NC700, NCHUGH)
    colnames(out700DF) <- c("nc", "pc_VL", "pc_700_L", "NPP_700", 
                            "NPP_700_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    
    # Find equilibrate intersection and plot
    LongN <- solveLong_root_ocn(CO2_2, Cpass=CpassVLong, NinL=Nin+NrelwoodVLong)
    
    equil700DF <- data.frame(VLongN, LongN)
    colnames(equil700DF) <- c("nc_VL", "pc_VL","NPP_VL", 
                              "nc_L", "pc_L", "NPP_L")
    

    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(round(nfseq,3), NC700))
    inst700 <- inst_NPP(equil350DF$nc_VL, df700)
        
    ######### Plotting
    
    #tiff("Plots/Analytical_Run8_2.tiff",
    #     width = 8, height = 7, units = "in", res = 300)
    #par(mar=c(5.1,5.1,2.1,2.1))
    
    
    # shoot nc vs. NPP
    plot(out350DF$nc, out350DF$NPP_350, xlim=c(0.0, 0.1),
         ylim=c(0, 3), 
         type = "l", xlab = "Shoot N:C ratio", 
         ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
         col="cyan", lwd = 3)
    points(equil350DF$nc_VL, equil350DF$NPP_VL, type="p", pch = 19, col = "blue")
    points(out350DF$nc, out350DF$NPP_350_L, type='l',col="violet", lwd = 3)
    points(out700DF$nc, out700DF$NPP_700, col="green", type="l", lwd = 3)
    points(equil350DF$nc_VL, inst700$equilNPP, type="p", col = "darkgreen", pch=19)
    points(equil700DF$nc_VL, equil700DF$NPP_VL, type="p", col="orange", pch = 19)
    
    points(equil700DF$nc_L, equil700DF$NPP_L,type="p", col="red", pch = 19)
    
    
    # shoot nc vs. shoot pc
    plot(out350DF$nc, out350DF$pc_VL, xlim=c(0.0, 0.05),
         ylim=c(0, 0.005), 
         type = "l", xlab = "Shoot N:C ratio", 
         ylab = "Shoot P:C ratio",
         col="cyan", lwd = 3)
    points(out350DF$nc, out350DF$pc_VL, type="l", col="tomato", lwd = 3)
    
    points(equil350DF$nc_VL, equil350DF$pc_VL, type="p", pch = 19, col = "blue")
    
    points(out350DF$nc, out350DF$pc_VL, type='l',col="violet", lwd = 3)
    
    points(out700DF$nc, out700DF$pc_VL, col="green", type="l", lwd = 3)
    
    points(equil350DF$nc_VL, equil350DF$pc_VL, type="p", col = "darkgreen", pch=19)
    
    points(equil700DF$nc_VL, equil700DF$pc_VL, type="p", col="orange", pch = 19)
    
    points(equil700DF$nc_L, equil700DF$pc_L, type="p", col="red", pch = 19)
    
    legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
                         expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
                         "VL nutrient constraint", "L nutrient constraint",
                         "A", "B", "C", "D"),
           col=c("cyan","green", "tomato", "violet","blue", "darkgreen","red", "orange"), 
           lwd=c(2,2,2,2,NA,NA,NA,NA), pch=c(NA,NA,NA,NA,19,19,19,19), cex = 0.7, 
           bg = adjustcolor("grey", 0.8))
    
    
    dev.off()    

    
}
