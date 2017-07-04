#### setting CO2 concentrations
CO2_1 <- 400.0
CO2_2 <- 550.0

#### define parameters
nwood = 0.003 
pwood = 0.00014
nrho = 0.7
prho = 0.7
nretrans = 0.5
pretrans = 0.6
nwvar = FALSE
pwvar = FALSE
LUE0=1.4
I0=3
Nref=0.04
kext=0.5
SLA=5.1
sf=0.5
cfrac = 0.45
cue = 0.5
leachn = 0.05
leachp = 0.1
Nin = 0.2
Pin = 0.02          #0.0086
k1=0.048            # 0.096  # default in full GDAY = 0.048, and 0.4-0.8 of the labile is available to uptake
k2=0.0146           # 0.0146 At EucfACE, based on pH = 4.5, k2 = 0.0146 yr-1, and only half into labile
k3=0.05
Tsoil = 15
Texture = 0.5
ligfl = 0.2
ligrl = 0.16
pcp = 0.005
ncp = 0.1
PAR_MJ <- 4.0
J_2_UMOL <- 4.57
MJ_TO_J <- 1000000.0
par <- MJ_TO_J * J_2_UMOL * PAR_MJ
UMOL_TO_MOL <- 0.000001
MOL_C_TO_GRAMS_C <- 12.0
conv <- UMOL_TO_MOL * MOL_C_TO_GRAMS_C
mt <- 25.0 + 273.5  # degree to kelvin
tk <- 20.0 + 273.5  # air temperature
gamstar25 <- 42.75
eag <- 37830.0
eac <- 79430.0
eao <- 36380.0
kc25 <- 404.9
ko25 <- 278400.0
oi <- 210000.0
vpd <- 2.4
PA_2_KPA <- 0.001
wtfac_root <- 1.0
g1 <- 3.8667
alpha_j <- 0.308
daylen <- 5.0
kn <- 0.3