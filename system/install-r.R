#!/usr/bin/env Rscript

# Set package repository
repos <- getOption("repos")
if (repos["CRAN"] == "@CRAN@") {
  repos["CRAN"] <- "https://cloud.r-project.org/"
  options(repos = repos)
}

# Set user library
#
# NOTE: R_LIBS_USER is similar to PATH and is a colon separated string of paths.
# Here we only consider the first one which is similar to builtin functions.
user_libpath <- path.expand(
  strsplit(Sys.getenv("R_LIBS_USER", unset = "~/.local/lib/R/library"),
           ":")[[1]])
if (!dir.exists(user_libpath)) {
  dir.create(user_libpath, recursive = TRUE)
}
.libPaths(user_libpath)

# Install packages
Sys.setenv(STRINGI_DISABLE_PKG_CONFIG = 1)
packages <- c("lintr",
              "rmarkdown",
              "tidyverse",
              "sf",
              "lwgeom",
              "RSQLite")
install.packages(packages, lib = user_libpath)
