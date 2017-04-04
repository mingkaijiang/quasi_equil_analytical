
#### Analytical script to match GDAY Run 1 settings
####
#### Assumptions:
#### 1. N and P cycle on
#### 2. Variable wood stoichiometry
#### 3. Uses G to reverse calculate leaf P (see open Issue #1 for more details)
####
################################################################################

Perform_Analytical_Run1 <- function() {
    #### Function to perform analytical run 1 simulations
    #### Will save multiple dataframes
    ####
    
    
    #### setting CO2 concentrations
    CO2_1 <- 350.0
    CO2_2 <- 700.0
    
    # plot photosynthetic constraints - not quite same as Hugh's, not sure why? 
    # N:C and P:C ratio
    nfseq <- round(seq(0.005, 0.05, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq))
    
    pfseq <- inferpfVL(nfseq, a_nf, Pin=0.04, Nin=1.0)
    a_pf <- as.data.frame(allocp(pfseq))
    
    ##### CO2 = 350
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC350 <- solveNC(nfseq, a_nf$af, co2=CO2_1)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=1.0)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLongN(co2=CO2_1)
    equilNPP <- VLongN$equilNPP_N   
    equilpf <- equilpVL(equilNPP,Pin = 0.04)   
    VLongNP <- data.frame(VLongN, equilpf)
    
    # Get Cpassive from very-long nutrient cycling solution
    aequiln <- allocn(VLongNP$equilnf)
    aequilp <- allocp(VLongNP$equilpf)
    pass <- passive(df=VLongNP$equilnf, a=aequiln)
    omega <- aequiln$af*pass$omegaf + aequiln$ar*pass$omegar
    CpassVLong <- omega*VLongNP$equilNPP/pass$decomp/(1-pass$qq)*1000.0
    
    # Calculate nutrient release from recalcitrant pools
    PrelwoodVLong <- aequilp$aw*aequilp$pw*VLongNP$equilNPP_N*1000.0
    NrelwoodVLong <- aequiln$aw*aequiln$nw*VLongNP$equilNPP_N*1000.0
    
    # Calculate pf based on nf of long-term nutrient exchange
    pfseqL <- inferpfL(nfseq, a_nf, Pin = 0.04+PrelwoodVLong,
                       Nin = 1.0+NrelwoodVLong,Cpass=CpassVLong)
    
    # Calculate long term nutrieng constraint
    NCHUGH <- NConsLong(df=nfseq, a=a_nf,Cpass=CpassVLong,
                        Nin = 1.0+NrelwoodVLong)
    
    # Find equilibrate intersection and plot
    LongN <- solveLongN(co2=CO2_1, Cpass=CpassVLong, Nin= 1.0+NrelwoodVLong)
    equilpf <- equilpL(LongN, Pin = 0.04+PrelwoodVLong, Cpass=CpassVLong)   
    LongNP <- data.frame(LongN, equilpf)
    
    out350DF <- data.frame(nfseq, pfseq, pfseqL, NC350, NCVLONG, NCHUGH)
    colnames(out350DF) <- c("nc", "pc_VL", "pc_350_L", "NPP_350", "NPP_VL",
                            "nleach_VL", "NPP_350_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    equil350DF <- data.frame(VLongNP, LongNP)
    colnames(equil350DF) <- c("nc_VL", "NPP_VL", "pc_VL",
                              "nc_L", "NPP_L", "pc_L")
    
    ##### CO2 = 700
    
    # N:C and P:C ratio
    nfseq <- round(seq(0.005, 0.05, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq))
    
    pfseq <- inferpfVL(nfseq, a_nf,Pin=0.04, Nin=1.0)
    a_pf <- as.data.frame(allocp(pfseq))
    
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC700 <- solveNC(nfseq, a_nf$af, co2=CO2_2)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=1.0)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLongN(co2=CO2_2)
    equilNPP <- VLongN$equilNPP_N   
    equilpf <- equilpVL(equilNPP,Pin = 0.04)   
    VLongNP <- data.frame(VLongN, equilpf)
    
    out700DF <- data.frame(nfseq, pfseq, pfseqL, NC700, NCVLONG, NCHUGH)
    colnames(out700DF) <- c("nc", "pc_VL", "pc_700_L", "NPP_700", "NPP_VL",
                            "nleach_VL", "NPP_700_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    
    # Find equilibrate intersection and plot
    LongN <- solveLongN(co2=CO2_2, Cpass=CpassVLong, Nin=1.0+NrelwoodVLong)
    equilNPP <- LongN$equilNPP
    
    a_new <- allocn(LongN$equilnf)
    equilpf <- inferpfVL(LongN$equilnf, a_new)
    
    LongNP <- data.frame(LongN, equilpf)
    
    equil700DF <- data.frame(VLongNP, LongNP)
    colnames(equil700DF) <- c("nc_VL", "NPP_VL", "pc_VL",
                              "nc_L", "NPP_L", "pc_L")
    
    
}