/* ============================================================================
* Generic Decomposition And Yield (GDAY) model.
*
* Simple version for quasi-equilibrium analysis
* 
* This version runs at monthly timestep by using met forcing data averaged annually
* 
*
* Paramaeter descriptions are in gday.h
*
* NOTES:
*
*
* AUTHOR:
*   Mingkai Jiang & Martin De Kauwe
*
* DATE:
*   18.01.2017
*
* =========================================================================== */

#include "gday.h"

int main(int argc, char **argv)
{
    int error = 0;

    /*
     * Setup structures, initialise stuff, e.g. zero fluxes.
     */
    control *c;
    fluxes *f;
    met_arrays *ma;
    met *m;
    params *p;
    state *s;
    nrutil *nr;

    c = (control *)malloc(sizeof(control));
    if (c == NULL) {
        fprintf(stderr, "control structure: Not allocated enough memory!\n");
    	exit(EXIT_FAILURE);
    }

    f = (fluxes *)malloc(sizeof(fluxes));
    if (f == NULL) {
    	fprintf(stderr, "fluxes structure: Not allocated enough memory!\n");
    	exit(EXIT_FAILURE);
    }
    
    ma = (met_arrays *)malloc(sizeof(met_arrays));
    if (ma == NULL) {
      fprintf(stderr, "met arrays structure: Not allocated enough memory!\n");
      exit(EXIT_FAILURE);
    }

    m = (met *)malloc(sizeof(met));
    if (m == NULL) {
    	fprintf(stderr, "met structure: Not allocated enough memory!\n");
    	exit(EXIT_FAILURE);
    }

    p = (params *)malloc(sizeof(params));
    if (p == NULL) {
    	fprintf(stderr, "params structure: Not allocated enough memory!\n");
    	exit(EXIT_FAILURE);
    }

    s = (state *)malloc(sizeof(state));
    if (s == NULL) {
    	fprintf(stderr, "state structure: Not allocated enough memory!\n");
    	exit(EXIT_FAILURE);
    }

    nr = (nrutil *)malloc(sizeof(nrutil));
    if (nr == NULL) {
        fprintf(stderr, "nrutil structure: Not allocated enough memory!\n");
        exit(EXIT_FAILURE);
    } 

    initialise_control(c);
    initialise_params(p);
    initialise_fluxes(f);
    initialise_state(s);
    initialise_nrutil(nr);
    
    clparser(argc, argv, c);
    /*
     * Read .ini parameter file and meterological data
     */
    error = parse_ini_file(c, p, s);
    if (error != 0) {
        prog_error("Error reading .INI file on line", __LINE__);
    }
    strcpy(c->git_code_ver, build_git_sha);
    if (c->PRINT_GIT) {
        fprintf(stderr, "\n%s\n", c->git_code_ver);
        exit(EXIT_FAILURE);
    }
    
    
    /* set initial lai */
    s->lai = MAX(0.01, (p->sla * M2_AS_HA / KG_AS_TONNES / p->cfracts * s->shoot));
    
    /* model runs */
    if (c->spin_up) {
        /* save spin-up simulations and end state parameters */
        spin_up_annual(c, f, m, p, s, nr);     
    } else {
        /* read transient monthly met data */
        read_monthly_met_data(argv, c, ma);
      
        /* Run simulation, forced by transient met input */
        run_sim(c, f, ma, m, p, s, nr);
    }

    /* clean up */
    fclose(c->ofp);
    fclose(c->ifp);
    free(c);
    if (! c->spin_up) {
        free(ma->year);
        free(ma->prjmonth);
        free(ma->tsoil);
        free(ma->co2);
        free(ma->ndep);
        free(ma->pdep);
        free(ma->par);
        free(ma->nfix);
    }
    free(ma);
    free(m);
    free(p);
    free(s);
    free(f);

    exit(EXIT_SUCCESS);
}

void run_sim(control *c, fluxes *f,  met_arrays *ma, met *m, 
             params *p, state *s, nrutil *nr){

    int    nyr, i, moy;

    double year, current_limitation, npitfac;

    /* Setup output file */
    if (c->print_options == ANNUAL && c->spin_up == FALSE) {
        /* Annual outputs */
        open_output_file(c, c->out_fname, &(c->ofp));
        write_output_header(c, p, &(c->ofp));
    } else if (c->print_options == END && c->spin_up == FALSE) {
        /* Final state + param file */
        open_output_file(c, c->out_param_fname, &(c->ofp));
    }
    
    /* ====================== **
     **   Y E A R    L O O P   **
     ** ====================== */
    c->month_idx = 0;
    
    for (nyr = 0; nyr < c->num_years; nyr++) {
        year = ma->year[c->month_idx];

        /* =================== **
         ** M O N T H   L O O P   **
         ** =================== */
        for (moy = 0; moy < c->num_months; moy++) {
        
          /* read in transient monthly met data from input files */
          unpack_met_data_transient(c, f, ma, m, p);
          
          /* correct annual rate */
          correct_rate_constants(p, FALSE);
          
          /* start the year with all fluxes and stock mass balance */
          year_start_calculations(c, p, s);
          
          calculate_litterfall(c, f, p, s);
          
          calc_annual_growth(c, f, m, nr, p, s);
          
          calculate_csoil_flows(c, f, p, s, m->tsoil);
          calculate_nsoil_flows(c, f, p, s);
          
          if (c->pcycle == TRUE) {
            calculate_psoil_flows(c, f, p, s);
          }

          /* Turn off all N calculations */
          if (c->ncycle == FALSE)
            reset_all_n_pools_and_fluxes(f, s);
          
          /* Turn off all P calculations */
          if (c->pcycle == FALSE)
            reset_all_p_pools_and_fluxes(f, s);
          
          /* calculate C:N:P ratios and increment annual flux sum */
          year_end_calculations(c, p, s);
          
          if (c->print_options == ANNUAL && c->spin_up == FALSE) {
            write_annual_outputs_ascii(c, f, s, year, moy+1);
          }      
          
          correct_rate_constants(p, TRUE);
          
          /* ======================= **
          ** E N D   O F   M O N T H **
          ** ======================= */
          c->month_idx++;
        }
        
        /* ========================= **
         **   E N D   O F   Y E A R   **
         ** ========================= */
    }
    
    if (c->print_options == END && c->spin_up == FALSE) {
        write_final_state(c, p, s);
    }

    return;

}


void spin_up_annual(control *c, fluxes *f, met *m,
                    params *p, state *s, nrutil *nr){
    /* Run annual simulation to reach quasi-equilibrium state for all pools
    
    - Examine sequences of 1 year and check if C pools are changing
    by more than tol_c unit per yr;
    
    - Check N and P pools as well if N & P are turned on.
    
    References:
    ----------
    Adapted from...
    * Murty, D and McMurtrie, R. E. (2000) Ecological Modelling, 134,
    185-205, specifically page 196.
    */
    double tol_c = 1E-06;
    double tol_n = 1E-06;
    double tol_p = 1E-04;
    double prev_plantc = 99999.9;
    double prev_soilc = 99999.9;
    double prev_plantn = 99999.9;
    double prev_soiln = 99999.9;
    double prev_plantp = 99999.9;
    double prev_soilp = 99999.9;

    /* run simulation variables */
    int    year = 0; 
    int    moy = 0;

    /* Setup output file */
      /* Annual outputs */
      open_output_file(c, c->out_fname, &(c->ofp));
      write_output_header(c, p, &(c->ofp));
    
    fprintf(stderr, "Spinning up the model...\n");
    while (TRUE) {
        if (fabs((prev_plantc) - (s->plantc)) < tol_c &&
            fabs((prev_soilc) - (s->soilc)) < tol_c &&
            fabs((prev_plantn) - (s->plantn)) < tol_n &&
            fabs((prev_soiln) - (s->soiln)) < tol_n &&
            fabs((prev_plantp) - (s->plantp)) < tol_p && 
            fabs((prev_soilp) - (s->soilp-s->inorgoccp)) < tol_p) {
          break;
      } else {
            prev_plantc = s->plantc;
            prev_soilc = s->soilc;
            prev_plantn = s->plantn;
            prev_soiln = s->soiln;
            prev_plantp = s->plantp;
            prev_soilp = s->soilp-s->inorgoccp;
            
            for(moy = 0; moy < 12; moy++) {
                /* read in simple annual met data from parameter files */
                unpack_met_data_simple(f, m, p);
                
                /* correct annual rate */
                correct_rate_constants(p, FALSE);
                
                /* start the year with all fluxes and stock mass balance */
                year_start_calculations(c, p, s);
                
                calculate_litterfall(c, f, p, s);
                
                calc_annual_growth(c, f, m, nr, p, s);
                
                calculate_csoil_flows(c, f, p, s, m->tsoil);
                calculate_nsoil_flows(c, f, p, s);
              
                if (c->pcycle == TRUE) {
                  calculate_psoil_flows(c, f, p, s);
                }
                
                /* Turn off all N calculations */
                if (c->ncycle == FALSE)
                  reset_all_n_pools_and_fluxes(f, s);
                
                /* Turn off all P calculations */
                if (c->pcycle == FALSE)
                  reset_all_p_pools_and_fluxes(f, s);
                
                /* calculate C:N:P ratios and increment annual flux sum */
                year_end_calculations(c, p, s);
                
                correct_rate_constants(p, TRUE);
                
                /* Print to screen and check the process */
                if (c->pcycle) {
                  /* Have we reached a steady state? */
                  fprintf(stderr,
                          "Spinup: Iteration %d, moy %d, Leaf NC %f, Leaf PC %f, NPP %f, GPP %f, stem %f\n",
                          year, moy, s->shootnc, s->shootpc, f->npp, f->gpp, s->stem);
                } else if (c->ncycle) {
                  /* Have we reached a steady state? */
                  fprintf(stderr,
                          "Spinup: Iteration %d, moy %d, Plant C %f, Leaf NC %f, Active C %f, Slow C %f, Passive C %f, NPP %f, InorgN %f\n",
                          year, moy, s->plantc, s->shootnc, s->activesoil, s->slowsoil, s->passivesoil, f->npp, s->inorgn);
                } else {
                  /* Have we reached a steady state? */
                  fprintf(stderr,
                          "Spinup: Plant C - %f, Soil C - %f\n",
                          s->plantc, s->soilc);
                }   // Print to screen end;
                
                /* save spin-up fluxes and stocks */
                  write_annual_outputs_ascii(c, f, s, year, moy+1);
                
            
            }  /* end month loop */
            
            /* continue at annual timestep */
            year += 1;
            
            
      }     // if else statement end checking equilibrium;
    }       // while statement end;

    /* save end of spin-up parameters and stocks */
    open_output_file(c, c->out_param_fname, &(c->ofp));
    write_final_state(c, p, s);
    
    return;
}


void clparser(int argc, char **argv, control *c) {
    int i;

    for (i = 1; i < argc; i++) {
        if (*argv[i] == '-') {
            if (!strncasecmp(argv[i], "-p", 2)) {
			    strcpy(c->cfg_fname, argv[++i]);
            } else if (!strncasecmp(argv[i], "-s", 2)) {
                c->spin_up = TRUE;
            } else if (!strncasecmp(argv[i], "-ver", 4)) {
                c->PRINT_GIT = TRUE;
            } else if (!strncasecmp(argv[i], "-u", 2) ||
                       !strncasecmp(argv[i], "-h", 2)) {
                usage(argv);
                exit(EXIT_FAILURE);
            } else {
                fprintf(stderr, "%s: unknown argument on command line: %s\n",
                               argv[0], argv[i]);
                usage(argv);
                exit(EXIT_FAILURE);
            }
        }
    }
    return;
}


void usage(char **argv) {
    fprintf(stderr, "\n========\n");
    fprintf(stderr, " USAGE:\n");
    fprintf(stderr, "========\n");
    fprintf(stderr, "%s [options]\n", argv[0]);
    fprintf(stderr, "\n\nExpected input file is a .ini/.cfg style param file, passed with the -p flag .\n");
    fprintf(stderr, "\nThe options are:\n");
    fprintf(stderr, "\n++General options:\n" );
    fprintf(stderr, "[-ver          \t] Print the git hash tag.]\n");
    fprintf(stderr, "[-p       fname\t] Location of parameter file (.ini/.cfg).]\n");
    fprintf(stderr, "[-s            \t] Spin-up GDAY, when it the model is finished it will print the final state to the param file.]\n");
    fprintf(stderr, "\n++Print this message:\n" );
    fprintf(stderr, "[-u/-h         \t] usage/help]\n");

    return;
}

void reset_all_n_pools_and_fluxes(fluxes *f, state *s) {
    /*
        If the N-Cycle is turned off the way I am implementing this is to
        do all the calculations and then reset everything at the end. This is
        a waste of resources but saves on multiple IF statements.
    */

    /*
    ** State
    */
    s->shootn = 0.0;
    s->rootn = 0.0;
    s->structsurfn = 0.0;
    s->metabsurfn = 0.0;
    s->structsoiln = 0.0;
    s->metabsoiln = 0.0;
    s->activesoiln = 0.0;
    s->slowsoiln = 0.0;
    s->passivesoiln = 0.0;
    s->inorgn = 0.0;
    s->stemn = 0.0;

    /*
    ** Fluxes
    */
    f->nuptake = 0.0;
    f->nloss = 0.0;
    f->npassive = 0.0;
    f->ngross = 0.0;
    f->nimmob = 0.0;
    f->nlittrelease = 0.0;
    f->nmineralisation = 0.0;
    f->npleaf = 0.0;
    f->nproot = 0.0;
    f->npstem = 0.0;
    f->deadleafn = 0.0;
    f->deadrootn = 0.0;
    f->deadstemn = 0.0;
    f->leafretransn = 0.0;
    f->rootretransn = 0.0;
    f->stemretransn = 0.0;
    f->n_surf_struct_litter = 0.0;
    f->n_surf_metab_litter = 0.0;
    f->n_soil_struct_litter = 0.0;
    f->n_soil_metab_litter = 0.0;
    f->n_surf_struct_to_slow = 0.0;
    f->n_soil_struct_to_slow = 0.0;
    f->n_surf_struct_to_active = 0.0;
    f->n_soil_struct_to_active = 0.0;
    f->n_surf_metab_to_active = 0.0;
    f->n_surf_metab_to_active = 0.0;
    f->n_active_to_slow = 0.0;
    f->n_active_to_passive = 0.0;
    f->n_slow_to_active = 0.0;
    f->n_slow_to_passive = 0.0;
    f->n_passive_to_active = 0.0;

    return;
}

void reset_all_p_pools_and_fluxes(fluxes *f, state *s) {
    /*
        If the P-Cycle is turned off the way I am implementing this is to
        do all the calculations and then reset everything at the end. This is
        a waste of resources but saves on multiple IF statements.
    */

    /*
    ** State
    */
    s->shootp = 0.0;
    s->rootp = 0.0;
    s->structsurfp = 0.0;
    s->metabsurfp = 0.0;
    s->structsoilp = 0.0;
    s->metabsoilp = 0.0;
    s->activesoilp = 0.0;
    s->slowsoilp = 0.0;
    s->passivesoilp = 0.0;
    s->inorgp = 0.0;
    s->inorgavlp = 0.0;
    s->inorgssorbp = 0.0;
    s->inorgoccp = 0.0;
    s->inorgparp = 0.0;
    s->stemp = 0.0;

    /*
    ** Fluxes
    */
    f->puptake = 0.0;
    f->ploss = 0.0;
    f->ppassive = 0.0;
    f->pgross = 0.0;
    f->pimmob = 0.0;
    f->plittrelease = 0.0;
    f->pmineralisation = 0.0;
    f->ppleaf = 0.0;
    f->pproot = 0.0;
    f->ppstem = 0.0;
    f->deadleafp = 0.0;
    f->deadrootp = 0.0;
    f->deadstemp = 0.0;
    f->leafretransp = 0.0;
    f->rootretransp = 0.0;
    f->stemretransp = 0.0;
    f->p_surf_struct_litter = 0.0;
    f->p_surf_metab_litter = 0.0;
    f->p_soil_struct_litter = 0.0;
    f->p_soil_metab_litter = 0.0;
    f->p_surf_struct_to_slow = 0.0;
    f->p_soil_struct_to_slow = 0.0;
    f->p_surf_struct_to_active = 0.0;
    f->p_soil_struct_to_active = 0.0;
    f->p_surf_metab_to_active = 0.0;
    f->p_surf_metab_to_active = 0.0;
    f->p_active_to_slow = 0.0;
    f->p_active_to_passive = 0.0;
    f->p_slow_to_active = 0.0;
    f->p_slow_to_passive = 0.0;
    f->p_passive_to_active = 0.0;
    f->p_avl_to_ssorb = 0.0;
    f->p_ssorb_to_avl = 0.0;
    f->p_ssorb_to_occ = 0.0;
    f->p_par_to_avl = 0.0;
    f->p_atm_dep = 0.0;

    return;
}

void year_end_calculations(control *c, params *p, state *s) {
    /* 
     Calculate derived values from state variables.
    */
    
    /* update N:C and P:C of plant pool */
    if (float_eq(s->shoot, 0.0)) {
        s->shootnc = 0.0;
        s->shootpc = 0.0;
    } else {
        s->shootnc = s->shootn / s->shoot;
        s->shootpc = s->shootp / s->shoot;
    }

    /* Explicitly set the shoot N:C */
    if (c->ncycle == FALSE)
        s->shootnc = p->prescribed_leaf_NC;

    if (c->pcycle == FALSE)
        s->shootpc = p->prescribed_leaf_PC;

    if (float_eq(s->root, 0.0)) {
        s->rootnc = 0.0;
        s->rootpc = 0.0;
    } else {
        s->rootnc = MAX(0.0, s->rootn / s->root);
        s->rootpc = MAX(0.0, s->rootp / s->root);
    }

    /* total plant, soil & litter nitrogen */
    s->soiln = s->inorgn + s->activesoiln + s->slowsoiln + s->passivesoiln;
    s->litternag = s->structsurfn + s->metabsurfn;
    s->litternbg = s->structsoiln + s->metabsoiln;
    s->littern = s->litternag + s->litternbg;
    s->plantn = s->shootn + s->rootn + s->stemn;
    s->totaln = s->plantn + s->littern + s->soiln;

    /* total plant, soil & litter phosphorus */
    s->inorgp = s->inorgavlp + s->inorgssorbp + s->inorgoccp + s->inorgparp;
    s->soilp = s->inorgp + s->activesoilp + s->slowsoilp + s->passivesoilp;
    s->litterpag = s->structsurfp + s->metabsurfp;
    s->litterpbg = s->structsoilp + s->metabsoilp;
    s->litterp = s->litterpag + s->litterpbg;
    s->plantp = s->shootp + s->rootp + s->stemp;
    s->totalp = s->plantp + s->litterp + s->soilp;

    /* total plant, soil, litter and system carbon */
    s->soilc = s->activesoil + s->slowsoil + s->passivesoil;
    s->littercag = s->structsurf + s->metabsurf;
    s->littercbg = s->structsoil + s->metabsoil;
    s->litterc = s->littercag + s->littercbg;
    s->plantc = s->root + s->shoot + s->stem;
    s->totalc = s->soilc + s->litterc + s->plantc;
    
    /* optional constant passive pool */
    if (c->passiveconst) {
      s->passivesoil = p->passivesoilz;
      s->passivesoiln = p->passivesoilnz;
      s->passivesoilp = p->passivesoilpz;
    }
    
    return;
}


void year_start_calculations(control *c, params *p, state *s) {
  /* 
  Calculate derived values from state variables.
  */
  
  /* update N:C and P:C of plant pool */
  if (float_eq(s->shoot, 0.0)) {
    s->shootnc = 0.0;
    s->shootpc = 0.0;
  } else {
    s->shootnc = s->shootn / s->shoot;
    s->shootpc = s->shootp / s->shoot;
  }
  
  /* Explicitly set the shoot N:C */
  if (c->ncycle == FALSE)
    s->shootnc = p->prescribed_leaf_NC;
  
  if (c->pcycle == FALSE)
    s->shootpc = p->prescribed_leaf_PC;
  
  if (float_eq(s->root, 0.0)) {
    s->rootnc = 0.0;
    s->rootpc = 0.0;
  } else {
    s->rootnc = MAX(0.0, s->rootn / s->root);
    s->rootpc = MAX(0.0, s->rootp / s->root);
  }
  
  /* total plant, soil & litter nitrogen */
  s->soiln = s->inorgn + s->activesoiln + s->slowsoiln + s->passivesoiln;
  s->litternag = s->structsurfn + s->metabsurfn;
  s->litternbg = s->structsoiln + s->metabsoiln;
  s->littern = s->litternag + s->litternbg;
  s->plantn = s->shootn + s->rootn + s->stemn;
  s->totaln = s->plantn + s->littern + s->soiln;
  
  /* total plant, soil & litter phosphorus */
  s->inorgp = s->inorgavlp + s->inorgssorbp + s->inorgoccp + s->inorgparp;
  s->soilp = s->inorgp + s->activesoilp + s->slowsoilp + s->passivesoilp;
  s->litterpag = s->structsurfp + s->metabsurfp;
  s->litterpbg = s->structsoilp + s->metabsoilp;
  s->litterp = s->litterpag + s->litterpbg;
  s->plantp = s->shootp + s->rootp + s->stemp;
  s->totalp = s->plantp + s->litterp + s->soilp;
  
  /* total plant, soil, litter and system carbon */
  s->soilc = s->activesoil + s->slowsoil + s->passivesoil;
  s->littercag = s->structsurf + s->metabsurf;
  s->littercbg = s->structsoil + s->metabsoil;
  s->litterc = s->littercag + s->littercbg;
  s->plantc = s->root + s->shoot + s->stem;
  s->totalc = s->soilc + s->litterc + s->plantc;
  
  return;
}

void unpack_met_data_simple(fluxes *f, met *m, params *p) {
  
  /* unpack met forcing */
  m->Ca = p->co2_in;
  m->par = p->I0 / NMONTHS_IN_YR;       // convert annual input to monthly
  
  m->ndep = p->ndep_in / NMONTHS_IN_YR; // convert annual input to monthly
  m->nfix = p->nfix_in / NMONTHS_IN_YR; // convert annual input to monthly
  m->pdep = p->pdep_in / NMONTHS_IN_YR; // convert annual input to monthly
  m->tsoil = p->tsoil_in;
  
  f->ninflow = (m->ndep + m->nfix);
  f->p_atm_dep = m->pdep;
  
  return;
}

void unpack_met_data_transient(control *c, fluxes *f, met_arrays *ma, met *m, params *p) {
  
  /* unpack met forcing */
  m->Ca = ma->co2[c->month_idx];
  m->par = ma->par[c->month_idx];
  m->ndep = ma->ndep[c->month_idx];
  m->nfix = ma->nfix[c->month_idx];
  m->pdep = ma->pdep[c->month_idx];
  m->tsoil = ma->tsoil[c->month_idx];

  
  f->ninflow = (m->ndep + m->nfix);
  f->p_atm_dep = m->pdep;
  
  return;
}

void correct_rate_constants(params *p, int output) {
  /* adjust rate constants for the number of months in years */
  
  if (output) {
    p->rateuptake *= NMONTHS_IN_YR;
    p->prateuptake *= NMONTHS_IN_YR;
    p->rateloss *= NMONTHS_IN_YR;
    p->prateloss *= NMONTHS_IN_YR;
    //p->fretransn *= NMONTHS_IN_YR;  // commented out because deadleaf nc should be half of leaf nc
    //p->fretransp *= NMONTHS_IN_YR;
    //p->rretrans *= NMONTHS_IN_YR;
    //p->wretrans *= NMONTHS_IN_YR;
    p->fdecay *= NMONTHS_IN_YR;
    p->rdecay *= NMONTHS_IN_YR;
    p->wdecay *= NMONTHS_IN_YR;
    p->sapturnover *= NMONTHS_IN_YR;
    p->kdec1 *= NMONTHS_IN_YR;
    p->kdec2 *= NMONTHS_IN_YR;
    p->kdec3 *= NMONTHS_IN_YR;
    p->kdec4 *= NMONTHS_IN_YR;
    p->kdec5 *= NMONTHS_IN_YR;
    p->kdec6 *= NMONTHS_IN_YR;
    p->kdec7 *= NMONTHS_IN_YR;
    //p->k1 *= NMONTHS_IN_YR;
    //p->k2 *= NMONTHS_IN_YR;
    //p->k3 *= NMONTHS_IN_YR;
    p->nuptakez *= NMONTHS_IN_YR;
    p->puptakez *= NMONTHS_IN_YR;
  } else {
    p->rateuptake /= NMONTHS_IN_YR;
    p->prateuptake /= NMONTHS_IN_YR;
    p->rateloss /= NMONTHS_IN_YR;
    p->prateloss /= NMONTHS_IN_YR;
    //p->fretransn /= NMONTHS_IN_YR;
    //p->fretransp /= NMONTHS_IN_YR;
    //p->rretrans /= NMONTHS_IN_YR;
    //p->wretrans /= NMONTHS_IN_YR;
    p->fdecay /= NMONTHS_IN_YR;
    p->rdecay /= NMONTHS_IN_YR;
    p->wdecay /= NMONTHS_IN_YR;
    p->sapturnover /= NMONTHS_IN_YR;
    p->kdec1 /= NMONTHS_IN_YR;
    p->kdec2 /= NMONTHS_IN_YR;
    p->kdec3 /= NMONTHS_IN_YR;
    p->kdec4 /= NMONTHS_IN_YR;
    p->kdec5 /= NMONTHS_IN_YR;
    p->kdec6 /= NMONTHS_IN_YR;
    p->kdec7 /= NMONTHS_IN_YR;
    //p->k1 /= NMONTHS_IN_YR;
    //p->k2 /= NMONTHS_IN_YR;
    //p->k3 /= NMONTHS_IN_YR;
    p->nuptakez /= NMONTHS_IN_YR;
    p->puptakez /= NMONTHS_IN_YR;
  }
  
  return;
}
