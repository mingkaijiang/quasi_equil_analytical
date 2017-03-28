#ifndef PLANT_GROWTH_H
#define PLANT_GROWTH_H

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>


#include "gday.h"
#include "constants.h"
#include "utilities.h"
#include "photosynthesis.h"

/* C stuff */
void    calc_annual_growth(control *, fluxes *, met *,
                        nrutil *, params *, state *);
void    carbon_allocation(control *, fluxes *, params *, state *);
void    calc_carbon_allocation_fracs(control *c, fluxes *, params *, state *);
double  alloc_goal_seek(double, double, double, double);
void    update_plant_state(control *, fluxes *, params *, state *);
void    precision_control(fluxes *, state *);
void    carbon_annual_production(control *, fluxes *, met *m, params *, state *);

void    calculate_cnp_wood_ratios(control *c, params *, state *, double *, double *);

/* N stuff */
void    np_allocation(control *c, fluxes *, params *, state *, double,
                     double);
double calculate_nuptake(control *, params *, state *, fluxes *);

double nitrogen_retrans(control *, fluxes *, params *, state *);

void cut_back_production_n(control *, fluxes *, params *, state *, double,
                           double, double);

/* P stuff */
double calculate_puptake(control *, params *, state *, fluxes *);
double phosphorus_retrans(control *, fluxes *, params *, state *);

void cut_back_production_p(control *, fluxes *, params *, state *, double,
                          double, double);

/* Priming/Exudation stuff */
void   calc_root_exudation(control *c, fluxes *, params *p, state *);

#endif /* PLANT_GROWTH */
