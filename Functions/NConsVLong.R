### Calculate the very long term nutrient cycling constraint for N, i.e. passive pool equilibrated
# it is just Nin = Nleach
NConsVLong <- function(df, a, Nin=0.4, 
                       leachn=0.05) {
    # passed are bf and nf, the allocation and plant N:C ratios
    # parameters : 
    # Nin is fixed N inputs (N fixed and deposition) in g m-2 yr-1 (could vary fixation)
    # leachn is the rate of leaching of the mineral N pool (per year)
    
    # equation for N constraint with just leaching
    U0 <- Nin
    nleach <- leachn/(1-leachn) * (a$nfl*a$af + a$nr*(a$ar) + a$nw*a$aw)
    NPP_NC <- U0 / (nleach)   # will be in g C m-2 yr-1
    NPP_N <- NPP_NC*10^-3     # returned in kg C m-2 yr-1
    
    df <- data.frame(NPP_N,nleach)
    return(df)   
}