
# Parameters --------------------------------------------------------------

  folder = "/home/emrys/gorkang@gmail.com"
  destination = "~/Downloads/INSYNC/FILES"
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
  non_declared_dependencies = c("qs", "visNetwork", "webshot", "performance", "shinyWidgets")
  extra_packages = c("shrtcts")
  packages_to_load = c(main_packages, data_preparation_packages, data_visualization_packages, non_declared_dependencies, extra_packages)
  
  # target options (packages, errors...)
  tar_option_set(packages = packages_to_load, # Load packages for all targets
                 workspace_on_error = TRUE) # Needed to load workspace on error to debug
  

# Define targets -------------------------------------------------------------
  
targets <- list(
  
  # Safely rename lonely file (2) folder (2)
  tar_target(DT_safely_rename, safely_rename_extra_copies(folder = folder, test_run = test_run), priority = 1),
  
  # Common
  # tar_target(input_files, list.files(path = folder, full.names = TRUE, recursive = TRUE, all.files = TRUE, include.dirs = FALSE)),
  tar_target(input_files, system2(command = 'find', args = c(folder, '-type f'), stdout = TRUE)),
  
  tar_target(DF_all, prepare_files(input_files = input_files)),
  
  # Files
  tar_target(DF_all_files_processed, process_duplicate_files(DF_all = DF_all, folder = folder, destination = destination)),
  tar_target(log_files, store_log(DF_all_files_processed, files_folders = "files", test_run = test_run)),
  tar_target(DF_files_moved, move_duplicate_files(DF_all_files_processed, destination = destination, test_run = test_run))
  
)


# Declare pipeline --------------------------------------------------------

  targets
