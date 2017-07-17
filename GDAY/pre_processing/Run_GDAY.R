#### Source R wrapper files to swap parameters and running GDAY.
#### All sub-simulations are performed here. 
#### 
#### Run definitions:
#### Run 1: baseline, variable wood stoichiometry, N and P cycles on,
####        implicit mineral N and P pools
#### Run 2: same as Run1, but P cycle off
#### Run 3: same as Run1, but fixed wood stoichiometry
#### Run 4: same as Run1, but autotrophic respiration as a function of plant N concentration
#### Run 5: same as Run4, but fixed wood stoichiometry and increased nutrient supply
#### Run 6: same as Run1, but with separate coarse woody debris pool
#### Run 7: same as Run1, but with explicit mineral N pool
#### 

################################################################################

#### get the existing working directory
cwd <- getwd()

#### Perform GDAY simulations:

### Run1
setwd("GDAY/simulations/Run1")   # Setting to subfolder helps as you can also run in terminal without the need to change anything in the code
source("quasi_equil_annual_spin_up.R")
source("quasi_equil_annual_simulations.R")
setwd(cwd)

### An example of using python wrapper file to run GDAY
# setwd("GDAY/simulations/Run1")  
# system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
# setwd(cwd)

#### Run2
#setwd("GDAY/simulations/Run2")
#source("quasi_equil_annual_spin_up.R")
#source("quasi_equil_annual_simulations.R")
#setwd(cwd)
#
#### Run3
#setwd("GDAY/simulations/Run3")
#source("quasi_equil_annual_spin_up.R")
#source("quasi_equil_annual_simulations.R")
#setwd(cwd)

### Run4
#setwd("GDAY/simulations/Run4")
#source("quasi_equil_annual_spin_up.R")
#source("quasi_equil_annual_simulations.R")
#setwd(cwd)

### Run5
#setwd("GDAY/simulations/Run5")
#source("quasi_equil_annual_spin_up.R")
#source("quasi_equil_annual_simulations.R")
#setwd(cwd)

### Run6
#setwd("GDAY/simulations/Run6")
#source("quasi_equil_annual_spin_up.R")
#source("quasi_equil_annual_simulations.R")
#setwd(cwd)

### Run7
#setwd("GDAY/simulations/Run7")
#source("quasi_equil_annual_spin_up.R")
#source("quasi_equil_annual_simulations.R")
#setwd(cwd)


#### We only need to show a few examples that gday solution matches with the analytical solution
#### So the following gday simulations are not performed

### Run8
#setwd("GDAY/simulations/Run8")
#source("quasi_equil_annual_spin_up.R")
#source("quasi_equil_annual_simulations.R")
#setwd(cwd)

### Run9
#setwd("GDAY/simulations/Run9")
#source("quasi_equil_annual_spin_up.R")
#source("quasi_equil_annual_simulations.R")
#setwd(cwd)

### Run10
#setwd("GDAY/simulations/Run10")
#source("quasi_equil_annual_spin_up.R")
#source("quasi_equil_annual_simulations.R")
#setwd(cwd)

