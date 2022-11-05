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
           url = paste0(root_url, name)) %>%
    select(name, url, last_modified, size)
}

#' Get a tibble with current available packages on CRAN
#' @param ... Arguments passed down to `available.packages()`
#' @importFrom janitor clean_names
#' @importFrom tibble as_tibble
#' @return A tibble of 17 columns
#' @details
#' This function is a simple wrapper around `available.packages()`
#' @examples
#' get_available_packages()
get_available_packages <- function(...){

  as_tibble(available.packages(...)) %>%
    janitor::clean_names()

}

get_view_packages_list <- function(view_url){

  view_url %>%
    read_html() %>%
    html_elements("li") %>%
    html_elements("a") %>%
    html_attr("href") %>%  
    keep(., ~grepl("\\.\\.\\/packages", .)) %>%
    stringr::str_remove_all("\\.\\.\\/packages\\/") %>%  
    stringr::str_remove_all("\\/index\\.html") 


}

get_view_packages_table <- function(view_url){

  view_url %>%
    read_html() %>%
    html_nodes(xpath = "/html/body/table[2]") %>%
    html_table(fill=TRUE) %>%
    pluck(1) %>%
    pivot_wider(names_from = "X1", values_from = "X2") %>%
    clean_names() %>%
    mutate(across(everything(), ~stringr::str_remove_all(., "\\.$"))) %>%  
    as.list() %>%
    purrr::map(., ~strsplit(., ", ")) %>%
    purrr::flatten()

}
