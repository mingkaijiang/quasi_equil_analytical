
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


#### Create output folders if not exist
if(!dir.exists("/GDAY/simulations/Run1"))dir.create("/GDAY/simulations/Run1")
if(!dir.exists("/GDAY/simulations/Run2"))dir.create("/GDAY/simulations/Run2")
if(!dir.exists("/GDAY/simulations/Run3"))dir.create("/GDAY/simulations/Run3")
if(!dir.exists("/GDAY/simulations/Run4"))dir.create("/GDAY/simulations/Run4")
if(!dir.exists("/GDAY/simulations/Run5"))dir.create("/GDAY/simulations/Run5")
if(!dir.exists("/GDAY/simulations/Run6"))dir.create("/GDAY/simulations/Run6")
if(!dir.exists("/GDAY/simulations/Run7"))dir.create("/GDAY/simulations/Run7")
if(!dir.exists("/GDAY/simulations/Run8"))dir.create("/GDAY/simulations/Run8")
if(!dir.exists("/GDAY/simulations/Run9"))dir.create("/GDAY/simulations/Run9")
if(!dir.exists("/GDAY/simulations/Run10"))dir.create("/GDAY/simulations/Run10")


#### Create params folders at the same time for each subfolders of output
if(!dir.exists("/GDAY/params/Run1"))dir.create("/GDAY/params/Run1")
if(!dir.exists("/GDAY/params/Run2"))dir.create("/GDAY/params/Run2")
if(!dir.exists("/GDAY/params/Run3"))dir.create("/GDAY/params/Run3")
if(!dir.exists("/GDAY/params/Run4"))dir.create("/GDAY/params/Run4")
if(!dir.exists("/GDAY/params/Run5"))dir.create("/GDAY/params/Run5")
if(!dir.exists("/GDAY/params/Run6"))dir.create("/GDAY/params/Run6")
if(!dir.exists("/GDAY/params/Run7"))dir.create("/GDAY/params/Run7")
if(!dir.exists("/GDAY/params/Run8"))dir.create("/GDAY/params/Run8")
if(!dir.exists("/GDAY/params/Run9"))dir.create("/GDAY/params/Run9")
if(!dir.exists("/GDAY/params/Run10"))dir.create("/GDAY/params/Run10")


#### Create analyses folders at the same time for each subfolders of output
if(!dir.exists("/GDAY/analyses/Run1"))dir.create("/GDAY/analyses/Run1")
if(!dir.exists("/GDAY/analyses/Run2"))dir.create("/GDAY/analyses/Run2")
if(!dir.exists("/GDAY/analyses/Run3"))dir.create("/GDAY/analyses/Run3")
if(!dir.exists("/GDAY/analyses/Run4"))dir.create("/GDAY/analyses/Run4")
if(!dir.exists("/GDAY/analyses/Run5"))dir.create("/GDAY/analyses/Run5")
if(!dir.exists("/GDAY/analyses/Run6"))dir.create("/GDAY/analyses/Run6")
if(!dir.exists("/GDAY/analyses/Run7"))dir.create("/GDAY/analyses/Run7")
if(!dir.exists("/GDAY/analyses/Run8"))dir.create("/GDAY/analyses/Run8")
if(!dir.exists("/GDAY/analyses/Run9"))dir.create("/GDAY/analyses/Run9")
if(!dir.exists("/GDAY/analyses/Run10"))dir.create("/GDAY/analyses/Run10")


#### paste gday executive program to simulation folders
system("cp GDAY/code/src/gday GDAY/simulations/Run1/")
system("cp GDAY/code/src/gday GDAY/simulations/Run2/")
system("cp GDAY/code/src/gday GDAY/simulations/Run3/")
system("cp GDAY/code/src/gday GDAY/simulations/Run4/")
system("cp GDAY/code/src/gday GDAY/simulations/Run5/")
system("cp GDAY/code/src/gday GDAY/simulations/Run6/")
system("cp GDAY/code/src/gday GDAY/simulations/Run7/")
system("cp GDAY/code/src/gday GDAY/simulations/Run8/")
system("cp GDAY/code/src/gday GDAY/simulations/Run9/")
system("cp GDAY/code/src/gday GDAY/simulations/Run10/")

