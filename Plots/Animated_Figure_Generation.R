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
    
    ### Create df to store all the constraints
    nfseq <- round(seq(0.001, 0.1, b=0.001), 5)
    csDF <- data.frame(nfseq, NA, NA, NA, NA, NA)
    colnames(csDF) <- c("nf", "aCO2", "eCO2", "VL",
                        "L", "M")
    
    csDF.new <- analytical_generation(csDF) 
    
    
    
    ### Plotting
    with(csDF.new, plot(aCO2~nf, type="l", xlim=c(0.01, 0.05), 
                        ylim=c(0, 3)))
    with(csDF.new, lines(eCO2~nf, type="l", col="red"))
    with(csDF.new, lines(VL~nf, type="l", col="blue"))
    with(csDF.new, lines(L~nf, type="l", col="orange"))
    with(csDF.new, lines(M~nf, type="l", col="purple"))
    
    locator()
}


### Script
Animated_Figure_Generation() 
