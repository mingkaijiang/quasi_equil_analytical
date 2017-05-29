/* ============================================================================
* Photosynthesis - C3 Simple version for quasi-equilibrium analysis
*
* see below
*
* NOTES:
*
*
* AUTHOR:
*   Mingkai Jiang
*
* DATE:
*   07.02.2017
*
* =========================================================================== */
#include "photosynthesis.h"

void simple_photosynthesis(control *c, fluxes *f, met *m, params *p, state *s, 
                           double ncontent, double pcontent) {
    /* 
    Modifies mate_C3_photosynthesis using a simplier approach 
    
    */
    double lue_avg, conv1, conv2;
    double leafn, stemn, rootn, respl, resps, respr;
    double a1 = 2.753;    /* original value 0.753, changed so that CUE = ~ 50% */
    double b1 = 1.411;   /* Reich et al. 2008 Ecol. Let. Table 1, Leaves */
    double a2 = 1.053;
    double b2 = 1.315;   /* Reich et al. 2008 Ecol. Let. Table 1, Stems */
    double a3 = 0.915;
    double b3 = 1.597;   /* Reich et al. 2008 Ecol. Let. Table 1, Roots */
    double N0, P0, gamma_star, Km, jmax, vcmax, ci, alpha, ac, aj, asat, conv;
    double measurement_temp = 25.0;
    double mt = measurement_temp + DEG_TO_KELVIN;
    double Tk = 20.0 + DEG_TO_KELVIN;
    double vpd = 2.4;
    double daylen = 8.0;
    
    /* Calculate mate params & account for temperature dependencies */
    N0 = calculate_top_of_canopy_n(p, s, ncontent);   //Unit: g N m-2;
    
    if (c->pcycle == TRUE) {
        P0 = calculate_top_of_canopy_p(p, s, pcontent);   //Unit: g P m-2
    } else {
        P0 = 0.0;
    }
    
    gamma_star = calculate_co2_compensation_point(p, Tk, mt);

    Km = calculate_michaelis_menten_parameter(p, Tk, mt);

    if (c->pcycle == TRUE) {
        calculate_jmax_and_vcmax_with_p(c, p, s, Tk, N0, P0, &jmax,
                                        &vcmax, mt);
    } else {
        calculate_jmax_and_vcmax(c, p, s, Tk, N0, &jmax,
                                 &vcmax, mt);
    }
    
    ci = calculate_ci(c, p, s, vpd, m->Ca);

    /* quantum efficiency calculated for C3 plants */
    alpha = calculate_quantum_efficiency(p, ci, gamma_star);

    /* Rubisco carboxylation limited rate of photosynthesis */
    ac = assim(ci, gamma_star, vcmax, Km);

    /* Light-limited rate of photosynthesis allowed by RuBP regeneration */
    aj = assim(ci, gamma_star, jmax/4.0, 2.0*gamma_star);

    asat = MIN(aj, ac);
    
    /* Covert PAR units (umol PAR MJ-1) */
    conv = MJ_TO_J * J_2_UMOL;
    m->par *= conv;
    
    /* LUE (umol C umol-1 PAR) ; note conversion in epsilon */
    lue_avg = epsilon(p, asat, m->par, alpha, daylen);
    
    /* absorbed photosynthetically active radiation (umol m-2 s-1) */
    f->apar = m->par * s->fipar;
    
    /* convert umol m-2 d-1 -> gC m-2 d-1 */
    conv = UMOL_TO_MOL * MOL_C_TO_GRAMS_C;
    f->gpp_gCm2 = f->apar * lue_avg * conv;
    
    /* g C m-2 to tonnes hectare-1 day-1 */
    f->gpp = f->gpp_gCm2 * G_AS_TONNES / M2_AS_HA;
    
    
    /* calculate plant respiration */
    if (c->respiration_model == FIXED) {
      /* use cue to obtain gpp and auto_resp */
      f->npp_gCm2 = f->gpp_gCm2 * p->cue;
      
      /* g C m-2 to tonnes hectare-1 m-1 */
      f->npp = f->npp_gCm2 * G_AS_TONNES / M2_AS_HA;

      /* Calculate plant respiration */
      f->auto_resp = f->gpp - f->npp;
      
    } else if(c->respiration_model == TEMPERATURE) {
      fprintf(stderr, "Not implemented yet");
      exit(EXIT_FAILURE);
    } else if (c->respiration_model == LEAFN) {
        
        /* calculate leafn per leaf dry biomass, and same for stem and root, 
        in the unit of mmol[N] g-1*/
        leafn =s->shootnc / MOL_N_TO_GRAMS_N * MOL_2_MMOL;
        stemn = (s->stemn/s->stem) / MOL_N_TO_GRAMS_N * MOL_2_MMOL;
        rootn = s->rootnc / MOL_N_TO_GRAMS_N * MOL_2_MMOL;
      
        /* calculate dark respiration in nmol CO2 g-1 s-1*/
        respl = a1 * pow(leafn, b1);
        resps = a2 * pow(stemn, b2);
        respr = a3 * pow(rootn, b3);
        
        /* convert to g C m-2 month-1 */
        respl = respl * 0.031104 * s->shoot;
        resps = resps * 0.031104 * s->stem;
        respr = respr * 0.031104 * s->root;
      
        /* compute autotrophic respiration */
        f->auto_resp = respl + resps + respr;
        f->npp = f->gpp - f->auto_resp;
    }
    
    return;
  
}

double lue_simplified(control *c, params *p, state *s, double co2) {
    /*
     * New LUE function replacing epsilon function for a simplified calculation
     * of LUE
     * 
     * 
     * Parameters:
     * Nref: leaf N:C for saturation of photosynthesis   
     * LUE0: maximum gross LUE in kg C GJ-1
     */
    double lue, CaResp, Nresp, conv, assim, assim_max;
  
    CaResp = 1.632 * (co2 - 60.9) / (co2 + 121.8);
    
    if (c->pcycle) {
        assim = 16.848 + 178.664 * s->shootnc + 1418.722 * s->shootpc;
        assim_max = 16.848 + 178.664 * 0.1 + 1418.722 * 0.004;
        Nresp = assim/assim_max;
    } else {
        Nresp = MIN(s->shootnc / p->nref, 1);
    }

    
    /* converting unit for lue0 from kg C GJ-1 to umol C umol -1 PAR */
    conv = (KG_AS_G / MOL_C_TO_GRAMS_C * MOL_TO_UMOL) / (J_2_UMOL * GJ_TO_J);
      
    lue = p->lue0 * conv * CaResp * Nresp;
    
    
    return (lue);
}


double calculate_top_of_canopy_n(params *p, state *s, double ncontent)  {
    
    /*
    Calculate the canopy N at the top of the canopy (g N m-2), N0.
    Assuming an exponentially decreasing N distribution within the canopy:
    
    Note: swapped kext with kn;
    
    Returns:
    -------
    N0 : float (g N m-2)
    Top of the canopy N
    
    References:
    -----------
    * Chen et al 93, Oecologia, 93,63-69.
    
    */
    double N0;
    double kn = 0.3;
    
    if (s->lai > 0.0) {
        /* calculation for canopy N content at the top of the canopy */
        N0 = ncontent * kn / (1.0 - exp(-kn * s->lai));
    } else {
        N0 = 0.0;
    }
    
    return (N0);
}

double calculate_top_of_canopy_p(params *p, state *s, double pcontent)  {
    
    /*
    Calculate the canopy P at the top of the canopy (g P m-2), P0.
    Assuming an exponentially decreasing P distribution within the canopy:
    
    Note: swapped kext with kp;
    
    Returns:
    -------
    P0 : float (g P m-2)
    Top of the canopy P
    
    */
    double P0;
    double kn = 0.3;
    
    if (s->lai > 0.0) {
        /* calculation for canopy P content at the top of the canopy */
        P0 = pcontent * kn / (1.0 - exp(-kn * s->lai));
    } else {
        P0 = 0.0;
    }
    
    return (P0);
}

double calculate_co2_compensation_point(params *p, double Tk, double mt) {
    /*
    CO2 compensation point in the absence of mitochondrial respiration
    Rate of photosynthesis matches the rate of respiration and the net CO2
    assimilation is zero.
    
    Parameters:
    ----------
    Tk : float
    air temperature (Kelvin)
    
    Returns:
    -------
    gamma_star : float
    CO2 compensation point in the abscence of mitochondrial respiration
    */
    double gamstar25 = 42.75;
    double eag = 37830.0;
    
    return (arrh(mt, gamstar25, eag, Tk));
}

double arrh(double mt, double k25, double Ea, double Tk) {
    /*
    Temperature dependence of kinetic parameters is described by an
    Arrhenius function
    
    Parameters:
    ----------
    k25 : float
    rate parameter value at 25 degC
    Ea : float
    activation energy for the parameter [J mol-1]
    Tk : float
    leaf temperature [deg K]
    
    Returns:
    -------
    kt : float
    temperature dependence on parameter
    
    References:
    -----------
    * Medlyn et al. 2002, PCE, 25, 1167-1179.
    */
    return (k25 * exp((Ea * (Tk - mt)) / (mt * RGAS * Tk)));
}


double calculate_michaelis_menten_parameter(params *p, double Tk, double mt) {
    /*
    Effective Michaelis-Menten coefficent of Rubisco activity
    
    Parameters:
    ----------
    Tk : float
    air temperature (Kelvin)
    
    Returns:
    -------
    Km : float
    Effective Michaelis-Menten constant for Rubisco catalytic activity
    
    References:
    -----------
    Rubisco kinetic parameter values are from:
    * Bernacchi et al. (2001) PCE, 24, 253-259.
    * Medlyn et al. (2002) PCE, 25, 1167-1179, see pg. 1170.
    
    */
    
    double Kc, Ko;
    double kc25 = 404.9;
    double ko25 = 278400.0;
    double eac = 79430.0;
    double eao = 36380.0;
    double oi = 210000.0;
    
    /* Michaelis-Menten coefficents for carboxylation by Rubisco */
    Kc = arrh(mt, kc25, eac, Tk);
    
    /* Michaelis-Menten coefficents for oxygenation by Rubisco */
    Ko = arrh(mt, ko25, eao, Tk);
    
    /* return effective Michaelis-Menten coefficient for CO2 */
    return ( Kc * (1.0 + oi / Ko) ) ;
    
}

void calculate_jmax_and_vcmax(control *c, params *p, state *s, double Tk,
                              double N0, double *jmax, double *vcmax,
                              double mt) {
    /*
    Calculate the maximum RuBP regeneration rate for light-saturated
    leaves at the top of the canopy (Jmax) and the maximum rate of
    rubisco-mediated carboxylation at the top of the canopy (Vcmax).
    
    Parameters:
    ----------
    Tk : float
    air temperature (Kelvin)
    N0 : float
    leaf N   (g N m-2)
    
    
    Returns:
    --------
    jmax : float (umol/m2/sec)
    the maximum rate of electron transport at 25 degC
    vcmax : float (umol/m2/sec)
    the maximum rate of electron transport at 25 degC
    */
    double jmax25, vcmax25;
    double conv;
    double log_jmax, log_vcmax;
    
    *vcmax = 0.0;
    *jmax = 0.0;
    

    log_vcmax = 1.993 + 2.555 * log(N0) - 0.372 * log(p->sla) + 0.422 * log(N0) * log(p->sla);
    *vcmax = exp(log_vcmax);
    
    log_jmax = 1.197 + 0.847 * log_vcmax;
    *jmax = exp(log_jmax);

    return;
    
}

void calculate_jmax_and_vcmax_with_p(control *c, params *p, state *s, double Tk,
                                     double N0, double P0, double *jmax, double *vcmax,
                                     double mt) {
    /*
    Calculate the maximum RuBP regeneration rate for light-saturated
    leaves at the top of the canopy (Jmax) and the maximum rate of
    rubisco-mediated carboxylation at the top of the canopy (Vcmax).
    
    Parameters:
    ----------
    Tk : float
    air temperature (Kelvin)
    N0 : float
    leaf N   (g N m-2)
    P0 : float
    leaf P   (g P m-2)
    
    Returns:
    --------
    jmax : float (umol/m2/sec)
    the maximum rate of electron transport at 25 degC
    vcmax : float (umol/m2/sec)
    the maximum rate of electron transport at 25 degC
    */
    double jmax25, vcmax25;
    double jmax25p, jmax25n;
    double vcmax25p, vcmax25n;
    double log_jmax, log_vcmax;
    
    *vcmax = 0.0;
    *jmax = 0.0;
 
     log_vcmax = 3.946 + 0.921 * log(N0) + 0.121 * log(P0) + 0.282 * log(N0) * log(P0);
     *vcmax = exp(log_vcmax);
 
     log_jmax = 1.246 + 0.886 * log_vcmax + 0.089 * log(P0);
     *jmax = exp(log_jmax);
        

    return;
    
}

double calculate_ci(control *c, params *p, state *s, double vpd, double Ca) {
    /*
    Calculate the intercellular (Ci) concentration
    
    Formed by substituting gs = g0 + 1.6 * (1 + (g1/sqrt(D))) * A/Ca into
    A = gs / 1.6 * (Ca - Ci) and assuming intercept (g0) = 0.
    
    Parameters:
    ----------
    vpd : float
    vapour pressure deficit [Pa]
    Ca : float
    ambient co2 concentration
    
    Returns:
    -------
    ci:ca : float
    ratio of intercellular to atmospheric CO2 concentration
    
    References:
    -----------
    * Medlyn, B. E. et al (2011) Global Change Biology, 17, 2134-2144.
    */
    
    double g1w, cica, ci=0.0;
    double g1 = 3.8667;
    double wtfac_root = 1.0;
    
    g1w = g1 * wtfac_root;
    cica = g1w / (g1w + sqrt(vpd * PA_2_KPA));
    ci = cica * Ca;

    
    return (ci);
}

double calculate_quantum_efficiency(params *p, double ci, double gamma_star) {
    /*
    
    Quantum efficiency for AM/PM periods replacing Sands 1996
    temperature dependancy function with eqn. from Medlyn, 2000 which is
    based on McMurtrie and Wang 1993.
    
    Parameters:
    ----------
    ci : float
    intercellular CO2 concentration.
    gamma_star : float [am/pm]
    CO2 compensation point in the abscence of mitochondrial respiration
    
    Returns:
    -------
    alpha : float
    Quantum efficiency
    
    References:
    -----------
    * Medlyn et al. (2000) Can. J. For. Res, 30, 873-888
    * McMurtrie and Wang (1993) PCE, 16, 1-13.
    
    */
    double alpha_j = 0.308;
    
    return (assim(ci, gamma_star, alpha_j/4.0, 2.0*gamma_star));
}

double assim(double ci, double gamma_star, double a1, double a2) {
    /*
    Morning and afternoon calcultion of photosynthesis with the
    limitation defined by the variables passed as a1 and a2, i.e. if we
    are calculating vcmax or jmax limited.
    
    Parameters:
    ----------
    ci : float
    intercellular CO2 concentration.
    gamma_star : float
    CO2 compensation point in the abscence of mitochondrial respiration
    a1 : float
    variable depends on whether the calculation is light or rubisco
    limited.
    a2 : float
    variable depends on whether the calculation is light or rubisco
    limited.
    
    Returns:
    -------
    assimilation_rate : float
    assimilation rate assuming either light or rubisco limitation.
    */
    if (ci < gamma_star)
        return (0.0);
    else
        return (a1 * (ci - gamma_star) / (a2 + ci));
    
}

double epsilon(params *p, double asat, double par, double alpha,
               double daylen) {
    /*
    Canopy scale LUE using method from Sands 1995, 1996.
    
    Sands derived daily canopy LUE from Asat by modelling the light response
    of photosysnthesis as a non-rectangular hyperbola with a curvature
    (theta) and a quantum efficiency (alpha).
    
    Assumptions of the approach are:
    - horizontally uniform canopy
    - PAR varies sinusoidally during daylight hours
    - extinction coefficient is constant all day
    - Asat and incident radiation decline through the canopy following
    Beer's Law.
    - leaf transmission is assumed to be zero.
    
    * Numerical integration of "g" is simplified to 6 intervals.
    
    Parameters:
    ----------
    asat : float
    Light-saturated photosynthetic rate at the top of the canopy
    par : float
    photosyntetically active radiation (umol m-2 d-1)
    theta : float
    curvature of photosynthetic light response curve
    alpha : float
    quantum yield of photosynthesis (mol mol-1)
    
    Returns:
    -------
    lue : float
    integrated light use efficiency over the canopy (umol C umol-1 PAR)
    
    Notes:
    ------
    NB. I've removed solar irradiance to PAR conversion. Sands had
    gamma = 2000000 to convert from SW radiation in MJ m-2 day-1 to
    umol PAR on the basis that 1 MJ m-2 = 2.08 mol m-2 & mol to umol = 1E6.
    We are passing PAR in umol m-2 d-1, thus avoiding the above.
    
    References:
    -----------
    See assumptions above...
    * Sands, P. J. (1995) Australian Journal of Plant Physiology,
    22, 601-14.
    
    */
    double delta, q, integral_g, sinx, arg1, arg2, arg3, lue, h;
    int i;
    
    /* subintervals scalar, i.e. 6 intervals */
    delta = 0.16666666667;
    
    /* number of seconds of daylight */
    h = daylen * SECS_IN_HOUR;
    
    double theta = 0.7;
    
    if (asat > 0.0) {
        /* normalised daily irradiance */
        q = M_PI * p->kext * alpha * par / (2.0 * h * asat);
        integral_g = 0.0;
        for (i = 1; i < 13; i+=2) {
            sinx = sin(M_PI * i / 24.);
            arg1 = sinx;
            arg2 = 1.0 + q * sinx;
            arg3 = (sqrt(pow((1.0 + q * sinx), 2) - 4.0 * theta * q * sinx));
            integral_g += arg1 / (arg2 + arg3);
        }
        integral_g *= delta;
        lue = alpha * integral_g * M_PI;
    } else {
        lue = 0.0;
    }
    
    return (lue);
}

