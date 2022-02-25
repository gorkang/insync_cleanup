prepare_files <- function(input_files) {
  
  cli::cli_alert_info("\nChecking {format(as.numeric(length(input_files)), big.mark = ',')} files and folders. it will take a while... [ESC to abort]\n\n")
  
  now_str = Sys.time()
  
  DF_all = input_files %>% as_tibble() %>%
    mutate(date = now_str,
           size = file.size(value),
           is_folder = file_test("-d", value)) %>% 
    mutate(filename = 
             case_when(
               is_folder == FALSE ~ basename(value),
               is_folder == TRUE ~ NA_character_
               ),
           clean_filename = gsub("(.?) \\([0-9]\\)(\\.?)", "\\1\\2", filename),
           full_folder = 
             case_when(
               is_folder == FALSE ~ dirname(value),
               is_folder == TRUE ~ value
             ),
           folder = basename(full_folder),
           clean_filename = gsub("(.?) \\([0-9]\\)(\\.?)", "\\1\\2", filename),
           ID_folder = gsub("(.?) \\([0-9]\\)(\\.?)", "\\1\\2", full_folder), 
           ID_file = paste0(full_folder, "/", clean_filename)) %>% 
    rename(full_filename = value)
  
  return(DF_all)
  
}