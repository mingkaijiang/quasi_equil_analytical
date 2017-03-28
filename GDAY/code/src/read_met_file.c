#include "read_met_file.h"



void read_annual_met_data_simple(char **argv, control *c, met *m, params *p)
{
    double current_yr = -999.9;
    
    /* unpack met forcing */
    m->year = 1;
    m->co2 = p->co2_in;
    m->par = p->I0;
    
    m->ndep = p->ndep_in;
    m->nfix = p->nfix_in;
    m->pdep = p->pdep_in;
    m->tsoil = p->tsoil_in;
    
    return;
}


void read_monthly_met_data(char **argv, control *c, met_arrays *ma)
{
  FILE  *fp;
  char   line[STRING_LENGTH];
  int    file_len = 0;
  int    i = 0;
  int    nvars = 8;
  int    skipped_lines = 0;
  double current_yr = -999.9;
  
  if ((fp = fopen(c->met_fname, "r")) == NULL) {
    fprintf(stderr, "Error: couldn't open monthly Met file %s for read\n",
            c->met_fname);
    exit(EXIT_FAILURE);
  }
  
  /* work out how big the file is */
  file_len = 0;
  while (fgets(line, STRING_LENGTH, fp) != NULL) {
    /* ignore comment line */
    if (*line == '#')
      continue;
    file_len++;
  }
  rewind(fp);
  
  /* allocate memory for meteorological arrays */
  if ((ma->year = (double *)calloc(file_len, sizeof(double))) == NULL) {
    fprintf(stderr,"Error allocating space for year array\n");
    exit(EXIT_FAILURE);
  }
  
  if ((ma->prjmonth = (double *)calloc(file_len, sizeof(double))) == NULL) {
    fprintf(stderr,"Error allocating space for prjmonth array\n");
    exit(EXIT_FAILURE);
  }
  
  if ((ma->tsoil = (double *)calloc(file_len, sizeof(double))) == NULL) {
    fprintf(stderr,"Error allocating space for tsoil array\n");
    exit(EXIT_FAILURE);
  }
  
  if ((ma->co2 = (double *)calloc(file_len, sizeof(double))) == NULL) {
    fprintf(stderr,"Error allocating space for co2 array\n");
    exit(EXIT_FAILURE);
  }
  
  if ((ma->ndep = (double *)calloc(file_len, sizeof(double))) == NULL) {
    fprintf(stderr,"Error allocating space for ndep array\n");
    exit(EXIT_FAILURE);
  }
  
  if ((ma->nfix = (double *)calloc(file_len, sizeof(double))) == NULL) {
    fprintf(stderr,"Error allocating space for nfix array\n");
    exit(EXIT_FAILURE);
  }
  
  if ((ma->pdep = (double *)calloc(file_len, sizeof(double))) == NULL) {
    fprintf(stderr,"Error allocating space for pdep array\n");
    exit(EXIT_FAILURE);
  }
  
  if ((ma->par = (double *)calloc(file_len, sizeof(double))) == NULL) {
    fprintf(stderr,"Error allocating space for par array\n");
    exit(EXIT_FAILURE);
  }
  
  i = 0;
  c->num_years = 0;
  skipped_lines = 0;
  while (fgets(line, STRING_LENGTH, fp) != NULL) {
    /* ignore comment line */
    if (*line == '#') {
      skipped_lines++;
      continue;
    }
    
    if (sscanf(line, "%lf,%lf,                                          \
                 %lf,%lf,%lf,                                           \
                 %lf,%lf,%lf",                                          \
                 &(ma->year[i]), &(ma->prjmonth[i]),                    \
                 &(ma->tsoil[i]), &(ma->co2[i]), &(ma->ndep[i]),        \
                 &(ma->nfix[i]),  &(ma->pdep[i]), &(ma->par[i])) != nvars) {
                 fprintf(stderr, "%s: badly formatted input in met file on line %d %d\n", \
                         *argv, (int)i+1+skipped_lines, nvars);
      exit(EXIT_FAILURE);
    }
    
    /* Build an array of the unique years as we loop over the input file */
    if (current_yr != ma->year[i]) {
      c->num_years++;
      current_yr = ma->year[i];
    }
    i++;
  }
  fclose(fp);
  return;
}