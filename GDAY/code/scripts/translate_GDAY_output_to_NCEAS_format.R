#### Quasi-equilibrium Simulations

#### Translate GDAY output file

#### Match the NCEAS format and while we are at it carry out unit conversion so that
#### we matched required standard. Data should be comma-delimited

#### Author: Mingkai Jiang (m.jiang@westernsydney.edu.au)
#### Date Created: Mar-30-2017
##########################################################################################

#################################### Functions ###########################################
def date_converter(*args):
    return dt.datetime.strptime(str(int(float(args[0]))) + " " +\
                                str(int(float(args[1]))), '%Y %j')

def load_met_input_data(fname):
    MJ_TO_MOL = 4.6
SW_TO_PAR = 0.48
DAYS_TO_HRS = 24.0
UMOL_TO_MOL = 1E-6
tonnes_per_ha_to_g_m2 = 100.0

s = remove_comments_from_header(fname)
met_data = pd.read_csv(s, parse_dates=[[0,1]], skiprows=4, index_col=0,
                       sep=",", keep_date_col=True,
                       date_parser=date_converter)

precip = met_data["rain"]
par = (met_data["par_am"] + met_data["par_pm"]) * MJ_TO_MOL
air_temp = met_data["tair"]
soil_temp = met_data["tsoil"]
vpd = (met_data["vpd_am"] + met_data["vpd_pm"]) / 2.0
co2 = met_data["co2"]
ndep = met_data["ndep"] * tonnes_per_ha_to_g_m2

return {'CO2': co2, 'PREC':precip, 'PAR':par, 'TAIR':air_temp, 'TSOIL':soil_temp,
    'VPD':vpd, 'NDEP':ndep}



load_gday_output(fname,git_v) {
    #### To load gday outputs
    
    #### library
    require(data.table)
    
    #### Setting parameters
    SW_RAD_TO_PAR <- 2.3
    UNDEF <- -9999.
    tonnes_per_ha_to_g_m2 <- 100
    yr_to_day <- 365.25
    
    #### getting the git version number
    git_v <- readLines(out_fname, n=1)
    git_v <- gsub("#","",git_v)
    
    #### Read in the gday output file
    out <- fread(out_fname, header=T,sep=",",skip=1) 
    
        year = out["year"]
        doy = out["doy"]
        
        # state outputs
        pawater_root = out["pawater_root"]
        shoot = out["shoot"] * tonnes_per_ha_to_g_m2
        stem = out["stem"] * tonnes_per_ha_to_g_m2
        branch = out["branch"] * tonnes_per_ha_to_g_m2
        fine_root = out["root"] * tonnes_per_ha_to_g_m2
        coarse_root = out["croot"] * tonnes_per_ha_to_g_m2
        coarse_rootn = out["crootn"] * tonnes_per_ha_to_g_m2
        litterc = out["litterc"] * tonnes_per_ha_to_g_m2
        littercag = out["littercag"] * tonnes_per_ha_to_g_m2
        littercbg = out["littercbg"] * tonnes_per_ha_to_g_m2
        soilc = out["soilc"] * tonnes_per_ha_to_g_m2
        lai = out["lai"]
        shootn = out["shootn"] * tonnes_per_ha_to_g_m2
        stemn = out["stemn"] * tonnes_per_ha_to_g_m2
        branchn = out["branchn"] * tonnes_per_ha_to_g_m2
        rootn = out["rootn"] * tonnes_per_ha_to_g_m2
        crootn = out["crootn"] * tonnes_per_ha_to_g_m2
        litternag = out["litternag"] * tonnes_per_ha_to_g_m2
        litternbg = out["litternbg"] * tonnes_per_ha_to_g_m2
        nsoil = out["soiln"] * tonnes_per_ha_to_g_m2
        inorgn = out["inorgn"] * tonnes_per_ha_to_g_m2
        tnc = out["cstore"] * tonnes_per_ha_to_g_m2
        nstorage = out["nstore"] * tonnes_per_ha_to_g_m2
        pstorage = out["pstore"] * tonnes_per_ha_to_g_m2
        activesoiln = out["activesoiln"] * tonnes_per_ha_to_g_m2
        slowsoiln = out["slowsoiln"] * tonnes_per_ha_to_g_m2
        passivesoiln = out["passivesoiln"] * tonnes_per_ha_to_g_m2
        npoolo = activesoiln + slowsoiln + passivesoiln
        shootp = out["shootp"] * tonnes_per_ha_to_g_m2
        stemp = out["stemp"] * tonnes_per_ha_to_g_m2
        branchp = out["branchp"] * tonnes_per_ha_to_g_m2
        rootp = out["rootp"] * tonnes_per_ha_to_g_m2
        crootp = out["crootp"] * tonnes_per_ha_to_g_m2
        litterpag = out["litterpag"] * tonnes_per_ha_to_g_m2
        litterpbg = out["litterpbg"] * tonnes_per_ha_to_g_m2
        psoil = out["soilp"] * tonnes_per_ha_to_g_m2
        inorgp = out["inorgp"] * tonnes_per_ha_to_g_m2
        inorglabp = out["inorglabp"] * tonnes_per_ha_to_g_m2
        inorgsorbp = out["inorgsorbp"] * tonnes_per_ha_to_g_m2
        inorgavlp = out["inorgavlp"] * tonnes_per_ha_to_g_m2
        inorgssorbp = out["inorgssorbp"] * tonnes_per_ha_to_g_m2
        inorgoccp = out["inorgoccp"] * tonnes_per_ha_to_g_m2
        inorgparp = out["inorgparp"] * tonnes_per_ha_to_g_m2
        activesoilp = out["activesoilp"] * tonnes_per_ha_to_g_m2
        slowsoilp = out["slowsoilp"] * tonnes_per_ha_to_g_m2
        passivesoilp = out["passivesoilp"] * tonnes_per_ha_to_g_m2
        ppoolo = activesoilp + slowsoilp + passivesoilp
        
        
        # fluxes outputs
        beta = out["wtfac_root"]
        nep = out["nep"] * tonnes_per_ha_to_g_m2
        gpp = out["gpp"] * tonnes_per_ha_to_g_m2
        npp = out["npp"] * tonnes_per_ha_to_g_m2
        rh = out["hetero_resp"] * tonnes_per_ha_to_g_m2
        ra = out["auto_resp"] * tonnes_per_ha_to_g_m2
        et = out["et"] # mm of water' are same value as kg/m2
        trans = out["transpiration"] # mm of water' are same value as kg/m2
        soil_evap = out["soil_evap"] # mm of water' are same value as kg/m2
        can_evap = out["canopy_evap"] # mm of water' are same value as kg/m2
        runoff = out["runoff"] # mm of water' are same value as kg/m2
        gl = out["cpleaf"] * tonnes_per_ha_to_g_m2
        # gw summed from cpstem and cpbranch below
        cpstem = out["cpstem"] * tonnes_per_ha_to_g_m2
        cpbranch = out["cpbranch"] * tonnes_per_ha_to_g_m2
        gr = out["cproot"] * tonnes_per_ha_to_g_m2
        gcr = out["cpcroot"] * tonnes_per_ha_to_g_m2
        deadleaves = out["deadleaves"] * tonnes_per_ha_to_g_m2
        deadroots = out["deadroots"] * tonnes_per_ha_to_g_m2
        deadcroots = out["deadcroots"] * tonnes_per_ha_to_g_m2
        deadbranch = out["deadbranch"] * tonnes_per_ha_to_g_m2
        deadstems = out["deadstems"] * tonnes_per_ha_to_g_m2
        deadleafn = out["deadleafn"] * tonnes_per_ha_to_g_m2
        deadbranchn = out["deadbranchn"] * tonnes_per_ha_to_g_m2
        deadstemn = out["deadstemn"] * tonnes_per_ha_to_g_m2
        deadrootn = out["deadrootn"] * tonnes_per_ha_to_g_m2
        deadcrootn = out["deadcrootn"] * tonnes_per_ha_to_g_m2
        nup = out["nuptake"] * tonnes_per_ha_to_g_m2
        ngross = out["ngross"] * tonnes_per_ha_to_g_m2
        nmin = out["nmineralisation"] * tonnes_per_ha_to_g_m2
        npleaf = out["npleaf"] * tonnes_per_ha_to_g_m2
        nproot = out["nproot"] * tonnes_per_ha_to_g_m2
        npcroot = out["npcroot"] * tonnes_per_ha_to_g_m2
        npstemimm = out["npstemimm"] * tonnes_per_ha_to_g_m2
        npstemmob = out["npstemmob"] * tonnes_per_ha_to_g_m2
        npbranch = out["npbranch"] * tonnes_per_ha_to_g_m2
        apar = out["apar"] / SW_RAD_TO_PAR
        gcd = out["gs_mol_m2_sec"]
        ga = out["ga_mol_m2_sec"]
        nleach = out["nloss"] * tonnes_per_ha_to_g_m2
        activesoil = out["activesoil"] * tonnes_per_ha_to_g_m2
        slowsoil = out["slowsoil"] * tonnes_per_ha_to_g_m2
        passivesoil = out["passivesoil"] * tonnes_per_ha_to_g_m2
        cfretransn = out["leafretransn"] * tonnes_per_ha_to_g_m2
        deadleafp = out["deadleafp"] * tonnes_per_ha_to_g_m2
        deadbranchp = out["deadbranchp"] * tonnes_per_ha_to_g_m2
        deadstemp = out["deadstemp"] * tonnes_per_ha_to_g_m2
        deadrootp = out["deadrootp"] * tonnes_per_ha_to_g_m2
        deadcrootp = out["deadcrootp"] * tonnes_per_ha_to_g_m2
        pup = out["puptake"] * tonnes_per_ha_to_g_m2
        pgross = out["pgross"] * tonnes_per_ha_to_g_m2
        pmin = out["pmineralisation"] * tonnes_per_ha_to_g_m2
        ppleaf = out["ppleaf"] * tonnes_per_ha_to_g_m2
        pproot = out["pproot"] * tonnes_per_ha_to_g_m2
        ppcroot = out["ppcroot"] * tonnes_per_ha_to_g_m2
        ppstemimm = out["ppstemimm"] * tonnes_per_ha_to_g_m2
        ppstemmob = out["ppstemmob"] * tonnes_per_ha_to_g_m2
        ppbranch = out["ppbranch"] * tonnes_per_ha_to_g_m2
        pleach = out["ploss"] * tonnes_per_ha_to_g_m2
        cfretransp = out["leafretransp"] * tonnes_per_ha_to_g_m2
        
        # extra traceability stuff
        tfac_soil_decomp = out["tfac_soil_decomp"]
        c_into_active = out["c_into_active"] * tonnes_per_ha_to_g_m2
        c_into_slow = out["c_into_slow"] * tonnes_per_ha_to_g_m2
        c_into_passive = out["c_into_passive"] * tonnes_per_ha_to_g_m2
        active_to_slow = out["active_to_slow"] * tonnes_per_ha_to_g_m2
        active_to_passive = out["active_to_passive"] * tonnes_per_ha_to_g_m2
        slow_to_active = out["slow_to_active"] * tonnes_per_ha_to_g_m2
        slow_to_passive = out["slow_to_passive"] * tonnes_per_ha_to_g_m2
        passive_to_active = out["passive_to_active"] * tonnes_per_ha_to_g_m2
        co2_rel_from_surf_struct_litter = out["co2_rel_from_surf_struct_litter"] * tonnes_per_ha_to_g_m2
        co2_rel_from_soil_struct_litter = out["co2_rel_from_soil_struct_litter"] * tonnes_per_ha_to_g_m2
        co2_rel_from_surf_metab_litter = out["co2_rel_from_surf_metab_litter"] * tonnes_per_ha_to_g_m2
        co2_rel_from_soil_metab_litter = out["co2_rel_from_soil_metab_litter"] * tonnes_per_ha_to_g_m2
        co2_rel_from_active_pool = out["co2_rel_from_active_pool"] * tonnes_per_ha_to_g_m2
        co2_rel_from_slow_pool = out["co2_rel_from_slow_pool"] * tonnes_per_ha_to_g_m2
        co2_rel_from_passive_pool = out["co2_rel_from_passive_pool"] * tonnes_per_ha_to_g_m2
        
        # extra priming stuff
        rexc = [UNDEF] * len(doy)
        rexn = [UNDEF] * len(doy)
        co2x = [UNDEF] * len(doy)
        factive = [UNDEF] * len(doy)
        rtslow = [UNDEF] * len(doy)
        rexcue = [UNDEF] * len(doy)
        cslo = out["slowsoil"] * tonnes_per_ha_to_g_m2
        nslo = out["slowsoiln"] * tonnes_per_ha_to_g_m2
        cact = out["activesoil"] * tonnes_per_ha_to_g_m2
        nact = out["activesoiln"] * tonnes_per_ha_to_g_m2
        
        
        # Misc stuff we don't output
        drainage = [UNDEF] * len(doy)
        rleaf = [UNDEF] * len(doy)
        rwood = [UNDEF] * len(doy)
        rcr = [UNDEF] * len(doy)
        rfr = [UNDEF] * len(doy)
        rgrow = [UNDEF] * len(doy)
        rsoil = [UNDEF] * len(doy)
        cex = [UNDEF] * len(doy)
        cvoc = [UNDEF] * len(doy)
        lh = [UNDEF] * len(doy)
        sh = [UNDEF] * len(doy)
        ccoarse_lit = [UNDEF] * len(doy)
        ndw = [UNDEF] * len(doy)
        pclitb = [UNDEF] * len(doy)
        nvol = [UNDEF] * len(doy)
        gb = [UNDEF] * len(doy)
        grepr = [UNDEF] * len(doy)
        cwretransn = [UNDEF] * len(doy)
        ccrretransn = [UNDEF] * len(doy)
        cfrretransn = [UNDEF] * len(doy)
        plretr = [UNDEF] * len(doy)
        pwretr = [UNDEF] * len(doy)
        pcrretr = [UNDEF] * len(doy)
        pfrretr = [UNDEF] * len(doy)
        
        # Misc calcs from fluxes/state
        lma = shoot / lai
        ncon = shootn / shoot
        nflit = litternag + litternbg
        pflit = litterpag + litterpbg
        pcon = shootp / shoot
        recosys = rh + ra
        secp = inorgsorbp + inorgssorbp
        cw = stem + branch
        cwp = stemp + branchp
        gw = cpstem + cpbranch
        cwn = stemn + branchn
        cwin = deadstems + deadbranch
        ccrlin = deadcroots
        cfrlin = deadroots
        ndeadwood = deadbranchn + deadstemn
        pdeadwood = deadbranchp + deadstemp
        nwood_growth = npstemimm + npstemmob + npbranch
        pwood_growth = ppstemimm + ppstemmob + ppbranch
        
        return {'YEAR':year, 'DOY':doy, 'SW':pawater_root, 'SWPA':pawater_root,
            'NEP':nep, 'GPP':gpp, 'NPP':npp, 'CEX':cex, 'CVOC':cvoc,
            'RECO':recosys, 'RAU':ra, 'RL':rleaf, 'RW':rwood,
            'RCR':rcr, 'RFR':rfr,
            'RGR':rgrow, 'RHET':rh, 'RSOIL':rsoil, 'ET':et, 'T':trans,
            'ES':soil_evap, 'EC':can_evap, 'RO':runoff, 'DRAIN':drainage,
            'LE':lh, 'SH':sh, 'CL':shoot, 'CW':cw, 'CCR':coarse_root,
            'CFR':fine_root, 'CSTOR':tnc, 'CFLIT':litterc, 'CFLITA':littercag,
            'CFLITB':littercbg, 'CCLITB':ccoarse_lit, 'CSOIL':soilc,
            'CGL':gl, 'CGW':gw, 'CGCR':gcr, 'CGFR':gr, 'CREPR':grepr, 'CLITIN':deadleaves,
            'CCRLIN':ccrlin, 'CFRLIN':cfrlin, 'CWLIN':cwin, 'LAI':lai, 'LMA':lma, 'NCON':ncon,
            'NL':shootn, 'NW':cwn, 'NCR':coarse_rootn, 'NFR':rootn,
            'NSTOR':nstorage, 'NFLIT': nflit, 'NFLITA':litternag, 'NFLITB':litternbg, 'NCLITB':ndw,
            'NSOIL':nsoil, 'NPMIN':inorgn, 'NPORG':npoolo, 
            'NGL':npleaf, 'NGW':nwood_growth, 'NGCR':npcroot, 'NGFR':nproot,
            'NLITIN':deadleafn, 'NCRLIN':deadcrootn,
            'NFRLIN':deadrootn, 'NWLIN':ndeadwood, 'NUP':nup,
            'NGMIN':ngross, 'NMIN':nmin, 'NVOL': nvol, 'NLEACH':nleach,
            'NLRETR':cfretransn, 'NWRETR':cwretransn,
            'NCRRETR':ccrretransn, 'NFRRETR':cfrretransn,
            'APARd':apar, 'GCd':gcd, 'GAd':ga, 'Gbd':gb, 'Betad':beta,
            'PL':shootp, 'PW':cwp,
            'PCR':crootp, 'PFR':rootp,
            'PSTOR':pstorage, 'PFLIT':pflit,
            'PFLITA':litterpag, 'PFLITB':litterpbg, 'PCLITB':pclitb,
            'PSOIL':psoil, 'PLAB':inorglabp,
            'PSEC':secp, 'POCC':inorgoccp,
            'PPAR':inorgparp,
            'PPMIN':inorgp, 'PPORG':ppoolo,
            'PLITIN':deadleafp, 'PCRLIN':deadcrootp,
            'PFRLIN':deadrootp, 'PWLIN':pdeadwood, 'PUP':pup,
            'PGMIN':pgross, 'PMIN':pmin, 'PLEACH':pleach,
            'PGL':ppleaf, 'PGW':pwood_growth, 'PGCR':ppcroot, 'PGFR':pproot,
            'PLRETR':cfretransp, 'PWRETR':pwretr, 'PFRRETR':pcrretr, 'PFRRETR':pfrretr, 
            'CTOACTIVE':c_into_active, 'CTOSLOW':c_into_slow,
            'CTOPASSIVE':c_into_passive, 'CACTIVETOSLOW':active_to_slow,
            'CACTIVETOPASSIVE':active_to_passive, 'CSLOWTOACTIVE':slow_to_active,
            'CSLOWTOPASSIVE':slow_to_passive, 'CPASSIVETOACTIVE':passive_to_active,
            'CACTIVE':activesoil, 'CSLOW':slowsoil, 'CPASSIVE':passivesoil,
            'CO2SLITSURF':co2_rel_from_surf_struct_litter,
            'CO2SLITSOIL':co2_rel_from_soil_struct_litter,
            'CO2MLITSURF':co2_rel_from_surf_metab_litter,
            'CO2MLITSOIL':co2_rel_from_soil_metab_litter,
            'CO2FSOM':co2_rel_from_active_pool,
            'CO2SSOM':co2_rel_from_slow_pool,
            'CO2PSOM':co2_rel_from_passive_pool,
            'TFACSOM':tfac_soil_decomp,
            'REXC':rexc,
            'REXN':rexn,
            'CO2X':co2x,
            'FACTIVE':factive,
            'RTSLOW':rtslow,
            'REXCUE':rexcue,
            'CSLO':cslo,
            'NSLO':nslo,
            'CACT':cact,
            'NACT':nact}, git_ver
}



get_header_info <- function() {
    #### read in the csv file that contains the header information
    
    ### updating the directory path
    d <- dirname(dirname(getwd())) 
    
    ### sourcing the header file
    hDF <- read.table(paste0(d, "/code/scripts/header_file.csv"),
                      header=T,sep=",")

    return(hDF)
}

translate_output <- function(infname, outdir) {

    ### Read in the header file
    h <- get_header_info()
    units <- h[,"units.list"]
    variable <- h[,"variable"]
    variable_names <- h[,"variable_names"]
    
    #### set parameters
    UNDEF <- -9999.
    git_ver <- NA
    
    #### load the rest of the gday output
    
    
        # load the rest of the g'day output
        (gday, git_ver) = load_gday_output(infname, git_ver)
        
        # merge dictionaries to ease output
        data_dict = dict(envir, **gday)
        
        ofname = os.path.join(outdir, "temp.nceas")
        f = open(ofname, "w")
        f.write("%s" % (git_ver))
        
        # write output in csv format
        writer = csv.writer(f, dialect=csv.excel, lineterminator="\n")
        writer.writerow(variable)
        writer.writerow(units)
        writer.writerow(variable_names)
        for i in range(len(gday['DOY'])):
            writer.writerow([("%.8f" % (float(data_dict[k][i])) \
                              if k in data_dict else UNDEF)
                             for k in variable_names])
        
        # Need to replace the temp file with the infname which is actually
        # the filename we want to use
        shutil.move(ofname, infname)
}

#################################### Program ###########################################

translate_output(fname,run_dir)
