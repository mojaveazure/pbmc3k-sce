#!/usr/bin/env Rscript

options(echo = TRUE)

args <- commandArgs(TRUE)

path <- args[1L]
repo <- args[2L]

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages(
    "remotes",
    repos = repo,
    INSTALL_opts = "--no-staged-install"
  )
}

remotes::install_deps(
  path,
  dependencies = TRUE,
  repos = repo,
  upgrade = FALSE,
  INSTALL_opts = "--no-staged-install"
)
