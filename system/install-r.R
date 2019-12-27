#!/usr/bin/env Rscript

# Set package repository
local({
  r <- getOption("repos")
  if(r["CRAN"] == "@CRAN@") {
    r["CRAN"] <- "https://cloud.r-project.org/"
    options(repos = r)
  }
})

# Set user library
# NOTE: Only consider the first one
user_libpath = path.expand(
  strsplit(Sys.getenv("R_LIBS_USER",
                      unset = "~/.local/lib/R/library"),
           ":")[[1]])
if(!dir.exists(user_libpath)) {
  dir.create(user_libpath, recursive = TRUE)
}
.libPaths(user_libpath)

# Install packages
packages = c("lintr",
             "devtools",
             "rmarkdown",
             "tidyverse",
             "sf",
             "lwgeom")
install.packages(packages,
                 lib = user_libpath)
