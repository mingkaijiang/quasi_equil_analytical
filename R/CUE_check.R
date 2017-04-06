
#### Check Carbon Use Efficiency of Run 4
#### Autotrophic respiration as a function of plant tissue N
#### Compute CUE for gday simulation and analytical solution result over time
####
################################################################################


############################## Functions #######################################

Analytical_R4 <- function() {
    #### Function to perform analytical run 4 simulations
    #### should be the same as function Perform_Analytical_Run4
    #### except we are outputing CUE only
    
    #### DF for storage of ra, npp and cue at L and VL at aCO2 and eCO2
    outDF <- matrix(ncol=5, nrow=4)
    outDF <- as.data.frame(outDF)
    colnames(outDF) <- c("co2", "time", "npp", "ra", "cue")
    outDF[1:2, "co2"] <- 350.0
    outDF[3:4, "co2"] <- 700.0
    outDF[1, "time"] <- outDF[3,"time"] <- "VL"
    outDF[2, "time"] <- outDF[4,"time"] <- "L"
    
    #### setting CO2 concentrations
    CO2_1 <- 350.0
    CO2_2 <- 700.0
    
    # create nc and pc for shoot to initiate
    nfseq <- round(seq(0.005, 0.05, by = 0.001),5)
    a_nf <- as.data.frame(allocn(nfseq,nwvar=T))
    
    pfseq <- inferpfVL(nfseq, a_nf, Pin=0.04, Nin=1.0, pwvar=T)
    a_pf <- as.data.frame(allocp(pfseq, pwvar=T))
    
    ##### CO2 = 350
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC350 <- solveNC_respiration(nfseq, a_nf, co2=CO2_1)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=1.0)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLongN_respiration(co2=CO2_1, nwvar=T)
    equilNPP <- VLongN$equilNPP_N   
    equilpf <- equilpVL(equilNPP,Pin = 0.04,pwvar=T)   
    VLongNP <- data.frame(VLongN, equilpf)
    
    # compute Ra and CUE
    outDF[1,"npp"] <-equilNPP
    outDF[1,"ra"] <- Compute_Ra(allocn(VLongNP$equilnf), NPP=equilNPP)
    
    # Get Cpassive from very-long nutrient cycling solution
    aequiln <- allocn(VLongNP$equilnf,nwvar=T)
    aequilp <- allocp(VLongNP$equilpf,pwvar=T)
    pass <- passive(df=VLongNP$equilnf, a=aequiln)
    omega <- aequiln$af*pass$omegaf + aequiln$ar*pass$omegar
    CpassVLong <- omega*VLongNP$equilNPP/pass$decomp/(1-pass$qq)*1000.0
    
    # Calculate nutrient release from recalcitrant pools
    PrelwoodVLong <- aequilp$aw*aequilp$pw*VLongNP$equilNPP_N*1000.0
    NrelwoodVLong <- aequiln$aw*aequiln$nw*VLongNP$equilNPP_N*1000.0
    
    # Calculate pf based on nf of long-term nutrient exchange
    pfseqL <- inferpfL(nfseq, a_nf, Pin = 0.04+PrelwoodVLong,
                       Nin = 1.0+NrelwoodVLong,Cpass=CpassVLong, nwvar=T, pwvar=T)
    
    # Calculate long term nutrieng constraint
    NCHUGH <- NConsLong(df=nfseq, a=a_nf,Cpass=CpassVLong,
                        Nin = 1.0+NrelwoodVLong)
    
    # Find equilibrate intersection and plot
    LongN <- solveLongN_respiration(co2=CO2_1, Cpass=CpassVLong, Nin= 1.0+NrelwoodVLong, nwvar=T)
    equilpf <- equilpL(LongN, Pin = 0.04+PrelwoodVLong, Cpass=CpassVLong, 
                       nwvar=T, pwvar=T)   
    LongNP <- data.frame(LongN, equilpf)
    
    # compute Ra and CUE
    outDF[2,"npp"] <-LongNP$equilNPP
    outDF[2,"ra"] <- Compute_Ra(allocn(LongNP$equilnf), NPP=LongNP$equilNPP)
    
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
    a_nf <- as.data.frame(allocn(nfseq, nwvar=T))
    
    pfseq <- inferpfVL(nfseq, a_nf,Pin=0.04, Nin=1.0,pwvar=T)
    a_pf <- as.data.frame(allocp(pfseq, pwvar=T))
    
    # calculate NC vs. NPP at CO2 = 350 respectively
    NC700 <- solveNC_respiration(nfseq, a_nf, co2=CO2_2)
    
    # calculate very long term NC and PC constraint on NPP, respectively
    NCVLONG <- NConsVLong(df=nfseq,a=a_nf,Nin=1.0)
    
    # solve very-long nutrient cycling constraint
    VLongN <- solveVLongN_respiration(co2=CO2_2, nwvar=T)
    equilNPP <- VLongN$equilNPP_N   
    equilpf <- equilpVL(equilNPP,Pin = 0.04, pwvar=T)   
    VLongNP <- data.frame(VLongN, equilpf)
    
    # compute Ra and CUE
    outDF[3,"npp"] <-equilNPP
    outDF[3,"ra"] <- Compute_Ra(allocn(VLongNP$equilnf), NPP=equilNPP)
    
    out700DF <- data.frame(nfseq, pfseq, pfseqL, NC700, NCVLONG, NCHUGH)
    colnames(out700DF) <- c("nc", "pc_VL", "pc_700_L", "NPP_700", "NPP_VL",
                            "nleach_VL", "NPP_700_L", "nwood_L", "nburial_L",
                            "nleach_L", "aw")
    
    # Find equilibrate intersection and plot
    LongN <- solveLongN_respiration(co2=CO2_2, Cpass=CpassVLong, Nin=1.0+NrelwoodVLong, nwvar=T)
    equilNPP <- LongN$equilNPP
    
    a_new <- allocn(LongN$equilnf, nwvar=T)
    equilpf <- inferpfVL(LongN$equilnf, a_new, pwvar=T)
    
    LongNP <- data.frame(LongN, equilpf)
    
    # compute Ra and CUE
    outDF[4,"npp"] <-LongNP$equilNPP
    outDF[4,"ra"] <- Compute_Ra(allocn(LongNP$equilnf), NPP=LongNP$equilNPP)
    
    equil700DF <- data.frame(VLongNP, LongNP)
    colnames(equil700DF) <- c("nc_VL", "NPP_VL", "pc_VL",
                              "nc_L", "NPP_L", "pc_L")
    
    
    outDF$cue <- outDF$npp / (outDF$ra+outDF$npp)
    
    return(outDF)
}




save_CUE_stats <- function() {
    
    ### Performing analytical calculation and obtain CUE
    out <- Analytical_R4()
    
    ### Save the table
    write.table(out, "Tables/CUE_summary.csv", sep=",",
                col.names=T, row.names=F)
   
}




############################## Main program #######################################
save_CUE_stats()
