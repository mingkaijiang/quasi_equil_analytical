/* ============================================================================
* Calculate C and N litter production
*
* Litter production for each pool is assumed to be proportional to biomass
* pool size.
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
#include "litter_production.h"

void calculate_litterfall(control *c, fluxes *f, params *p, state *s) {

    double  ncflit, ncrlit;
    double  pcflit, pcrlit;

    /* litter N:C ratios, roots and shoot */
    ncflit = s->shootnc * (1.0 - p->fretransn);
    ncrlit = s->rootnc * (1.0 - p->rretrans);
    
    /* litter P:C ratios, roots and shoot */
    pcflit = s->shootpc * (1.0 - p->fretransp);
    pcrlit = s->rootpc * (1.0 - p->rretrans);
    
    /* C litter production */
    f->deadroots = p->rdecay * s->root;
    f->deadstems = p->wdecay * s->stem;
    f->deadleaves = p->fdecay * s->shoot;
    
    f->deadsapwood = (p->wdecay + p->sapturnover) * s->sapwood;
    
    
    /* N litter production */
    f->deadleafn = f->deadleaves * ncflit;

    /* P litter production */
    f->deadleafp = f->deadleaves * pcflit;
    
    /* Assuming fraction is retranslocated before senescence, i.e. a fracion
       of nutrients is stored within the plant */
    f->deadrootn = f->deadroots * ncrlit;

    f->deadrootp = f->deadroots * pcrlit;

    /* N in stemwood litter */
    f->deadstemn = p->wdecay * (s->stemn * (1.0 - p->wretrans));

    /* P in stemwood litter - only mobile p is retranslocated */
    f->deadstemp = p->wdecay * (s->stemp * (1.0 - p->wretrans));
        
    return;

}
