# checking GDAY simulated N and P fluxes to see if they match with the coefficients
require(data.table)

#### read in file
myDF <- fread("GDAY/outputs/Run1/Quasi_equil_model_spinup_equilib.csv",skip=1)
e <- nrow(myDF)
s <- e - 10000.0

subDF <- myDF[s:e,]

#### Set parameters
rateloss <- 0.05
NDAYS_IN_YR <- 365.0

#### Check nuptake rate calculations
nuptake <- (1.0 - rateloss) * subDF$inorgn   # considering annual loss rate
c.nuptake <- round(nuptake - subDF$nuptake, 5)
summary(c.nuptake)    # this is what went into GDAY simulation

#### annual nuptake ~ total inorgn
yr <- 2524
inorgn <- subDF[subDF$year == yr & subDF$doy == 365, "inorgn"]
nup.flux <- sum(subDF[subDF$year == yr, "nuptake"])
frac <- nup.flux / inorgn
frac.orign <- (1.0 - rateloss) * NDAYS_IN_YR
# too much uptake

#### Check nuptake rate calculations
nuptake <- (1.0 - rateloss / NDAYS_IN_YR) * subDF$inorgn   # considering daily loss rate


