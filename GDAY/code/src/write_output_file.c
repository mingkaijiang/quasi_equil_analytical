/* ============================================================================
* Print output file (ascii)
*
*
*
* NOTES:
*   Currently I have only implemented the ascii version
*
* AUTHOR:
*   Martin De Kauwe
*
* DATE:
*   25.02.2015
*
* =========================================================================== */
#include "write_output_file.h"


void open_output_file(control *c, char *fname, FILE **fp) {
    *fp = fopen(fname, "w");
    if (*fp == NULL)
        prog_error("Error opening output file for write on line", __LINE__);
}

void write_output_header(control *c, params *p, FILE **fp) {
    /*
        Write annual state and fluxes headers to an output CSV file. Note we
        are not writing anything useful like units as there is a wrapper
        script to translate the outputs to a nice CSV file with input met
        data, units and nice header information.
    */

    /* Git version */
    fprintf(*fp, "#Git_revision_code:%s\n", c->git_code_ver);

    /* time stuff */
    fprintf(*fp, "year,month,");

    /*
    ** STATE
    */
    /* plant */
    fprintf(*fp, "shoot,lai,stem,root,");
    fprintf(*fp, "shootn,stemn,rootn,");
    fprintf(*fp, "shootp,stemp,rootp,");

    /* belowground */
    fprintf(*fp, "soilc,soiln,soilp,inorgn,");
    fprintf(*fp, "inorgp,inorgavlp,inorgssorbp,inorgoccp,inorgparp,");
    fprintf(*fp, "litterc,littercag,littercbg,litternag,litternbg,");
    fprintf(*fp, "litterpag,litterpbg,");
    fprintf(*fp, "activesoil,slowsoil,passivesoil,");
    fprintf(*fp, "activesoiln,slowsoiln,passivesoiln,activesoilp,slowsoilp,passivesoilp,");

    /*
    ** FLUXES
    */

    /* litter */
    fprintf(*fp, "deadleaves,deadstems,deadroots,");
    fprintf(*fp, "deadleafn,deadstemn,deadrootn,");
    fprintf(*fp, "deadleafp,deadstemp,deadrootp,");


    /* C fluxes */
    fprintf(*fp, "nep,gpp,npp,hetero_resp,auto_resp,apar,");

    /* C, N and P growth */
    fprintf(*fp, "cpleaf,cpstem,cproot,");
    fprintf(*fp, "npleaf,npstem,nproot,");
    fprintf(*fp, "ppleaf,ppstem,pproot,");


    /* N stuff */
    fprintf(*fp, "ninflow,nuptake,ngross,nmineralisation,nloss,nlittrelease,");

    /* P stuff */
    fprintf(*fp, "p_atm_dep,puptake,pgross,pmineralisation,ploss,plittrelease,");

    /* traceability stuff */
    fprintf(*fp, "tfac_soil_decomp,c_into_active,c_into_slow,");
    fprintf(*fp, "c_into_passive,active_to_slow,active_to_passive,");
    fprintf(*fp, "slow_to_active,slow_to_passive,passive_to_active,");
    fprintf(*fp, "co2_rel_from_surf_struct_litter,");
    fprintf(*fp, "co2_rel_from_soil_struct_litter,");
    fprintf(*fp, "co2_rel_from_surf_metab_litter,");
    fprintf(*fp, "co2_rel_from_soil_metab_litter,");
    fprintf(*fp, "co2_rel_from_active_pool,");
    fprintf(*fp, "co2_rel_from_slow_pool,");
    fprintf(*fp, "co2_rel_from_passive_pool,");

    /* Misc */
    fprintf(*fp, "leafretransn,");
    fprintf(*fp, "leafretransp,");
    fprintf(*fp, "rootretransn,");
    fprintf(*fp, "rootretransp,");
    fprintf(*fp, "stemretransn,");
    fprintf(*fp, "stemretransp,");
    fprintf(*fp, "retransn,");
    fprintf(*fp, "retransp\n");
    

    return;
}

void write_annual_outputs_ascii(control *c, fluxes *f, state *s, int year, int month) {
    /*
        Write annual state and fluxes headers to an output CSV file. Note we
        are not writing anything useful like units as there is a wrapper
        script to translate the outputs to a nice CSV file with input met
        data, units and nice header information.
    */


    /* time stuff */
    fprintf(c->ofp, "%.10f,%.10f,", (double)year, (double)month);

    /*
    ** STATE

    */

    /* plant */
    fprintf(c->ofp, "%.10f,%.10f,%.10f,%.10f,",
                    s->shoot,s->lai,s->stem,s->root);

    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    s->shootn,s->stemn,s->rootn);

    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    s->shootp,s->stemp,s->rootp);

    /* belowground */
    fprintf(c->ofp, "%.10f,%.10f,%.10f,%.10f,",
                    s->soilc,s->soiln,s->soilp,s->inorgn);

    fprintf(c->ofp, "%.10f,%.10f,%.10f,%.10f,%.10f,",
                    s->inorgp,s->inorgavlp,s->inorgssorbp,
                    s->inorgoccp,s->inorgparp);

    fprintf(c->ofp, "%.10f,%.10f,%.10f,%.10f,%.10f,",
                    s->litterc,s->littercag,s->littercbg,s->litternag,s->litternbg);

    fprintf(c->ofp, "%.10f,%.10f,",
                    s->litterpag,s->litterpbg);

    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    s->activesoil,s->slowsoil,s->passivesoil);

    fprintf(c->ofp, "%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,",
                    s->activesoiln,s->slowsoiln,s->passivesoiln,
                    s->activesoilp,s->slowsoilp,s->passivesoilp);
    /*
    ** FLUXES
    */

    /* litter */
    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    f->deadleaves,f->deadstems,f->deadroots);
    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    f->deadleafn,f->deadstemn,f->deadrootn);
    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    f->deadleafp,f->deadstemp,f->deadrootp);

    /* C fluxes */
    fprintf(c->ofp, "%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,",
                    f->nep,f->gpp,f->npp,f->hetero_resp,f->auto_resp,
                    f->apar);

    /* C N and P growth */
    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    f->cpleaf,f->cpstem,f->cproot);
    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    f->npleaf,f->npstem,f->nproot);
    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    f->ppleaf,f->ppstem,f->pproot);

    /* N stuff */
    fprintf(c->ofp, "%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,",
                    f->ninflow,f->nuptake,f->ngross,f->nmineralisation,f->nloss,f->nlittrelease);

    /* P stuff */
    fprintf(c->ofp, "%.10f,%.10f,%.10f,%.10f,%.10f,%.10f,",
                    f->p_atm_dep,f->puptake,f->pgross,f->pmineralisation,f->ploss,f->plittrelease);


    /* traceability stuff */
    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    f->tfac_soil_decomp,f->c_into_active,f->c_into_slow);
    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    f->c_into_passive,f->active_to_slow,f->active_to_passive);
    fprintf(c->ofp, "%.10f,%.10f,%.10f,",
                    f->slow_to_active,f->slow_to_passive,f->passive_to_active);
    fprintf(c->ofp, "%.10f,", f->co2_rel_from_surf_struct_litter);
    fprintf(c->ofp, "%.10f,", f->co2_rel_from_soil_struct_litter);
    fprintf(c->ofp, "%.10f,", f->co2_rel_from_surf_metab_litter);
    fprintf(c->ofp, "%.10f,", f->co2_rel_from_soil_metab_litter);
    fprintf(c->ofp, "%.10f,", f->co2_rel_from_active_pool);
    fprintf(c->ofp, "%.10f,", f->co2_rel_from_slow_pool);
    fprintf(c->ofp, "%.10f,", f->co2_rel_from_passive_pool);

    /* Misc */
    fprintf(c->ofp, "%.10f,", f->leafretransn);
    fprintf(c->ofp, "%.10f,", f->leafretransp);
    fprintf(c->ofp, "%.10f,", f->rootretransn);
    fprintf(c->ofp, "%.10f,", f->rootretransp);
    fprintf(c->ofp, "%.10f,", f->stemretransn);
    fprintf(c->ofp, "%.10f,", f->stemretransp);
    fprintf(c->ofp, "%.10f,", f->retransn);
    fprintf(c->ofp, "%.10f\n", f->retransp);
    
    return;
}


int write_final_state(control *c, params *p, state *s)
{
    /*
    Write the final state to the input param file so we can easily restart
    the model. This function copies the input param file with the exception
    of anything in the git hash and the state which it replaces with the updated
    stuff.

    */

    char line[STRING_LENGTH];
    char saved_line[STRING_LENGTH];
    char section[STRING_LENGTH] = "";
    char prev_name[STRING_LENGTH] = "";
    char *start;
    char *end;
    char *name;
    char *value;

    int error = 0;
    int line_number = 0;
    int match = FALSE;

    while (fgets(line, sizeof(line), c->ifp) != NULL) {
        strcpy(saved_line, line);
        line_number++;
        start = lskip(rstrip(line));
        if (*start == ';' || *start == '#') {
            /* Per Python ConfigParser, allow '#' comments at start of line */
        }
        else if (*start == '[') {
            /* A "[section]" line */
            end = find_char_or_comment(start + 1, ']');
            if (*end == ']') {
                *end = '\0';
                strncpy0(section, start + 1, sizeof(section));
                *prev_name = '\0';

            }
            else if (!error) {
                /* No ']' found on section line */
                error = line_number;

            }
        }
        else if (*start && *start != ';') {
            /* Not a comment, must be a name[=:]value pair */
            end = find_char_or_comment(start, '=');
            if (*end != '=') {
                end = find_char_or_comment(start, ':');
            }
            if (*end == '=' || *end == ':') {
                *end = '\0';
                name = rstrip(start);
                value = lskip(end + 1);
                end = find_char_or_comment(value, '\0');
                if (*end == ';')
                    *end = '\0';
                rstrip(value);

                /* Valid name[=:]value pair found, call handler */
                strncpy0(prev_name, name, sizeof(prev_name));

                if (!ohandler(section, name, value, c, p, s, &match) && !error)
                    error = line_number;
            }
            else if (!error) {
                /* No '=' or ':' found on name[=:]value line */
                error = line_number;
                break;
            }
        }
        if (match == FALSE)
            fprintf(c->ofp, "%s", saved_line);
        else
            match = FALSE; /* reset match flag */
    }
    return error;

}


int ohandler(char *section, char *name, char *value, control *c, params *p,
             state *s, int *match)
{
    /*
    Search for matches of the git and state values and where found write the
    current state values to the output parameter file.

    - also added previous ncd as this potential can be changed internally
    */

    #define MATCH(s, n) strcasecmp(section, s) == 0 && strcasecmp(name, n) == 0

    /*
    ** GIT
    */
    if (MATCH("git", "git_hash")) {
        fprintf(c->ofp, "git_hash = %s\n", c->git_code_ver);
        *match = TRUE;
    }

    /*
    ** STATE
    */

    if (MATCH("state", "activesoil")) {
        fprintf(c->ofp, "activesoil = %.10f\n", s->activesoil);
        *match = TRUE;
    } else if (MATCH("state", "activesoiln")) {
        fprintf(c->ofp, "activesoiln = %.10f\n", s->activesoiln);
        *match = TRUE;
    } else if (MATCH("state", "activesoilp")) {
        fprintf(c->ofp, "activesoilp = %.10f\n", s->activesoilp);
        *match = TRUE;
    } else if (MATCH("state", "canht")) {
      fprintf(c->ofp, "canht = %.10f\n", s->canht);
      *match = TRUE;
    } else if (MATCH("state", "inorgn")) {
        fprintf(c->ofp, "inorgn = %.10f\n", s->inorgn);
        *match = TRUE;
    } else if (MATCH("state", "inorgp")) {
        fprintf(c->ofp, "inorgp = %.10f\n", s->inorgp);
        *match = TRUE;
    } else if (MATCH("state", "inorgavlp")) {
        fprintf(c->ofp, "inorgavlp = %.10f\n", s->inorgavlp);
        *match = TRUE;
    } else if (MATCH("state", "inorgssorbp")) {
        fprintf(c->ofp, "inorgssorbp = %.10f\n", s->inorgssorbp);
        *match = TRUE;
    } else if (MATCH("state", "inorgoccp")) {
        fprintf(c->ofp, "inorgoccp = %.10f\n", s->inorgoccp);
        *match = TRUE;
    } else if (MATCH("state", "inorgparp")) {
        fprintf(c->ofp, "inorgparp = %.10f\n", s->inorgparp);
        *match = TRUE;
    } else if (MATCH("state", "lai")) {
        fprintf(c->ofp, "lai = %.10f\n", s->lai);
        *match = TRUE;
    } else if (MATCH("state", "metabsoil")) {
        fprintf(c->ofp, "metabsoil = %.10f\n", s->metabsoil);
        *match = TRUE;
    } else if (MATCH("state", "metabsoiln")) {
        fprintf(c->ofp, "metabsoiln = %.10f\n", s->metabsoiln);
        *match = TRUE;
    } else if (MATCH("state", "metabsoilp")) {
        fprintf(c->ofp, "metabsoilp = %.10f\n", s->metabsoilp);
        *match = TRUE;
    } else if (MATCH("state", "metabsurf")) {
        fprintf(c->ofp, "metabsurf = %.10f\n", s->metabsurf);
        *match = TRUE;
    } else if (MATCH("state", "metabsurfn")) {
        fprintf(c->ofp, "metabsurfn = %.10f\n", s->metabsurfn);
        *match = TRUE;
    } else if (MATCH("state", "metabsurfp")) {
        fprintf(c->ofp, "metabsurfp = %.10f\n", s->metabsurfp);
        *match = TRUE;
    } else if (MATCH("state", "passivesoil")) {
        fprintf(c->ofp, "passivesoil = %.10f\n", s->passivesoil);
        *match = TRUE;
    } else if (MATCH("state", "passivesoiln")) {
        fprintf(c->ofp, "passivesoiln = %.10f\n", s->passivesoiln);
        *match = TRUE;
    } else if (MATCH("state", "passivesoilp")) {
        fprintf(c->ofp, "passivesoilp = %.10f\n", s->passivesoilp);
        *match = TRUE;
    } else if (MATCH("state", "root")) {
        fprintf(c->ofp, "root = %.10f\n", s->root);
        *match = TRUE;
    } else if (MATCH("state", "rootn")) {
        fprintf(c->ofp, "rootn = %.10f\n", s->rootn);
        *match = TRUE;
    } else if (MATCH("state", "rootp")) {
        fprintf(c->ofp, "rootp = %.10f\n", s->rootp);
        *match = TRUE;
    } else if (MATCH("state", "sapwood")) {
      fprintf(c->ofp, "sapwood = %.10f\n", s->sapwood);
      *match = TRUE;
    } else if (MATCH("state", "shoot")) {
        fprintf(c->ofp, "shoot = %.10f\n", s->shoot);
        *match = TRUE;
    } else if (MATCH("state", "shootn")) {
        fprintf(c->ofp, "shootn = %.10f\n", s->shootn);
        *match = TRUE;
    } else if (MATCH("state", "shootp")) {
        fprintf(c->ofp, "shootp = %.10f\n", s->shootp);
        *match = TRUE;
    } else if (MATCH("state", "slowsoil")) {
        fprintf(c->ofp, "slowsoil = %.10f\n", s->slowsoil);
        *match = TRUE;
    } else if (MATCH("state", "slowsoiln")) {
        fprintf(c->ofp, "slowsoiln = %.10f\n", s->slowsoiln);
        *match = TRUE;
    } else if (MATCH("state", "slowsoilp")) {
        fprintf(c->ofp, "slowsoilp = %.10f\n", s->slowsoilp);
        *match = TRUE;
    } else if (MATCH("state", "stem")) {
        fprintf(c->ofp, "stem = %.10f\n", s->stem);
        *match = TRUE;
    } else if (MATCH("state", "stemn")) {
        fprintf(c->ofp, "stemn = %.10f\n", s->stemn);
        *match = TRUE;
    } else if (MATCH("state", "stemp")) {
        fprintf(c->ofp, "stemp = %.10f\n", s->stemp);
        *match = TRUE;
    } else if (MATCH("state", "structsoil")) {
        fprintf(c->ofp, "structsoil = %.10f\n", s->structsoil);
        *match = TRUE;
    } else if (MATCH("state", "structsoiln")) {
        fprintf(c->ofp, "structsoiln = %.10f\n", s->structsoiln);
        *match = TRUE;
    } else if (MATCH("state", "structsoilp")) {
        fprintf(c->ofp, "structsoilp = %.10f\n", s->structsoilp);
        *match = TRUE;
    } else if (MATCH("state", "structsurf")) {
        fprintf(c->ofp, "structsurf = %.10f\n", s->structsurf);
        *match = TRUE;
    } else if (MATCH("state", "structsurfn")) {
        fprintf(c->ofp, "structsurfn = %.10f\n", s->structsurfn);
        *match = TRUE;
    } else if (MATCH("state", "structsurfp")) {
        fprintf(c->ofp, "structsurfp = %.10f\n", s->structsurfp);
        *match = TRUE;
    } else if (MATCH("state", "shootnc")) {
      fprintf(c->ofp, "shootnc = %.10f\n", s->shootnc);
      *match = TRUE;
    } else if (MATCH("state", "rootnc")) {
      fprintf(c->ofp, "rootnc = %.10f\n", s->rootnc);
      *match = TRUE;
    } else if (MATCH("state", "shootpc")) {
      fprintf(c->ofp, "shootpc = %.10f\n", s->shootpc);
      *match = TRUE;
    } else if (MATCH("state", "rootpc")) {
      fprintf(c->ofp, "rootpc = %.10f\n", s->rootpc);
      *match = TRUE;
    } else if (MATCH("state", "litterc")) {
      fprintf(c->ofp, "litterc = %.10f\n", s->litterc);
      *match = TRUE;
    } else if (MATCH("state", "littern")) {
      fprintf(c->ofp, "littern = %.10f\n", s->littern);
      *match = TRUE;
    } else if (MATCH("state", "litterp")) {
      fprintf(c->ofp, "litterp = %.10f\n", s->litterp);
      *match = TRUE;
    } else if (MATCH("state", "littercbg")) {
      fprintf(c->ofp, "littercbg = %.10f\n", s->littercbg);
      *match = TRUE;
    } else if (MATCH("state", "littercag")) {
      fprintf(c->ofp, "littercag = %.10f\n", s->littercag);
      *match = TRUE;
    } else if (MATCH("state", "litternbg")) {
      fprintf(c->ofp, "litternbg = %.10f\n", s->litternbg);
      *match = TRUE;
    } else if (MATCH("state", "litternag")) {
      fprintf(c->ofp, "litternag = %.10f\n", s->litternag);
      *match = TRUE;
    } else if (MATCH("state", "litterpbg")) {
      fprintf(c->ofp, "litterpbg = %.10f\n", s->litterpbg);
      *match = TRUE;
    } else if (MATCH("state", "litterpag")) {
      fprintf(c->ofp, "litterpag = %.10f\n", s->litterpag);
      *match = TRUE;
    } else if (MATCH("state", "plantc")) {
      fprintf(c->ofp, "plantc = %.10f\n", s->plantc);
      *match = TRUE;
    } else if (MATCH("state", "plantn")) {
      fprintf(c->ofp, "plantn = %.10f\n", s->plantn);
      *match = TRUE;
    } else if (MATCH("state", "plantp")) {
      fprintf(c->ofp, "plantp = %.10f\n", s->plantp);
      *match = TRUE;
    }  else if (MATCH("state", "totalc")) {
        fprintf(c->ofp, "totalc = %.10f\n", s->totalc);
        *match = TRUE;
    }  else if (MATCH("state", "totaln")) {
      fprintf(c->ofp, "totaln = %.10f\n", s->totaln);
      *match = TRUE;
    }  else if (MATCH("state", "totalp")) {
      fprintf(c->ofp, "totalp = %.10f\n", s->totalp);
      *match = TRUE;
    } else if (MATCH("state", "soilc")) {
      fprintf(c->ofp, "soilc = %.10f\n", s->soilc);
      *match = TRUE;
    } else if (MATCH("state", "soiln")) {
      fprintf(c->ofp, "soiln = %.10f\n", s->soiln);
      *match = TRUE;
    } else if (MATCH("state", "soilp")) {
      fprintf(c->ofp, "soilp = %.10f\n", s->soilp);
      *match = TRUE;
    } 

    return (1);
}
