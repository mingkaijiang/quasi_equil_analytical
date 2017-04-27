
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
    
    #### setting CO2 concentrations
    CO2_1 <- 350.0
    CO2_2 <- 700.0
    
    # create nc and pc for shoot to initiate
    nfseq <- round(seq(0.01, 0.05, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq,nwvar=F))
    
    ##### CO2 = 350
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC350 <- solveNC(nfseq, a_nf$af, co2=CO2_1)
    
    # Get Cpassive from very-long nutrient cycling solution
    pass <- passive(df=nfseq, a=a_nf)
    omega <- a_nf$af*pass$omegaf + a_nf$ar*pass$omegar
    
    # Calculate long term nutrieng constraint
    NCHUGH <- NConsLong_root_ocn(df=nfseq, a=a_nf,
                                 Nin = 0.4)
    
    # Find equilibrate intersection and plot
    LongN350 <- solveLongN_root_ocn(co2=CO2_1, Nin= 0.4, nwvar=F)
    
    out350DF <- data.frame(nfseq, NC350, NCHUGH)
    colnames(out350DF) <- c("nc", "NPP_350",  "NPP_350_L", "Nmin_L", "aw")

    
    ##### CO2 = 700
    
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC700 <- solveNC(nfseq, a_nf$af, co2=CO2_2)
    
    out700DF <- data.frame(nfseq, NC700, NCHUGH)
    colnames(out700DF) <- c("nc", "NPP_700",  "NPP_700_L", "Nmin_L", "aw")
    
    
    # Find equilibrate intersection and plot
    LongN700 <- solveLongN_root_ocn(co2=CO2_2, Nin=0.4, nwvar=F)

    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(round(nfseq,3), NC700))
    inst700 <- inst_NPP(LongN700$equilnf, df700)

        
    ######### Plotting
    
    #tiff("Plots/Analytical_Run8_2.tiff",
    #     width = 8, height = 7, units = "in", res = 300)
    #par(mar=c(5.1,5.1,2.1,2.1))
    
    
    # NPP constraint by CO2 = 350
    plot(out350DF$nc, out350DF$NPP_350, xlim=c(0.0, 0.05),
         ylim = c(0.0,5.0), 
         type = "l", xlab = "Shoot N:C ratio", 
         ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
         col="cyan", lwd = 3)
    
    # NPP constraint by long term nutrient availability
    points(out350DF$nc, out350DF$NPP_350_L, type="b", col="tomato", lwd = 3)
    
    # equilibrated NPP for very long term nutrient and CO2 = 350
    points(LongN350$equilnf, LongN350$equilNPP,
           type="p", pch = 19, col = "blue")
    
    
    # NPP constraint by CO2 = 700
    points(out700DF$nc, out700DF$NPP_700, col="green", type="l", lwd = 3)
    
    # equilibrated NPP for very long term nutrient and CO2 = 700
    points(LongN700$equilnf,LongN700$equilNPP, 
           type="p", col="orange", pch = 19)
    
    legend("topright", c(expression(paste("Photo constraint at ", CO[2]," = 350 ppm")), 
                         expression(paste("Photo constraint at ", CO[2]," = 700 ppm")), 
                         "L nutrient constraint",
                         "A", "B"),
           col=c("cyan","green", "tomato", "blue", "orange"), 
           lwd=c(2,2,2,NA,NA), pch=c(NA,NA,NA,19,19), cex = 1.0, 
           bg = adjustcolor("grey", 0.8))
    
    #dev.off()    

    
}
