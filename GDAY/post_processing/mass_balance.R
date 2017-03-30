
#### Quality check gday simulation results
####
#### Mass-balancing
################################################################################

######################## Functions ###################################
############# Process annual data, calculate delta and plot mass balance
mass_balance_check_delta <- function(FilePath) {
    
    ## Read in the file
    ann <- read.table(paste(FilePath, "/annual_gday_result_spinup.csv", sep=""),
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

############# Mass balance checking plots
mass_bal_check <- function(inDF) {
    #### Check mass balance of the time series data
    
    ###### Plottting
    
    #productivity
    plot(I(npp+auto_resp)~gpp,inDF,
         main='NPP+Ra~GPP', type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(nep+hetero_resp+auto_resp)~gpp,inDF,
         main='NEP+Rh+Ra~GPP', type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(lai~shoot,inDF,
         main='LAI~SHOOT',type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    # carbon growth rates
    plot(I(cpleaf-deadleaves)~deltashoot,inDF,
         main='Leaf C production - Dead leaf ~ Delta shoot', type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(cpstem-deadstems)~deltastem,inDF,
         main='Stem C production - Dead stem ~ Delta stem',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(cproot-deadroots)~deltaroot,inDF,
         main='Root C production - Dead root ~ Delta root',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(cpleaf+cproot+cpstem)~npp,inDF,
         main='I(cpleaf+cproot+cpstem)~npp',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(auto_resp+cpleaf+cproot+cpstem)~gpp,inDF,
         main='I(auto_resp+cpleaves+cproot+cpstem)~gpp',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(littercag+littercbg)~litterc,inDF,
         main='I(littercag+littercbg)~litterc',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(deadleaves+deadstems+deadroots-hetero_resp)~I(deltasoilc+deltalitterc),inDF,
         main='I(deadleaves+deadstems+deadroots-hetero_resp)~I(deltasoilc+deltalitterc)',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(cpleaf+cpstem+cproot)~npp,inDF,
         main='I(cpleaf+cpstem+cproot)~npp',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    
    # N cycle
    plot(I(nuptake+retransn)~I(npleaf+npstem+nproot),inDF,
         main='I(nuptake+retransn)~I(npleaf+npstem+nproot)',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(ninflow+deadleafn+deadstemn+deadrootn-nuptake-nloss)~I(deltasoiln+deltalitternag+deltalitternbg),inDF,
         main='I(ninflow+deadleafn+deadstemn+deadrootn-nuptake-nloss)~I(deltasoiln+deltalitternag+deltalitternbg)',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(activesoiln+slowsoiln+passivesoiln+inorgn)~soiln,inDF,
         main='I(activesoiln+slowsoiln+passivesoiln+inorgn)~soiln',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    # P cycle
    plot(I(puptake+retransp)~I(ppleaf+ppstem+pproot), inDF,
         main='I(puptake+retransp)~I(ppleaf+ppstem+pproot)',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(p_atm_dep+deadleafp+deadstemp+deadrootp-puptake-ploss)~I(deltasoilp+deltalitterpag+deltalitterpbg),inDF,
         main='I(p_atm_dep+deadleafp+deadstemp+deadrootp-puptake-ploss)~I(deltasoilp+deltalitterpag+deltalitterpbg)',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(inorgp+activesoilp+slowsoilp+passivesoilp)~soilp,inDF,
         main='I(inorgp+activesoilp+slowsoilp+passivesoilp)~soilp',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
    plot(I(inorgavlp+inorgssorbp+inorgoccp+inorgparp)~inorgp,inDF,
         main='I(inorgavlp+inorgssorbp+inorgoccp+inorgparp)~inorgp',
         type='p', col="blue")
    abline(a=0,b=1,col="black")
    
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
