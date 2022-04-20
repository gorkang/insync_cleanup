# Looks for duplicate files regardless of the folder they are in. Very time consuming, and not all duplicates are unintentional. Some are copies made because of reasons! :)

process_global_duplicate_files <- function(DF_all) {
  
  DF_all <- lazy_dt(DF_all) # USE dtplyr to do this step with data.table. From 16 to 5 seconds
  
  clean_filename_duplicate_files = 
    DF_all %>% 
    filter(size > 10) %>% # Avoid 1 char files 
    select(full_filename, ID_file, clean_filename) %>% 
    filter(!grepl(".Rproj.user", full_filename)) %>% # LOTS of trivial duplicate files inside
    distinct(full_filename, .keep_all = TRUE) %>%  # One row for each full_filename
    count(clean_filename) %>%   # How many instances of ID_file (common file root without (2)'s)
    filter(n > 1) %>% 
    pull(clean_filename)
  
  duplicate_files = DF_all %>% 
    filter(clean_filename %in% clean_filename_duplicate_files) %>% 
    pull(ID_file)
  
  if (length(duplicate_files) == 0) {
    
    cli::cli_alert_success(paste0("No duplicates found! ", praise::praise()))
    DF_all_files_processed = NULL
    DF_duplicate_files = NULL
    
  } else {
    
    cli::cli_alert_info("\nComputing {length(duplicate_files)} HASHES... it will take a while... [ESC to abort]\n\n")
    
    DF_duplicate_files = DF_all %>% 
      filter(ID_file %in% duplicate_files) %>% 
      mutate(HASH = tools::md5sum(full_filename),
             ID = paste0(HASH, "_", ID_file)) %>%  # We need an UNIQUE ID. Even if the file is in another folder,
      as_tibble() # Go back to tibble as data.table fail in the next split

    # Split DF by HASH to get the duplicates together no matter where they are
      # REMEMBER: some of the copies are legitimate
    DF_folders_split_HASH = split(DF_duplicate_files, DF_duplicate_files$HASH) 

    WHITELIST = 
    DF_duplicate_files %>%
      count(HASH) %>%
      filter(n > 1)
    
    # DUPLICATED FILES ----------------------------------------------------------
    
    WHITELIST = DF_folders_split_HASH %>% 
      bind_rows() %>%
      group_by(HASH) %>% 
      summarise(N = n(), .groups = "drop") %>% 
      filter(N > 1) 
    
    if (length(WHITELIST$HASH) == 0) {
      
      cli::cli_alert_success(paste0("No duplicates found! ", praise::praise()))
      
      DF_all_files_processed = 
        list(DF_CANONICALS = NULL,
             DF_TO_DELETE = NULL,
             DT_delete = NULL)
      
    } else {
      
      # Get only lists where we have duplicates
      DF_final = DF_folders_split_HASH[names(DF_folders_split_HASH) %in% WHITELIST$HASH]  
      
      # DF_final = 
      #   WHITELIST$HASH %>% 
      #   purrr::set_names() %>% 
      #   purrr::map(~ 
      #                {
      #                  # .x = WHITELIST[1]
      #                  
      #                  TEMP = DF_folders_split_HASH[[.x]] %>%
      #                    mutate(
      #                      # HASH = last(names(DF_folders_split[[.x]])),
      #                      raw_filename = basename(full_filename),
      #                      CANONICAL = 
      #                        case_when(
      #                          !grepl("\\([0-9]\\)", basename(full_filename)) ~ "CANONICAL",
      #                          TRUE ~ "NOPE"
      #                        )) %>%
      #                    select(raw_filename, clean_filename, full_filename, date, size, ID_file, ID, HASH, CANONICAL)
      #                  
      #                  # Randomly choose one to be the canonical
      #                  if (length(unique(TEMP$CANONICAL)) == 1) {
      #                    TEMP$CANONICAL[sample(1:nrow(TEMP), 1)] = "CANONICAL"
      #                  }
      #                  
      #                  # cat(unique(TEMP$HASH), unique(TEMP$raw_filename), "\n")  
      #                  TEMP 
      #                  
      #                  
      #                  
      #                }
      #              
      #   )
      
      # DF_CANONICALS =
      #   DF_final %>% bind_rows() %>% 
      #   select(full_filename, ID_file, date, size, CANONICAL) %>% distinct(full_filename, .keep_all = TRUE) %>%
      #   filter(CANONICAL == "CANONICAL") %>% 
      #   mutate(DESTINATION = gsub(destination, paste0(destination, "/CANONICAL/"), gsub(folder, destination, full_filename)))
      # 
      # DF_TO_DELETE =
      #   DF_final %>% bind_rows() %>% 
      #   select(full_filename, ID_file, date, size, CANONICAL) %>% distinct(full_filename, .keep_all = TRUE) %>%
      #   filter(CANONICAL != "CANONICAL") %>% 
      #   mutate(DESTINATION = gsub(destination, paste0(destination, "/DUPLICATES/"), gsub(folder, destination, full_filename)))
      # # DELETE_name_terminal = gsub(" ", "\\\\ ", full_filename) %>% gsub("\\(", "\\\\(", .) %>% gsub("\\)", "\\\\)", .), # If need to do something via terminal
      
      
      # DF_ALL = DF_CANONICALS %>% right_join(DF_TO_DELETE, by = "ID_file")
      
      
      # Final DFs ---------------------------------------------------------------
      
      # ADD CHECK. Each element of list should have at least two rows
      
      # DT_delete = DT::datatable(DF_TO_DELETE %>% mutate(filename = basename(full_filename)) %>%  select(filename, full_filename, ID_file, DESTINATION))
      # DT_all = DT::datatable(DF_ALL)
      
      
      DF_all_duplicates = DF_final
      
    }
    
    return(DF_all_duplicates)
    
  }  
  
}
