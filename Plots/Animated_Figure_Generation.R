#### To generate an animated conceptual figure
#### for quasi-equilibrium analysis

### Function


### generating analytical solutions
analytical_generation <- function(inDF) {
    
    ######### Main program
    source("Parameters/Analytical_Run1_Parameters.R")
    
    # create a range of nc for shoot to initiate
    nfseq <- round(seq(0.001, 0.1, by = 0.001),5)
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
    
    pass <- slow_pool(df=VLong_equil$equilnf, a=aequiln)
    omegap <- aequiln$af*pass$omegafp + aequiln$ar*pass$omegarp
    CpassVLong <- omegap*VLong_equil$equilNPP/pass$decomp_p/(1-pass$qpq)*1000.0
    
    # Calculate long term nutrient constraint
    NCLONG <- Long_constraint_N(nfseq, a_nf, CpassVLong,
                                NinL = Nin)#+NrelwoodVLong)
    
    # Calculate pf based on nf of long-term nutrient exchange
    pfseqL <- inferpfL(nfseq, a_nf, PinL = Pin,#+PrelwoodVLong,
                       NinL = Nin,#+NrelwoodVLong,
                       Cpass=CpassVLong)
    
    PCLONG <- Long_constraint_P(nfseq, pfseqL, allocp(pfseqL),
                                CpassVLong, PinL=Pin)#+PrelwoodVLong)
    
    # Find long term equilibrium point
    Long_equil <- solveLong_full_cnp(CO2=CO2_1, Cpass=CpassVLong, NinL = Nin,#+NrelwoodVLong, 
                                     PinL=Pin)#+PrelwoodVLong)
    
    # Get Cslow from long nutrient cycling solution
    omegas <- aequiln$af*pass$omegafs + aequiln$ar*pass$omegars
    CslowLong <- omegas*Long_equil$equilNPP/pass$decomp_s/(1-pass$qsq)*1000.0
    
    ### Calculate nutrient release from slow woody pool
    PrelwoodVLong <- aequilp$aw*aequilp$pw*VLong_equil$equilNPP*1000.0
    NrelwoodVLong <- aequiln$aw*aequiln$nw*VLong_equil$equilNPP*1000.0
    
    # Calculate pf based on nf of medium-term nutrient exchange
    pfseqM <- inferpfM(nfseq, a_nf, PinM = Pin+PrelwoodVLong,
                       NinM = Nin+NrelwoodVLong,
                       CpassL=CpassVLong, CpassM=CslowLong)
    
    # Calculate medium term nutrient constraint
    NCMEDIUM <- NConsMedium(df=nfseq, 
                            a=a_nf, 
                            Cpass=CpassVLong, 
                            Cslow=CslowLong, 
                            NinL = Nin+NrelwoodVLong)
    # PCMEDIUM_350 is implicit, but can also be calculated if needed
    
    Medium_equil_350 <- solveMedium_full_cnp(CO2=CO2_1, Cpass=CpassVLong, Cslow=CslowLong, NinL = Nin+NrelwoodVLong,
                                             PinL=Pin+PrelwoodVLong)
    
    inDF$aCO2 <- Photo350
    inDF$VL <- NCVLONG$NPP_N
    inDF$L <- NCLONG$NPP
    inDF$M <- NCMEDIUM$NPP
    
    equil350DF <- data.frame(VLong_equil, Long_equil)
    colnames(equil350DF) <- c("nc_VL", "pc_VL", "NPP_VL", 
                              "nc_L","pc_L", "NPP_L")
    
    
    ##### CO2 = 700
    
    # N:C and P:C ratio
    nfseq <- round(seq(0.001, 0.1, by = 0.001),5)
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
    Long_equil <- solveLong_full_cnp(CO2=CO2_2, Cpass=CpassVLong, NinL = Nin,#+NrelwoodVLong, 
                                     PinL=Pin)#+PrelwoodVLong)
    
    # Find medium term equilibrium point
    Medium_equil_350 <- solveMedium_full_cnp(CO2_1, Cpass = CpassVLong, Cslow = CslowLong, 
                                             NinL=Nin+NrelwoodVLong, PinL=Pin+PrelwoodVLong)
    Medium_equil_700 <- solveMedium_full_cnp(CO2_2, Cpass = CpassVLong, Cslow = CslowLong, 
                                             NinL=Nin+NrelwoodVLong, PinL=Pin+PrelwoodVLong)
    
    inDF$eCO2 <- Photo700
    
    
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
    
    return(inDF)
}



### master function
Animated_Figure_Generation <- function() {
    
    # library
    require(plotly)
    
    ### Create df to store all the constraints
    nfseq <- round(seq(0.001, 0.1, b=0.001), 5)
    csDF <- data.frame(nfseq, NA, NA, NA, NA, NA)
    colnames(csDF) <- c("nf", "aCO2", "eCO2", "VL",
                        "L", "M")
    
    # generate constraint lines 
    csDF.new <- analytical_generation(csDF) 
    
    # generate constraint moving points
    t <- c(1:600)
    mvDF <- data.frame(t, NA, NA)
    colnames(mvDF) <- c("Year", "nf", "NPP")
    mvDF[mvDF$Year == 1, "nf"] <- 0.02006922
    mvDF[mvDF$Year == 1, "NPP"] <- 1.556131
    mvDF[mvDF$Year == 2, "nf"] <- 0.02006922
    mvDF[mvDF$Year == 2, "NPP"] <- 1.914975
    mvDF[mvDF$Year == 50, "nf"] <- 0.01387631
    mvDF[mvDF$Year == 50, "NPP"] <- 1.528169
    mvDF[mvDF$Year >= 500, "nf"] <- 0.01748884
    mvDF[mvDF$Year >= 500, "NPP"] <- 1.770505
    
    # set equation for the range between I and M constraint
    a <- 62.46
    b <- 0.66
    diff <- mvDF[mvDF$Year == 2, "nf"] - mvDF[mvDF$Year == 50, "nf"]
    interval <- diff / 48
    for (i in 3:49) {
        mvDF[mvDF$Year == i, "nf"] <- mvDF[mvDF$Year == 2, "nf"] - interval * (i - 2)
        mvDF[mvDF$Year == i, "NPP"] <- mvDF[mvDF$Year == i, "nf"] * a + b
    }
    
    # set range between M and L
    diff <- mvDF[mvDF$Year == 500, "nf"] - mvDF[mvDF$Year == 50, "nf"] 
    interval <- diff / 449
    for (i in 51:499) {
        mvDF[mvDF$Year == i, "nf"] <- mvDF[mvDF$Year == 50, "nf"] + interval * (i - 50)
        mvDF[mvDF$Year == i, "NPP"] <- mvDF[mvDF$Year == i, "nf"] * a + b
    }
    
    ### Plotting
    dir.create(file.path("Plots/animated"), showWarnings = FALSE)

    frames <- t
    for (i in frames) {
        
        # creating a name for each plot file with leading zeros
        if (i < 10) {name = paste('Plots/animated/000',i,'plot.png',sep='')}
        if (i < 100 && i >= 10) {name = paste('Plots/animated/00',i,'plot.png', sep='')}
        if (i >= 100) {name = paste('Plots/animated/0', i,'plot.png', sep='')}
        
        png(name)
        
        split.screen(c(2,2))
        
        #split.screen(c(1,2), screen=2)
        
        screen(3)
        # plot the baseline constraint curves
        with(csDF.new, plot(aCO2~nf, type="l", 
                            xlim=c(0.01, 0.05),
                            ylim=c(0.5, 3), 
                            xlab = "Shoot N:C ratio", 
                            ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
                            col="cyan", lwd = 1.5, cex.lab=1.0))
        with(csDF.new, lines(eCO2~nf, col="green", type="l", lwd = 1.5))
        with(csDF.new, lines(VL~nf, type="l", col="tomato", lwd = 1.5))
        with(csDF.new, lines(L~nf, type="l", col="violet", lwd = 1.5))
        with(csDF.new, lines(M~nf, type="l", col="darkred", lwd = 1.5))
        
        # plot the time-variant constraint points
        if (i >= 1 & i < 2) {
            with(mvDF[i,], points(nf, NPP, cex=2, pch=16, col="blue",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
        } else if (i >= 2 & i < 50) {
            with(mvDF[1,], points(nf, NPP, cex=2, pch=16, col="blue",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
            with(mvDF[i,], points(nf, NPP, cex=2, pch=16, col="darkgreen",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
        } else if (i >= 50 & i < 500) {
            with(mvDF[1,], points(nf, NPP, cex=2, pch=16, col="blue",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
            with(mvDF[2,], points(nf, NPP, cex=2, pch=16, col="darkgreen",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
            with(mvDF[i,], points(nf, NPP, cex=2, pch=16, col="purple",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
        } else if (i >= 500 & i < 600) {
            with(mvDF[1,], points(nf, NPP, cex=2, pch=16, col="blue",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
            with(mvDF[2,], points(nf, NPP, cex=2, pch=16, col="darkgreen",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
            with(mvDF[50,], points(nf, NPP, cex=2, pch=16, col="purple",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
            with(mvDF[i,], points(nf, NPP, cex=2, pch=16, col="red",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
        } else if (i >= 600) {
            with(mvDF[1,], points(nf, NPP, cex=2, pch=16, col="blue",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
            with(mvDF[2,], points(nf, NPP, cex=2, pch=16, col="darkgreen",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
            with(mvDF[50,], points(nf, NPP, cex=2, pch=16, col="purple",
                                   xlim=c(0.01, 0.05), 
                                   ylim=c(0, 3)))
            with(mvDF[500,], points(nf, NPP, cex=2, pch=16, col="red",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
            with(mvDF[i,], points(nf, NPP, cex=2, pch=16, col="orange",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
        } else {
            with(mvDF[i,], points(nf, NPP, cex=1, pch=16, col="black",
                                  xlim=c(0.01, 0.05), 
                                  ylim=c(0, 3)))
        }
        
    
        # plot the time series nf
        screen(1)
        with(mvDF[1, ], plot(Year, nf, pch=16, cex=2,
                             xlim=c(0, 600), ylim=c(0.01, 0.03),
                             xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0, col="blue"))
        with(mvDF[1:i, ], lines(Year, nf, col="black",
                                xlim=c(0, 600), ylim=c(0.01, 0.03),
                                xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
        
        if (i >= 2 & i < 50) {
            with(mvDF[1, ], points(Year, nf, pch=16, cex=2,
                                 xlim=c(0, 600), ylim=c(0.01, 0.03),
                                 xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0, col="blue"))
            with(mvDF[i, ], points(Year, nf, pch=16, col="darkgreen", cex = 2, 
                                    xlim=c(0, 600), ylim=c(0.01, 0.03),
                                    xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
        } else if ( i >= 50 & i < 500) {
            with(mvDF[1, ], points(Year, nf, pch=16, cex=2,
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0, col="blue"))
            with(mvDF[2, ], points(Year, nf, pch=16, col="darkgreen", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
            with(mvDF[i, ], points(Year, nf, pch=16, col="purple", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
        } else if (i >= 500 & i < 600) {
            with(mvDF[1, ], points(Year, nf, pch=16, cex=2,
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0, col="blue"))
            with(mvDF[2, ], points(Year, nf, pch=16, col="darkgreen", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
            with(mvDF[50, ], points(Year, nf, pch=16, col="purple", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
            with(mvDF[i, ], points(Year, nf, pch=16, col="red", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
        } else if (i >= 600) {
            with(mvDF[1, ], points(Year, nf, pch=16, cex=2,
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0, col="blue"))
            with(mvDF[2, ], points(Year, nf, pch=16, col="darkgreen", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
            with(mvDF[50, ], points(Year, nf, pch=16, col="purple", cex = 2, 
                                    xlim=c(0, 600), ylim=c(0.01, 0.03),
                                    xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
            with(mvDF[500, ], points(Year, nf, pch=16, col="red", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
            with(mvDF[i, ], points(Year, nf, pch=16, col="orange", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.01, 0.03),
                                   xlab="Year", ylab="Shoot N:C ratio", cex.lab=1.0))
        }
        
        # plot time series NPP
        screen(2)
        with(mvDF[1, ], plot(Year, NPP, pch=16, col="blue", cex = 2, 
                             xlim=c(0, 600), ylim=c(0.8, 2),
                             xlab="Year", 
                             ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
        
        with(mvDF[1:i, ], lines(Year, NPP, col="black",
                                xlim=c(0, 600), ylim=c(0.8, 2),
                                xlab="Year", 
                                ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
        
        if (i >= 2 & i < 50) {
            with(mvDF[1, ], points(Year, NPP, pch=16, col="blue", cex = 2, 
                                 xlim=c(0, 600), ylim=c(0.8, 2),
                                 xlab="Year", 
                                 ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[i, ], points(Year, NPP, pch=16, col="darkgreen", cex = 2, 
                                    xlim=c(0, 600), ylim=c(0.8, 2),
                                    xlab="Year", 
                                    ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
        } else if (i >= 50 & i < 500) {
            with(mvDF[1, ], points(Year, NPP, pch=16, col="blue", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[2, ], points(Year, NPP, pch=16, col="darkgreen", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[i, ], points(Year, NPP, pch=16, col="purple", cex = 2, 
                                     xlim=c(0, 600), ylim=c(0.8, 2),
                                     xlab="Year", 
                                     ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
        } else if (i >= 500 & i < 600) {
            with(mvDF[1, ], points(Year, NPP, pch=16, col="blue", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[2, ], points(Year, NPP, pch=16, col="darkgreen", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[50, ], points(Year, NPP, pch=16, col="purple", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[i, ], points(Year, NPP, pch=16, col="red", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
        } else if (i >= 600) {
            with(mvDF[1, ], points(Year, NPP, pch=16, col="blue", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[2, ], points(Year, NPP, pch=16, col="darkgreen", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[50, ], points(Year, NPP, pch=16, col="purple", cex = 2, 
                                    xlim=c(0, 600), ylim=c(0.8, 2),
                                    xlab="Year", 
                                    ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[500, ], points(Year, NPP, pch=16, col="red", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
            with(mvDF[i, ], points(Year, NPP, pch=16, col="orange", cex = 2, 
                                   xlim=c(0, 600), ylim=c(0.8, 2),
                                   xlab="Year", 
                                   ylab=expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")), cex.lab=1.0))
        }
        
        screen(4)
        plot(1,xaxt='n',yaxt='n',bty='n',pch='',ylab='',xlab='')
        # add legends
        legend("bottomright", c("P350", "P700", "VL", "L", "M",
                                "A", "B", "C", "D", "E"),
               col=c("cyan","green", "tomato", "violet","darkred","blue", "darkgreen","purple","red", "orange"), 
               lwd=c(2,2,2,2,2,NA,NA,NA,NA,NA), pch=c(NA,NA,NA,NA,NA,19,19,19,19,19), cex = 1.0, 
               bg = adjustcolor("grey", 0.8), ncol=2)
        
        
        dev.off()
    }
    
    # system command to make it animated
    system("convert Plots/animated/*.png -delay 3 -loop 0 Plots/animated.gif")
    
    
    
    
}


### Script
Animated_Figure_Generation() 
