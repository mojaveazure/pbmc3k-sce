#!/usr/bin/env Rscript

options(echo = TRUE)

args <- commandArgs(TRUE)

path <- args[1L]
repo <- args[2L]

if (!requireNamespace("roxygen2", quietly = TRUE)) {
  install.packages(
    "roxygen2",
    repos = repo,
    INSTALL_opts = "--no-staged-install"
  )
}

if (!requireNamespace("pkgbuild", quietly = TRUE)) {
  install.packages(
    "pkgbuild",
    repos = repo,
    INSTALL_opts = "--no-staged-install"
  )
}

roxygen2::roxygenize(path)
