
#### Analytical script to match GDAY Run 8.1 settings
####
#### Same as Run 7, except
#### 1. N uptake rates as a function of root biomass - GDAY approach: saturaing function of root biomass
#### 2. Fixed passive SOM stoichiometry
####
################################################################################


#### Functions
Perform_Analytical_Run8_1 <- function(f.flag = 1, cDF, eDF) {
    #### Function to perform analytical run 8.1 simulations
    #### eDF: stores equilibrium points
    #### cDF: stores constraint points (curves)
    #### f.flag: = 1 simply plot analytical solution file
    #### f.flag: = 2 return cDF
    #### f.flag: = 3 return eDF

    ######### Main program
    
    #### setting CO2 concentrations
    CO2_1 <- 350.0
    CO2_2 <- 700.0
    
    # create nc and pc for shoot to initiate
    nfseq <- round(seq(0.01, 0.05, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq,nwvar=T))
    
    pfseq <- inferpfVL_root_gday(nfseq, a_nf, Pin=0.02, Nin=0.4, pwvar=T)
    a_pf <- as.data.frame(allocp(pfseq, pwvar=T))
    
    ##### CO2 = 350
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC350 <- solveNC(nfseq, a_nf$af, co2=CO2_1)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong_root_gday(df=nfseq,a=a_nf,Nin=0.4)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLongN_root_gday(co2=CO2_1, nwvar=T)
    equilNPP <- VLongN$equilNPP_N   
    equilpf <- equilpVL_root_gday(equilNPP,Pin = 0.02,pwvar=T)   
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
    pfseqL <- inferpfL_root_gday(nfseq, a_nf, Pin = 0.02+PrelwoodVLong,
                                Nin = 0.4+NrelwoodVLong,Cpass=CpassVLong, nwvar=T, pwvar=T)
    
    # Calculate long term nutrieng constraint
    NCHUGH <- NConsLong_root_gday(df=nfseq, a=a_nf,Cpass=CpassVLong,
                                 Nin = 0.4+NrelwoodVLong)
    
    # Find equilibrate intersection and plot
    LongN <- solveLongN_root_gday(co2=CO2_1, Cpass=CpassVLong, Nin= 0.4+NrelwoodVLong, nwvar=T)
    equilpf <- equilpL_root_gday(LongN, Pin = 0.02+PrelwoodVLong, Cpass=CpassVLong, 
                                nwvar=T, pwvar=T)   
    LongNP <- data.frame(LongN, equilpf)
    
    out350DF <- data.frame(nfseq, pfseq, pfseqL, NC350, NCVLONG, NCHUGH)
    colnames(out350DF) <- c("nc", "pc_VL", "pc_350_L", "NPP_350", "NPP_VL",
                            "nleach_VL", "NPP_350_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    equil350DF <- data.frame(VLongNP, LongNP)
    colnames(equil350DF) <- c("nc_VL", "NPP_VL", "pc_VL",
                              "nc_L", "NPP_L", "pc_L")
    
    # store constraint and equil DF onto their respective output df
    cDF[cDF$Run == 8 & cDF$CO2 == 350, 3:13] <- out350DF
    eDF[eDF$Run == 8 & eDF$CO2 == 350, 3:8] <- equil350DF
    
    ##### CO2 = 700
    
    # N:C and P:C ratio
    nfseq <- round(seq(0.01, 0.05, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq, nwvar=T))
    
    pfseq <- inferpfVL_root_gday(nfseq, a_nf,Pin=0.02, Nin=0.4,pwvar=T)
    a_pf <- as.data.frame(allocp(pfseq, pwvar=T))
    
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC700 <- solveNC(nfseq, a_nf$af, co2=CO2_2)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong_root_gday(df=nfseq,a=a_nf,Nin=0.4)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLongN_root_gday(co2=CO2_2, nwvar=T)
    equilNPP <- VLongN$equilNPP_N   
    equilpf <- equilpVL_root_gday(equilNPP,Pin = 0.02, pwvar=T)   
    VLongNP <- data.frame(VLongN, equilpf)
    
    out700DF <- data.frame(nfseq, pfseq, pfseqL, NC700, NCVLONG, NCHUGH)
    colnames(out700DF) <- c("nc", "pc_VL", "pc_700_L", "NPP_700", "NPP_VL",
                            "nleach_VL", "NPP_700_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    
    # Find equilibrate intersection and plot
    LongN <- solveLongN_root_gday(co2=CO2_2, Cpass=CpassVLong, Nin=0.4+NrelwoodVLong, nwvar=T)
    equilNPP <- LongN$equilNPP
    
    a_new <- allocn(LongN$equilnf, nwvar=T)
    equilpf <- inferpfVL_root_gday(LongN$equilnf, a_new, pwvar=T)
    
    LongNP <- data.frame(LongN, equilpf)
    
    equil700DF <- data.frame(VLongNP, LongNP)
    colnames(equil700DF) <- c("nc_VL", "NPP_VL", "pc_VL",
                              "nc_L", "NPP_L", "pc_L")
    
    # store constraint and equil DF onto their respective output df
    cDF[cDF$Run == 8 & cDF$CO2 == 700, 3:13] <- out700DF
    eDF[eDF$Run == 8 & eDF$CO2 == 700, 3:8] <- equil700DF
    
    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(round(nfseq,3), NC700))
    inst700 <- inst_NPP(equil350DF$nc_VL, df700)
    
    if (f.flag == 1) {
        
        #### Library
        require(scatterplot3d)
        
        ######### Plotting
        
        tiff("Plots/Analytical_Run8_1.tiff",
             width = 8, height = 7, units = "in", res = 300)
        par(mar=c(5.1,5.1,2.1,2.1))
        
        
        # NPP constraint by CO2 = 350
        plot(out350DF$nc, out350DF$NPP_350, xlim=c(0.0, 0.05),
             ylim=c(0, 5), 
             type = "l", xlab = "Shoot N:C ratio", 
             ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
             col="cyan", lwd = 3)
        
        # NPP constraint by very long term nutrient availability
        points(out350DF$nc, out350DF$NPP_VL, type="l", col="tomato", lwd = 3)
        
        # equilibrated NPP for very long term nutrient and CO2 = 350
        points(equil350DF$nc_VL, equil350DF$NPP_VL,
                     type="p", pch = 19, col = "blue")
        
        # NPP constraint by long term nutrient availability
        points(out350DF$nc, out350DF$NPP_350_L, type='l',col="violet", lwd = 3)

        
        # NPP constraint by CO2 = 700
        points(out700DF$nc, out700DF$NPP_700, col="green", type="l", lwd = 3)
        
        points(equil350DF$nc_VL,
                     inst700$equilNPP, type="p", col = "darkgreen", pch=19)
        
        # equilibrated NPP for very long term nutrient and CO2 = 700
        points(equil700DF$nc_VL,  equil700DF$NPP_VL, 
                     type="p", col="orange", pch = 19)
        
        # equilibrated NPP for long term nutrient and CO2 = 700
        points(equil700DF$nc_L, equil700DF$NPP_L,
                     type="p", col="red", pch = 19)
        
        
        legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
                            expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
                            "VL nutrient constraint", "L nutrient constraint",
                            "A", "B", "C", "D"),
               col=c("cyan","green", "tomato", "violet","blue", "darkgreen","red", "orange"), 
               lwd=c(2,2,2,2,NA,NA,NA,NA), pch=c(NA,NA,NA,NA,19,19,19,19), cex = 1.0, 
               bg = adjustcolor("grey", 0.8))
        
        dev.off()
    } else if (f.flag == 2) {
        return(cDF)
    } else if (f.flag == 3) {
        return(eDF)
    }
    
}
