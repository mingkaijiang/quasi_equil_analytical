# Quasi-equilibrium analysis of plant response to eCO2

This is a repository for evaluating carbon response to eCO2 by incorporating different model assumptions and evaluating their consequences dynamically and analytically. More background information please read McMurtrie and Comins (1993). 

# Code structure:
Script Run_prorgams.R contains the master-level executable commands. 
Folder Functions includes all analytical functions and the post-processing scripts
Folder GDAY includes numerous sub-folders:
1. analyses include all the analyses output
2. code include the simplified GDAY code (in language C)
3. met_data contains driving met data
4. outputs contains all the gday simulation output data
5. params contains the parameter files
6. post_processing contains the R code to post-process the simulations
7. pre_processing contains the R code to pre-process the simulations (e.g. generating met data)
8. simulations contains the gday executive program and the python code to run the simulations

# GDAY model framework
<p style="text-align:center"><img src="GDAY/code/doc/outline.png" width="700"/></p>

# Key references:
(more to be added)
Quasi-equilibrium analysis:
Comins and McMurtrie (1993)
Kirschbaum et al. (1994)
Kirschbaum et al. (1998)
etc.

Key model assumptions:
Reich et al. (2008)

GDAY model:


Contact Mingkai Jiang for more information (m.jiang@westernsydney.edu.au).
