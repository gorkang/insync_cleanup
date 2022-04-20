
# COMPARE FILES IN FOLDERS BY HASH ----------------------------------------

Sys.setenv(TAR_PROJECT = "folders")
targets::tar_load_globals()

DELETE = compare_hashes(NEW_PATH = "/home/emrys/Downloads/INSYNC_Rut/ROOT_files",
                        OLD_PATH = "/home/rut/rutcorreia@gmail.com_CS/",
                        label = "rut_ROOT")
# file.remove(DELETE_FILES$value)  

Sys.setenv(TAR_PROJECT = "folders")
FOLDER = "/home/emrys/Downloads/INSYNC/FOLDERS_RENAME"
FOLDER = "/home/emrys/gorkang@gmail.com"



# Folders ------------------------------------------------------------------

# CHANGE folder, destination and test_run
rstudioapi::navigateToFile("_targets_folders.R")

Sys.setenv(TAR_PROJECT = "folders")
targets::tar_destroy(ask = FALSE)
targets::tar_make()

# targets::tar_load(c(DT_safely_rename, DF_all_folders_processed))
# DT_safely_rename
# DF_all_folders_processed$DT_delete
# DF_all_folders_processed$DT_all


# Files --------------------------------------------------------------------

# CHANGE folder, destination and test_run
rstudioapi::navigateToFile("_targets_files.R")

Sys.setenv(TAR_PROJECT = "files") 
targets::tar_destroy(ask = FALSE)
targets::tar_make()

targets::tar_load(c(DT_safely_rename, DF_all_files_processed))
DT_safely_rename
DF_all_files_processed$DT_delete
# DF_all_files_processed$DT_all
# DF_all_files_processed$DF_CANONICALS %>% View
# DF_all_files_processed$DF_TO_DELETE %>% View
# DF_all_files_processed$DF_duplicate_files %>% View


# SAFELY REMOVE EXTRA COPIES ----------------------------------------------

Sys.setenv(TAR_PROJECT = "folders")
targets::tar_load_globals()

FOLDER = "/home/rut/rutcorreia@gmail.com/"
safely_rename_extra_copies(folder = FOLDER, test_run = TRUE)


# Visualize targets -------------------------------------------------------

targets::tar_visnetwork(targets_only = TRUE, label = "time")

