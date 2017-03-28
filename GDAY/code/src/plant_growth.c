/* ============================================================================
* Calls photosynthesis model, water balance and evolves aboveground plant
* C & Nstate. Pools recieve C through allocation of accumulated photosynthate
* and N from both soil uptake and retranslocation within the plant. Key feedback
* through soil N mineralisation and plant N uptake
*
*
* NOTES:
*
*
* AUTHOR:
*   Martin De Kauwe
*
* DATE:
*   17.02.2015
*
* =========================================================================== */
#include "plant_growth.h"

void calc_annual_growth(control *c, fluxes *f, 
                     met *m, nrutil *nr, params *p, state *s)
{
   double ncwnew;
   double pcwnew;

    /* calculate annual GPP/NPP, respiration and update water balance */
    carbon_annual_production(c, f, m, p, s);

    /* figure out the C allocation fractions */
    /* annual allocation ...*/
    calc_carbon_allocation_fracs(c, f, p, s);

    /* Distribute new C, N and P through the system */
    carbon_allocation(c, f, p, s);

    calculate_cnp_wood_ratios(c, p, s, &ncwnew, &pcwnew);
    
    np_allocation(c, f, p, s,ncwnew, pcwnew);
    
    if (c->exudation) {
      calc_root_exudation(c, f, p, s);
    }
    
    update_plant_state(c, f, p, s);

    precision_control(f, s);
    
    return;
}

void calc_root_exudation(control *c, fluxes *f, params *p, state *s) {
  /*
   Rhizodeposition (f->root_exc) is assumed to be a fraction of the
   current root growth rate (f->cproot), which increases with increasing
   N stress of the plant.
   */
  double CN_leaf, frac_to_rexc, CN_ref, arg;
  
  if (float_eq(s->shoot, 0.0) || float_eq(s->shootn, 0.0)) {
    /* nothing happens during leaf off period */
    CN_leaf = 0.0;
    frac_to_rexc = 0.0;
  } else {
     CN_ref = p->nref;
    
    /*
     ** The fraction of growth allocated to rhizodeposition, constrained
     ** to solutions lower than 0.5
     */
    CN_leaf = 1.0 / s->shootnc;
    arg = MAX(0.0, (CN_leaf - CN_ref) / CN_ref);
    frac_to_rexc = MIN(0.5, p->a0rhizo + p->a1rhizo * arg);
  }
  
  /* Rhizodeposition */
  f->root_exc = frac_to_rexc * f->cproot;
  if (float_eq(f->cproot, 0.0)) {
    f->root_exn = 0.0;
    f->root_exp = 0.0;
  } else {
    /*
     ** N flux associated with rhizodeposition is based on the assumption
     ** that the CN ratio of rhizodeposition is equal to that of fine root
     ** growth
     */
    f->root_exn = f->root_exc * (f->nproot / f->cproot);
    f->root_exp = f->root_exc * (f->pproot / f->cproot);
    
  }
  
  /*
   ** Need to remove exudation C & N fluxes from fine root growth fluxes so
   ** that things balance.
   */
  f->cproot -= f->root_exc;
  f->nproot -= f->root_exn;
  f->pproot -= f->root_exp;
  
  /*fprintf(stderr, "calc_root_exudation cproot %f, nproot %f, pproot %f\n", 
          f->cproot,  f->nproot, f->pproot);
  */
  return;
}

void carbon_annual_production(control *c, fluxes *f, met *m, params *p, state *s) {
    /* Calculate GPP, NPP and plant respiration at the annual timestep

    References:
    -----------
    * Jackson, J. E. and Palmer, J. W. (1981) Annals of Botany, 47, 561-565.
    */

    /* fIPAR - the fraction of intercepted PAR = IPAR/PAR incident at the
       top of the canopy, accounting for partial closure based on Jackson
       and Palmer (1979). */
    
    double lue_avg, conv1, conv2;
  
    if (s->lai > 0.0)
        s->fipar = 1.0 - exp(-p->kext * s->lai);
    else
        s->fipar = 0.0;
 
    /* Estimate photosynthesis */
    simple_photosynthesis(c, f, m, p, s);
    

    return;
}

void calculate_cnp_wood_ratios(control *c, params *p, state *s,
                               double *ncwnew, double *pcwnew) {
    /* Estimate the N:C and P:C ratio in the stem. Option to vary
    the N:C and P:C ratio of the stem following Jeffreys (1999) or keep it a fixed
    fraction

    Parameters:
    -----------
    npitfac: float
       min of nitfac and pitfac;
    nitfac: float
       leaf N:C as a fraction of Ncmaxyoung;
    pitfac : float
       leaf P:C as a fraction of Pcmaxyoung;

    Returns:
    --------
    ncwnew : float
        N:C ratio of mobile stem
    pcwnew : float
        P:C ratio of mobile stem

    References:
    ----------
    * Jeffreys, M. P. (1999) Dynamics of stemwood nitrogen in Pinus radiata
      with modelled implications for forest productivity under elevated
      atmospheric carbon dioxide. PhD.
    */

    /* fixed N:C in the stemwood */
    if (c->fixed_stem_nc) {
      
      /* New stem ring N:C at critical leaf N:C (mobile) */
      *ncwnew = p->ncwnewz;
      
    } else {
      *ncwnew = s->shootnc * p->ncwnewz;
    }

    /* fixed P:C in the stemwood */
    if (c->fixed_stem_pc) {
      
      *pcwnew = p->pcwnewz;
      
    } else {
      *pcwnew = s->shootpc * p->pcwnewz;
    }

    return;
}

void np_allocation(control *c, fluxes *f, params *p, state *s, 
                   double ncwnew, double pcwnew) {
    /*
        Nitrogen and phosphorus distribution - allocate available N and
        P (mineral) through system. N and P is first allocated to the woody
        component, surplus N and P is then allocated to the shoot and roots
        with flexible ratios.

        References:
        -----------
        McMurtrie, R. E. et al (2000) Plant and Soil, 224, 135-152.

        Parameters:
        -----------
        ncwnew : float
            N:C ratio of mobile stem
        pcwnew : float
            P:C ratio of mobile stem
        fdecay : float
            foliage decay rate
        rdecay : float
            fine root decay rate
    */

    //int    recalc_wb;
    double nsupply, psupply, rtot, ntot, ptot, arg;

    /* default is we don't need to recalculate the water balance,
       however if we cut back on NPP due to available N and P below then we do
       need to do this */
    //recalc_wb = FALSE;

    /* N and P retranslocated proportion from dying plant tissue and stored within
       the plant */
    f->retransn = nitrogen_retrans(c, f, p, s);
    f->retransp = phosphorus_retrans(c, f, p, s);
    
    /* N and P uptake */
    f->nuptake = calculate_nuptake(c, p, s, f);
    f->puptake = calculate_puptake(c, p, s, f);
    
    /* Mineralised nitrogen lost from the system by volatilisation/leaching */
    if(c->nuptake_model == 0) {
      f->nloss = (p->rateloss * NMONTHS_IN_YR) * s->inorgn;
    } else if (c->nuptake_model == 1) {
      f->nloss = p->rateloss * s->inorgn;
    } else if (c->nuptake_model == 2) {
      f->nloss = p->rateloss * s->inorgn;
    }

    /* Mineralised P lost from the system by leaching */
    if(c->puptake_model == 0) {
      f->ploss = (p->prateloss * NMONTHS_IN_YR) * s->inorgavlp; 
    } else if (c->puptake_model == 1) {
      f->ploss = p->prateloss * s->inorgavlp;
    } else if (c->puptake_model == 2) {
      f->ploss = p->prateloss * s->inorgavlp;
    }

    /* total nitrogen/phosphorus to allocate */
    ntot = MAX(0.0, f->nuptake + f->retransn);
    ptot = MAX(0.0, f->puptake + f->retransp);
    
    /* allocate N to pools with fixed N:C ratios */
    /* N flux into new ring */
    f->npstem = f->npp * f->alstem * ncwnew;

    /* allocate P to pools with fixed P:C ratios */
    f->ppstem = f->npp * f->alstem * pcwnew;
    
    /* If we have allocated more N than we have avail, cut back C prodn */
    arg = f->npstem;
    if (arg > ntot && c->fixleafnc == FALSE && c->ncycle) {
      fprintf(stderr, "in cut back n \n");
      cut_back_production_n(c, f, p, s, ntot, ncwnew, pcwnew);
    }
    
    /* If we have allocated more P than we have avail, cut back C prodn */
    arg = f->ppstem;
    if (arg > ptot && c->fixleafpc == FALSE && c->pcycle) {
      fprintf(stderr, "in cut back p \n");
      cut_back_production_p(c, f, p, s, ptot, ncwnew, pcwnew);
    }
    
    /* Nitrogen reallocation to flexible-ratio pools */
    ntot -= f->npstem;
    ntot = MAX(0.0, ntot);
    
    /* allocate remaining N to flexible-ratio pools */
    f->npleaf = ntot * f->alleaf / (f->alleaf + f->alroot * p->ncrfac);
    f->nproot = ntot - f->npleaf;
    
    /* Phosphorus reallocation to flexible-ratio pools */
    ptot -= f->ppstem;
    ptot = MAX(0.0, ptot);
    
    /* allocate remaining P to flexible-ratio pools */
    f->ppleaf = ptot * f->alleaf / (f->alleaf + f->alroot * p->pcrfac);
    f->pproot = ptot - f->ppleaf;
    
    return;
}

void cut_back_production_n(control *c, fluxes *f, params *p, state *s,
                        double tot, double ncwnew, double pcwnew) {

    double lai_inc, conv;
    double shoot_biomass, leafn, resp;
    double a = 0.645;   /* Reich et al. 2008 Ecol. Let. Table 1, Leaves */
    double b = 1.66;    /* Reich et al. 2008 Ecol. Let. Table 1, Leaves */
    /* default is we don't need to recalculate the water balance,
       however if we cut back on NPP due to available N and P below then we do
       need to do this */

    /* Need to readjust the LAI for the reduced growth as this will
       have already been increased. First we need to figure out how
       much we have increased LAI by, important it is done here
       before cpleaf is reduced! */
    if (float_eq(s->shoot, 0.0)) {
        lai_inc = 0.0;
    } else {
        lai_inc = (f->cpleaf *
                   (p->sla * M2_AS_HA / (KG_AS_TONNES * p->cfracts)) -
                   f->deadleaves * s->lai / s->shoot);
    }

    f->npp *= tot / f->npstem;

    /* need to adjust growth values accordingly as well */
    f->cpleaf = f->npp * f->alleaf;
    f->cproot = f->npp * f->alroot;
    f->cpstem = f->npp * f->alstem;


    if (c->pcycle) {
        f->npstem = f->npp * f->alstem * ncwnew;
        f->ppstem = f->npp * f->alstem * pcwnew;
    } else {
        f->npstem = f->npp * f->alstem * ncwnew;
    }
    
    /* Now reduce LAI for down-regulated growth. */
    /* update leaf area [m2 m-2] */
    if (float_eq(s->shoot, 0.0)) {
      s->lai = 0.0;
    } else {
      s->lai -= lai_inc;
      s->lai += (f->cpleaf *
        (p->sla * M2_AS_HA / \
        (KG_AS_TONNES * p->cfracts)) -
        f->deadleaves * s->lai / s->shoot);
    }
    
    /* calculate plant respiration */
    if (c->respiration_model == FIXED) {
      /* use cue to obtain gpp and auto_resp */
      f->gpp = f->npp / p->cue;
      conv = G_AS_TONNES / M2_AS_HA;
      f->gpp_gCm2 = f->gpp / conv;
      
      /* New respiration flux */
      f->auto_resp =  f->gpp - f->npp;
      
    } else if(c->respiration_model == TEMPERATURE) {
      fprintf(stderr, "Not implemented yet");
      exit(EXIT_FAILURE);
    } else if (c->respiration_model == LEAFN) {
      /* obtain leaf biomass in g/m2 */
      shoot_biomass = s->lai / (p->sla * M2_AS_HA / (KG_AS_TONNES * p->cfracts)) / G_AS_TONNES * M2_AS_HA; 
      
      /* convert shootn from t/ha to mmol/m2 */
      leafn = s->shootn / G_AS_TONNES * M2_AS_HA / MOL_N_TO_GRAMS_N * MOL_2_MMOL;
      
      /* calculate leafn in mmol [N] g-1 [shoot biomass] */
      leafn = leafn / shoot_biomass;
      
      /* calculate leaf dark respiration in nmol g-1 s-1 */
      resp = a * leafn * exp(b);
      
      /* convert respiration rate from mmol g-1 s-1 to t/ha/m */
      /* 1: from nmol g-1 s-1 to g m-2 s-1 */
      resp = resp * NMOL_2_MOL * MOL_C_TO_GRAMS_C * shoot_biomass;
      
      /* 2: from g m-2 s-1 to t ha-2 month-1 */
      resp = resp * SECS_IN_HOUR * 24.0 * NDAYS_IN_YR / NMONTHS_IN_YR * G_AS_TONNES / M2_AS_HA;
      
      f->auto_resp = resp;
      f->gpp = f->npp + f->auto_resp;
    }

    return;
}

void cut_back_production_p(control *c, fluxes *f, params *p, state *s,
                           double tot, double ncwnew, double pcwnew) {
  
  double lai_inc, conv;
  double shoot_biomass, leafn, resp;
  double a = 0.645;   /* Reich et al. 2008 Ecol. Let. Table 1, Leaves */
  double b = 1.66;    /* Reich et al. 2008 Ecol. Let. Table 1, Leaves */
  /* default is we don't need to recalculate the water balance,
  however if we cut back on NPP due to available N and P below then we do
  need to do this */
  
  /* Need to readjust the LAI for the reduced growth as this will
  have already been increased. First we need to figure out how
  much we have increased LAI by, important it is done here
  before cpleaf is reduced! */
  if (float_eq(s->shoot, 0.0)) {
    lai_inc = 0.0;
  } else {
    lai_inc = (f->cpleaf *
      (p->sla * M2_AS_HA / (KG_AS_TONNES * p->cfracts)) -
      f->deadleaves * s->lai / s->shoot);
  }
  
  f->npp *= tot / f->ppstem;
  
  /* need to adjust growth values accordingly as well */
  f->cpleaf = f->npp * f->alleaf;
  f->cproot = f->npp * f->alroot;
  f->cpstem = f->npp * f->alstem;
  
  f->npstem = f->npp * f->alstem * ncwnew;
  f->ppstem = f->npp * f->alstem * pcwnew;
  
  /* Now reduce LAI for down-regulated growth. */
  /* update leaf area [m2 m-2] */
  if (float_eq(s->shoot, 0.0)) {
    s->lai = 0.0;
  } else {
    s->lai -= lai_inc;
    s->lai += (f->cpleaf *
      (p->sla * M2_AS_HA / \
      (KG_AS_TONNES * p->cfracts)) -
      f->deadleaves * s->lai / s->shoot);
  }
  
  /* calculate plant respiration */
  if (c->respiration_model == FIXED) {
    /* use cue to obtain gpp and auto_resp */
    f->gpp = f->npp / p->cue;
    conv = G_AS_TONNES / M2_AS_HA;
    f->gpp_gCm2 = f->gpp / conv;
    
    /* New respiration flux */
    f->auto_resp =  f->gpp - f->npp;
    
  } else if(c->respiration_model == TEMPERATURE) {
    fprintf(stderr, "Not implemented yet");
    exit(EXIT_FAILURE);
  } else if (c->respiration_model == LEAFN) {
    /* obtain leaf biomass in g/m2 */
    shoot_biomass = s->lai / (p->sla * M2_AS_HA / (KG_AS_TONNES * p->cfracts)) / G_AS_TONNES * M2_AS_HA; 
    
    /* convert shootn from t/ha to mmol/m2 */
    leafn = s->shootn / G_AS_TONNES * M2_AS_HA / MOL_N_TO_GRAMS_N * MOL_2_MMOL;
    
    /* calculate leafn in mmol [N] g-1 [shoot biomass] */
    leafn = leafn / shoot_biomass;
    
    /* calculate leaf dark respiration in nmol g-1 s-1 */
    resp = a * leafn * exp(b);
    
    /* convert respiration rate from mmol g-1 s-1 to t/ha/m */
    /* 1: from nmol g-1 s-1 to g m-2 s-1 */
    resp = resp * NMOL_2_MOL * MOL_C_TO_GRAMS_C * shoot_biomass;
    
    /* 2: from g m-2 s-1 to t ha-2 month-1 */
    resp = resp * SECS_IN_HOUR * 24.0 * NDAYS_IN_YR / NMONTHS_IN_YR * G_AS_TONNES / M2_AS_HA;
    
    f->auto_resp = resp;
    f->gpp = f->npp + f->auto_resp;
  }
  
  return;
}

void calc_carbon_allocation_fracs(control *c, fluxes *f, params *p, state *s) {
    /* Carbon allocation fractions to move photosynthate through the plant.

    Parameters:
    -----------
    npitfac : float
        the smallest value of leaf N:C as a fraction of 'Ncmaxf' (max 1.0) &
        leaf P:C as a fraction of "Pcmaxf" (max 1.0)

    Returns:
    --------
    alleaf : float
        allocation fraction for shoot
    alroot : float
        allocation fraction for fine roots
    alstem : float
        allocation fraction for stem

    References:
    -----------
    Corbeels, M. et al (2005) Ecological Modelling, 187, 449-474.
    McMurtrie, R. E. et al (2000) Plant and Soil, 224, 135-152.
    */
    double adj, arg1, arg2, arg3, arg4, leaf2sa_target,
    sap_cross_sec_area, total_alloc, leaf2sap;
  
    if (c->alloc_model == FIXED) {
      
      f->alleaf = p->c_alloc_fmax + (p->c_alloc_fmax - p->c_alloc_fmin);
      
      f->alroot = p->c_alloc_rmax + (p->c_alloc_rmax - p->c_alloc_rmin);
      
      f->alstem = 1.0 - f->alleaf - f->alroot;
      
    } else if (c->alloc_model == ALLOMETRIC) {
      /* Calculate tree height: allometric reln using the power function
       (Causton, 1985) */
      s->canht = p->heighto * pow(s->stem, p->htpower);
      
      /* LAI to stem sapwood cross-sectional area (As m-2 m-2)
      (dimensionless)
      Assume it varies between LS0 and LS1 as a linear function of tree
      height (m) */
      arg1 = s->sapwood * TONNES_AS_KG * M2_AS_HA;
      arg2 = s->canht * p->density * p->cfracts;
      sap_cross_sec_area = arg1 / arg2;
      leaf2sap = s->lai / sap_cross_sec_area;
      
      /* Allocation to leaves dependant on height. Modification of pipe
      theory, leaf-to-sapwood ratio is not constant above a certain
      height, due to hydraulic constraints (Magnani et al 2000; Deckmyn
      et al. 2006). */
      
      if (s->canht < p->height0) {
        leaf2sa_target = p->leafsap0;
      } else if (float_eq(s->canht, p->height1)) {
        leaf2sa_target = p->leafsap1;
      } else if (s->canht > p->height1) {
        leaf2sa_target = p->leafsap1;
      } else {
        arg1 = p->leafsap0;
        arg2 = p->leafsap1 - p->leafsap0;
        arg3 = s->canht - p->height0;
        arg4 = p->height1 - p->height0;
        leaf2sa_target = arg1 + (arg2 * arg3 / arg4);
      }
      f->alleaf = alloc_goal_seek(leaf2sap, leaf2sa_target, p->c_alloc_fmax,
                                  p->targ_sens);
      
      /* figure out root allocation given available water & nutrients
      hyperbola shape to allocation, this is adjusted below as we aim
      to maintain a functional balance - taken out water stress */
      
      f->alroot = (p->c_alloc_rmax * p->c_alloc_rmin /
        (p->c_alloc_rmin + (p->c_alloc_rmax - p->c_alloc_rmin)));
      
      f->alstem = 1.0 - f->alroot - f->alleaf;
      
    } else {
      fprintf(stderr, "Unknown C allocation model: %d\n", c->alloc_model);
      exit(EXIT_FAILURE);
    }

    /* Total allocation should be one, if not print warning */
    total_alloc = f->alroot + f->alleaf + f->alstem;
    if (total_alloc > 1.0+EPSILON) {
      fprintf(stderr, "Allocation fracs > 1: %.13f\n", total_alloc);
      exit(EXIT_FAILURE);
    }
    
    return;
}

double alloc_goal_seek(double simulated, double target, double alloc_max,
                       double sensitivity) {
  
  /* Sensitivity parameter characterises how allocation fraction respond
  when the leaf:sapwood area ratio departs from the target value
  If sensitivity close to 0 then the simulated leaf:sapwood area ratio
  will closely track the target value */
  double frac = 0.5 + 0.5 * (1.0 - simulated / target) / sensitivity;
  
  return MAX(0.0, alloc_max * MIN(1.0, frac));
}

void carbon_allocation(control *c, fluxes *f, params *p, state *s) {
    /* C distribution - allocate available C through system

    Parameters:
    -----------
    npitfac : float
        leaf N:C as a fraction of 'Ncmaxf' (max 1.0)
    */
    f->cpleaf = f->npp * f->alleaf;        
    f->cproot = f->npp * f->alroot;
    f->cpstem = f->npp * f->alstem;

    /* update leaf area [m2 m-2] */
    if (float_eq(s->shoot, 0.0)) {
      s->lai = 0.0;
    } else {
      s->lai += (f->cpleaf *
        (p->sla * M2_AS_HA / (KG_AS_TONNES * p->cfracts)) -
        f->deadleaves * s->lai / s->shoot);
    }

    return;
}

void update_plant_state(control *c, fluxes *f, params *p, state *s) {
    /*
    Annual change in C content

    Parameters:
    -----------
    fdecay : float
        foliage decay rate
    rdecay : float
        fine root decay rate

    */
    double ncmaxf, ncmaxr;
    double extrasn, extrarn;   /* extra_s_n and extra_r_n - extra shoot/root n uptake */
    double pcmaxf, pcmaxr;
    double extrasp, extrarp;   /* extra_s_p and extra_r_p - extra shoot/root p uptake */

    /*
    ** Carbon pools
    */
    s->shoot += f->cpleaf - f->deadleaves;
    s->root += f->cproot - f->deadroots;
    s->stem += f->cpstem - f->deadstems;
    
    if (float_eq(s->stem, 0.01)) {
      s->sapwood = 0.01;
    } else if (s->stem < 0.01) {
      s->sapwood = 0.01;
    } else {
      s->sapwood += f->cpstem - f->deadsapwood;
    }

    /*
    ** Nitrogen and Phosphorus pools
    */
    s->shootn += f->npleaf - p->fdecay * s->shootn;
    s->shootp += f->ppleaf - p->fdecay * s->shootp;
    
    s->rootn += f->nproot - p->rdecay * s->rootn;
    
    s->stemn += f->npstem - p->wdecay * s->stemn;

    s->rootp += f->pproot - p->rdecay * s->rootp;

    s->stemp += f->ppstem - p->wdecay * s->stemp;
    
    /*
     =============================
     Enforce maximum N:C and P:C ratios.
     =============================
     */
    
    /* If foliage or root N/C exceeds its max, then N uptake is cut back
    Similarly, of foliage or root P/C exceeds max, then P uptake is cut back */
    
    /* maximum leaf n:c and p:c ratios is function of stand age*/
    ncmaxf = p->ncmaxf;
    pcmaxf = p->pcmaxf;
    
    extrasn = 0.0;
    
    if (s->lai > 0.0) {
      
      if (s->shootn > (s->shoot * ncmaxf)) {
        extrasn = s->shootn - s->shoot * ncmaxf;
        s->shootn -= extrasn;
        
        /* Ensure N uptake cannot be reduced below zero. */
        if (extrasn >  f->nuptake) {
          extrasn = f->nuptake;
        }
        //s->shootn -= extrasn;
        f->nuptake -= extrasn;
      }
    }
    
    extrasp = 0.0;
    if (s->lai > 0.0) {
      
      if (s->shootp > (s->shoot * pcmaxf)) {
        extrasp = s->shootp - s->shoot * pcmaxf;
        s->shootp -= extrasp;
        
        /* Ensure P uptake cannot be reduced below zero. */
        if (extrasp >  f->puptake) {
          extrasp = f->puptake;
        }
        
        //s->shootp -= extrasp;
        f->puptake -= extrasp;
      }
    }
    
    /* if root N:C ratio exceeds its max, then nitrogen uptake is cut
    back. n.b. new ring n/c max is already set because it is related
    to leaf n:c */
    
    /* max root n:c */
    ncmaxr = ncmaxf * p->ncrfac;
    extrarn = 0.0;
    if (s->rootn > (s->root * ncmaxr)) {
      extrarn = s->rootn - s->root * ncmaxr;
      s->rootn -= extrarn;
      
      /* Ensure N uptake cannot be reduced below zero. */
      if (extrarn > f->nuptake) {
          extrarn = f->nuptake;
      }
      
      //s->rootn -= extrarn;
      f->nuptake -= extrarn;
    }
    
    /* max root p:c */
    pcmaxr = pcmaxf * p->pcrfac;
    extrarp = 0.0;
    if (s->rootp > (s->root * pcmaxr)) {
      extrarp = s->rootp - s->root * pcmaxr;
      s->rootp -= extrarp;
      
      /* Ensure P uptake cannot be reduced below zero. */
      if (extrarp > f->puptake) {
          extrarp = f->puptake;
      }

      //s->rootp -= extrarp;
      f->puptake -= extrarp;
      
    }
    
    return;
}

void precision_control(fluxes *f, state *s) {
    /* Detect very low values in state variables and force to zero to
    avoid rounding and overflow errors */

    double tolerance = 1E-10;

    /* C, N & P state variables */
    if (s->shoot < tolerance) {
        f->deadleaves += s->shoot;
        f->deadleafn += s->shootn;
        f->deadleafp += s->shootp;
        s->shoot = 0.0;
        s->shootn = 0.0;
        s->shootp = 0.0;
    }

    if (s->root < tolerance) {
        f->deadrootn += s->rootn;
        f->deadrootp += s->rootp;
        f->deadroots += s->root;
        s->root = 0.0;
        s->rootn = 0.0;
        s->rootp = 0.0;
    }

    /* Not setting these to zero as this just leads to errors with desert
       regrowth...instead seeding them to a small value with a CN~25 and CP~300. */

    if (s->stem < tolerance) {
        f->deadstems += s->stem;
        f->deadstemn += s->stemn;
        f->deadstemp += s->stemp;
        //s->stem = 0.001;
        //s->stemn = 0.00004;
        //s->stemp = 0.000003;
    }

    
    return;
}


double nitrogen_retrans(control *c, fluxes *f, params *p, state *s) {
    /* Nitrogen retranslocated from senesced plant matter.
    Constant rate of n translocated from mobile pool

    Parameters:
    -----------
    fdecay : float
        foliage decay rate
    rdecay : float
        fine root decay rate

    Returns:
    --------
    N retrans : float
        N retranslocated plant matter

    */
    double leafretransn,rootretransn,stemretransn;

    leafretransn = p->fretransn * p->fdecay * s->shootn;
    rootretransn = p->rretrans * p->rdecay * s->rootn;
    stemretransn = (p->wretrans * p->wdecay * s->stemn);
    
    /* store for NCEAS output */
    f->leafretransn = leafretransn;
    f->rootretransn = rootretransn;
    f->stemretransn = stemretransn;

    return (leafretransn + rootretransn + stemretransn);
}

double phosphorus_retrans(control *c, fluxes *f, params *p, state *s) {
    /*
        Phosphorus retranslocated from senesced plant matter.
        Constant rate of p translocated from mobile pool

        Parameters:
        -----------
        fdecay : float
        foliage decay rate
        rdecay : float
        fine root decay rate

        Returns:
        --------
        P retrans : float
        P retranslocated plant matter
    */
    double leafretransp,rootretransp,stemretransp;

    leafretransp = p->fretransp * p->fdecay * s->shootp;
    rootretransp = p->rretrans * p->rdecay * s->rootp;
    stemretransp = (p->wretrans * p->wdecay * s->stemp);
    

    /* store for NCEAS output */
    f->leafretransp = leafretransp;
    f->rootretransp = rootretransp;
    f->stemretransp = stemretransp;

    return (leafretransp + rootretransp + stemretransp);
}

double calculate_nuptake(control *c, params *p, state *s, fluxes *f) {
    /*
        N uptake depends on the rate at which soil mineral N is made
        available to the plants.

        Returns:
        --------
        nuptake : float
            N uptake

        References:
        -----------
        * Dewar and McMurtrie, 1996, Tree Physiology, 16, 161-171.
        * Raich et al. 1991, Ecological Applications, 1, 399-429.

    */
    double nuptake, U0, Kr;

    if (c->nuptake_model == 0) {
        /* Constant N uptake */
        //nuptake = p->nuptakez;
        nuptake = (1.0 - (p->rateloss * NMONTHS_IN_YR)) * s->inorgn;
    } else if (c->nuptake_model == 1) {
        /* evaluate nuptake : proportional to dynamic inorganic N pool */
        nuptake = p->rateuptake * s->inorgn;
    } else if (c->nuptake_model == 2) {
        /* N uptake is a saturating function on root biomass following
           Dewar and McMurtrie, 1996. */

        /* supply rate of available mineral N */
        U0 = p->rateuptake * s->inorgn;
        Kr = p->kr;
        nuptake = MAX(U0 * s->root / (s->root + Kr), 0.0);
    } else {
        fprintf(stderr, "Unknown N uptake option\n");
        exit(EXIT_FAILURE);
    }

    return (nuptake);
}

double calculate_puptake(control *c, params *p, state *s, fluxes *f) {
    /*
        P uptake depends on the rate at which soil mineral P is made
        available to the plants.

        Returns:
        --------
        puptake : float
        P uptake
    */
    double puptake, U0, Kr, pocc, pleach;
    double k1 = p->k1 * NMONTHS_IN_YR;
    double k2 = p->k2 * NMONTHS_IN_YR;
    double k3 = p->k3 * NMONTHS_IN_YR;
    double prateloss = p->prateloss * NMONTHS_IN_YR;

    if (c->puptake_model == 0) {
        /* Constant P uptake */
        //puptake = p->puptakez;
        //pleach = prateloss / (1.0 - prateloss);
        //pocc = (k3 / (k2 + k3)) * (k1 / (1.0 - k1));
        //puptake = (1.0 - pleach - pocc - 0.109) * s->inorgavlp; 
         pleach = ((prateloss) / (1.0 - prateloss));
         pocc = (k3 / (k2 + k3)) * (k1 / (1.0 - k1));
         puptake = (1.0 - prateloss - p->k1) * s->inorgavlp;
        
    } else if (c->puptake_model == 1) {
        // evaluate puptake : proportional to lab P pool that is
        // available to plant uptake
        puptake = p->prateuptake * s->inorgavlp;
    } else if (c->puptake_model == 2) {
        /* P uptake is a saturating function on root biomass, as N */

        /* supply rate of available mineral P */
        U0 = p->prateuptake * s->inorgavlp;
        Kr = p->krp;
        puptake = MAX(U0 * s->root / (s->root + Kr), 0.0);
    } else {
        fprintf(stderr, "Unknown P uptake option\n");
        exit(EXIT_FAILURE);
    }

    return (puptake);
}

