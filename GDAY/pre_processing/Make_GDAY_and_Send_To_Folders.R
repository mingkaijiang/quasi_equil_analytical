
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
if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run1", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run1", sep=""))
if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run2", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run2", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run3", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run3", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run4", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run4", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run5", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run5", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run6", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run6", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run7", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run7", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run8", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run8", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run9", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run9", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/simulations/Run10", sep="")))dir.create(paste(getwd(), "/GDAY/simulations/Run10", sep=""))

#### Create output folders if not exist
if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run1", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run1", sep=""))
if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run2", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run2", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run3", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run3", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run4", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run4", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run5", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run5", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run6", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run6", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run7", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run7", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run8", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run8", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run9", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run9", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/outputs/Run10", sep="")))dir.create(paste(getwd(), "/GDAY/outputs/Run10", sep=""))



#### Create params folders at the same time for each subfolders of output
if(!dir.exists(paste(getwd(),"/GDAY/params/Run1", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run1", sep=""))
if(!dir.exists(paste(getwd(),"/GDAY/params/Run2", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run2", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/params/Run3", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run3", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/params/Run4", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run4", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/params/Run5", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run5", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/params/Run6", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run6", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/params/Run7", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run7", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/params/Run8", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run8", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/params/Run9", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run9", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/params/Run10", sep="")))dir.create(paste(getwd(), "/GDAY/params/Run10", sep=""))


#### Create analyses folders at the same time for each subfolders of output
if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run1", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run1", sep=""))
if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run2", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run2", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run3", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run3", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run4", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run4", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run5", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run5", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run6", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run6", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run7", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run7", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run8", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run8", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run9", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run9", sep=""))
#if(!dir.exists(paste(getwd(),"/GDAY/analyses/Run10", sep="")))dir.create(paste(getwd(), "/GDAY/analyses/Run10", sep=""))


#### paste gday executive program to simulation folders
system("cp GDAY/code/src/gday GDAY/simulations/Run1/")
system("cp GDAY/code/src/gday GDAY/simulations/Run2/")
#system("cp GDAY/code/src/gday GDAY/simulations/Run3/")
#system("cp GDAY/code/src/gday GDAY/simulations/Run4/")
#system("cp GDAY/code/src/gday GDAY/simulations/Run5/")
#system("cp GDAY/code/src/gday GDAY/simulations/Run6/")
#system("cp GDAY/code/src/gday GDAY/simulations/Run7/")
#system("cp GDAY/code/src/gday GDAY/simulations/Run8/")
#system("cp GDAY/code/src/gday GDAY/simulations/Run9/")
#system("cp GDAY/code/src/gday GDAY/simulations/Run10/")

