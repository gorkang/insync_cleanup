#' compare_hashes
#' the function will compare two folders and give a list of files in the 
#' ^OLD_PATH that can safely be deleted (have an exact replica in NEW_PATH)
#'
#' @param NEW_PATH 
#' @param OLD_PATH path for files that can probably be deleted
#' @param label 
#'
#' @return
#' @export
#'
#' @examples
compare_hashes <- function(NEW_PATH, OLD_PATH, label = "") {
  
  # TODO: 
  # - hash in parallel?  # test_hashing_parallel.R
  # ADD date to output files
  
  # DEBUG
  # NEW_PATH = "/home/rut/rutcorreia@gmail.com/"
  # OLD_PATH = "/home/rut/rutcorreia@gmail.com_CS/"
  # label = "rut"
  
  library(tidyverse)
  if (!require('parallel')) install.packages('parallel')
  options(Ncpus = parallel::detectCores() - 2)
  

  # LIST files --------------------------------------------------------------

  cli::cli_alert_info("Looking for files in both folders")
  
  NEW_FILES = list.files(path = NEW_PATH, full.names = TRUE, recursive = TRUE, all.files = TRUE, include.dirs = FALSE) %>% as_tibble()
  OLD_FILES = list.files(path = OLD_PATH, full.names = TRUE, recursive = TRUE, all.files = TRUE, include.dirs = FALSE) %>% as_tibble()
  
  all_files_n = nrow(OLD_FILES) + nrow(NEW_FILES)
  minutes_estimated = round((all_files_n * 0.0028) / 60, 2)
  
  cli::cli_alert_info("You have: \n - {nrow(NEW_FILES)} files in {NEW_PATH}\n - {nrow(OLD_FILES)} files in {OLD_PATH}")
  
  if (all_files_n > 1000) cli::cli_alert_warning("Hashing all those files will take a while (around {minutes_estimated} minutes)")
  

  # HASH files --------------------------------------------------------------

  cli::cli_alert_info("Hashing {nrow(NEW_FILES)} files in {NEW_PATH}")
  tictoc::tic()
  NEW_hash = NEW_FILES %>% mutate(HASH = tools::md5sum(value))
  data.table::fwrite(NEW_hash, paste0("outputs/compare_hashes_", label ,"_NEW_hashed.csv.gz"))
  
  cli::cli_alert_info("Hashing {nrow(OLD_FILES)} files in {OLD_PATH}")
  OLD_hash = OLD_FILES %>% mutate(HASH = tools::md5sum(value))
  data.table::fwrite(OLD_hash, paste0("outputs/compare_hashes_", label ,"_OLD_hashed.csv.gz"))
  tictoc::toc()
  

  # FILTER files to delete --------------------------------------------------

  DELETE_FILES = OLD_hash %>% filter(HASH %in% NEW_hash$HASH)
  data.table::fwrite(DELETE_FILES, paste0("outputs/compare_hashes-", label ,"-DELETE_FILES.csv.gz"))
  
  cli::cli_alert_info("We found {nrow(DELETE_FILES)} files in {OLD_PATH} that you can safely delete")
  cli::cli_alert_info("To delete the files you can do `file.remove(DELETE_FILES$value)`")
  # DT::datatable(DELETE_FILES)
  
  return(DELETE_FILES)
  # DELETE_FILES = fread("outputs/compare_hashes_rut_DELETE_FILES.csv.gz")
  
  # Delete old files that have an identical copy
  # file.remove(DELETE_FILES$value)
}