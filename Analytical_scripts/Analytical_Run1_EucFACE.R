
#### Analytical script for EucFACE parameters, variable wood, P cycle on
####
#### Assumptions:
#### 1. N and P cycle on
#### 2. Variable wood stoichiometry
####
################################################################################
#### Functions
Perform_Analytical_Run1_EucFACE <- function(f.flag) {
    #### Function to perform analytical run 1 simulations
    #### f.flag: = 1 simply plot analytical solution file
    #### f.flag: = 2 return a data list

    ######### Main program
    source("Parameters/Analytical_Run1_Parameters_EucFACE.R")
    
    # create a range of nc for shoot to initiate
    nfseq <- seq(0.01, 0.1, by = 0.001)
    a_nf <- allocn(nfseq)
    
    # using very long term relationship to calculate pf from nf
    pfseq <- infer_pf_VL(nfseq, a_nf)
    a_pf <- allocp(pfseq)
    
    # calculate photosynthetic constraint at CO2 = 350
    C350 <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_1)

    ### calculate very long term NC and PC constraint on NPP, respectively
    NC_VL <- VL_constraint_N(nf=nfseq, nfdf=a_nf)
    
    ### NPP derived from PCVLONG should match NPP from NCVLONG
    PC_VL <- VL_constraint_P(pf=pfseq, pfdf=a_pf)
    
    ### finding the equilibrium point between photosynthesis and very long term nutrient constraints
    VL_eq <- solve_VL_full_cnp(CO2=CO2_1)
    
    ### Get Cpassive from very-long nutrient cycling solution
    aequiln <- allocn(VL_eq$equilnf)
    aequilp <- allocp(VL_eq$equilpf)
    pass <- passive(df=VL_eq$equilnf, a=aequiln)
    omega <- aequiln$af*pass$omegaf + aequiln$ar*pass$omegar
    C_pass_VL <- omega*VL_eq$equilNPP/pass$decomp/(1-pass$qq)*1000.0
    
    ### Calculate nutrient release from recalcitrant pools
    P_rel_wood_VL <- aequilp$aw*aequilp$pw*VL_eq$equilNPP*1000.0
    N_rel_wood_VL <- aequiln$aw*aequiln$nw*VL_eq$equilNPP*1000.0
    
    # Calculate pf based on nf of long-term nutrient exchange
    pfseq_L <- infer_pf_L(nfseq, a_nf, PinL = Pin+P_rel_wood_VL,
                         NinL = Nin+N_rel_wood_VL,
                         Cpass=C_pass_VL)
    
    # Calculate long term nutrieng constraint
    NC_L <- L_constraint_N(nfseq, a_nf, C_pass_VL,
                           NinL = Nin+N_rel_wood_VL)
    
    PC_L <- L_constraint_P(nfseq, pfseqL, allocp(pfseq_L),
                          C_pass_VL, PinL=Pin+P_rel_wood_VL)
    
    # Find long term equilibrium point
    L_eq <- solve_L_full_cnp(CO2=CO2_1, Cpass=C_pass_VL, NinL = Nin+N_rel_wood_VL, 
                               PinL=Pin+P_rel_wood_VL)


    out350DF <- data.frame(nfseq, pfseq, pfseq_L, C350, NC_VL, NC_L)
    colnames(out350DF) <- c("nc", "pc_VL", "pc_L", "NPP_photo", "NPP_VL",
                            "nleach_VL", "NPP_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    equil350DF <- data.frame(VL_eq, L_eq)
    colnames(equil350DF) <- c("nc_VL", "pc_VL", "NPP_VL", 
                              "nc_L","pc_L", "NPP_L")
    
    ##### CO2 = 700
    # N:C and P:C ratio
    nfseq <- seq(0.01, 0.1, by = 0.001)
    a_nf <- allocn(nfseq)
    
    # using very long term relationship to calculate pf from nf
    pfseq <- infer_pf_VL(nfseq, a_nf)
    a_pf <- allocp(pfseq)
    
    # calculate NC vs. NPP at CO2 = 350 respectively
    C700 <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_2)
    
    ### finding the equilibrium point between photosynthesis and very long term nutrient constraints
    VL_eq <- solve_VL_full_cnp(CO2=CO2_2)
    
    # Find long term equilibrium point
    L_eq <- solve_L_full_cnp(CO2=CO2_2, Cpass=C_pass_VL, NinL = Nin+N_rel_wood_VL, 
                                     PinL=Pin+P_rel_wood_VL)
    
    out700DF <- data.frame(nfseq, pfseq, pfseq_L, C700, NC_VL, NC_L)
    colnames(out700DF) <- c("nc", "pc_VL", "pc_L", "NPP_photo", "NPP_VL",
                            "nleach_VL", "NPP_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    
    equil700DF <- data.frame(VL_eq, L_eq)
    colnames(equil700DF) <- c("nc_VL", "pc_VL", "NPP_VL", 
                              "nc_L","pc_L", "NPP_L")
    
    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(nfseq, C700))
    inst700 <- inst_NPP(equil350DF$nc_VL, df700)
    
    equil350DF$NPP_I <- inst700$equilNPP
    equil700DF$NPP_I <- inst700$equilNPP
    
    if (f.flag == 1) {
        
        ########## Plotting
        #tiff("Plots/Analytical_Run1_3d_EucFACE.pdf")
        #
        ## NPP constraint by CO2 = 350
        #s3d <- scatter3D(out350DF$nc, out350DF$pc_VL, out350DF$NPP_photo, ticktype="detailed",
        #                     xlab = "Leaf N:C ratio", ylab = "Leaf P:C ratio", 
        #                     zlab = "Production")
        #
        ## NPP constraint by very long term nutrient availability
        #scatter3D(out350DF$nc, out350DF$pc_VL, out350DF$NPP_VL, add=T)
        #
        ## equilibrated NPP for very long term nutrient and CO2 = 350
        #scatter3D(equil350DF$nc_VL, equil350DF$pc_VL, equil350DF$NPP_VL,
        #             type="h", pch = 19, col = "blue", add=T)
        #
        #dev.off()
        
        
        p1<-ggplot() + 
            geom_line(data=out350DF, aes(x=nc, y=NPP_photo, col="C350")) +   
            geom_line(data=out350DF, aes(x=nc, y=NPP_VL, col="VL")) + 
            geom_line(data=out350DF, aes(x=nc, y=NPP_L, col="L")) +  
            #geom_line(data=out350DF, aes(x=nc, y=NPP_M, col="M")) +            
            geom_line(data=out700DF, aes(x=nc, y=NPP_photo, col="C700")) +     
            geom_point(data=equil350DF, aes(x=nc_VL, y=NPP_VL, fill="A"), 
                       color="black", shape=21, size=5) + 
            geom_point(data=equil700DF, aes(x=nc_L, y=NPP_L, fill="D"), 
                       shape=21, color="black", size=5) +
            #geom_point(data=equil700DF, aes(x=nc_M, y=NPP_M, fill="C"), 
            #           shape=21, color="black", size=5) +
            geom_point(data=equil700DF, aes(x=nc_VL, y=NPP_VL, fill="E"), 
                       shape=21, color="black", size=5) +
            geom_point(data=equil350DF, aes(x=nc_VL, y=NPP_I, fill="B"), 
                       shape=21, color="black", size=5) +
            ylim(0.5, 2.0) + 
            xlim(0.01, 0.03) +
            labs(x="Leaf N:C Ratio", 
                 y=expression(paste("NPP [kg C ", m^-2, " ", yr^-1, "]"))) +
            theme_linedraw() +
            theme(panel.grid.minor=element_blank(),
                  axis.text=element_text(size=14),
                  axis.title=element_text(size=16),
                  legend.text=element_text(size=14),
                  legend.title=element_text(size=16),
                  panel.grid.major=element_line(color="grey")) +
            scale_colour_manual(name="Constraint line", 
                                values = c("C350" = cbbPalette[1], "C700" = cbbPalette[2], "VL" = cbbPalette[7],
                                           "L" = cbbPalette[4], "M" = cbbPalette[3])) +
            scale_fill_manual(name="QE point", values = c("A" = cbPalette[1], "B" = cbPalette[2], "C" = cbPalette[3],
                                                          "D" = cbPalette[4], "E" = cbPalette[7])) 
        
        
        p2<-ggplot()+
            geom_line(data=out350DF, aes(x=nc, y=pc_VL, col="VL")) + 
            geom_line(data=out350DF, aes(x=nc, y=pc_L, col="L")) +  
            #geom_line(data=out350DF, aes(x=nc, y=pc_M, col="M")) +    
            geom_line(data=out700DF, aes(x=nc, y=pc_VL, col="VL")) + 
            geom_line(data=out700DF, aes(x=nc, y=pc_L, col="L")) +  
            #geom_line(data=out700DF, aes(x=nc, y=pc_M, col="M")) +  
            geom_point(data=equil350DF, aes(x=nc_VL, y=pc_VL, fill="A"), 
                       color="black", shape=21, size=5) + 
            geom_point(data=equil700DF, aes(x=nc_L, y=pc_L, fill="D"), 
                       shape=21, color="black", size=5) +
            #geom_point(data=equil700DF, aes(x=nc_M, y=pc_M, fill="C"), 
            #           shape=21, color="black", size=5) +
            geom_point(data=equil700DF, aes(x=nc_VL, y=pc_VL, fill="E"), 
                       shape=21, color="black", size=5) +
            #geom_point(data=equil700DF, aes(x=nc_L, y=pc_L, fill="B"), 
            #           shape=21, color="black", size=5) +
            ylim(0.0001, 0.002) + 
            xlim(0.01, 0.03) +
            labs(x="Leaf N:C Ratio", 
                 y="Leaf P:C Ratio") +
            theme_linedraw() +
            theme(panel.grid.minor=element_blank(),
                  axis.text=element_text(size=14),
                  axis.title=element_text(size=16),
                  legend.text=element_text(size=14),
                  legend.title=element_text(size=16),
                  panel.grid.major=element_line(color="grey")) +
            scale_colour_manual(name="Constraint line", 
                                values = c("C350" = cbbPalette[1], "C700" = cbbPalette[2], "VL" = cbbPalette[7],
                                           "L" = cbbPalette[4], "M" = cbbPalette[3])) +
            scale_fill_manual(name="QE point", values = c("A" = cbPalette[1], "B" = cbPalette[2], "C" = cbPalette[3],
                                                          "D" = cbPalette[4], "E" = cbPalette[7])) 
            
        ### plot 2-d plots of nf vs. npp and nf vs. pf
        pdf("Plots/Analytical_Run1_2d_EucFACE.pdf")
        plot(p1)
        plot(p2)
        dev.off()
        
    } else if (f.flag == 2) {
        my.list <- list(cDF = data.frame(rbind(out350DF, out700DF)), 
                        eDF = data.frame(rbind(equil350DF, equil700DF)))
        
        return(my.list)
    } 
    
}
