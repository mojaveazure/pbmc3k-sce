## code to prepare `pbmc3k` dataset goes here

url <- 'http://cf.10xgenomics.com/samples/cell-exp/1.1.0/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz'
tmp <- tempfile(pattern = 'pbmc3k')
if (file.exists(tmp) || dir.exists(paths = tmp)) {
  unlink(x = tmp, recursive = TRUE, force = TRUE)
}
dir.create(path = tmp, showWarnings = FALSE, recursive = TRUE)

download.file(url = url, destfile = file.path(tmp, basename(url)))
untar(tarfile = file.path(tmp, basename(path = url)), exdir = tmp)

pbmc3k <- DropletUtils::read10xCounts(
  samples = file.path(tmp, 'filtered_gene_bc_matrices', 'hg19'),
  sample.names = 'pbmc3k',
  col.names = TRUE
)

unlink(x = tmp, recursive = TRUE, force = TRUE)

usethis::use_data(pbmc3k, overwrite = TRUE)
