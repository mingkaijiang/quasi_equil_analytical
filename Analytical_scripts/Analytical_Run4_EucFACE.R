
#### Analytical script EucFACE parameters, fixed wood, P cycle off
####
#### Assumptions:
#### 1. P cycle off
#### 2. Fixed wood 
####
################################################################################

#### Functions
Perform_Analytical_Run4_EucFACE <- function(f.flag = 1, cDF, eDF) {
    #### Function to perform analytical run 1 simulations
    #### f.flag: = 1 simply plot analytical solution file
    #### f.flag: = 2 return a data list

    ######### Main program
    source("Parameters/Analytical_Run4_Parameters_EucFACE.R")
    
    # N:C ratios for x-axis
    nfseq <- seq(0.01,0.1,by=0.001)
    # need allocation fractions here
    a_vec <- allocn(nfseq)
    
    # plot photosynthetic constraints
    C350 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_1)
    C700 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_2)
    
    #plot very-long nutrient cycling constraint
    NC_VL <- VL_constraint_N(nfseq,a_vec)
    
    #solve very-long nutrient cycling constraint
    VL_eq <- solve_VL_full_cn(CO2=CO2_1)
    
    #get Cpassive from very-long nutrient cycling solution
    aequil <- allocn(VL_eq$equilnf)
    pass <- passive(df=VL_eq$equilnf, a=aequil)
    omegap <- aequil$af*pass$omegaf + aequil$ar*pass$omegar
    CpassVLong <- omegap*VL_eq$equilNPP/pass$decomp/(1-pass$qq)*1000.0
    NrelwoodVLong <- aequil$aw*aequil$nw*VL_eq$equilNPP*1000
    
    #now plot long-term constraint with this Cpassive
    NC_L <- L_constraint_N(nfseq,a_vec,Cpass=CpassVLong,Nin+NrelwoodVLong)
    
    # Solve longterm equilibrium
    L_eq_350 <- solve_L_full_cn(CO2=CO2_1, Cpass=CpassVLong, NinL = Nin+NrelwoodVLong)
    L_eq_700 <- solve_L_full_cn(CO2=CO2_2, Cpass=CpassVLong, NinL = Nin+NrelwoodVLong)
    
    ## locate the intersect between VL nutrient constraint and CO2 = 700
    VL_eq_700 <- solve_VL_full_cn(CO2=CO2_2)
    
    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(nfseq, C700))
    inst700 <- inst_NPP(VL_eq$equilnf, df700)
    
    out350DF <- data.frame(nfseq, C350, NC_VL, NC_L)
    colnames(out350DF) <- c("nc", "NPP_photo", "NPP_VL",
                            "nleach_VL", "NPP_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    equil350DF <- data.frame(VL_eq, L_eq_350)
    colnames(equil350DF) <- c("nc_VL", "NPP_VL", 
                              "nc_L", "NPP_L")
    
    out700DF <- data.frame(nfseq, C700, NC_VL, NC_L)
    colnames(out700DF) <- c("nc", "NPP_photo", "NPP_VL",
                            "nleach_VL", "NPP_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    
    equil700DF <- data.frame(VL_eq_700, L_eq_700)
    colnames(equil700DF) <- c("nc_VL", "NPP_VL", 
                              "nc_L", "NPP_L")
    equil350DF$NPP_I <- inst700$equilNPP
    equil700DF$NPP_I <- inst700$equilNPP
    
    if (f.flag ==1 ) {
        

        
    } else if (f.flag == 2) {
        my.list <- list(cDF = data.frame(rbind(out350DF, out700DF)), 
                        eDF = data.frame(rbind(equil350DF, equil700DF)))
        
        return(my.list)
    } 
}
