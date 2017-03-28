#ifndef UTILITIES_H
#define UTILITIES_H

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include "gday.h"
#include "constants.h"




/* utilities */
void   prog_error(const char *, const unsigned int);
bool   float_eq(double, double);

char   *rstrip(char *);
char   *lskip(char *);
char   *find_char_or_comment(char*, char);
char   *strncpy0(char*, char*, size_t);

#endif /* UTILITIES_H */
