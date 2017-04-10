
#### Delete raw GDAY output files to save space as they are large 
####
#### 
################################################################################

delete_output_folder <- function() {
    
    f.list <- list.files(path=paste0(getwd(), "/GDAY/outputs"))
    
    for (i in f.list) {
        filePath <- paste0(getwd(), "/GDAY/outputs/", i, "/")
        dcommand <- paste0("rm -f ", filePath, "*")
        
        system(dcommand)
    }
}

################################################################################
delete_output_folder()

