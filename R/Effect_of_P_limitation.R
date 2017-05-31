#### Functions
P_limitation_effect <- function() {
    #### Perform CNP only analysis of VL pools
    source("Parameters/Analytical_Run1_Parameters.R")
    
    # create a range of nc for shoot to initiate
    nfseq <- round(seq(0.01, 0.05, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq,nwvar=nwvar))
    
    # using very long term relationship to calculate pf from nf
    pfseq <- inferpfVL(nfseq, a_nf)
    a_pf <- as.data.frame(allocp(pfseq,pwvar=pwvar))
    
    # calculate photosynthetic constraint at CO2 = 350
    photo_350_cnp <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_1)
    photo_700_cnp <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_2)
    
    ### calculate very long term NC and PC constraint on NPP, respectively
    vlong_cnp <- VLong_constraint_N(nf=nfseq, nfdf=a_nf)
    
    ### finding the equilibrium point between photosynthesis and very long term nutrient constraints
    VLong_equil_cnp <- solveVLong_full_cnp(CO2=CO2_1, nwvar=nwvar, pwvar=pwvar)
    
    #### Perform CN only analysis of VL pools
    source("Parameters/Analytical_Run2_Parameters.R")
    
    # N:C ratios for x-axis
    nfseq <- seq(0.01,0.05,by=0.001)
    # need allocation fractions here
    a_vec <- allocn(nfseq,nwvar=nwvar)
    
    # plot photosynthetic constraints
    photo_350_cn <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_1)
    photo_700_cn <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_2)
    
    #plot very-long nutrient cycling constraint
    vlong_cn <- VLong_constraint_N(nfseq,a_vec)
    
    #solve very-long nutrient cycling constraint
    VLong_equil_cn <- solveVLong_full_cn(CO2=CO2_1, nwvar=nwvar)
    
    
    #### Plotting
    tiff("Plots/Effect_of_P_limitation.tiff",
         width = 8, height = 7, units = "in", res = 300)
    par(mar=c(5.1,6.1,2.1,2.1))

    # shoot nc vs. NPP
    plot(nfseq, photo_350_cnp, xlim=c(0.0, 0.05),
         ylim=c(0.5, 3), 
         type = "l", xlab = "Shoot N:C ratio", 
         ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
         col="blue", lwd = 3, cex.lab = 2.0)
    points(nfseq, vlong_cnp$NPP_N, type="l", col="tomato", lwd = 3)
    points(VLong_equil_cnp$equilnf, VLong_equil_cnp$equilNPP, type="p", pch = 19, col = "green", cex = 2.5)
    points(nfseq, photo_350_cn, type="l", col = "blue", lty = 3, lwd = 3)
    points(VLong_equil_cn$equilnf, VLong_equil_cn$equilNPP, type="p", pch = 19, col = "red", cex = 2.5)
    
    
    legend("topright", c("CNP constraint on photosynthesis", 
                         "CN constraint on photosynthesis", 
                         "VL nutrient constraint", 
                         "A", "B"),
           col=c("blue","blue", "tomato", "green","red"), 
           lwd=c(2,2,2,NA,NA), pch=c(NA,NA,NA,19,19), lty=c(1,3,1, NA,NA), cex = 1.2, 
           bg = adjustcolor("grey", 0.8))
    
    dev.off()
    
}


#### Program
P_limitation_effect()
