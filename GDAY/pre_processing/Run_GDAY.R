#### Run python wrapper file to run GDAY
####
#### Currently this is an easy solution, 
#### in the future this will possibly change to remove the dependency on python wrapper file
################################################################################

#### get the existing working directory
cwd <- getwd()

#### Set working directory to each simulation folder and run GDAY

### Run1
setwd("GDAY/simulations/Run1")   # Setting to subfolder helps as you can also run in terminal without the need to change anything in the code
source("quasi_equil_annual_spin_up.R")
source("quasi_equil_annual_simulations.R")
setwd(cwd)

### Run2
setwd("GDAY/simulations/Run2")
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
setwd(cwd)

### Run3
setwd("GDAY/simulations/Run3")
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
setwd(cwd)

### Run4
setwd("GDAY/simulations/Run4")
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
setwd(cwd)

### Run5
setwd("GDAY/simulations/Run5")
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
setwd(cwd)

### Run6
setwd("GDAY/simulations/Run6")
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
setwd(cwd)

### Run7
setwd("GDAY/simulations/Run7")
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
setwd(cwd)

### Run8
setwd("GDAY/simulations/Run8")
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
setwd(cwd)

### Run9
setwd("GDAY/simulations/Run9")
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
setwd(cwd)

### Run10
setwd("GDAY/simulations/Run10")
system("./quasi_equil_annual_spin_up.py; ./quasi_equil_annual_simulations.py")
setwd(cwd)
