
#### Run analytical functions for each sub-simulations of GDAY
#### Output the necessary dataframe onto a cohesive framework,
#### so that they are available for cross-match with GDAY simulation results
####
#### This is the main script to call individual analytical run scripts and functions
####
################################################################################
#### Create dataframes to store all the data
constraintDF <- create_constraint_DF()
equilDF <- create_equil_DF()


#### Step 1: simply run analytical solution and plot quasi-equil plots
### f.flag: = 1 simply plot analytical solution graph
###         = 2 return constraintDF
###         = 3 return equilDF
Perform_Analytical_Run1(f.flag = 1, constraintDF, equilDF)
Perform_Analytical_Run2(f.flag = 1, constraintDF, equilDF)
Perform_Analytical_Run3(f.flag = 1, constraintDF, equilDF)
Perform_Analytical_Run4(f.flag = 1, constraintDF, equilDF)
#Perform_Analytical_Run5(f.flag = 1, constraintDF, equilDF)
#Perform_Analytical_Run6(f.flag = 1, constraintDF, equilDF)
#Perform_Analytical_Run7(f.flag = 1, constraintDF, equilDF)
#Perform_Analytical_Run8(f.flag = 1, constraintDF, equilDF)
#Perform_Analytical_Run9(f.flag = 1, constraintDF, equilDF)
#Perform_Analytical_Run10(f.flag = 1, constraintDF, equilDF)

#### Step 2 store run 1 - 10 constrainDF dataframes

### Run 1
constraintDF <- Perform_Analytical_Run1(f.flag = 2, constraintDF, equilDF)

### Run 2
constraintDF <- Perform_Analytical_Run2(f.flag = 2, constraintDF, equilDF)

### Run 3
constraintDF <- Perform_Analytical_Run3(f.flag = 2, constraintDF, equilDF)

### Run 4
constraintDF <- Perform_Analytical_Run4(f.flag = 2, constraintDF, equilDF)

### Run 5
#constraintDF <- Perform_Analytical_Run5(f.flag = 2, constraintDF, equilDF)

### Run 6
#constraintDF <- Perform_Analytical_Run6(f.flag = 2, constraintDF, equilDF)

### Run 7
#constraintDF <- Perform_Analytical_Run7(f.flag = 2, constraintDF, equilDF)

### Run 8
#constraintDF <- Perform_Analytical_Run8(f.flag = 2, constraintDF, equilDF)

### Run 9
#constraintDF <- Perform_Analytical_Run9(f.flag = 2, constraintDF, equilDF)

### Run 10
#constraintDF <- Perform_Analytical_Run10(f.flag = 2, constraintDF, equilDF)


#### Step 3 store run 1 - 10 equilDF dataframes

### Run 1
equilDF <- Perform_Analytical_Run1(f.flag = 3, constraintDF, equilDF)

### Run 2
equilDF <- Perform_Analytical_Run2(f.flag = 3, constraintDF, equilDF)

### Run 3
equilDF <- Perform_Analytical_Run3(f.flag = 3, constraintDF, equilDF)

### Run 4
equilDF <- Perform_Analytical_Run4(f.flag = 3, constraintDF, equilDF)

### Run 5
#equilDF <- Perform_Analytical_Run5(f.flag = 3, constraintDF, equilDF)

### Run 6
#equilDF <- Perform_Analytical_Run6(f.flag = 3, constraintDF, equilDF)

### Run 7
#equilDF <- Perform_Analytical_Run7(f.flag = 3, constraintDF, equilDF)

### Run 8
#equilDF <- Perform_Analytical_Run8(f.flag = 3, constraintDF, equilDF)

### Run 9
#equilDF <- Perform_Analytical_Run9(f.flag = 3, constraintDF, equilDF)

### Run 10
#equilDF <- Perform_Analytical_Run10(f.flag = 3, constraintDF, equilDF)


