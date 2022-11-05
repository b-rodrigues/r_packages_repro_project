# I want to know which packages were part of views in the past

ctv_econ <- get_packages_from_view("Econometrics", date = "2015-01-01")

# Now, I want urls for the archived sources of these packages

ctv_sources <- get_sources_for_selected_packages(ctv_econ)



url <- "https://cran.r-project.org/src/contrib/Archive/AER/AER_0.2-1.tar.gz"
get_man_package("AER", "AER_0.2-1", url)


ctv_sources %>%
  head() %>%
  mutate(get_sources = pmap(list(name, version, url),
                            get_man_package))
