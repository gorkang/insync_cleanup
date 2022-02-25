store_log <- function(DF, files_folders, test_run = TRUE) {
  
  # DF_all_files_processed$DF_CANONICALS
  
  now_str = Sys.time()
  
  DF_TO_DELETE = DF$DF_TO_DELETE
  DF_CANONICALS = DF$DF_CANONICALS
  
  
  if (test_run == FALSE & !is.null(DF_TO_DELETE)) {
    
    if (!files_folders %in% c("files", "folders")) {
      rlang::abort("files_folders needs to be either 'files' or 'folders'")
    }
    
    snapshot_duplicate_file = paste0("logs/", files_folders, "_duplicate_", now_str, ".csv.gz")
    snapshot_canonical_file = paste0("logs/", files_folders, "_canonical_", now_str, ".csv.gz")
    
    data.table::fwrite(DF_TO_DELETE, snapshot_duplicate_file)
    data.table::fwrite(DF_CANONICALS, snapshot_canonical_file)
  }
  
}