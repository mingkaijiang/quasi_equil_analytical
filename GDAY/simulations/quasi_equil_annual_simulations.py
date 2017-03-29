#!/usr/bin/env python

""" Quasi-equilibrium Simulations

- Model simulation: using hypothetical annual met forcing data and hypothetical parameters
                 to run sensitivity tests.

"""

import os
import shutil
import sys
import subprocess
USER = os.getlogin()
# get the parent directory of the current working directory
from os.path import dirname, abspath
d = dirname(dirname(abspath(__file__)))

sys.path.append(os.path.join(d, "code/scripts"))

import adjust_gday_param_file as ad

__author__  = "Martin De Kauwe"
__version__ = "1.0 (05.08.2016)"
__email__   = "mdekauwe@gmail.com"

def main(site, treatment):

    GDAY_SPIN = "./gday -s -p "
    GDAY = "./gday -p "

    # dir names
    base_dir = os.path.dirname(os.getcwd())
    param_dir = os.path.join(d, "params")
    met_dir = os.path.join(d, "met_data")
    run_dir = os.path.join(d, "outputs")
    
    
    shutil.copy(os.path.join(param_dir, "%s_model_spunup.cfg" % (site)),
                os.path.join(param_dir, "%s_model_transient.cfg" % (site)))

    itag = "%s_model_transient" % (site)
    otag = "%s_model_simulation_%s" % (site, treatment)
    mtag = "%s_met_forcing_transient_%s.csv" % (site, treatment)
    out_fn = "%s_transient_%s.csv" % (site, treatment.upper())
    out_param_fname = os.path.join(param_dir, otag + ".cfg")
    cfg_fname = os.path.join(param_dir, itag + ".cfg")
    met_fname = os.path.join(met_dir, mtag)
    out_fname = os.path.join(run_dir, out_fn)

    replace_dict = {
                     # files
                     "out_param_fname": "%s" % (out_param_fname),
                     "cfg_fname": "%s" % (cfg_fname),
                     "met_fname": "%s" % (met_fname),
                     "out_fname": "%s" % (out_fname),


                     # control
                     "print_options": "annual",

                    }
    ad.adjust_param_file(cfg_fname, replace_dict)
    os.system(GDAY + cfg_fname)


    # add this directory to python search path so we can find the scripts!
    sys.path.append(os.path.join(d, "code/scripts"))
    import translate_GDAY_output_to_NCEAS_format as tr
    # tr.translate_output(out_fname, met_fname)


if __name__ == "__main__":



    site = "Quasi_equil"

    # Ambient
    main(site, treatment="co2_amb")

    # Elevated
    main(site, treatment="co2_ele")
