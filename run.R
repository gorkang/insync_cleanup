# 1) Get all changes in the last 24h  (-mtime -1: last 1 day) (-mmin -30: last 30 minutes)
tictoc::tic()
ALL_changes = tibble::tibble(filename = system("find /home/emrys/gorkang@gmail.com/* -mtime -1", intern = TRUE)) 
DF = ALL_changes |> dplyr::rowwise() |> dplyr::mutate(HASH = secretbase::sha3(filename))
tictoc::toc()


# 2) Hash those files and compare to previous hash
# ....

# 3) Get all files
tictoc::tic()
# ALL_files_t0 = tibble::tibble(file = system("find /home/emrys/gorkang@gmail.com/*", intern = TRUE)) |> dtplyr::lazy_dt()
# ALL_files_t1 = tibble::tibble(file = system("find /home/emrys/gorkang@gmail.com/*", intern = TRUE)) |> dtplyr::lazy_dt()
ALL_files_t0 |> anti_join(ALL_files_t1, by = "file")
tictoc::toc()

# 4) Compare to previous snapshot and show files deleted






# COMPARE FILES IN FOLDERS BY HASH ----------------------------------------

Sys.setenv(TAR_PROJECT = "folders")
targets::tar_load_globals()

DELETE = compare_hashes(NEW_PATH = "/home/rut/rutcorreia@gmail.com/TRANSFERENCIA-cuentaUDP/",
                        OLD_PATH = "/home/rut/rutcorreia@gmail.com/TRANSFERENCIA_2",
                        label = "rut_UDP")
# file.remove(DELETE$value)

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

