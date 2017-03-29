#### Run python wrapper file to run GDAY
####
#### Currently this is an easy solution, 
#### in the future this will possibly change to remove the dependency on python wrapper file
################################################################################

#### get the existing working directory
cwd <- getwd()

#### Set working directory to each simulation folder
setwd("GDAY/simulations")

#### Run the python code
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")

#### Reset working directory back to parent level
setwd(cwd)
