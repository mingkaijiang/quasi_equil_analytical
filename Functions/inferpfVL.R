### Make inference of pf based on nf
inferpfVL <- function(nf, a) {
    
    # output nf, based on F(nf) = F(pf)
    pf <- c()
    
    Nleach <- (leachn/(1-leachn)) * (a$nfl * a$af + a$nr * a$ar +
                                         a$nw *a$aw)
    
    Pleach <- (leachp/(1-leachp-k1)) 
    Pocc <- (k3/(k2+k3))*(k1/(1-k1-leachp)) 
    
    Pg <- ((Pin * Nleach)/Nin) / (Pocc + Pleach)
    
    if(pwvar == FALSE) {
        pf <- (Pg - pwood * a$aw) / ((1.0 - pretrans) * a$af + prho * a$ar)
    } else {
        pf <- Pg / ((1.0 - pretrans) * a$af + prho * a$ar + a$aw * pwood)
    }
    return(round(pf,8))
}
