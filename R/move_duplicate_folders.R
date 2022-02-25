move_duplicate_folders <- function(DF_all_folders_processed, destination = "~/Downloads/INSYNC/FOLDERS", test_run = TRUE) {
  
  if (!dir.exists(destination)) dir.create(destination, recursive = TRUE)
  
  DF_TO_DELETE = DF_all_folders_processed$DF_TO_DELETE
  
  if (is.null(DF_TO_DELETE)) {
    
    cli::cli_alert_success("No duplicates, so nothing to move. Yay!")
    
  } else {
    
    if(nrow(DF_TO_DELETE) == 0) cli::cli_abort("NO ROWS!")
    if (test_run == TRUE) cli::cli_alert_info("TEST RUN: nothing will be done")
    cli::cli_h1("\nMOVE {nrow(DF_TO_DELETE)} duplicated folders to `{destination}`")
    
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
    
    cli::cli_alert_success("\n\nAll {nrow(DF_TO_DELETE)} folders renamed!")
    if (test_run == TRUE) cli::cli_alert_info("TEST RUN: nothing done! :)")
    
  }
}