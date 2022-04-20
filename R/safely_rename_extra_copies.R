# RENAMES ONLY files that have the (2) when there is no CANONICAL file in the same location
safely_rename_extra_copies <- function(folder, test_run = TRUE, after) {
  
  ALL_FILES = list.files(path = folder, full.names = TRUE, recursive = TRUE, all.files = TRUE, include.dirs = TRUE, pattern = " \\([2-9]\\)")
  # SLOWER: ALL_FILES2 = system2(command = 'find', args = c(folder, '-type f', '-regex ".* ([2-9]).*"'), stdout = TRUE)
  
  DF = ALL_FILES %>% 
    as_tibble() %>% 
    mutate(REPLACEMENT = gsub("(.?) \\([0-9]\\)(\\.?)", "\\1\\2", value),
           REPLACEMENT_CONFLICT = file.exists(REPLACEMENT)) %>% 
    filter(REPLACEMENT_CONFLICT == FALSE)
  
  # Check if we have more coincidences in the replacement names!
  REPEATED_REPLACEMENTS = DF %>% count(REPLACEMENT) %>% filter(n > 1)
   
  if (nrow(REPEATED_REPLACEMENTS) > 0) {
    # DT::datatable(DF %>% filter(REPLACEMENT %in% REPEATED_REPLACEMENTS$REPLACEMENT))
    DF = DF %>% mutate(REPLACEMENT_CONFLICT = 
                    case_when(
                      REPLACEMENT %in% REPEATED_REPLACEMENTS$REPLACEMENT ~ "overlap in REPLACEMENT",
                      TRUE ~ NA_character_)) %>% 
      select(value, REPLACEMENT, REPLACEMENT_CONFLICT)
    cli::cli_alert_danger("Some of the replacements are equal!")  
    
  }
  
  if (nrow(DF) == 0) {
    
    cli::cli_alert_success("No files or folders to rename!")
    
  } else {
    
    DF_to_rename = DF %>% filter(is.na(REPLACEMENT_CONFLICT))
    
    cli::cli_h1("We can safely rename {nrow(DF_to_rename)} files and folders")
    if (test_run == FALSE) {
      file.rename(from = DF_to_rename$value, to = DF_to_rename$REPLACEMENT)
      cli::cli_alert_success("{nrow(DF_to_rename)} files and folders renamed")  
    } else {
      cli::cli_alert_info("THIS WAS A TEST RUN, so nothing was actually done! :)")  
    }
    
    DT::datatable(DF)
    
  }
  
}