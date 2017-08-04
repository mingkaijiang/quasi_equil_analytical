#### Functions
wood_stoichiometry_effect <- function() {
    #### Perform CNP only analysis of VL pools
    source("Parameters/Analytical_Run1_Parameters.R")
    
    # create a range of nc for shoot to initiate
    nfseq <- round(seq(0.01, 0.1, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq))
    
    # using very long term relationship to calculate pf from nf
    pfseq <- inferpfVL(nfseq, a_nf)
    a_pf <- as.data.frame(allocp(pfseq))
    
    # calculate photosynthetic constraint at CO2 = 350
    photo_350_vary <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_1)
    photo_700_vary <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_2)
    
    ### calculate very long term NC and PC constraint on NPP, respectively
    vlong_vary <- VLong_constraint_N(nf=nfseq, nfdf=a_nf)
    
    ### finding the equilibrium point between photosynthesis and very long term nutrient constraints
    VLong_equil_vary_350 <- solveVLong_full_cnp(CO2=CO2_1)
    VLong_equil_vary_700 <- solveVLong_full_cnp(CO2=CO2_2)
    
    #### Perform CNP only analysis of VL pools
    source("Parameters/Analytical_Run3_Parameters.R")
    
    # create a range of nc for shoot to initiate
    nfseq <- round(seq(0.01, 0.1, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq))
    
    # using very long term relationship to calculate pf from nf
    pfseq <- inferpfVL(nfseq, a_nf)
    a_pf <- as.data.frame(allocp(pfseq))
    
    # calculate photosynthetic constraint at CO2 = 350
    photo_350_fix <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_1)
    photo_700_fix <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_2)
    
    ### calculate very long term NC and PC constraint on NPP, respectively
    vlong_fix <- VLong_constraint_N(nf=nfseq, nfdf=a_nf)
    
    ### finding the equilibrium point between photosynthesis and very long term nutrient constraints
    VLong_equil_fix_350 <- solveVLong_full_cnp(CO2=CO2_1)
    VLong_equil_fix_700 <- solveVLong_full_cnp(CO2=CO2_2)
    
    co2_effect_vary <- (VLong_equil_vary_700$equilNPP - VLong_equil_vary_350$equilNPP) / VLong_equil_vary_350$equilNPP * 100
    co2_effect_fix <- (VLong_equil_fix_700$equilNPP - VLong_equil_fix_350$equilNPP) / VLong_equil_fix_350$equilNPP * 100
 
    #### Plotting
    tiff("Plots/Effect_of_wood_stoichiometry_on_CO2_fertilization.tiff",
         width = 8, height = 7, units = "in", res = 300)
    par(mar=c(5.1,6.1,2.1,2.1))
    
    # shoot nc vs. NPP
    plot(nfseq, photo_350_vary, xlim=c(0.0, 0.1),
         ylim=c(0.5, 3), 
         type = "l", xlab = "Shoot N:C ratio", 
         ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
         col="blue", lwd = 3, cex.lab = 1.5)
    points(nfseq, vlong_vary$NPP_N, type="l", col="tomato", lwd = 3)
    points(VLong_equil_vary_350$equilnf, VLong_equil_vary_350$equilNPP, type="p", pch = 15, col = "orange", cex = 2.5)
    points(nfseq, photo_350_fix, type="l", col = "blue", lty = 3, lwd = 3)
    points(VLong_equil_fix_350$equilnf, VLong_equil_fix_350$equilNPP, type="p", pch = 15, col = "blue", cex = 2.5)
    
    points(nfseq, photo_700_vary, type="l", col="darkgreen", lwd=3)
    points(nfseq, photo_700_fix, type="l", col="darkgreen", lwd=3, lty=3)
    points(VLong_equil_vary_700$equilnf, VLong_equil_vary_700$equilNPP, type="p", pch = 15, col = "green", cex=2.5)
    points(VLong_equil_fix_700$equilnf, VLong_equil_fix_700$equilNPP, type="p", pch = 15, col = "red", cex=2.5)
    
    #    legend("bottomright", c("CNP constraint on photosynthesis, aCO2", 
    #                         "CN constraint on photosynthesis, aCO2", 
    #                         "CNP constraint on photosynthesis, eCO2", 
    #                         "CN constraint on photosynthesis, eCO2", 
    #                         "VL nutrient constraint", 
    #                         "A", "B","C","D"),
    #           col=c("blue","blue", "darkgreen", "darkgreen", "tomato", "orange","green", "blue", "red"), 
    #           lwd=c(2,2,2,2,2,NA,NA,NA,NA), pch=c(NA,NA,NA,NA,NA,15,15,15,15), lty=c(1,3,1,3,1,NA,NA,NA,NA), cex = 0.8, 
    #           bg = adjustcolor("grey", 0.8))
    
    legend("bottomleft", c("NP constraint on photosynthesis, aCO2", 
                           "N constraint on photosynthesis, aCO2", 
                           "NP constraint on photosynthesis, eCO2", 
                           "N constraint on photosynthesis, eCO2", 
                           "VL nutrient constraint"),
           col=c("blue","blue", "darkgreen", "darkgreen", "tomato"), 
           lwd=c(2,2,2,2,2),  lty=c(1,3,1,3,1), cex = 1.0)
    
    legend("topright", c("A", "B","C","D"),
           col=c("orange","green", "blue", "red"), 
           pch=c(15,15,15,15), cex = 1.0)   
    
    dev.off()
    
}


#### Program
wood_stoichiometry_effect()