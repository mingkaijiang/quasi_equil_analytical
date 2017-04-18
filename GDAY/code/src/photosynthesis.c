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

void simple_photosynthesis(control *c, fluxes *f, met *m, params *p, state *s) {
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
    
    /* Covert PAR units (umol PAR MJ-1) */
    conv1 = MJ_TO_J * J_2_UMOL;
    m->par *= conv1;
    
    /* lue in umol C umol-1 PAR */
    lue_avg = lue_simplified(p, s, m->Ca);
    
    /* absorbed photosynthetically active radiation (umol m-2 m-1) */
    if (float_eq(s->lai, 0.0))
      f->apar = 0.0;
    else
      f->apar = m->par * s->fipar;
    
    /* convert umol m-2 -> gC m-2 */
    conv2 = UMOL_TO_MOL * MOL_C_TO_GRAMS_C;
    
    if (s->lai > 0.0) {
      /* calculation for npp */
      f->gpp_gCm2 = lue_avg * f->apar * conv2;
    } else {
      f->gpp_gCm2 = 0.0;
    }
    
    f->gpp = f->gpp_gCm2 * G_AS_TONNES / M2_AS_HA;
    
    /* save apar in MJ m-2 m-1 */
    f->apar *= UMOL_2_JOL * J_TO_MJ;
    
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

double lue_simplified(params *p, state *s, double co2) {
    /*
     * New LUE function replacing epsilon function for a simplified calculation
     * of LUE
     * 
     * 
     * Parameters:
     * Nref: leaf N:C for saturation of photosynthesis   
     * LUE0: maximum gross LUE in kg C GJ-1
     */
    double lue, CaResp, Nresp, conv;
  
    CaResp = 1.632 * (co2 - 60.9) / (co2 + 121.8);
    Nresp = MIN(s->shootnc / p->nref, 1);
    
    /* converting unit for lue0 from kg C GJ-1 to umol C umol -1 PAR */
    conv = (KG_AS_G / MOL_C_TO_GRAMS_C * MOL_TO_UMOL) / (J_2_UMOL * GJ_TO_J);
      
    lue = p->lue0 * conv * CaResp * Nresp;
    
    
    return (lue);
}
