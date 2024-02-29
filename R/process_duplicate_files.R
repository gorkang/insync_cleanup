process_duplicate_files <- function(DF_all, folder, destination = "~/Downloads/INSYNC/FILES") {

  DF_all <- lazy_dt(DF_all) # USE dtplyr to do this step with data.table. From 16 to 5 seconds
  
  duplicate_files = DF_all %>% 
    select(full_filename, ID_file) %>% 
    distinct(full_filename, .keep_all = TRUE) %>%  # One row for each full_filename
    count(ID_file) %>%   # How many instances of ID_file (common file root without (2)'s)
    filter(n > 1) %>% 
    pull(ID_file)

    
  if (length(duplicate_files) == 0) {
    
    cli::cli_alert_success(paste0("No duplicates found! ", praise::praise()))
    DF_all_files_processed = NULL
    DF_duplicate_files = NULL
    
  } else {
    
    cli::cli_alert_info("\nComputing {length(duplicate_files)} HASHES... it will take a while... [ESC to abort]\n\n")
    
    DF_duplicate_files = DF_all %>% 
      filter(ID_file %in% duplicate_files) %>% 
      dplyr::as_tibble() |> 
      dplyr::rowwise() |> # for secretbase::sha3()
      mutate(
        # HASH = tools::md5sum(full_filename),
        HASH = secretbase::sha3(full_filename),
        
        ID = paste0(HASH, "_", ID_file)) %>%  # We need an UNIQUE ID. Even if the file is in another folder,
      as_tibble() # Go back to tibble as data.table fail in the next split
    
    # Split DF by folder and then file
    
    # Split by full_folder so we only compare duplicated files in the same folder!!!
    DF_folders_split1 = split(DF_duplicate_files, DF_duplicate_files$full_folder) 
    
    # Inside each folder, split by clean_filename and flatten to get a single list
    DF_folders_split2 = 1:length(DF_folders_split1) %>% 
      map(~ split(DF_folders_split1[[.x]], DF_folders_split1[[.x]]$clean_filename)) %>% 
      flatten()
    
    # Inside each file, split by HASH and flatten. If not, when there are many different dups inside a file, we miss them
    DF_folders_split = 
      1:length(DF_folders_split2) %>% 
      map(~ split(DF_folders_split2[[.x]], DF_folders_split2[[.x]]$ID)) %>% 
      flatten()
    
    
    # DUPLICATED FILES ----------------------------------------------------------
      
      WHITELIST = DF_folders_split %>% 
        bind_rows() %>% 
        group_by(ID) %>% 
        summarise(N = n(), .groups = "drop") %>% 
        filter(N > 1) 
    
    if (length(WHITELIST$ID) == 0) {
      
      cli::cli_alert_success(paste0("No duplicates found! ", praise::praise()))
      
      DF_all_files_processed = 
        list(DF_CANONICALS = NULL,
             DF_TO_DELETE = NULL,
             DT_delete = NULL)
      
    } else {
      
      DF_final = 
        WHITELIST$ID %>% 
        purrr::set_names() %>% 
        purrr::map(~ 
                     {
                       # .x = WHITELIST[1]
                       
                       TEMP = DF_folders_split[[.x]] %>%
                         mutate(
                           # HASH = last(names(DF_folders_split[[.x]])),
                                raw_filename = basename(full_filename),
                                CANONICAL = 
                                  case_when(
                                    !grepl("\\([0-9]\\)", basename(full_filename)) ~ "CANONICAL",
                                    TRUE ~ "NOPE"
                                  )) %>%
                         select(raw_filename, clean_filename, full_filename, date, size, ID_file, ID, CANONICAL)
                       
                       # Randomly choose one to be the canonical
                       if (length(unique(TEMP$CANONICAL)) == 1) {
                         TEMP$CANONICAL[sample(1:nrow(TEMP), 1)] = "CANONICAL"
                       }
                       
                       # cat(unique(TEMP$HASH), unique(TEMP$raw_filename), "\n")  
                       TEMP 
                       
                       
                       
                     }
                   
        )
      
      DF_CANONICALS =
        DF_final %>% bind_rows() %>% 
        select(full_filename, ID_file, date, size, CANONICAL) %>% distinct(full_filename, .keep_all = TRUE) %>%
        filter(CANONICAL == "CANONICAL") %>% 
        mutate(DESTINATION = gsub(destination, paste0(destination, "/CANONICAL/"), gsub(folder, destination, full_filename)))
  
      DF_TO_DELETE =
        DF_final %>% bind_rows() %>% 
        select(full_filename, ID_file, date, size, CANONICAL) %>% distinct(full_filename, .keep_all = TRUE) %>%
        filter(CANONICAL != "CANONICAL") %>% 
        mutate(DESTINATION = gsub(destination, paste0(destination, "/DUPLICATES/"), gsub(folder, destination, full_filename)))
      # DELETE_name_terminal = gsub(" ", "\\\\ ", full_filename) %>% gsub("\\(", "\\\\(", .) %>% gsub("\\)", "\\\\)", .), # If need to do something via terminal
      
  
      DF_ALL = DF_CANONICALS %>% right_join(DF_TO_DELETE, by = "ID_file")
      
          
      # Final DFs ---------------------------------------------------------------
      
      # ADD CHECK. Each element of list should have at least two rows
    
      DT_delete = DT::datatable(DF_TO_DELETE %>% mutate(filename = basename(full_filename)) %>%  select(filename, full_filename, ID_file, DESTINATION))
      DT_all = DT::datatable(DF_ALL)
      
  
      DF_all_files_processed = 
        list(DF_CANONICALS = DF_CANONICALS,
             DF_TO_DELETE = DF_TO_DELETE,
             DF_duplicate_files = DF_duplicate_files,
             DT_delete = DT_delete,
             DT_all = DT_all)
      
    }
    
      return(DF_all_files_processed)
  
  }  
  
}
