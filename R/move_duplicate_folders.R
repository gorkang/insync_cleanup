move_duplicate_folders <- function(DF_all_folders_processed, destination = "~/Downloads/INSYNC/FOLDERS", test_run = TRUE) {
  
  if (!dir.exists(destination)) dir.create(destination, recursive = TRUE)
  
  DF_TO_DELETE = DF_all_folders_processed$DF_TO_DELETE
  DF_CANONICALS = DF_all_folders_processed$DF_CANONICAL
  
  if (is.null(DF_TO_DELETE)) {
    
    cli::cli_alert_success("No duplicates, so nothing to move. Yay!")
    
  } else if(nrow(DF_TO_DELETE) == 0)  {
    
    cli::cli_alert_info("NO ROWS!")
    
  } else {
    
    
    if (test_run == TRUE) cli::cli_alert_info("TEST RUN: nothing will be done")
    # cli::cli_h1("\nMOVE {nrow(DF_TO_DELETE)} duplicated folders to `{destination}`")
    # cli::cli_h1("\nMOVE {nrow(DF_TO_DELETE)} duplicated files to `paste0({destination}, /DUPLICATES/)`")
    # cli::cli_h1("\nMOVE {nrow(DF_CANONICALS)} duplicated files to `paste0({destination}, /DUPLICATES/)`")
    cli::cli_h1("\nMOVE {nrow(DF_TO_DELETE)} duplicated files to `{paste0(destination)}/DUPLICATES/`")
    cli::cli_h1("\nMOVE {nrow(DF_CANONICALS)} duplicated files to `{paste0(destination)}/DUPLICATES/`")
    
    
    1:nrow(DF_TO_DELETE) %>% 
      purrr::walk(~
                    {
                      RENAME_origin = DF_TO_DELETE$full_folder[.x]
                      RENAME_destination = DF_TO_DELETE$DESTINATION[.x]
                      
                      if (test_run == FALSE) {
                        dir.create(dirname(RENAME_destination), recursive = TRUE, showWarnings = FALSE)
                        # file.copy(RENAME_origin, RENAME_destination)
                        file.rename(from = RENAME_origin, to = RENAME_destination)  
                      } 
                    }
      )

    
    1:nrow(DF_CANONICALS) %>% 
      purrr::walk(~
                    {
                      RENAME_origin = DF_CANONICALS$full_folder[.x]
                      RENAME_destination = DF_CANONICALS$DESTINATION[.x]
                      
                      if (test_run == FALSE) {
                        dir.create(dirname(RENAME_destination), recursive = TRUE, showWarnings = FALSE)
                        # file.copy(RENAME_origin, RENAME_destination)
                        file.rename(from = RENAME_origin, to = RENAME_destination)  
                      } 
                    }
      )
    
    cli::cli_alert_success("\n\nAll {nrow(DF_TO_DELETE)} folders renamed!")
    cli::cli_alert_success("\n\nAll {nrow(DF_CANONICALS)} folders renamed!")
    if (test_run == TRUE) cli::cli_alert_info("TEST RUN: nothing done! :)")
    
  }
}