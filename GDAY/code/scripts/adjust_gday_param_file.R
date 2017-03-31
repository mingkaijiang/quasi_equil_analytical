#### Change various params in a G'DAY input file.
####
#### All that needs to be supplied is a dictionary with the variable to be changed
#### and the corresponding paramter value (oh and of course the param fname!).
####
#### Author: Mingkai Jiang (m.jiang@westernsydney.edu.au)
#### Date Created: Mar-30-2017

################################ Main functions #########################################

if (!require("ini")){
    install.packages("ini")
    library(ini)
}


adjust_param_file <- function(fname, oname, replacements) {
    #### adjust model parameters in the file and save over the original.
    
    #### Parameters:
    #### ----------
    #### fname : string, parameter filename to be changed.
    #### replacements : dictionary of replacement values.
    
    inParams <- readLines(fname)

    #### Transform replacement file into dataframe
    even <- seq(2, length(replacements), by=2)
    odd <- seq(1, length(replacements)-1, by=2)
    rDF <- cbind(replacements[odd], replacements[even])
    rDF <- as.data.frame(rDF)

    new_str = replace_keys(inParams, rDF)
    
    writeLines(new_str, fname)
    writeLines(new_str, oname)
}


replace_keys <- function(text, rDF) {
    #### Function expects to find GDAY input file formatted key = value.
    
    #### Parameters:
    #### ----------
    #### text : string
    #### input file data.
    #### rDF : replacement df
    
    #### Returns:
    #### --------
    #### out : string, input file with replacement values
    
    #### Finding the locations of the category names
    git_l <- which(text == "[git]")
    files_l <- which(text == "[files]")
    params_l <- which(text == "[params]")
    state_l <- which(text == "[state]")
    control_l <- which(text == "[control]")
    
    #### unlist the original parameter file
    # lines <- unlist(strsplit(text, " = "))
    
    #### Split the original file into different categories
    git_g <- text[2:(files_l-1)]
    files_g <- text[(files_l+1):(params_l-1)]
    params_g <- text[(params_l+1):(state_l-1)]
    state_g <- text[(state_l+1):(control_l-1)]
    control_g <- text[(control_l+1):length(text)]
    
    #### unlist all the groups except control
    git_u <- unlist(strsplit(git_g, " = "))
    files_u <- unlist(strsplit(files_g, " = "))
    params_u <- unlist(strsplit(params_g, " = "))
    state_u <- unlist(strsplit(state_g, " = "))
    
    #### assign replacement parameters onto each subgroups
    for (i in 1:length(rDF$V1)){
        ### Grep through the subgroups
        ### when a match is found, insert the value to the subsequent cell 
        git_u[grep(x=git_u, pattern = paste0("\\b",rDF$V1[[i]], "\\b"))+1] <- as.character(rDF[i,"V2"])
        files_u[grep(x=files_u, pattern = paste0("\\b",rDF$V1[[i]], "\\b"))+1] <- as.character(rDF[i,"V2"])
        params_u[grep(x=params_u, pattern = paste0("\\b",rDF$V1[[i]], "\\b"))+1] <- as.character(rDF[i,"V2"])
        state_u[grep(x=state_u, pattern = paste0("\\b",rDF$V1[[i]], "\\b"))+1] <- as.character(rDF[i,"V2"])
    }
    
    #### add back the equal signs 
    git_o <- add_equal_sign(git_u)
    files_o <- add_equal_sign(files_u)
    params_o <- add_equal_sign(params_u)
    state_o <- add_equal_sign(state_u)

    #### Add all arrays back together
    out <- c(text[git_l], git_o, "",
                text[files_l], files_o, "",
                text[params_l], params_o, "",
                text[state_l], state_o, "",
                text[control_l], control_g)
    
    return(out)
}


add_equal_sign <- function(inF) {
    
    ## get even and odd numbers
    even <- seq(2, length(inF), by=2)
    odd <- seq(1, length(inF)-1, by=2)
    
    outF <- paste0(inF[odd], " = ", inF[even])
    
    return(outF)
}

adjust_gday_params <- function(in_fname, replacements) {
    
    g <- read.ini(in_fname)
    
    for (key in names(replacements)) {
        
        match_git <- key %in% names(g$git)
        match_files <- key %in% names(g$files)
        match_params <- key %in% names(g$params)
        match_state <- key %in% names(g$state)
        match_control <- key %in% names(g$control)
        
        if (match_git) {
            g$git[key] <- as.character(replacements[1,key])
        } else if (match_files) {
            g$files[key] <- as.character(replacements[1,key])
        } else if (match_params) {
            g$params[key] <- as.character(replacements[1,key])
        } else if (match_state) {
            g$state[key] <- as.character(replacements[1,key])
        } else if (match_control) {
            g$control[key] <- as.character(replacements[1,key])
        }
        
    }
    
    write.ini(g, in_fname)
    #write.ini(g, out_fname)
}

make_df <- function(inDF) {
    
    even <- seq(2, length(inDF), by=2)
    odd <- seq(1, length(inDF)-1, by=2)
    oDF <- t(cbind(inDF[odd], inDF[even]))
    oDF <- as.data.frame(oDF)
    colnames(oDF) <- as.character(unlist(oDF[1,]))
    oDF<-oDF[-1,]
    
    return(oDF)
}
