#### Check continuity in transient files
#### For both pools and fluxes
#### Can set end year
#### Different from Check_continuity in that it doesn't start from spin-up files
#### And it includes fluxes in addition to pools
################################################################################

######################## Functions ###################################
############# Check transient pool and flux continuity
transient_continuity <- function(tranDF, endyear) {
    
    tranDF <- tranDF[1:endyear,]
    
    message <- expression(paste("Doubling of ", CO[2]))
    
    #### Fluxes
    ## Create multi-panel dataset
    panelDF <- melt(subset(tranDF, select=c("year", "npp", "nuptake", "puptake")),
                    id.var="year")
    
    ## Plot
    p1 <- xyplot(value~year|variable, data=panelDF, type="l",
                 scales=list(y=list(relation="free")),
                 layout=c(1,3), main=message)
    
    #### Plant C
    ## Create multi-panel dataset
    panelDF <- melt(subset(tranDF, select=c("year", "shoot", "stem", "root")),
                    id.var="year")
    
    ## Plot
    p2 <- xyplot(value~year|variable, data=panelDF, type="l",
                 scales=list(y=list(relation="free")),
                 layout=c(1,3), main=message)
    
    #### Plant N
    ## Create multi-panel dataset
    panelDF <- melt(subset(tranDF, select=c("year", "shootn", "stemn", "rootn")),
                    id.var="year")
    
    ## Plot
    p3 <- xyplot(value~year|variable, data=panelDF, type="l",
                 scales=list(y=list(relation="free")),
                 layout=c(1,3), main=message)
    
    #### Plant P
    ## Create multi-panel dataset
    panelDF <- melt(subset(tranDF, select=c("year", "shootp", "stemp", "rootp")),
                    id.var="year")
    
    ## Plot
    p4 <- xyplot(value~year|variable, data=panelDF, type="l",
                 scales=list(y=list(relation="free")),
                 layout=c(1,3), main=message)
    
    #### Organic soil C
    ## Create multi-panel dataset
    panelDF <- melt(subset(tranDF, select=c("year", "activesoil", "slowsoil", "passivesoil")),
                    id.var="year")
    
    ## Plot
    p5 <- xyplot(value~year|variable, data=panelDF, type="l",
                 scales=list(y=list(relation="free")),
                 layout=c(1,3), main=message)
    
    #### Soil N
    ## Create multi-panel dataset
    panelDF <- melt(subset(tranDF, select=c("year", "activesoiln", "slowsoiln", "passivesoiln","inorgn")),
                    id.var="year")
    
    ## Plot
    p6 <- xyplot(value~year|variable, data=panelDF, type="l",
                 scales=list(y=list(relation="free")),
                 layout=c(1,4), main=message)
    
    #### Soil P
    ## Create multi-panel dataset
    panelDF <- melt(subset(tranDF, select=c("year", "activesoilp", "slowsoilp", "passivesoilp","inorgp")),
                    id.var="year")
    
    ## Plot
    p7 <- xyplot(value~year|variable, data=panelDF, type="l",
                 scales=list(y=list(relation="free")),
                 layout=c(1,4), main=message)
    
    #### Inorg P
    ## Create multi-panel dataset
    panelDF <- melt(subset(tranDF, select=c("year", "inorgavlp", "inorgssorbp", "inorgoccp","inorgparp")),
                    id.var="year")
    
    ## Plot
    p8 <- xyplot(value~year|variable, data=panelDF, type="l",
                 scales=list(y=list(relation="free")),
                 layout=c(1,4), main=message)
    
    print(p1)
    print(p2)
    print(p3)
    print(p4)
    print(p5)
    print(p6)
    print(p7)
    print(p8)
    
}

run_transient_continuity <- function() {
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
        inDF <- read.table(paste(FilePath, "/annual_gday_result_transient_CO2_ELE.csv", sep=""),
                         header=T,sep=",")
        
        pdf(paste(FilePath,"/gday_continuity_eCO2_transient.pdf", sep=""), width=10,height=8)
        continuity_pool_plot(inDF, endyear = 200)
        dev.off()
    }
}


######################## program ###################################
run_transient_continuity()