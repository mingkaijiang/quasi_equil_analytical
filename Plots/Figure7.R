#### To plot Figure 7
#### comparison of analytical run 8.1 and 8.2
#### Plant N uptake: GDAY vs. OCN

#### Program

gday_vs_ocn_plot <- function() {
    
    ######## GDAY approach
    source("Parameters/Analytical_Run8_1_Parameters.R")
    
    # N:C ratios for x-axis
    nfseq <- seq(0.001,0.1,by=0.001)
    # need allocation fractions here
    a_vec <- allocn(nfseq)
    
    # plot photosynthetic constraints
    PC350_gday <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_1)
    PC700_gday <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_2)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG_gday <- NConsVLong_root_gday(df=nfseq,a=a_vec)
    
    # solve very-long nutrient cycling constraint
    VLongN_gday <- solveVLong_root_gday(CO2_1)
    
    # Get Cpassive from very-long nutrient cycling solution
    aequiln <- allocn(VLongN_gday$equilnf)
    pass <- slow_pool(df=VLongN_gday$equilnf, a=aequiln)
    omegap <- aequiln$af*pass$omegafp + aequiln$ar*pass$omegarp
    omegas <- aequiln$af*pass$omegafs + aequiln$ar*pass$omegars
    CpassVLong <- omegap*VLongN_gday$equilNPP/pass$decomp_p/(1-pass$qpq)*1000.0
    
    # Calculate nutrient release from recalcitrant pools
    NrelwoodVLong <- aequiln$aw*aequiln$nw*VLongN_gday$equilNPP*1000.0
    
    # Calculate long term nutrieng constraint
    NCHUGH_gday <- NConsLong_root_gday(df=nfseq, a=a_vec,Cpass=CpassVLong,
                                  NinL = Nin)#+NrelwoodVLong)
    
    # Find equilibrate intersection and plot
    equil_long_350_gday <- solveLong_root_gday(CO2_1, Cpass=CpassVLong, NinL= Nin)#+NrelwoodVLong)
    equil_long_700_gday <- solveLong_root_gday(CO2_2, Cpass=CpassVLong, NinL= Nin)#+NrelwoodVLong)
    
    CslowLong <- omegas*equil_long_350_gday$equilNPP/pass$decomp_s/(1-pass$qsq)*1000.0
    
    # plot medium nutrient cycling constraint
    NCMEDIUM_gday <- NConsMedium_root_gday(nfseq, a_vec, Cpass=CpassVLong, Cslow=CslowLong, NinL=Nin+NrelwoodVLong)
    
    # solve medium term equilibrium at CO2 = 700 ppm
    equil_medium_700_gday <- solveMedium_root_gday(CO2_2,Cpass=CpassVLong,Cslow=CslowLong,Nin=Nin+NrelwoodVLong)
    
    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(round(nfseq,3), PC700_gday))
    inst700_gday <- inst_NPP(VLongN_gday$equilnf, df700)
    
    ## locate the intersect between VL nutrient constraint and CO2 = 700
    VLong700_gday <- solveVLong_root_gday(CO2=CO2_2)
    
    
    ######## OCN approach
    source("Parameters/Analytical_Run8_2_Parameters.R")
    
    # N:C ratios for x-axis
    nfseq <- seq(0.001,0.1,by=0.001)
    # need allocation fractions here
    a_vec <- allocn(nfseq)
    
    # plot photosynthetic constraints
    PC350_ocn <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_1)
    PC700_ocn <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_2)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    VLongN_ocn <- NConsVLong_root_ocn(CO2_1)
    
    # Get Cpassive from very-long nutrient cycling solution
    aequiln <- allocn(VLongN_ocn$equilnf)
    pass <- slow_pool(df=VLongN_ocn$equilnf, a=aequiln)
    omegap <- aequiln$af*pass$omegafp + aequiln$ar*pass$omegarp
    omegas <- aequiln$af*pass$omegafs + aequiln$ar*pass$omegars
    CpassVLong <- omegap*VLongN_ocn$equilNPP/pass$decomp_p/(1-pass$qpq)*1000.0
    
    # Calculate nutrient release from recalcitrant pools
    NrelwoodVLong <- aequiln$aw*aequiln$nw*VLongN_ocn$equilNPP*1000.0
    
    # Calculate long term nutrieng constraint
    NCHUGH_ocn <- NConsLong_root_ocn(df=nfseq, a=a_vec,Cpass=CpassVLong,
                                 NinL = Nin)#+NrelwoodVLong)
    
    # Find equilibrate intersection and plot
    equil_long_350_ocn <- solveLong_root_ocn(CO2_1, Cpass=CpassVLong, NinL= Nin)#+NrelwoodVLong)
    equil_long_700_ocn <- solveLong_root_ocn(CO2_2, Cpass=CpassVLong, NinL= Nin)#+NrelwoodVLong)
    
    CslowLong <- omegas*equil_long_350_ocn$equilNPP/pass$decomp_s/(1-pass$qsq)*1000.0
    
    # plot medium nutrient cycling constraint
    NCMEDIUM_ocn <- NConsMedium_root_ocn(nfseq, a_vec, Cpass=CpassVLong, Cslow=CslowLong, NinL=Nin+NrelwoodVLong)
    
    # solve medium term equilibrium at CO2 = 700 ppm
    equil_medium_700_ocn <- solveMedium_root_ocn(CO2_2,Cpass=CpassVLong,Cslow=CslowLong,Nin=Nin+NrelwoodVLong)
    
    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(round(nfseq,3), PC700_ocn))
    inst700_ocn <- inst_NPP(VLongN_ocn$equilnf, df700)
    
    ## locate the intersect between VL nutrient constraint and CO2 = 700
    VLong700_ocn <-  NConsVLong_root_ocn(CO2_2)
    
    
    ########## Plotting
    tiff("Plots/Figure7.tiff",
         width = 12, height = 7, units = "in", res = 300)
    par(mfrow=c(1,2), mar=c(5.1,6.1,2.1,2.1))
    
    
    # GDAY approach
    plot(nfseq,PC350_gday,axes=T,
         type='l',xlim=c(0.001,0.05),ylim=c(0.0,3.0), 
         ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
         xlab = "Shoot N:C ratio", lwd = 2.5, col="cyan", cex.lab = 1.5)
    points(nfseq,PC700_gday,type='l',col="green", lwd = 2.5)
    points(nfseq,NCVLONG_gday$NPP_N,type='l',col="tomato", lwd = 2.5)
    points(nfseq,NCHUGH_gday$NPP,type='l',col="violet", lwd = 2.5)
    points(VLongN_gday$equilnf,VLongN_gday$equilNPP, pch = 19, cex = 2.0, col = "blue")
    with(equil_long_700_gday,points(equilnf,equilNPP,pch=19, cex = 2.0, col = "red"))
    points(VLongN_gday$equilnf, inst700_gday$equilNPP, cex = 2.0, col = "darkgreen", pch=19)
    points(VLong700_gday$equilnf, VLong700_gday$equilNPP, cex = 2.0, col = "orange", pch = 19)
    points(nfseq, NCMEDIUM_gday$NPP, type="l", col="darkred", lwd = 2.5)
    points(equil_medium_700_gday$equilnf, equil_medium_700_gday$equilNPP, cex = 2.0, col = "purple", pch = 19)
    text(x=0.005, y=2.9, "(a)", cex = 2)
    
    
    # OCN approach
    plot(nfseq,PC350_ocn,axes=T,
         type='l',xlim=c(0.001,0.05),ylim=c(0.0,3.0), 
         ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
         xlab = "Shoot N:C ratio", lwd = 2.5, col="cyan", cex.lab = 1.5)
    points(nfseq,PC700_ocn,type='l',col="green", lwd = 2.5)
    points(nfseq,NCHUGH_ocn$NPP,type='l',col="violet", lwd = 2.5)
    points(VLongN_ocn$equilnf,VLongN_ocn$equilNPP, pch = 19, cex = 2.0, col = "blue")
    with(equil_long_700_ocn,points(equilnf,equilNPP,pch=19, cex = 2.0, col = "red"))
    points(VLong700_ocn$equilnf, VLong700_ocn$equilNPP, cex = 2.0, col = "orange", pch = 19)
    points(nfseq, NCMEDIUM_ocn$NPP, type="l", col="darkred", lwd = 2.5)
    points(equil_medium_700_ocn$equilnf, equil_medium_700_ocn$equilNPP, cex = 2.0, col = "purple", pch = 19)
    points(VLongN_ocn$equilnf, inst700_ocn$equilNPP, cex = 1.0, col = "darkgreen", pch=19)
    text(x=0.005, y=2.9, "(b)", cex = 2)
    
    
    # legend
    legend("bottomright", c("P350", "P700", "VL", "L", "M",
                         "A", "B", "C", "D", "E"),
           col=c("cyan","green", "tomato", "violet","darkred","blue", "darkgreen","purple","red", "orange"), 
           lwd=c(2,2,2,2,2,NA,NA,NA,NA,NA), pch=c(NA,NA,NA,NA,NA,19,19,19,19,19), cex = 1.0, 
           bg = adjustcolor("grey", 0.8), ncol=2)
    
    dev.off()
    
}



#### Script
gday_vs_ocn_plot()

