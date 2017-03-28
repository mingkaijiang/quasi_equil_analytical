#ifndef GDAY_H
#define GDAY_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include <math.h>


#define EPSILON 1E-08
#define DEG2RAD(DEG) (DEG * M_PI / 180.0)
#define RAD2DEG(RAD) (180.0 * RAD / M_PI)
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#define STRING_LENGTH 2000

#define MIN(a,b) (((a) < (b)) ? (a) : (b))
#define MAX(a,b) (((a) > (b)) ? (a) : (b))
#define CLIP(x) ((x)<0. ? 0. : ((x)>1. ? 1. : (x)))

/* output time step, where end = the final state */
#define ANNUAL 0
#define END 1

/* Allocation models */
#define FIXED 0
#define GRASSES 1
#define ALLOMETRIC 2

/* Respiration models */
#define FIXED 0
#define TEMPERATURE 1
#define LEAFN 2

/* Texture identifiers */
#define SILT 0
#define SAND 1
#define CLAY 2

/* som_nc_calc models */
#define FIXED 0
#define INORGN 1

/* som_pc_calc models */
#define FIXED 0
#define INORGAVLP 1

#include "structures.h"
#include "initialise_model.h"
#include "plant_growth.h"
#include "litter_production.h"
#include "write_output_file.h"
#include "read_param_file.h"
#include "read_met_file.h"
#include "soils.h"
#include "version.h"


void   clparser(int, char **, control *);
void   usage(char **);

void   run_sim(control *, fluxes *, met_arrays *, met *,
               params *, state *, nrutil *);
void   spin_up_annual(control *, fluxes *, met *,
                      params *, state *, nrutil *);
void   reset_all_n_pools_and_fluxes(fluxes *, state *);
void   reset_all_p_pools_and_fluxes(fluxes *, state *);
void   year_end_calculations(control *, params *, state *);
void   year_start_calculations(control *, params *, state *);
void   unpack_met_data_simple(fluxes *, met *, params *); 
void   unpack_met_data_transient(control *, fluxes *, met_arrays *, met *, params *); 
void   correct_rate_constants(params *, int );

#endif /* GDAY_H */
