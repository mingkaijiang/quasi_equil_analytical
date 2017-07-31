#### Check GDAY simulated effect of root exudation on nmineralization and related production

myDF1 <- read.csv("GDAY/outputs/Run1/Quasi_equil_transient_CO2_AMB.csv",skip=1)
myDF2 <- read.csv("GDAY/outputs/Run9/Quasi_equil_transient_CO2_AMB.csv",skip=1)

# fluxes
with(myDF1, plot(nmineralisation))
with(myDF2, points(nmineralisation, col="red"))

with(myDF1, plot(nuptake, ylim=c(0.000204, 0.000206)))
with(myDF2, points(nuptake, col="red"))

with(myDF1, plot(puptake, ylim=c(0.0000086, 0.0000088)))
with(myDF2, points(puptake, col="red"))

plot(myDF1$nuptake, myDF2$nuptake, xlab = "exudation off",
     ylab = "exudation on")
abline(a=0,b=1, col="red")

with(myDF1, plot(npp))
with(myDF2, points(npp, col="red"))

# stocks
with(myDF1, plot(activesoil, ylim=c(0, 5)))
with(myDF2, points(activesoil, col="red"))

with(myDF1, plot(slowsoil, ylim=c(0, 50)))
with(myDF2, points(slowsoil, col="red"))

with(myDF1, plot(passivesoil, ylim=c(20, 50)))
with(myDF2, points(passivesoil, col="red"))


with(myDF1, plot(activesoiln, ylim=c(0, 0.2)))
with(myDF2, points(activesoiln, col="red"))

with(myDF1, plot(activesoilp, ylim=c(0, 0.01)))
with(myDF2, points(activesoilp, col="red"))

with(myDF1, plot(slowsoiln, ylim=c(0, 5)))
with(myDF2, points(slowsoiln, col="red"))

with(myDF1, plot(passivesoiln, ylim=c(0, 5)))
with(myDF2, points(passivesoiln, col="red"))

with(myDF1, plot(inorgn, ylim=c(0.078, 0.079)))
with(myDF2, points(inorgn, col="red"))


# CN ratios
with(myDF1, plot(activesoil/activesoiln, ylim=c(10, 20)))
with(myDF2, points(activesoil/activesoiln, col="red"))

with(myDF1, plot(slowsoil/slowsoiln, ylim=c(10, 30)))
with(myDF2, points(slowsoil/slowsoiln, col="red"))

with(myDF1, plot(passivesoil/passivesoiln, ylim=c(0, 15)))
with(myDF2, points(passivesoil/passivesoiln, col="red"))


# plant allocation
with(myDF1, plot(root/activesoiln, ylim=c(10, 20)))
with(myDF2, points(activesoil/activesoiln, col="red"))

## Comments:
## With Exudation turned on, we have higher NPP, higher N uptake,
##                           lower active, slow and passive soil C content
##                           lower active, slow and passive soil N content
## Root exudated C enters active SOM;
## To meet the CN demand of the active SOM pool, we need extra N from N mineralization;
## More N mineralized, bigger N mineral pool size, and higher N uptake;
## higher N uptake, higher NPP;
## Faster turnaround of the slow pool, less time to accumulate C, less slow pool;
## Less slow pool size, less active and passive pool