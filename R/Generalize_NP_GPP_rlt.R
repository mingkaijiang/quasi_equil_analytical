#### Scripts to obtain relationships between GPP and Leaf N and Leaf N, at annual timestep
####
#### For AmazonFACE and EucFACE in order to generalize results
####

#### Read in files
amazDF_N <- read.csv("~/Documents/Research/Projects/Amazon/AMAZ/drought/outputs/AmaFACE1_D_GDA_AMB_OBS.csv",skip=3)
amazDF_P <- read.csv("~/Documents/Research/Projects/Amazon/AMAZ/drought_p/outputs/AmaFACE1_D_GDP_AMB_OBS.csv",skip=3)

#### Create a storage DF for annual step calculation
t.s <- seq(1999, 2100)
aDF_n <- data.frame(t.s, NA, NA, NA, NA, NA, NA, NA)
aDF_p <- data.frame(t.s, NA, NA, NA, NA, NA, NA, NA, NA)
colnames(aDF_n) <- c("Year", "CO2", "PAR", "GPP", "CL", "NL", "LAI", "LMA")
colnames(aDF_p) <- c("Year", "CO2", "PAR", "GPP", "CL", "NL", "PL", "LAI", "LMA")

#### Assign fluxes and stocks
for (i in 1999:2100) {
    aDF_n[aDF_n$Year == i, "CO2"] <- amazDF_N[amazDF_N$YEAR == i & amazDF_N$DOY == 1, "CO2"]
    aDF_n[aDF_n$Year == i, "PAR"] <- sum(amazDF_N[amazDF_N$YEAR == i, "PAR"])
    aDF_n[aDF_n$Year == i, "GPP"] <- sum(amazDF_N[amazDF_N$YEAR == i, "GPP"])
    aDF_n[aDF_n$Year == i, "CL"] <- amazDF_N[amazDF_N$YEAR == i & amazDF_N$DOY == 1, "CL"]
    aDF_n[aDF_n$Year == i, "NL"] <- amazDF_N[amazDF_N$YEAR == i & amazDF_N$DOY == 1, "NL"]
    aDF_n[aDF_n$Year == i, "LAI"] <- amazDF_N[amazDF_N$YEAR == i & amazDF_N$DOY == 1, "LAI"]
    aDF_n[aDF_n$Year == i, "LMA"] <- amazDF_N[amazDF_N$YEAR == i & amazDF_N$DOY == 1, "LMA"]
    
    aDF_p[aDF_p$Year == i, "CO2"] <- amazDF_P[amazDF_P$YEAR == i & amazDF_P$DOY == 1, "CO2"]
    aDF_p[aDF_p$Year == i, "PAR"] <- sum(amazDF_P[amazDF_P$YEAR == i, "PAR"])
    aDF_p[aDF_p$Year == i, "GPP"] <- sum(amazDF_P[amazDF_P$YEAR == i, "GPP"])
    aDF_p[aDF_p$Year == i, "CL"] <- amazDF_P[amazDF_P$YEAR == i & amazDF_P$DOY == 1, "CL"]
    aDF_p[aDF_p$Year == i, "NL"] <- amazDF_P[amazDF_P$YEAR == i & amazDF_P$DOY == 1, "NL"]
    aDF_p[aDF_p$Year == i, "PL"] <- amazDF_P[amazDF_P$YEAR == i & amazDF_P$DOY == 1, "PL"]
    aDF_p[aDF_p$Year == i, "LAI"] <- amazDF_P[amazDF_P$YEAR == i & amazDF_P$DOY == 1, "LAI"]
    aDF_p[aDF_p$Year == i, "LMA"] <- amazDF_P[amazDF_P$YEAR == i & amazDF_P$DOY == 1, "LMA"]
}

#### prepare other variables based on calculations
# PAR in mol m-2 to GJ



#### Compute relationships
lm.n <- lm(GPP~CO2+PAR+CL+NL+LAI, data=aDF_n)
summary(lm.n)
