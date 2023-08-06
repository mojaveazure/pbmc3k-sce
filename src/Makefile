BUILD_FLAGS=

_COLON := :
CRAN := http$(_COLON)//cran.rstudio.com
DATA_RAW_DIR = ../data-raw

DATA_RAW := $(sort $(wildcard ${DATA_RAW_DIR}/*.r ${DATA_RAW_DIR}/*.R))
DATA_RDA := $(addprefix ../data/,$(addsuffix .rda,$(basename $(notdir ${DATA_RAW}))))
DATA_DOC := $(addprefix ../man/,$(addsuffix .Rd,$(basename $(notdir ${DATA_RAW}))))

.PHONY: all clean data deps docs resave

.NOTPARALLEL: $(DATA_RDA)

all: deps $(DATA_RDA) $(DATA_DOC)

data: $(DATA_RDA)

docs: $(DATA_DOC)

deps:
	#	Install package dependencies
	Rscript -e 'if (!require("remotes")) {install.packages("remotes", repos = "${CRAN}")}; remotes::install_deps("..", dependencies = TRUE, upgrade = FALSE)'

resave:
	# Try to compress datasets beyond the default
	Rscript -e 'if (require("tools")) tools::resaveRdaFiles(paths = "data")'

../data/%.rda: ../data-raw/%.R
	#	Build datasets
	Rscript -e 'source("$<", echo = TRUE)'

$(DATA_DOC)&: $(DATA_RDA)
	#	Generate documentation for the datasets (and package)
	Rscript -e 'if (!require("roxygen2")) {install.packages("roxygen2", repos = "${CRAN}")}; roxygen2::roxygenize("..")'

clean:
	#	Remove data files and associated man pages
	-rm -rf $(DATA_RDA)
	-rm -rf $(DATA_DOC)
