
pbmc3k <- local({
  callcheck <- "resave_data_others" %in% unlist(x = lapply(
    X = sys.calls(),
    FUN = as.character
  ))
  if (!isTRUE(x = callcheck)) {
    return(NULL)
  }

  # Check required packages
  if (!requireNamespace("DropletUtils", quietly = TRUE)) {
    return(NULL)
  }

  # Create a temporary directory to download the data from
  tmp <- tempfile(pattern = 'pbmc3k')
  if (file.exists(tmp) || dir.exists(paths = tmp)) {
    unlink(x = tmp, recursive = TRUE, force = TRUE)
  }
  dir.create(path = tmp, showWarnings = FALSE, recursive = TRUE)
  on.exit(expr = unlink(x = tmp, recursive = TRUE, force = TRUE), add = TRUE)

  # Download the data from 10x
  url <- 'http://cf.10xgenomics.com/samples/cell-exp/1.1.0/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz'
  download.file(url = url, destfile = file.path(tmp, basename(url)))
  untar(tarfile = file.path(tmp, basename(path = url)), exdir = tmp)

  # Create an SCE object from
  pbmc3k <- DropletUtils::read10xCounts(
    samples = file.path(tmp, 'filtered_gene_bc_matrices', 'hg19'),
    sample.names = 'pbmc3k',
    col.names = TRUE
  )

  SingleCellExperiment::mainExpName(x = pbmc3k) <- 'RNA'

  # Return
  pbmc3k
})
