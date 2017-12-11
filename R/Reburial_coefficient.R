### Function to look at priming effect on reburial coefficient

reburial_comparison <- function() {
    
    #### Baseline case - basic N model
    source("Parameters/Analytical_Run2_Parameters.R")
    nfseq <- seq(0.001,0.1,by=0.001)
    a_vec <- allocn(nfseq)
    PC350 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_1)
    PC700 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_2)
    NCVLONG <- VLong_constraint_N(nfseq,a_vec)
    VLong <- solveVLong_full_cn(CO2=CO2_1)
    aequil <- allocn(VLong$equilnf)
    pass_case1 <- slow_pool(df=VLong$equilnf, a=aequil)
    omegap_case1 <- aequil$af*pass$omegafp + aequil$ar*pass$omegarp
    omegas_case1 <- aequil$af*pass$omegafs + aequil$ar*pass$omegars

    #### Priming turned off, exudation turned on
    source("Parameters/Analytical_Run10_Parameters.R")
    nfseq <- round(seq(0.001, 0.1, by = 0.001),5)
    a_vec <- as.data.frame(allocn_exudation(nfseq))
    PC350 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_1)
    PC700 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_2)
    NCVLONG <- NConsVLong(df=nfseq,a=a_vec)
    VLongN <- solveVLong_full_cn_medium(CO2_1)
    aequiln <- allocn_exudation(VLongN$equilnf)
    pass_case2 <- slow_pool(df=VLongN$equilnf, a=aequiln)
    omegap_case2 <- aequiln$af*pass$omegafp + aequiln$ar*pass$omegarp
    omegas_case2 <- aequiln$af*pass$omegafs + aequiln$ar*pass$omegars
    
    #### Priming turned on, exudation turned on
    source("Parameters/Analytical_Run10_Parameters.R")
    nfseq <- round(seq(0.001, 0.1, by = 0.001),5)
    a_vec <- as.data.frame(allocn_exudation(nfseq))
    PC350 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_1)
    PC700 <- photo_constraint_full_cn(nfseq,a_vec,CO2=CO2_2)
    NCVLONG <- NConsVLong(df=nfseq,a=a_vec)
    VLongN <- solveVLong_full_cn_medium(CO2_1)
    aequiln <- allocn_exudation(VLongN$equilnf)
    pass_case3 <- slow_pool(df=VLongN$equilnf, a=aequiln)
    omegap_case3 <- aequiln$af*pass$omegafp + aequiln$ar*pass$omegarp
    omegas_case3 <- aequiln$af*pass$omegafs + aequiln$ar*pass$omegars
    
    
    
}

### Script
reburial_comparison()
