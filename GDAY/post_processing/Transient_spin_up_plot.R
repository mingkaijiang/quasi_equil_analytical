
#### Plot transient (annual) time-series spin-up plots
####
#### 
################################################################################

######################## Functions ###################################

############# Basic time-series plotting
basic_ts_plot_discrete <- function(plotDF) {
    #### Plot all variables through time, condensing time
    n <- names(plotDF)
    yvars <- n[-1]
    
    ## Plot all data, starting from 2nd column
    for (i in yvars) {
        #print(i)
        plot(get(i)~year, plotDF, type = "l", lwd = 2.5,
             cex = 2, ylab = i, 
             main = i)
        # print(timeplot)
    }
}


run_plot_discrete <- function() {
    #### obtain the original working directory
    cwd <- getwd()
    
    #### Setting working directory
    setwd("GDAY/outputs")
    
    #### Count number of simulations runs by counting the # folders
    dirFile <- list.dirs(path=".", full.names = F, recursive = FALSE)
    
    #### Set back to the original working directory
    setwd(cwd)
    
    #### Do mass balance for each sub-simulations
    for (i in 1:length(dirFile)) {
        FilePath <- paste(getwd(), "/GDAY/analyses/", dirFile[i], sep="")
        plotDF <- read.table(paste(FilePath, "/annual_gday_result_spinup.csv", sep=""),
                      header=T,sep=",")
        
        print(FilePath)
        pdf(paste(FilePath, "/Basic_time_series_spinup_discrete.pdf", sep=""))
        basic_ts_plot_discrete(plotDF)
        dev.off()
    }
}

######################## Programs ###################################
run_plot_discrete()

