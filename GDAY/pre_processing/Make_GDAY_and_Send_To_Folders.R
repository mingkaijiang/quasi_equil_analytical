
#### Compile the GDAY code and paste it to the correct sub-folders 
####
#### 
################################################################################

#### Get existing working directory
cwd <- getwd()

#### Set working directory to allow make file to source all .c
setwd("GDAY/code/src")

#### Compile GDAY
system("make -f Makefile gday")

#### Switch back to old working directory
setwd(cwd)

#### paste gday executive program to simulation folders
system("cp GDAY/code/src/gday GDAY/simulations/")
