## code to prepare `pbmc3k.final` dataset goes here

load(file.path(pkgload::pkg_path(), 'data', 'pbmc3k.rda'))

pbmc3k.final <- pbmc3k
is.mito <- grepl("^MT-", rownames(pbmc3k.final))
qcstats <- scater::perCellQCMetrics(pbmc3k.final, subsets = list(Mito = is.mito))
filtered <- scater::quickPerCellQC(qcstats, percent_subsets = "subsets_Mito_percent")
pbmc3k.final <- pbmc3k.final[, !filtered$discard]

pbmc3k.final <- scater::logNormCounts(pbmc3k.final)

dec <- scran::modelGeneVar(pbmc3k.final)
hvg <- scran::getTopHVGs(dec, prop = 0.1)

S4Vectors::metadata(pbmc3k.final) <- list(hvg = hvg)

pbmc3k.final <- scater::runPCA(pbmc3k.final, ncomponents = 50, subset_row = hvg)

SingleCellExperiment::colLabels(pbmc3k.final) <- scran::clusterCells(
  pbmc3k.final,
  use.dimred = 'PCA',
  BLUSPARAM = bluster::NNGraphParam(cluster.fun = "louvain")
)

pbmc3k.final <- scater::runUMAP(pbmc3k.final, dimred = 'PCA')

usethis::use_data(pbmc3k.final, overwrite = TRUE)
