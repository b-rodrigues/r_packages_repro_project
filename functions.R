generate_script_from_help <- function(path_to_rd){

  # Get root of package, with man/
  folder_root <- stringr::str_extract(path_to_rd,
                                      "^(.*?man\\/)")

  # Replace man/ with scripts/
  scripts_path <- stringr::str_replace(folder_root, "man", "scripts")

  # Check if scripts/ exists. If not, create it
  if (!dir.exists(scripts_path)){
    dir.create(scripts_path)
  } else {
    NULL
  }

  # Create path to save script to scripts/
  script_path <- stringr::str_replace(path_to_rd, "man", "scripts")
  script_path <- stringr::str_replace(script_path, "\\.Rd", "\\.R")

  tools::Rd2ex(path_to_rd, script_path)
}

#' Creates a tibble with the urls to the archived sources of a package
#' @param package String. Name of the package to query
#' @importFrom rvest read_html html_nodes html_table
#' @importFrom purrr pluck
#' @importFrom janitor clean_names
#' @importFrom dplyr filter mutate select
#' @importFrom lubridate ymd_hm
#' @return A tibble of 4 columns, `name`, `url`, `last_modified`, `size`
#' @details
#' The returned table is the same as the html table that can be found in the CRAN
#' archive url of a package, for instance \url{https://cran.r-project.org/src/contrib/Archive/AER/}.
#' The `url` column is added to make it easier to download a source package.
#' @examples
#' get_archived_sources("AER")
get_archived_sources <- function(package){

  root_url <- "https://cran.r-project.org/src/contrib/Archive/"

  package_archive_url <- paste0(root_url, package)

  package_archive_url %>%
    read_html() %>%
    html_nodes("table") %>%
    html_table() %>%
    pluck(1) %>%
    janitor::clean_names() %>%
    filter(name != "Parent Directory",
           last_modified != "",
           size != "-") %>%
    mutate(last_modified = lubridate::ymd_hm(last_modified),
           url = paste0(root_url, package, "/", name)) %>%
    select(version = name, url, last_modified, size) %>%
    mutate(version = str_remove_all(version, "\\.tar\\.gz"))
}

#' Get a tibble with current available packages on CRAN
#' @param ... Arguments passed down to `available.packages()`
#' @importFrom janitor clean_names
#' @importFrom tibble as_tibble
#' @return A tibble of 17 columns
#' @details
#' This function is a simple wrapper around `available.packages()`
#' @examples
#' \dontrun{
#' get_available_packages()
#' }
get_available_packages <- function(...){

  as_tibble(available.packages(...)) %>%
    janitor::clean_names()

}

#' Get a tibble of packages from a CRAN Task View
#' @param view String. View of interest
#' @param date String, format: '2015-01-01'. Queries MRAN to download state of the view at given date
#' @importFrom ctv ctv
#' @importFrom tibble as_tibble
#' @return A tibble of 2 columns
#' @details
#' This function is a simple wrapper around `ctv::ctv()`
#' @examples
#' \dontrun{
#' get_packages_from_view("Econometrics")
#' get_packages_from_view("Bayesian", "2022-01-01")
#' }
get_packages_from_view <- function(view, date = "2015-01-01"){
  ctv::ctv(view = view,
           repos = paste0("https://cran.microsoft.com/snapshot/",
                          date)) %>%
    pluck("packagelist") %>%
    as_tibble()
}

#' Get a tibble of source urls for a selection of packages
#' @param view_df A data frame as returned by `get_packages_from_view()`
#' @importFrom dplyr mutate select rename
#' @importFrom tidyr unnest
#' @return A tibble of 5 columns.
#' @details
#' This function returns a data frame with a column `name` giving the name
#' of a package, `version` giving its version, `url` the download url
#' `last_modified` the date on which the package was last modified on CRAN
#' and `size`, the size of the package
#' @examples
#' \dontrun{
#' ctv_econ <- get_packages_from_view("Econometrics", date = "2015-01-01")
#' get_sources_format_selected_packages(ctv_econ)
#' }
get_sources_for_selected_packages <- function(view_df){

  view_df %>%
    mutate(sources = map(name, get_archived_sources)) %>%
    select(-core) %>%
    unnest(cols = c(sources))

}

# https://cran.r-project.org/src/contrib/Archive/car/car_0.8-1.tar.gz
# function to download source package, and extract man/
get_man_package <- function(name, version, url, clean = TRUE){

  path_tempfile <- tempfile(fileext = ".tar.gz")

  download.file(url,
                destfile = path_tempfile)

  exdir_path <- paste0("archives/", name, "/", version )

  untar(path_tempfile, exdir = exdir_path, extras = "--strip-components=1")

  if(clean){

    files_to_delete <- list.files(exdir_path,
                                  full.names = TRUE) %>%
      setdiff(paste0("archives/", name, "/", version, "/man"))

    unlink(files_to_delete,
           recursive = TRUE)
  }

}
