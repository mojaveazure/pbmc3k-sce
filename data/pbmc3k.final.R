
pbmc3k.final <- local({
  callcheck <- 'resave_data_others' %in% unlist(x = lapply(
    X = sys.calls(),
    FUN = as.character
  ))
  if (!isTRUE(x = callcheck)) {
    return(NULL)
  }

  # Check required packages
  pkgcheck <- requireNamespace('rprojroot', quietly = TRUE) &&
    requireNamespace('scater', quietly = TRUE) &&
    requireNamespace('scran', quietly = TRUE) &&
    requireNamespace('bluster', quietly = TRUE)
  if (!isTRUE(x = pkgcheck)) {
    return(NULL)
  }

  # Find our `data` directory
  data.dir <- rprojroot::find_package_root_file('data')
  if (!dir.exists(data.dir)) {
    return(NULL)
  }

  # Find the source file for the raw pbmc3k.sce
  src <- Filter(
    f = file.exists,
    x = file.path(data.dir, paste('pbmc3k', c('rda', 'R'), sep = '.'))
  )
  if (!length(x = src)) {
    return(NULL)
  }

  # Load the source file, with preference given to the rda over the R script
  src <- src[1L]
  env <- new.env()
  pbmc3k.final <- switch(
    EXPR = tools::file_ext(x = src),
    R = {
      resave_data_others <- function(srcfile, envir) {
        sys.source(file = srcfile, envir = envir, chdir = TRUE)
        return(invisible(x = NULL))
      }
      resave_data_others(srcfile = src, envir = env)
      env$pbmc3k
    },
    rda = {
      load(file = src, envir = env, verbose = TRUE)
      env$pbmc3k
    }
  )

  # If pbmc3k.sce was `NULL` for whatever reason, return `NULL`
  if (is.null(x = pbmc3k.final)) {
    return(NULL)
  }

  # Process pbmc3k using Bioconductor equivalents of
  # the Seurat standard workflow
  is.mito <- grepl(pattern = '^MT-', x = rownames(x = pbmc3k.final))
  qcstats <- scater::perCellQCMetrics(
    x = pbmc3k.final,
    subsets = list(Mito = is.mito)
  )
  filtered <- scater::quickPerCellQC(
    x = qcstats,
    percent_subsets = 'subsets_Mito_percent'
  )
  pbmc3k.final <- pbmc3k.final[, !filtered$discard]

  pbmc3k.final <- scater::logNormCounts(x = pbmc3k.final)

  dec <- scran::modelGeneVar(x = pbmc3k.final)
  hvg <- scran::getTopHVGs(stats = dec, prop = 0.1)

  S4Vectors::metadata(x = pbmc3k.final) <- list(hvg = hvg)

  pbmc3k.final <- scater::runPCA(
    x = pbmc3k.final,
    ncomponents = 50,
    subset_row = hvg
  )

  SingleCellExperiment::colLabels(x = pbmc3k.final) <- scran::clusterCells(
    x = pbmc3k.final,
    use.dimred = 'PCA',
    BLUSPARAM = bluster::NNGraphParam(cluster.fun = 'louvain')
  )

  pbmc3k.final <- scater::runUMAP(x = pbmc3k.final, dimred = 'PCA')

  # Return
  pbmc3k.final
})
