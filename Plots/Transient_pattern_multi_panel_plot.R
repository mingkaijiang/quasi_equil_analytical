#### Check continuity in transient files
#### For both pools and fluxes
#### Can set end year
#### Different from Check_continuity in that it doesn't start from spin-up files
#### And it includes fluxes in addition to pools
################################################################################


######################## Main program ###################################
## Read in spin up, aCO2 and eCO2 files
inDF <- read.table( "GDAY/analyses/Run1/annual_gday_result_transient_CO2_ELE.csv",
                   header=T,sep=",")

## subset a period only
tranDF <- inDF[1:100,]

## add extra variables
tranDF$shootcn <- tranDF$shoot / tranDF$shootn
tranDF$shootcp <- tranDF$shoot / tranDF$shootp
tranDF$stemcn <- tranDF$stem / tranDF$stemn
tranDF$stemcp <- tranDF$stem / tranDF$stemp
tranDF$rootcn <- tranDF$root / tranDF$rootn
tranDF$rootcp <- tranDF$root / tranDF$rootp

## Plotting
tiff("Plots/Figure_transient_variable_wood_stoichiometry.tiff",
     width = 10, height = 7, units = "in", res = 300)
par(mar=c(5.1,5.1,2.1,2.1))

#### Fluxes
## Create multi-panel dataset
panelDF <- melt(subset(tranDF, select=c("year", "npp", "shoot", "shootcn", "shootcp",
                                        "nuptake", "stem", "stemcn", "stemcp",
                                        "puptake", "root", "rootcn", "rootcp")),
                id.var="year")

## Plot
xyplot(value~year|variable, data=panelDF, type="l", lwd = 2.5, col = "blue",
             scales=list(y=list(relation="free")),
             layout=c(4,3), ylab = "", xlab = "Year")


dev.off()

########################

## Read in spin up, aCO2 and eCO2 files
inDF <- read.table( "GDAY/analyses/Run3/annual_gday_result_transient_CO2_ELE.csv",
                    header=T,sep=",")

## subset a period only
tranDF <- inDF[1:100,]

## add extra variables
tranDF$shootcn <- tranDF$shoot / tranDF$shootn
tranDF$shootcp <- tranDF$shoot / tranDF$shootp
tranDF$stemcn <- tranDF$stem / tranDF$stemn
tranDF$stemcp <- tranDF$stem / tranDF$stemp
tranDF$rootcn <- tranDF$root / tranDF$rootn
tranDF$rootcp <- tranDF$root / tranDF$rootp


## Plotting
tiff("Plots/Figure_transient_fixed_wood_stoichiometry.tiff",
     width = 10, height = 7, units = "in", res = 300)
par(mar=c(5.1,5.1,2.1,2.1))

#### Fluxes
## Create multi-panel dataset
panelDF <- melt(subset(tranDF, select=c("year", "npp", "shoot", "shootcn", "shootcp",
                                        "nuptake", "stem", "stemcn", "stemcp",
                                        "puptake", "root", "rootcn", "rootcp")),
                id.var="year")

## Plot
xyplot(value~year|variable, data=panelDF, type="l", lwd = 2.5, col = "blue",
       scales=list(y=list(relation="free")),
       layout=c(4,3), ylab = "", xlab = "Year",
       ylim = list(c(9, 12), c(3.7, 4.2), c(40, 70), c(1390, 1800),
                c(0.06, 0.08), c(572, 575), c(190, 210), c(3320, 3340), 
                c(0.0029, 0.0033), c(1.2, 1.5), c(65, 100), c(2000, 2900)))


dev.off()