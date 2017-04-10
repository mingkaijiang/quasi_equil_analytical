
#### Analytical script to match GDAY Run 4 settings
####
#### Assumptions:
#### Same as Run 1, except
#### 1. Autotrophic respiration is a function of tissue N:C ratio
####
################################################################################

#### Library
require(scatterplot3d)

#### Functions
Perform_Analytical_Run4 <- function(plotting = T) {
    #### Function to perform analytical run 4 simulations
    #### Will save multiple dataframes

    ######### Main program
    
    #### setting CO2 concentrations
    CO2_1 <- 350.0
    CO2_2 <- 700.0
    
    # create nc and pc for shoot to initiate
    nfseq <- round(seq(0.01, 0.05, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq,nwvar=T))
    
    pfseq <- inferpfVL(nfseq, a_nf, Pin=0.02, Nin=0.4, pwvar=T)
    a_pf <- as.data.frame(allocp(pfseq, pwvar=T))
    
    ##### CO2 = 350
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC350 <- solveNC_respiration(nfseq, a_nf, co2=CO2_1)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=0.4)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLongN_respiration(co2=CO2_1, nwvar=T)
    equilNPP <- VLongN$equilNPP_N   
    equilpf <- equilpVL(equilNPP,Pin = 0.02,pwvar=T)   
    VLongNP <- data.frame(VLongN, equilpf)
    
    # Get Cpassive from very-long nutrient cycling solution
    aequiln <- allocn(VLongNP$equilnf,nwvar=T)
    aequilp <- allocp(VLongNP$equilpf,pwvar=T)
    pass <- passive(df=VLongNP$equilnf, a=aequiln)
    omega <- aequiln$af*pass$omegaf + aequiln$ar*pass$omegar
    CpassVLong <- omega*VLongNP$equilNPP/pass$decomp/(1-pass$qq)*1000.0
    
    # Calculate nutrient release from recalcitrant pools
    PrelwoodVLong <- aequilp$aw*aequilp$pw*VLongNP$equilNPP_N*1000.0
    NrelwoodVLong <- aequiln$aw*aequiln$nw*VLongNP$equilNPP_N*1000.0
    
    # Calculate pf based on nf of long-term nutrient exchange
    pfseqL <- inferpfL(nfseq, a_nf, Pin = 0.02+PrelwoodVLong,
                       Nin = 0.4+NrelwoodVLong,Cpass=CpassVLong, nwvar=T, pwvar=T)
    
    # Calculate long term nutrieng constraint
    NCHUGH <- NConsLong(df=nfseq, a=a_nf,Cpass=CpassVLong,
                        Nin = 0.4+NrelwoodVLong)
    
    # Find equilibrate intersection and plot
    LongN <- solveLongN_respiration(co2=CO2_1, Cpass=CpassVLong, Nin= 0.4+NrelwoodVLong, nwvar=T)
    equilpf <- equilpL(LongN, Pin = 0.02+PrelwoodVLong, Cpass=CpassVLong, 
                       nwvar=T, pwvar=T)   
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
    a_nf <- as.data.frame(allocn(nfseq, nwvar=T))
    
    pfseq <- inferpfVL(nfseq, a_nf,Pin=0.02, Nin=0.4,pwvar=T)
    a_pf <- as.data.frame(allocp(pfseq, pwvar=T))
    
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC700 <- solveNC_respiration(nfseq, a_nf, co2=CO2_2)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=0.4)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLongN_respiration(co2=CO2_2, nwvar=T)
    equilNPP <- VLongN$equilNPP_N   
    equilpf <- equilpVL(equilNPP,Pin = 0.02, pwvar=T)   
    VLongNP <- data.frame(VLongN, equilpf)
    
    out700DF <- data.frame(nfseq, pfseq, pfseqL, NC700, NCVLONG, NCHUGH)
    colnames(out700DF) <- c("nc", "pc_VL", "pc_700_L", "NPP_700", "NPP_VL",
                            "nleach_VL", "NPP_700_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    
    # Find equilibrate intersection and plot
    LongN <- solveLongN_respiration(co2=CO2_2, Cpass=CpassVLong, Nin=0.4+NrelwoodVLong, nwvar=T)
    equilNPP <- LongN$equilNPP
    
    a_new <- allocn(LongN$equilnf, nwvar=T)
    equilpf <- inferpfVL(LongN$equilnf, a_new, pwvar=T)
    
    LongNP <- data.frame(LongN, equilpf)
    
    equil700DF <- data.frame(VLongNP, LongNP)
    colnames(equil700DF) <- c("nc_VL", "NPP_VL", "pc_VL",
                              "nc_L", "NPP_L", "pc_L")
    
    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(round(nfseq,3), NC700))
    inst700 <- inst_NPP(equil350DF$nc_VL, df700)
    
    if (plotting == T) {
        ######### Plotting
        
        tiff("Plots/Analytical_Run4.tiff",
             width = 8, height = 7, units = "in", res = 300)
        par(mar=c(5.1,5.1,2.1,2.1))
        
        
        # NPP constraint by CO2 = 350
        s3d <- scatterplot3d(out350DF$nc, out350DF$pc_VL, out350DF$NPP_350, xlim=c(0.0, 0.05),
                             ylim = c(0.0, 0.002), zlim=c(0, 5), 
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
                     inst700$equilNPP, type="h", col = "darkgreen", pch=19)
        
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
    }
}

#### Main program

Perform_Analytical_Run4(plotting = T)