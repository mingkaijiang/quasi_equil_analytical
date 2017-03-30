#### Check continuity in spin-up and transient files
#### Only for the pools
#### Currently the end year is 50 yr
################################################################################

######################## Functions ###################################

############# Integrate spin-up and transient DF together
integrate_DF <- function(spinDF, tranDF) {
    
    ## Collecting last 10 years of spin-out DF
    l <- nrow(spinDF)
    s <- l-10
    spinDF <- as.data.frame(spinDF[s:l,])
    spinDF$year <- spinDF$year-l+1
    
    ## Collecting next 50 years of transient DF
    tranDF <- as.data.frame(tranDF[1:50,])
    
    
    ## combining the two DF
    outDF <- rbind(spinDF, tranDF)
    
    return(outDF)
    
}

############# Check spin up and transient continuity
continuity_pool_plot <- function(spinDF, tranDF1, tranDF2) {
    
    #### Combine spinup and transient datasets
    DF1 <- integrate_DF(spinDF, tranDF1)
    DF2 <- integrate_DF(spinDF, tranDF2)
    
    #### Identify fluxes and stocks: 0 is other, 1 is flux, 2 is stock
    fop<-c(rep(0,2),rep(2,35),rep(1,36),rep(0,1),rep(1,23))
    
    fop<-fop[-2] 
    varnames <- names(DF1)[fop==2]
    
    #### Plotting labels
    message1 <- expression(paste(CO[2], " = 350 ppm"))
    message2 <- expression(paste(CO[2], " = 700 ppm"))
    
    
    #### Plotting all the stocks
    for (y in varnames) {
        print(y)
        plot(get(y)~year, DF2, type = "l", lwd = 2.5,
             ylab = paste(y, " [t/ha/yr]", sep=""), col="red", main = y)
        lines(get(y)~year, DF1, type = "l", lwd = 2.5, col="black")
        legend("topleft", c(message1, message2), col=c("black", "red"),
               lwd=2)
    }
    
}

run_continuity_plot <- function() {
    #### obtain the original working directory
    cwd <- getwd()
    
    #### Setting working directory
    setwd("GDAY/analyses")
    
    #### Count number of simulations runs by counting the # folders
    dirFile <- list.dirs(path=".", full.names = TRUE, recursive = FALSE)
    
    #### Set back to the original working directory
    setwd(cwd)
    
    #### plot continuity plot for each subdirectory
    for (i in 1:length(dirFile)) {
        ## Set file path
        FilePath <- paste(getwd(), "/GDAY/analyses/Run", i, sep="")
        
        ## Read in spin up, aCO2 and eCO2 files
        F1 <- read.table(paste(FilePath, "/Quasi_equil_model_spinup_equilib.csv", sep=""),
                             header=T,sep=",")
        F2 <- read.table(paste(FilePath, "/annual_gday_result_transient_CO2_AMB.csv", sep=""),
                         header=T,sep=",")
        F3 <- read.table(paste(FilePath, "/annual_gday_result_transient_CO2_ELE.csv", sep=""),
                         header=T,sep=",")
        
        pdf(paste(FilePath,"/gday_continuity_pools.pdf", sep=""), width=10,height=8)
        continuity_pool_plot(F1, F2, F3)
        dev.off()
    }
}

######################## Program ###################################
run_continuity_plot()
