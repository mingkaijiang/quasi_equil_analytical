
### Quasi-equlibrium analysis
###
### Create monthly met forcing data based on hypothetical climate data
###
### Author: Mingkai Jiang
### Created on: Feb-07-2017

######### Functions
create_dataset <- function(outName,
                           nyear=20000.0, tsoil=15.0, co2 = 350.0, ndep = 0.002, nfix = 0.002,
                           pdep = 0.0002, par = 3000.0) {
    #### Create hypothetical monthly input data for simplfied gday transient runs
    #### outName: Out File name
    #### nyear: number of years for met forcing data
    #### tsoil: soil temperature in degree C
    #### co2: co2 level in ppm
    #### ndep: N deposition in t/ha/yr
    #### nfix: N fixation in t/ha/yr
    #### pdep: P deposition in t/ha/yr
    #### par: PAR in MJ/m2/yr
  
    ### get date
    date<-Sys.Date()
    
    ### Create empty outDF
    ny <- 12*nyear
    outDF <- matrix(nrow=ny, ncol=8)
    colnames(outDF) <- c("year", "moy", "tsoil", "co2", "ndep", "nfix", "pdep", "par")
    outDF <- as.data.frame(outDF)
    outDF$year <- seq(from=1, to=nyear, by = 1)
    outDF <- outDF[order(outDF$year),]
    outDF$moy <- seq(from=1, to=12, by = 1)
    
    ### baseline met, i.e. those used in spin-up
    tsoil_b <- 15.0
    co2_b <- 350.0
    ndep_b_m <- 0.002/12.0
    nfix_b_m <- 0.002/12.0
    pdep_b_m <- 0.0002/12.0
    par_b_m <- 3000/12.0
    
    ### assign baseline met to first 5 years of the dataframe
    outDF[1:60,"tsoil"] <- tsoil_b
    outDF[1:60,"co2"] <- co2_b
    outDF[1:60,"ndep"] <- ndep_b_m
    outDF[1:60,"nfix"] <- nfix_b_m
    outDF[1:60,"pdep"] <- pdep_b_m
    outDF[1:60,"par"] <- par_b_m
    
    ### conver from annual to monthly rates, for those needed
    ndep_m <- ndep/12.0
    nfix_m <- nfix/12.0
    pdep_m <- pdep/12.0
    par_m <- par/12.0
    
    ### Assign met data defined by user onto the rest years 
    outDF[61:ny,"tsoil"] <- tsoil
    outDF[61:ny,"co2"] <- co2
    outDF[61:ny,"ndep"] <- ndep_m
    outDF[61:ny,"nfix"] <- nfix_m
    outDF[61:ny,"pdep"] <- pdep_m
    outDF[61:ny,"par"] <- par_m
    
    ### rows
    row1 <- "# simplified gday met forcing transient"
    row2 <- "# Data from 1 - 500 years"
    row3 <- paste("# Created by Mingkai Jiang: ", date, sep="")
    
    row4 <- as.list(c("#--", "--", "degC", "ppm", "t/ha/m",
                                   "t/ha/m", "t/ha/m", "mj/m2/m"))
    row5 <- as.list(as.character(c("#year", "moy", "tsoil", "co2", "ndep", "nfix", "pdep", "par")))
    
    # write into folder
    write.table(row1, outName,
                col.names=F, row.names=F, sep=",", append=F, quote = F)
    
    write.table(row2, outName,
                col.names=F, row.names=F, sep=",", append=T, quote=F)
    
    write.table(row3, outName,
                col.names=F, row.names=F, sep=",", append=T, quote=F)
    
    write.table(row4, outName,
                col.names=F, row.names=F, sep=",", append=T, quote=F)
    
    write.table(row5, outName,
                col.names=F, row.names=F, sep=",", append=T, quote=F)
    
    write.table(outDF, outName,
                col.names=F, row.names=F, sep=",", append=T, quote=F)
    

}


######### Scripts

  f.Path <- "GDAY/met_data"
  
  ifelse(!dir.exists(file.path(f.Path)), dir.create(file.path(f.Path)), FALSE)

  met1 <- paste(f.Path, "/Quasi_equil_met_forcing_transient_co2_amb.csv", sep="")
  met2 <- paste(f.Path, "/Quasi_equil_met_forcing_transient_co2_ele.csv", sep="")
  
  create_dataset(met1, co2=350, nyear = 200)   # no need of running for a very long time as the model equilibrates already in spinup
  create_dataset(met2, co2=700, nyear = 20000)



