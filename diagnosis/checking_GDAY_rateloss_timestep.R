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
subDF[1:6,1:6]
yr <- 383
inorgn <- subDF[subDF$year == yr & subDF$doy == 365, "inorgn"]
nup.flux <- sum(subDF[subDF$year == yr, "nuptake"])
frac <- nup.flux / inorgn
frac.orign <- (1.0 - rateloss) 

frac
frac.orign
# at annual timestep, looks good

#### Check nuptake rate calculations
nuptake <- (1.0 - rateloss) / NDAYS_IN_YR * subDF$inorgn   # considering daily loss rate
c.nuptake <- round(nuptake - subDF$nuptake, 5)
summary(c.nuptake)    # this is what went into GDAY simulation

# I may be confused with annual rate and daily rate for nuptake
# right now, I set rateloss = 0.05 with a unit of yr-1
# the left-overs of inorgn will be uptaken by plants
# so on annual timestep, uptake rate = 0.95 yr-1
# but inorgn is a pool, whereas nuptake is a flux, so
# at each time step (daily), we need to have uptake rate divided by 365.


with(subDF, plot(lai))
with(myDF, plot(lai))
summary(myDF$inorgn)
summary(myDF$inorgavlp)

# at daily time step check mass balance for inorgn
subDF$tot_in <- subDF$ninflow + subDF$nmineralisation
subDF$tot_out <- subDF$nloss + subDF$nuptake
net <- subDF$tot_in - subDF$tot_out

diff <- subDF[ , list(year,inorgn,Diff=diff(inorgn))  ]
diff <- diff(subDF$inorgn)

## check if Nin = Nloss at VL equilibrium
test <- subDF$ninflow - subDF$nloss
summary(test)
