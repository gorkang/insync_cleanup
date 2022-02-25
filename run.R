# Folders ------------------------------------------------------------------

# GO TO: rstudioapi::navigateToFile("_targets_folders.R")
# CHANGE folder, destination and test_run

Sys.setenv(TAR_PROJECT = "folders")
targets::tar_destroy(ask = FALSE)
targets::tar_make()

# targets::tar_load(c(DT_safely_rename, DF_all_folders_processed))
# DT_safely_rename
# DF_all_folders_processed$DT_delete
# DF_all_folders_processed$DT_all


# Files --------------------------------------------------------------------

# GO TO: rstudioapi::navigateToFile("_targets_files.R")
# CHANGE folder, destination and test_run

Sys.setenv(TAR_PROJECT = "files") 
targets::tar_destroy(ask = FALSE)
targets::tar_make()

# targets::tar_load(c(DT_safely_rename, DF_all_files_processed))
# DF_all_files_processed$DT_delete
# DF_all_folders_processed$DT_all



# Visualize targets -------------------------------------------------------

targets::tar_visnetwork(targets_only = TRUE, label = "time")

