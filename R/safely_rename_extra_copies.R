safely_rename_extra_copies <- function(folder, test_run = TRUE) {
  
  ALL_FILES = list.files(path = folder, full.names = TRUE, recursive = TRUE, all.files = TRUE, include.dirs = TRUE, pattern = " \\([2-9]\\)")
  # SLOWER: ALL_FILES2 = system2(command = 'find', args = c(folder, '-type f', '-regex ".* ([2-9]).*"'), stdout = TRUE)
  
  DF = ALL_FILES %>% 
    as_tibble() %>% 
    mutate(REPLACEMENT = gsub("(.?) \\([0-9]\\)(\\.?)", "\\1\\2", value),
           REPLACEMENT_CONFLICT = file.exists(REPLACEMENT)) %>% 
    filter(REPLACEMENT_CONFLICT == FALSE)
   
  if (nrow(DF) == 0) {
    
    cli::cli_alert_success("No files or folders to rename!")
    
  } else {
    
    cli::cli_h1("We can safely rename {nrow(DF)} files and folders")
    if (test_run == FALSE) {
      file.rename(from = DF$value, to = DF$REPLACEMENT)
      cli::cli_alert_success("{nrow(DF)} files and folders renamed")  
    } else {
      cli::cli_alert_info("THIS WAS A TEST RUN, so nothing was actually done! :)")  
    }
    
    DT::datatable(DF)
    
  }
  
}