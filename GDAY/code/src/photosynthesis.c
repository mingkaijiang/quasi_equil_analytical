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
    double lue_avg, conv1, conv2, shoot_biomass, leafn, resp;
    double a = 0.645;   /* Reich et al. 2008 Ecol. Let. Table 1, Leaves */
    double b = 1.66;    /* Reich et al. 2008 Ecol. Let. Table 1, Leaves */
    double Csapwood, Rmsw, Rmf, Rmr, Rm, Rc;
    double R0 = 27.0;
    double Q10 = 2.0;
    double Q10s = 1.98;
    double stem = 3.5;  /* kg/m2 */
    
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
      
//      /* obtain leaf biomass in g/m2 */
//      shoot_biomass = s->lai / (p->sla * M2_AS_HA / (KG_AS_TONNES * p->cfracts)) / G_AS_TONNES * M2_AS_HA; 
//      
//      /* convert shootn from t/ha to mmol/m2 */
//      leafn = s->shootn / G_AS_TONNES * M2_AS_HA / MOL_N_TO_GRAMS_N * MOL_2_MMOL;
//      
//      /* calculate leafn in mmol [N] g-1 [shoot biomass] */
//      leafn = leafn / shoot_biomass;
//      
//      /* calculate leaf dark respiration in nmol g-1 s-1 */
//      resp = a * pow(leafn, b);
//      
//      /* convert respiration rate from mmol g-1 s-1 to t/ha/m */
//      /* 1: from nmol g-1 s-1 to g m-2 s-1 */
//      resp = resp * NMOL_2_MOL * MOL_C_TO_GRAMS_C * shoot_biomass;
//      
//      /* 2: from g m-2 s-1 to t ha-2 month-1 */
//      resp = resp * SECS_IN_HOUR * 24.0 * NDAYS_IN_YR / NMONTHS_IN_YR * G_AS_TONNES / M2_AS_HA;
//      
//      f->auto_resp = resp;
//      f->npp = f->gpp - f->auto_resp;

      /* calculate C content of sapwood kg m-2 */
      Csapwood = 1.11 * pow(stem, 0.77);
      
      /* calculate sapwood maintenance respiration */
      Rmsw = 0.00876 * Csapwood * pow(Q10s, m->tsoil/10);
      
      /* calculate leaf and root maintenance respiration */
      Rmf = 0.5 * R0 * (s->shootn * 0.1) * pow(Q10, m->tsoil/10);
      Rmr = R0 * (s->rootn * 0.1) * pow(Q10, m->tsoil/10);
      
      /* total maintanence respiration */
      Rm = (Rmf + Rmr + Rmsw) / 0.1;
      
      /* calculate NPP and construction respiration */
      Rc = (f->gpp - Rm) * 0.25;
      f->npp = f->gpp - Rc - Rm;
      f->auto_resp = Rc + Rm;
      
    }
    
    fprintf(stderr, "Csapwood %f, stem %f, Rmsw %f, Rmf %f, Rmr %f\n", Csapwood, s->stem, Rmsw, Rmf, Rmr);
    
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
