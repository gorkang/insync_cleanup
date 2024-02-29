
# Parameters --------------------------------------------------------------

  folder = "/home/emrys/gorkang@gmail.com"
  destination = "~/Downloads/INSYNC/FOLDERS"
  
  # folder = "/home/emrys/rutcorreia@gmail.com"
  # destination = "~/Downloads/INSYNC_Rut/FOLDERS"
  
  test_run = TRUE


# Libraries ---------------------------------------------------------------

  library(targets) 
  library(tarchetypes) 
  library(data.table)
  library(dtplyr)
  library(dplyr, warn.conflicts = FALSE)
  

# Set options, load packages -----------------------------------------------
  
  # Source all /R files
  lapply(list.files("./R", full.names = TRUE, pattern = ".R$"), source)
  options(pillar.sigfig = 5)
  
  # Packages to load
  main_packages = c("cli", "crayon", "furrr", "patchwork", "renv", "tarchetypes", "targets", "testthat")
  data_preparation_packages = c("data.table", "dplyr", "dtplyr", "forcats", "here", "janitor", "purrr", "readr", "stringr", "tibble", "tidyr")
  data_visualization_packages = c("DT", "ggalluvial", "ggridges")
  non_declared_dependencies = c("qs", "visNetwork", "webshot", "performance", "shinyWidgets", "R.utils")
  extra_packages = c() #"shrtcts"
  packages_to_load = c(main_packages, data_preparation_packages, data_visualization_packages, non_declared_dependencies, extra_packages)
  
  # target options (packages, errors...)
  tar_option_set(packages = packages_to_load, # Load packages for all targets
                 workspace_on_error = TRUE) # Needed to load workspace on error to debug
  

# Define targets -------------------------------------------------------------
  
targets <- list(
  
  # Safely rename lonely file (2) folder (2)
  tar_target(DT_safely_rename, safely_rename_extra_copies(folder = folder, test_run = test_run), priority = 1),
  
  # Common
  # tar_target(input_files, list.files(path = folder, full.names = TRUE, recursive = TRUE, all.files = TRUE, include.dirs = TRUE)),
  tar_target(input_files, system2(command = 'find', args = c(folder), stdout = TRUE)),
  
  tar_target(DF_all, prepare_files(input_files = input_files)),
  
  # Folders
  tar_target(DF_all_folders_processed, process_duplicate_folders(DF_all = DF_all, folder = folder, destination = destination)),
  tar_target(log_folders, store_log(DF_all_folders_processed, files_folders = "folders", test_run = test_run)),
  tar_target(DF_folders_moved, move_duplicate_folders(DF_all_folders_processed, destination = destination, test_run = test_run)),
  
  # If folder or file (2) is the canonical and file is deleted, rename file (2) -> file to avoid issues with other computers (where file would be the canonical)
  tar_target(DT_safely_rename2, safely_rename_extra_copies(folder = folder, test_run = test_run, after = DF_folders_moved), priority = 1)
  

)


# Declare pipeline --------------------------------------------------------

  targets
