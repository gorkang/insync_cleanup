process_duplicate_folders <- function(DF_all, folder, destination = "~/Downloads/INSYNC/FOLDERS") {
  
  # DEBUG
  # jsPsychR::debug_function("process_duplicate_folders")
# targets::tar_load_globals()
  
  cli::cli_alert_info("\nChecking duplicate folders. it will take a while... [ESC to abort]\n\n")
  
  DF_all <- lazy_dt(DF_all) # USE dtplyr to do this step with data.table. From 16 to 5 seconds
  
  duplicate_folders = DF_all %>% 
    distinct(full_folder, .keep_all = TRUE) %>% # One row for each unique folder
    count(ID_folder) %>% # How many instances of ID_folder (common folder root without (2)'s)
    filter(n > 1) %>% pull(ID_folder)
  
  
  if (length(duplicate_folders) == 0) {
    
    cli::cli_alert_success(paste0("No duplicate folders found! ", praise::praise()))
    DF_all_folders_processed = NULL
    
  } else {
    
    cli::cli_alert_info("\nComputing {length(duplicate_folders)} HASHES... it will take a while... [ESC to abort]\n\n")
    
    # Separate folders from files because HASH does not work on folders
    DF_duplicate_files_temp = 
      DF_all %>% 
      filter(ID_folder %in% duplicate_folders & is_folder == FALSE) %>% 
      mutate(HASH = tools::md5sum(full_filename),
             ID = paste0(HASH, "_", ID_file)) # We need an UNIQUE ID. Even if the file is in another folder,
    
    DF_duplicate_folders_temp = 
      DF_all %>% 
      filter(ID_folder %in% duplicate_folders & is_folder == TRUE) %>% 
      mutate(HASH = full_filename,
             ID = paste0(HASH, "_", ID_file)) # We need an UNIQUE ID. Even if the file is in another folder,
      
    DF_duplicate_folders = 
      DF_duplicate_files_temp %>% as_tibble() %>% # Go back to tibble as data.table fails in bind_rows
      bind_rows(DF_duplicate_folders_temp %>% as_tibble()) # Go back to tibble as data.table fails in bind_rows
    
    
    # Split by ID_folder, so we can compare all the variants of the same folder in the same subfolder
    DF_folders_split1 = DF_duplicate_folders %>% split(DF_duplicate_folders$ID_folder)
    
    
    # WIDE version ------------------------------------------------------------
    
    # CHECK specific file
    # DF_folders_split1[[1]] %>% select(-full_filename, -full_folder, -ID_file, -ID) %>% pivot_wider(names_from = folder, values_from = filename, values_fn = list) %>% View
    
    # Allows to compare the different files in each of the duplicate folders
    DF_folders_split = 
      purrr::map(DF_folders_split1,
                 {
                   # DF_folders_split1[[25]] %>%
                  . %>%
                   select(-full_filename, -full_folder, -ID_file, -ID) %>%
                   pivot_wider(names_from = folder, values_from = filename, values_fn = list) 
                 }
      )
  
    # IF columns > 6 and NO NULLS. perfect replicas
    # IF columns > 6 and SOME NULLS. 
      # - IF all nulls in one of the folders, that is the NON-canonical

    # For each unique folder, calculate parameters. We will use these parameter to filter and get specific folders from DF_folders_split_wide
    # 5 columns means parent folder is the duplicate (we pivot_wider using folder, if folder is the same, all filenames will be in a single column)
    # 6 or more folder means this is the duplicate folder
    # number of rows is number of files in folder
    # NAs should be 0. If >0 means there are NON-duplicate files in this duplicate folder?
    
    DF_final_temp =
      names(DF_folders_split) %>% 
      purrr::set_names() %>% 
      purrr::map( ~
                       {
                         
                         # Simple case
                         # .x = names(DF_folders_split)[1]
                         
                         # TOO COMPLEX
                         # .x = names(DF_folders_split)[8]

                         # SHOULD CHOOSE NON NULL
                         # .x = names(DF_folders_split)[25]
                         
                         # EMPTY FOLDERS

                         # DF_folders_split[[.x]] %>% View
                         
                        initial_column = which(names(DF_folders_split[[.x]]) == "HASH") + 1
                         
                        TEMP = DF_folders_split[[.x]] %>%
                          filter(is_folder == FALSE) # Get rid of folder, as we are checking if files are in folders
                          
                        if (nrow(TEMP) == 0) {
                          
                          # If there are only empty FOLDERS 
                          TEMP1 = DF_folders_split[[.x]] %>% pivot_longer(all_of(initial_column):ncol(DF_folders_split[[.x]]), names_to = "raw_folder", values_to = "values") %>% 
                            rowwise() %>% 
                            mutate(values = ifelse(is.null(values[[1]]), NA, values[[1]]))
                          # TEMP2 = tibble()
                          
                        } else {
                          
                          TEMP1 = TEMP %>% 
                           pivot_longer(all_of(initial_column):ncol(DF_folders_split[[.x]]), names_to = "raw_folder", values_to = "values") %>% 
                           rowwise() %>% 
                           mutate(values = ifelse(is.null(values[[1]]), NA, values[[1]]))
                          
                        }
                        
                        TEMP2 = TEMP1 %>% 
                          group_by(raw_folder) %>% 
                          summarise(ID_folder = unique(ID_folder),
                                    full_folder = unique(paste0(dirname(ID_folder), "/", raw_folder)),
                                    N = n(),
                                    NAs = sum(is.na(values))) %>% 
                          mutate(
                            CANONICAL = 
                              case_when(
                                NAs == 0 & !grepl("\\([0-9]\\)", raw_folder) ~ "CANONICAL",
                                NAs == 0 & !all(.$NAs == 0) ~ "CANONICAL",
                                
                                # ONLY EMPTY FOLDERS
                                # CHECK WITH OTHER FOLDERS!
                                all(.$NAs == nrow(.)) & !grepl("\\([0-9]\\)", raw_folder) ~ "CANONICAL_EMPTY",
                                all(.$NAs == nrow(.)) & grepl("\\([0-9]\\)", raw_folder) ~ "NOPE_EMPTY",
                                
                                all(.$NAs != 0) & !grepl("\\([0-9]\\)", raw_folder) ~ "MAYBE",
                                all(.$NAs != 0) & grepl("\\([0-9]\\)", raw_folder) ~ "MAYBE_NOT",
                                TRUE ~ "NOPE"
                              ))
                        
                        
                        # If > 1 row, output
                        if (nrow(TEMP2) > 1) TEMP2
                        
                         
                       }
                     )
    
    # DROP NULLS!
    DF_final = DF_final_temp[lengths(DF_final_temp) != 0]
    
    if (length(DF_final) == 0) {
      
      cli::cli_alert_success(paste0("NO duplicates found! ", praise::praise()))
      
      DF_all_files_processed = 
        list(DF_CANONICALS = NULL,
             DF_TO_DELETE = NULL,
             DT_delete = NULL)
      
    } else {
      
      cli::cli_h1(paste0("Found ", length(DF_final), " potential duplicate/s"))
      
      # DF_final = 
      #   DF_status$index %>% 
      #   purrr::map(~ DF_folders_split_wide[[.x]])
      
      # Canonical folders to preserve  
      # DF_canonical_folders = DF_final %>% bind_rows() %>% distinct(ID_folder)
      
      
      
      DF_CANONICALS =
        DF_final %>% bind_rows() %>% 
        select(ID_folder, full_folder, CANONICAL) %>% 
        distinct(full_folder, .keep_all = TRUE) %>%
        filter(CANONICAL %in% c("CANONICAL", "CANONICAL_EMPTY")) %>% 
        mutate(DESTINATION = gsub(destination, paste0(destination, "/CANONICAL/"), gsub(folder, destination, full_folder)))
      
      DF_TO_DELETE =
        DF_final %>% bind_rows() %>% 
        select(ID_folder, full_folder, CANONICAL) %>% distinct(full_folder, .keep_all = TRUE) %>%
        filter(CANONICAL %in% c("NOPE", "NOPE_EMPTY")) %>% 
        mutate(DESTINATION = gsub(destination, paste0(destination, "/DUPLICATES/"), gsub(folder, destination, full_folder)))
        #   # DELETE_name_terminal = gsub(" ", "\\\\ ", full_filename) %>% gsub("\\(", "\\\\(", .) %>% gsub("\\)", "\\\\)", .), # If need to do something via terminal

      # No single candidate with all files
      DF_MAYBES =
        DF_final %>% bind_rows() %>% 
        select(ID_folder, full_folder, CANONICAL) %>% 
        distinct(full_folder, .keep_all = TRUE) %>%
        filter(CANONICAL %in% c("MAYBE", "MAYBE_NOT"))
  
      DF_ALL = DF_CANONICALS %>% right_join(DF_TO_DELETE, by = "ID_folder")
      
      
      # Final DFs ---------------------------------------------------------------
      
      # ADD CHECK. Each element of list should have at least two rows
      
      DT_delete = DT::datatable(DF_TO_DELETE %>% mutate(folder = basename(full_folder)) %>%  select(folder, full_folder, DESTINATION))
      DT_all = DT::datatable(DF_ALL)
      DT_MAYBES = DT::datatable(DF_MAYBES)
      
      DF_all_folders_processed = 
        list(DF_CANONICALS = DF_CANONICALS,
             DF_TO_DELETE = DF_TO_DELETE,
             DT_delete = DT_delete,
             DT_MAYBES = DT_MAYBES,
             DT_all = DT_all
             )
      
    }
    
    return(DF_all_folders_processed)
  }
  
}