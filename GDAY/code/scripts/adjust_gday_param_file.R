#### Change various params in a G'DAY input file.
####
#### All that needs to be supplied is a dictionary with the variable to be changed
#### and the corresponding paramter value (oh and of course the param fname!).
####
#### Author: Mingkai Jiang (m.jiang@westernsydney.edu.au)
#### Date Created: Mar-30-2017

################################ Main functions #########################################
adjust_param_file <- function(fname, replacements) {
    #### adjust model parameters in the file and save over the original.
    
    #### Parameters:
    #### ----------
    #### fname : string, parameter filename to be changed.
    #### replacements : dictionary of replacement values.
    
    conn <- file(fname,open="r")
    inParams <- readLines(conn)
    
    for (i in seq_along(inParams)){
        print(paste(i,names(inParams)[i],inParams[[i]]))
        }

    new_str = replace_keys(inParams, replacements)
    fd, path = tempfile.mkstemp()
    os.write(fd, str.encode(new_str))
    os.close(fd)
    shutil.copy(path, fname)
    os.remove(path)
    
    writelines(fout, out_param_fname)
}



replace_keys <- function(text, replacements_dict) {
    #### Function expects to find GDAY input file formatted key = value.
    
    #### Parameters:
    #### ----------
    #### text : string
    #### input file data.
    #### replacements_dict : dictionary
    #### dictionary of replacement values.
    
    #### Returns:
    #### --------
    #### new_text : string
    #### input file with replacement values
    
    
    lines = unlist(strsplit(text, " = "))
    
    for i, row in enumerate(lines):
        # skip blank lines
        if not row.strip():
        continue
    # skip .cfg section dividers
    elif not row.startswith("["):
        key, sep, val = row.split()
    lines[i] = " ".join((key, sep, replacements_dict.get(key, val)))
    elif row.startswith("[print]"):
        break
    
    
    return '\n'.join(lines) + '\n'
}


