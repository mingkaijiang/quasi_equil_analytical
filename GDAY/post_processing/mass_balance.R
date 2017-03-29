
#### Quality check gday simulation results
####
#### Mass-balancing
################################################################################

######################## Functions ###################################
############# Process annual data, calculate delta and plot mass balance
mass_balance_check_delta <- function(FilePath) {
    
    ## Read in the file
    ann <- read.table(paste(FilePath, "/Quasi_equil_model_spinup_equilib.csv", sep=""),
                      header=T,sep=",")
    
    ## update year list for calculation of delta
    yrange <- unique(ann$year)
    n <- names(ann)
    yvars <- n[-1]
    
    ## stock variable names
    svars <- yvars[1:35]
    
    ## add change in pools (delta) for mass balance check
    delta<- cbind(ann[,2:36])
    delta[,]<-NA
    
    ## update yrange to remove last year
    num <- length(yrange)
    yrange2 <- c(0:(num-2))
    
    ## Fill the delta dataframe
    for(n in svars) {
        for (yr in yrange2) {
            
            ind<-ann$year==yr
            ind1<-ann$year==yr+1
            
            delta[ind,n]<-ann[ind1,n]-ann[ind,n]
        }
    }
    
    ## update delta names
    names(delta)<-paste("delta",names(delta),sep="")
    
    ## update original dataframe to include delta dataframe
    ann<-cbind(ann,delta) 
    
    #### Plotting basic time series data, for the time period as stated
    #### Mass balance check, for the first 100 years only
    pdf(paste(FilePath, "/gday_spinup_QC_Initial.pdf", sep=""), width=10,height=8)
    mass_bal_check(ann[1:100,])
    dev.off()
    
    #### Mass balance check, for the last 100 years only
    end <-nrow(ann)
    start <- nrow(ann)-100
    pdf(paste(FilePath, "/gday_spinup_QC_End.pdf", sep=""), width=10,height=8)
    mass_bal_check(ann[start:end,])
    dev.off()
    
}

run_mass_balance_check <- function() {
    #### obtain the original working directory
    cwd <- getwd()
    
    #### Setting working directory
    setwd("GDAY/analyses")
    
    #### Count number of simulations runs by counting the # folders
    dirFile <- list.dirs(path=".", full.names = TRUE, recursive = FALSE)
    
    #### Set back to the original working directory
    setwd(cwd)
    
    #### Do mass balance for each sub-simulations
    for (i in 1:length(dirFile)) {
        FilePath <- paste(getwd(), "/GDAY/analyses/Run", i, sep="")
        mass_balance_check_delta(FilePath) 
        }
    
}


######################## Program ###################################
run_mass_balance_check()
