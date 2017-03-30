
#### Plot 2d NC vs. G, 2d PC vs. G and 3d NC, PC vs G plots
####
#### 
################################################################################

######################## Functions ###################################
############# Plot equilibrium constraint analysis
quasi_equil_constraint_plot <- function(plotDF, endyear) {
    
    message <- expression(paste("Quasi-equilibrium points of doubling ", CO[2]))
    
    ## setting plot labels
    L1 <- expression(paste("Very long term equilibrium at ",CO[2], "=350 ppm"))
    L2 <- expression(paste("Instantaneous response of ",CO[2], "=700 ppm"))
    L3 <- expression(paste("Long term equilibrium at ",CO[2], "=700 ppm"))
    L4 <- expression(paste("Very long term equilibrium at ",CO[2], "=700 ppm"))
    
    ## Plotting each plots
    nc_constraint_plot(plotDF, message, endyear)
    pc_constraint_plot(plotDF, message, endyear)
    constraint_3d(plotDF, message, endyear)
}


############# Plot nc constrant vs. NPP curve with transient data frame
nc_constraint_plot <- function(tranDF, message, endyear) {
    plot(npp~I(shootn/shoot), tranDF[5,], type="p",
         cex = 2, ylab = "NPP [t/ha/yr]", xlab = "Shoot NC", 
         ylim=c(10,35), col="black", pch=19)
    points(npp~I(shootn/shoot), tranDF[6,], type="p",
           cex = 2, col="red", pch=19)
    points(npp~I(shootn/shoot), tranDF[300,], type="p",
           cex = 2, col="orange", pch=19)
    points(npp~I(shootn/shoot), tranDF[endyear,], type="p",
           cex = 2, col="blue", pch=19)
    abline(v=(tranDF[5,"shootn"]/tranDF[5,"shoot"]))
    
    legend("bottomright", c(L1, L2, L3, L4),
           col=c("black", "red", "orange", "blue"), pch = 19)
    title(message)
}

############# Plot pc constrant vs. NPP curve with transient data frame
pc_constraint_plot <- function(tranDF, message, endyear) {
    plot(npp~I(shootp/shoot), tranDF[5,], type="p",
         cex = 2, ylab = "NPP [t/ha/yr]", xlab = "Shoot PC", 
         ylim=c(10,35), col="black", pch=19)
    points(npp~I(shootp/shoot), tranDF[6,], type="p",
           cex = 2, col="red", pch=19)
    points(npp~I(shootp/shoot), tranDF[300,], type="p",
           cex = 2, col="orange", pch=19)
    points(npp~I(shootp/shoot), tranDF[endyear,], type="p",
           cex = 2, col="blue", pch=19)
    abline(v=(tranDF[5,"shootp"]/tranDF[5,"shoot"]))
    legend("bottomright", c(L1, L2, L3, L4),
           col=c("black", "red", "orange", "blue"), pch = 19)
    title(message)
}

############# Plot 3d leaf constrant vs. NPP curve with transient data frame
constraint_3d <- function(tranDF, message, endyear) {
    ## library
    require(scatterplot3d)
    
    # constraint by nutrient and photo at CO2 = 350
    s3d <- scatterplot3d(tranDF[5,"shootn"]/tranDF[5,"shoot"], 
                         tranDF[5,"shootp"]/tranDF[5,"shoot"], 
                         tranDF[5,"npp"], xlim=c(0.005, 0.05),
                         ylim = c(0.0, 0.002), zlim=c(10, 35), 
                         type = "h", pch = 19, xlab = "N:C", ylab = "P:C", zlab = "NPP [t/ha/yr]",
                         color="black")
    
    # constraint by nutrient and photo at CO2 = 700 instantaneous
    s3d$points3d(tranDF[6,"shootn"]/tranDF[6,"shoot"], 
                 tranDF[6,"shootp"]/tranDF[6,"shoot"], 
                 tranDF[6,"npp"], type="h", pch=19, col="red")
    
    # constraint by nutrient and photo at CO2 = 700 long term
    s3d$points3d(tranDF[300,"shootn"]/tranDF[300,"shoot"], 
                 tranDF[300,"shootp"]/tranDF[300,"shoot"], 
                 tranDF[300,"npp"], type="h", pch=19, col="orange")
    
    # constraint by nutrient and photo at CO2 = 700 equilibrium
    s3d$points3d(tranDF[endyear,"shootn"]/tranDF[endyear,"shoot"], 
                 tranDF[endyear,"shootp"]/tranDF[endyear,"shoot"], 
                 tranDF[endyear,"npp"], type="h", pch=19, col="blue")
    
    legend("bottomright", c(L1, L2, L3, L4),
           col=c("black", "red", "orange", "blue"), pch = 19)
    
    title(message)
    
}

run_gday_quasi_equil_plot <- function() {
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
        
        ## Read in the eCO2 files
        inDF <- read.table(paste(FilePath, "/annual_gday_result_transient_CO2_ELE.csv", sep=""),
                         header=T,sep=",")
        
        pdf(paste(FilePath,"/gday_quasi_equil_eCO2.pdf", sep=""), width=10,height=8)
        quasi_equil_constraint_plot(inDF, endyear = 4850)
        dev.off()
    }
}

######################## Program ###################################
run_gday_quasi_equil_plot()
