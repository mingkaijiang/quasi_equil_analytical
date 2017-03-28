#ifndef PHOTOSYNTHESIS_H
#define PHOTOSYNTHESIS_H

#include "gday.h"
#include "constants.h"
#include "utilities.h"

/* Daily funcs */
void simple_photosynthesis(control *, fluxes *, met *, params *, state *);

double  lue_simplified(params *, state *, double);


#endif /* PHOTOSYNTHESIS */
