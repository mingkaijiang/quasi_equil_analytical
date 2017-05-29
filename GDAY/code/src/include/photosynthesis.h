#ifndef PHOTOSYNTHESIS_H
#define PHOTOSYNTHESIS_H

#include "gday.h"
#include "constants.h"
#include "utilities.h"

/* Daily funcs */
void simple_photosynthesis(control *, fluxes *, met *, params *, state *,
                           double, double);

double  lue_simplified(control *, params *, state *, double);

double  calculate_top_of_canopy_n(params *, state *, double);
double  calculate_top_of_canopy_p(params *, state *, double);
double  calculate_co2_compensation_point(params *, double, double);
double  arrh(double, double, double, double);
double  calculate_michaelis_menten_parameter(params *, double, double);
void    calculate_jmax_and_vcmax(control *, params *, state *, double, double,
                                 double *, double *, double);
void    calculate_jmax_and_vcmax_with_p(control *, params *, state *, double,
                                        double, double, double *, double *,
                                        double);
double  calculate_ci(control *, params *, state *, double, double);
double  calculate_quantum_efficiency(params *, double ci, double);
double  assim(double, double, double, double);
double  epsilon(params *, double, double, double, double);

#endif /* PHOTOSYNTHESIS */
