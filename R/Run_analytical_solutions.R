
#### Run analytical functions 
####
#### This is the main script to call individual analytical run scripts and functions
####
#### Run definitions:
#### Run 1: EucFACE parameters, variable wood stoichiometry, P cycle on
#### Run 2: EucFACE parameters, variable wood stoichiometry, P cycle off
#### Run 3: EucFACE parameters, fixed wood stoichiometry, P cycle on
#### Run 4: EucFACE parameters, fixed wood stoichiometry, P cycle off
#### Run 5: AmazonFACE parameters, variable wood stoichiometry, P cycle on
#### Run 6: AmazonFACE parameters, variable wood stoichiometry, P cycle off
#### Run 7: AmazonFACE parameters, fixed wood stoichiometry, P cycle on
#### Run 8: AmazonFACE parameters, fixed wood stoichiometry, P cycle off
################################################################################
#### Step 1: simply run analytical solution and plot quasi-equil plots
### f.flag: = 1 simply plot analytical solution graph
###         = 2 return output
Perform_Analytical_Run1_EucFACE(f.flag = 1)
Perform_Analytical_Run2_EucFACE(f.flag = 1)
Perform_Analytical_Run3_EucFACE(f.flag = 1)
Perform_Analytical_Run4_EucFACE(f.flag = 1)
Perform_Analytical_Run5_AmazonFACE(f.flag = 1)
Perform_Analytical_Run6_AmazonFACE(f.flag = 1)
Perform_Analytical_Run7_AmazonFACE(f.flag = 1)
Perform_Analytical_Run8_AmazonFACE(f.flag = 1)

#### Step 2 store output into list
r1 <- Perform_Analytical_Run1_EucFACE(f.flag = 2)
r2 <- Perform_Analytical_Run2_EucFACE(f.flag = 2)
r3 <- Perform_Analytical_Run3_EucFACE(f.flag = 2)
r4 <- Perform_Analytical_Run4_EucFACE(f.flag = 2)
r5 <- Perform_Analytical_Run5_AmazonFACE(f.flag = 2)
r6 <- Perform_Analytical_Run6_AmazonFACE(f.flag = 2)
r7 <- Perform_Analytical_Run7_AmazonFACE(f.flag = 2)
r8 <- Perform_Analytical_Run8_AmazonFACE(f.flag = 2)
