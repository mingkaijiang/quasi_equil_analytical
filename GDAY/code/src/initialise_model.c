#include "initialise_model.h"


void initialise_control(control *c) {
    /*
    *** Default values for control structure.
    */

    /* Values set via param file */
    strcpy(c->git_hash, "Err");

    c->ifp = NULL;
    c->ofp = NULL;
    strcpy(c->cfg_fname, "*NOT SET*");
    strcpy(c->met_fname, "*NOT SET*");
    strcpy(c->out_fname, "*NOT SET*");
    strcpy(c->out_param_fname, "*NOT SET*");

    c->alloc_model = ALLOMETRIC;    /* C allocation scheme: FIXED, GRASSES, ALLOMETRIC */
    c->exudation = TRUE;            /* Plant exudation */
    c->fixed_stem_nc = TRUE;        /* False=vary stem N:C with foliage, True=fixed stem N:C */
    c->fixed_stem_pc = TRUE;        /* False=vary stem P:C with foliage, True=fixed stem P:C */
    c->diagnosis = FALSE;           /* print out variables for diagnosis */
    c->fixleafnc = FALSE;           /* fixed leaf N C ? */
    c->fixleafpc = FALSE;           /* fixed leaf P C ? */
    c->ncycle = TRUE;               /* Nitrogen cycle on or off? */
    c->pcycle = TRUE;               /* Phosphorus cycle on or off? */
    c->nuptake_model = 1;           /* 0=constant uptake, 1=func of N inorgn, 2=depends on rate of soil N availability */
    c->puptake_model = 1;           /* 0=constant uptake, 1=func of P inorgp, 2=depends on rate of soil P availability */
    c->passiveconst = FALSE;        /* hold passive pool at passivesoil */
    c->print_options = ANNUAL;      /* ANNUAL=every timestep, END=end of run */
    c->som_nc_calc = FIXED;         /* calculates SOM NC ratio as a function of mineral N (1) or read from input (0) */
    c->som_pc_calc = FIXED;         /* calculates SOM PC ratio as a function of mineral AVL P (1) or read from input (0) */
    c->respiration_model = FIXED;   /* Plant respiration ... Fixed, TEMPERATURE or LEAFN */
    c->spin_up = FALSE;             /* Spin up to a steady state? If False it just runs the model */

    /* Internal calculated */
    c->num_years = 0;               /* Total number of years simulated */
    c->num_months = 12;            /* Number of months in a year */
    c->PRINT_GIT = FALSE;           /* print the git hash to the cmd line and exit? Called from cmd line parsar */

        return;
}

void initialise_params(params *p) {
    /*
    *** Default values for params structure.
    */
    int i;
    p->a0rhizo = 0.05;
    p->a1rhizo = 0.6;
    p->actncmax = 0.333333;
    p->actncmin = 0.066667;
    p->actpcmax = 0.033333;
    p->actpcmin = 0.0125;
    p->c_alloc_fmax = 0.2;
    p->c_alloc_fmin = 0.2;    
    p->c_alloc_rmax = 0.2;
    p->c_alloc_rmin = 0.2;
    p->cfracts = 0.5;
    p->cue = 0.5;
    p->co2_in = 350.0;
    p->density = 420.0;
    p->fdecay = 0.59988;
    p->finesoil = 0.51;
    p->fmleaf = 0.0;
    p->fmroot = 0.0;
    p->fretransn = 0.5;
    p->fretransp = 0.6;
    p->height0 = 5.0;
    p->height1 = 30.0;
    p->heighto = 4.826;
    p->htpower = 0.35;
    p->I0 = 3000.0;
    p->k1 = 0.048;
    p->k2 = 0.001;
    p->k3 = 0.000012;
    p->kdec1 = 3.965571;
    p->kdec2 = 14.61;
    p->kdec3 = 4.904786;
    p->kdec4 = 18.262499;
    p->kdec5 = 7.305;
    p->kdec6 = 0.198279;
    p->kdec7 = 0.006783;
    p->kext = 0.5;
    p->kr = 0.5;          /* this value is 1.0 in Wang et al. 2007 Global Biogeochemical Cycles, Kn Michaelis-Menten constant for plant N uptake [g P m-2] */
    p->krp = 0.01;        /* Wang et al. 2007 Global Biogeochemical Cycles, Kp Michaelis-Menten constant for plant P uptake [g P m-2] */
    p->leafsap0 = 8000.0;
    p->leafsap1 = 3060.0;
    p->ligroot = 0.22;
    p->ligshoot = 0.24;
    p->ndep_in = 0.001;
    p->nfix_in = 0.001;
    p->lue0 = 1.4;                /* maximum LUE in kg C GJ-1 */
    p->metabcnmax = 25.0;
    p->metabcnmin = 10.0;
    p->metabcpmax = 150.0;
    p->metabcpmin = 80.0;
    p->ncmaxf = 0.05;
    p->nref = 0.04;
    p->ncrfac = 0.8;
    p->ncwnewz = 0.003;
    p->nmin0 = 0.0;
    p->nmincrit = 2.0;
    p->nuptakez = 0.0;
    p->p_rate_par_weather = 0.001;
    p->passivesoilnz = 1.0;
    p->passivesoilpz = 1.0;
    p->passivesoilz = 1.0;
    p->passncmax = 0.142857;
    p->passncmin = 0.1;
    p->passpcmax = 0.05;
    p->passpcmin = 0.005;
    p->pcmaxf = 0.004;       /* guess value */
    p->pcrfac = 0.8;
    p->pcwnewz = 0.0003;
    p->pdep_in = 0.0004;
    p->pmin0 = 0.0;
    p->pmincrit = 2.0;       /* Based on CENTURY VARAT1(2,3) = 2 value */
    p->prateloss = 0.005;    
    p->prateuptake = 365.0;
    p->prescribed_leaf_NC = 0.03;
    p->prescribed_leaf_PC = 0.00249;   /*Crous et al. 2015, C:P ratio of 400, Figure 3, Plant Soil */
    p->puptakez = 0.0255;             /* calculated based on prateuptake 0.5 and inorglabp 0.051 */
    p->rateloss = 0.5;                /* value = 0.05 in Wang et al., 2007 GB1018 */
    p->rateuptake = 2.7;
    p->rdecay = 0.33333;
    p->rretrans = 0.0; 
    p->sapturnover = 0.1;
    p->sla = 4.4;
    p->slowncmax = 0.066666;
    p->slowncmin = 0.025;
    p->slowpcmax = 0.011111;
    p->slowpcmin = 0.005;
    p->structcn = 150.0;
    p->structcp = 5500.0;
    p->targ_sens = 0.5;
    p->tsoil_in = 15.0;
    p->wdecay = 0.02;
    p->wretrans = 0.0;

    for (i = 0; i < 7; i++) {
        p->decayrate[i] = 0.0;
    }

}


void initialise_fluxes(fluxes *f) {
    /*
    ** Default values for fluxes structure.
    */
    int i = 0;

    /* C fluxes */
    f->gpp_gCm2 = 0.0;
    f->npp_gCm2 = 0.0;
    f->gpp = 0.0;
    f->npp = 0.0;
    f->nep = 0.0;
    f->auto_resp = 0.0;
    f->hetero_resp = 0.0;
    f->retransn = 0.0;
    f->retransp = 0.0;
    f->apar = 0.0;

    /* N fluxes */
    f->nuptake = 0.0;
    f->nloss = 0.0;
    f->npassive = 0.0;              /* n passive -> active */
    f->ngross = 0.0;                /* N gross mineralisation */
    f->nimmob = 0.0;                /* N immobilisation in SOM */
    f->nlittrelease = 0.0;          /* N rel litter = struct + metab */
    f->nmineralisation = 0.0;

    /* P fluxes */
    f->puptake = 0.0;
    f->ploss = 0.0;
    f->ppassive = 0.0;              /* p passive -> active */
    f->pgross = 0.0;                /* P gross mineralisation */
    f->pimmob = 0.0;                /* P immobilisation in SOM */
    f->plittrelease = 0.0;          /* P rel litter = struct + metab */
    f->pmineralisation = 0.0;

    /* Annual C production */
    f->cpleaf = 0.0;
    f->cproot = 0.0;
    f->cpstem = 0.0;

    /* Annual N production */
    f->npleaf = 0.0;
    f->nproot = 0.0;
    f->npstem = 0.0;

    /* Annual P production */
    f->ppleaf = 0.0;
    f->pproot = 0.0;
    f->ppstem = 0.0;

    /* dying stuff */
    f->deadleaves = 0.0;   /* Leaf litter C production (t/ha/yr) */
    f->deadroots = 0.0;    /* Root litter C production (t/ha/yr) */
    f->deadstems = 0.0;    /* Stem litter C production (t/ha/yr) */
    f->deadleafn = 0.0;    /* Leaf litter N production (t/ha/yr) */
    f->deadrootn = 0.0;    /* Root litter N production (t/ha/yr) */
    f->deadstemn = 0.0;    /* Stem litter N production (t/ha/yr) */
    f->deadleafp = 0.0;    /* Leaf litter P production (t/ha/yr) */
    f->deadrootp = 0.0;    /* Root litter P production (t/ha/yr) */
    f->deadstemp = 0.0;    /* Stem litter P production (t/ha/yr) */
    f->deadsapwood = 0.0;

    /* retranslocation */
    f->leafretransn = 0.0;
    f->leafretransp = 0.0;
    f->rootretransn = 0.0;
    f->rootretransp = 0.0;
    f->stemretransn = 0.0;
    f->stemretransp = 0.0;
    
    /* C N & P Surface litter */
    f->surf_struct_litter = 0.0;
    f->surf_metab_litter = 0.0;
    f->n_surf_struct_litter = 0.0;
    f->n_surf_metab_litter = 0.0;
    f->p_surf_struct_litter = 0.0;
    f->p_surf_metab_litter = 0.0;

    /* C N & P Root Litter */
    f->soil_struct_litter = 0.0;
    f->soil_metab_litter = 0.0;
    f->n_soil_struct_litter = 0.0;
    f->n_soil_metab_litter = 0.0;
    f->p_soil_struct_litter = 0.0;
    f->p_soil_metab_litter = 0.0;

    /* C N & P litter fluxes to slow pool */
    f->surf_struct_to_slow = 0.0;
    f->soil_struct_to_slow = 0.0;
    f->n_surf_struct_to_slow = 0.0;
    f->n_soil_struct_to_slow = 0.0;
    f->p_surf_struct_to_slow = 0.0;
    f->p_soil_struct_to_slow = 0.0;

    /* C N & P litter fluxes to active pool */
    f->surf_struct_to_active = 0.0;
    f->soil_struct_to_active = 0.0;
    f->n_surf_struct_to_active = 0.0;
    f->n_soil_struct_to_active = 0.0;
    f->p_surf_struct_to_active = 0.0;
    f->p_soil_struct_to_active = 0.0;

    /* Metabolic fluxes to active pool */
    f->surf_metab_to_active = 0.0;
    f->soil_metab_to_active = 0.0;
    f->n_surf_metab_to_active = 0.0;
    f->n_soil_metab_to_active = 0.0;
    f->p_surf_metab_to_active = 0.0;
    f->p_soil_metab_to_active = 0.0;

    /* fluxes out of active pool */
    f->active_to_slow = 0.0;
    f->active_to_passive = 0.0;
    f->n_active_to_slow = 0.0;
    f->n_active_to_passive = 0.0;
    f->p_active_to_slow = 0.0;
    f->p_active_to_passive = 0.0;

    /* fluxes out of slow pool */
    f->slow_to_active = 0.0;
    f->slow_to_passive = 0.0;
    f->n_slow_to_active = 0.0;
    f->n_slow_to_passive = 0.0;
    f->p_slow_to_active = 0.0;
    f->p_slow_to_passive = 0.0;

    /* C N & P fluxes from passive to active pool */
    f->passive_to_active = 0.0;
    f->n_passive_to_active = 0.0;
    f->p_passive_to_active = 0.0;

    /* C source fluxes from the active, slow and passive pools */
    f->c_into_active = 0.0;
    f->c_into_slow = 0.0;
    f->c_into_passive = 0.0;

    /* inorganic P flux exchanges */
    f->p_avl_to_ssorb = 0.0;
    f->p_ssorb_to_avl = 0.0;
    f->p_ssorb_to_occ = 0.0;
    f->p_par_to_avl = 0.0;

    /* CO2 flows to the air */
    /* C flows to the air */
    for (i = 0; i < 7; i++) {
        f->co2_to_air[i] = 0.0;
    }

    /* C allocated fracs  */
    f->alleaf = 0.0;
    f->alroot = 0.0;
    f->alstem = 0.0;

    /* Misc stuff */
    f->tfac_soil_decomp = 0.0;
    f->co2_rel_from_surf_struct_litter = 0.0;
    f->co2_rel_from_soil_struct_litter = 0.0;
    f->co2_rel_from_surf_metab_litter = 0.0;
    f->co2_rel_from_soil_metab_litter = 0.0;
    f->co2_rel_from_active_pool = 0.0;
    f->co2_rel_from_slow_pool = 0.0;
    f->co2_rel_from_passive_pool = 0.0;

    return;
}

void initialise_state(state *s) {

    /*
    *** Default values for state structure.
    */

    s->activesoil = 2.53010543182;
    s->activesoiln = 0.833516379296;
    s->activesoilp = 0.04600192;          /* based on active soil pool C/P ratio of 55 from Parton et al., 1989, Ecology of arable land. */
    s->canht = 23.0964973582;
    s->inorgn = 0.0274523714275;
    s->inorgp = 0.0205;
    s->inorgavlp = 0.096;               /* lab p + sorb p */
    s->inorgssorbp = 0.055;             /* Binkley et al 2000 Forest Ecology and Management, Table 1, unit converted from 55 ug P g dry soil to t/ha */
    s->inorgoccp = 0.0;               
    s->inorgparp = 0.054;               /* Binkley et al 2000 Forest Ecology and Management, Table 1 */
    s->metabsoil = 0.135656771805;
    s->metabsoiln = 0.00542627087221;
    s->metabsoilp = 0.001179624;        /* based on metabolic pool C/P ratio of 115 from Parton et al., 1989, Ecology of arable land. */
    s->metabsurf = 0.0336324759951;
    s->metabsurfn = 0.0013452990398;
    s->metabsurfp = 0.0002924563;       /* based on metabolic pool C/P ratio of 115 from Parton et al., 1989, Ecology of arable land. */
    s->passivesoil = 59.5304597863;
    s->passivesoiln = 8.0134056319;
    s->passivesoilp = 0.541186;         /* based on passive SOM pool C/P ratio of 110 from Parton et al., 1989, Ecology of arable land. */
    s->root = 3.92887790342;
    s->rootn = 0.076296932914;
    s->rootp = 0.00392888;              /* Yang et al. 2016, Biogeosciences, Table S1, fine root C:P = 1000 */
    s->sapwood = 51.2600270003;
    s->shoot = 4.37991243755;
    s->shootn = 0.0978837857406; 
    s->shootp = 0.008759825;            /* Based on leaf C:P ratio of 500 from Crous et al., 2015, Plant Soil */
    s->slowsoil = 46.8769593608;
    s->slowsoiln = 2.90664959452;
    s->slowsoilp = 0.3232894;           /* based on slow SOM pool C/P ratio of 145 from Parton et al., 1989, Ecology of arable land. */
    s->stem = 87.6580936643;
    s->stemn = 0.263722246902;
    s->stemp = 0.02921933;              /* Yang et al. 2016, Biogeosciences, Table S1, wood C:P = 3000 */
    s->structsoil = 0.917128200367;
    s->structsoiln = 0.00611418800245;
    s->structsoilp = 0.001834256;       /* based on structural pool C/P ratio of 500 from Parton et al., 1989, Ecology of arable land. */
    s->structsurf = 7.10566198821;
    s->structsurfn = 0.0473710799214;
    s->structsurfp = 0.01421132;        /* based on structural pool C/P ratio of 500 from Parton et al., 1989, Ecology of arable land. */

    return;
}

void initialise_nrutil(nrutil *nr) {

    nr->kmax = 100;
    nr->N = 1;
    nr->xp = NULL;
  	nr->yp = NULL;
  	nr->yscal = NULL;
  	nr->y = NULL;
	  nr->dydx = NULL;
    nr->ystart = NULL;

    nr->ak2 = NULL;
    nr->ak3 = NULL;
    nr->ak4 = NULL;
    nr->ak5 = NULL;
    nr->ak6 = NULL;
    nr->ytemp = NULL;
    nr->yerr = NULL;

    return;
}
