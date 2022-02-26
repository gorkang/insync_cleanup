targets::tar_load_globals()
safely_rename_extra_copies(folder = "/home/emrys/Downloads/INSYNC/FOLDERS_RENAME", test_run = TRUE)

# Folders ------------------------------------------------------------------

# CHANGE folder, destination and test_run
# rstudioapi::navigateToFile("_targets_folders.R")

Sys.setenv(TAR_PROJECT = "folders")
targets::tar_destroy(ask = FALSE)
targets::tar_make()

# targets::tar_load(c(DT_safely_rename, DF_all_folders_processed))
# DT_safely_rename
# DF_all_folders_processed$DT_delete
# DF_all_folders_processed$DT_all


# Files --------------------------------------------------------------------

# CHANGE folder, destination and test_run
# rstudioapi::navigateToFile("_targets_files.R")

Sys.setenv(TAR_PROJECT = "files") 
targets::tar_destroy(ask = FALSE)
targets::tar_make()

targets::tar_load(c(DT_safely_rename, DF_all_files_processed))
# DT_safely_rename
# DF_all_files_processed$DT_delete
DF_all_files_processed$DT_all




# Visualize targets -------------------------------------------------------

targets::tar_visnetwork(targets_only = TRUE, label = "time")

