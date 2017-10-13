#### To generate figure 6
#### comparing 3 N uptake functions

#### programs

Nutrient_uptake_comparison <- function() {
    
    #### Run 7: explicit, linear coefficient approach
    source("Parameters/Analytical_Run7_Parameters.R")
    
    # create nc and pc for shoot to initiate
    nfseq <- round(seq(0.01, 0.1, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq))
    
    pfseq <- inferpfVL_expl_min(nfseq, a_nf)
    a_pf <- as.data.frame(allocp(pfseq))
    
    ##### CO2 = 350
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC350 <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_1)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong_expl_min(df=nfseq,a=a_nf)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLong_expl_min(CO2_1)
    
    # Get Cpassive from very-long nutrient cycling solution
    aequiln <- allocn(VLongN$equilnf)
    aequilp <- allocp(VLongN$equilpf)
    
    pass <- slow_pool(df=VLongN$equilnf, a=aequiln)
    omegap <- aequiln$af*pass$omegafp + aequiln$ar*pass$omegarp
    CpassVLong <- omegap*VLongN$equilNPP/pass$decomp_p/(1-pass$qpq)*1000.0
    
    # Calculate pf based on nf of long-term nutrient exchange
    pfseqL <- inferpfL_expl_min(nfseq, a_nf, PinL = Pin,#+PrelwoodVLong,
                                NinL = Nin,#+NrelwoodVLong,
                                Cpass=CpassVLong)
    
    # Calculate long term nutrieng constraint
    NCHUGH <- NConsLong_expl_min(nfseq, a_nf,CpassVLong,
                                 NinL = Nin)#+NrelwoodVLong)
    
    # Find equilibrate intersection and plot
    LongN <- solveLong_expl_min(CO2_1, Cpass=CpassVLong, NinL= Nin,#+NrelwoodVLong,
                                PinL=Pin)#+PrelwoodVLong)
    
    # Get Cslow from long nutrient cycling solution
    omegas <- aequiln$af*pass$omegafs + aequiln$ar*pass$omegars
    CslowLong <- omegas*LongN$equilNPP/pass$decomp_s/(1-pass$qsq)*1000.0
    
    # Calculate nutrient release from recalcitrant pools
    PrelwoodVLong <- aequilp$aw*aequilp$pw*VLongN$equilNPP_N*1000.0
    NrelwoodVLong <- aequiln$aw*aequiln$nw*VLongN$equilNPP_N*1000.0
    
    # Calculate medium term nutrieng constraint
    NCMEDIUM <- NConsMedium_expl_min(nfseq, a_nf,CpassVLong, CslowLong,
                                     NinL = Nin+NrelwoodVLong)
    
    out350DF <- data.frame(nfseq, pfseq, pfseqL, NC350, NCVLONG, NCHUGH)
    colnames(out350DF) <- c("nc", "pc_VL", "pc_350_L", "NPP_350", "NPP_VL",
                            "nleach_VL", "NPP_350_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    equil350DF <- data.frame(VLongN, LongN)
    colnames(equil350DF) <- c("nc_VL", "pc_VL","NPP_VL", 
                              "nc_L", "pc_L","NPP_L")
    
    ##### CO2 = 700
    # N:C and P:C ratio
    nfseq <- round(seq(0.01, 0.1, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq))
    
    pfseq <- inferpfVL_expl_min(nfseq, a_nf)
    a_pf <- as.data.frame(allocp(pfseq))
    
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC700 <- photo_constraint_full_cnp(nfseq, pfseq, a_nf, a_pf, CO2_2)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong_expl_min(df=nfseq,a=a_nf)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLong_expl_min(CO2_2)
    
    out700DF <- data.frame(nfseq, pfseq, pfseqL, NC700, NCVLONG, NCHUGH)
    colnames(out700DF) <- c("nc", "pc_VL", "pc_700_L", "NPP_700", "NPP_VL",
                            "nleach_VL", "NPP_700_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    
    # Find equilibrate intersection and plot
    LongN <- solveLong_expl_min(CO2_2, Cpass=CpassVLong, NinL=Nin)#+NrelwoodVLong)
    
    equil700DF <- data.frame(VLongN, LongN)
    colnames(equil700DF) <- c("nc_VL", "pc_VL","NPP_VL", 
                              "nc_L", "pc_L","NPP_L")
    
    # Find medium term equilibrium point
    Medium_equil_350 <- solveMedium_full_cnp(CO2_1, Cpass = CpassVLong, Cslow = CslowLong, 
                                             NinL=Nin+NrelwoodVLong, PinL=Pin+PrelwoodVLong)
    Medium_equil_700 <- solveMedium_full_cnp(CO2_2, Cpass = CpassVLong, Cslow = CslowLong, 
                                             NinL=Nin+NrelwoodVLong, PinL=Pin+PrelwoodVLong)
    
    # get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(round(nfseq,3), NC700))
    inst700 <- inst_NPP(equil350DF$nc_VL, df700)
    
    
    
    
    
}




#### Script
Nutrient_uptake_comparison()
