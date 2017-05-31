#### Functions
P_limitation_GDAY <- function() {
    #### read in csv files
    npDF <- read.csv("GDAY/analyses/Run1/annual_gday_result_transient_CO2_ELE.csv")
    nDF <- read.csv("GDAY/analyses/Run2/annual_gday_result_transient_CO2_ELE.csv")
    
    #### Making plots
    tiff("Plots/Effect_of_P_limitation.tiff",
         width = 8, height = 7, units = "in", res = 300)
    par(mar=c(5.1,6.1,2.1,2.1))
    
    with(nDF[1:100,], plot(shoot~year, type='l', xlab = "Year",
                           ylab = expression(paste("Production [kg C ", m^-2, " ", yr^-1, "]")),
                           col="blue", lwd = 3, cex.lab = 2.0))
    
    dev.off()
    
}


#### Program
P_limitation_GDAY()
