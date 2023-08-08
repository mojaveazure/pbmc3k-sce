_COLON := :
CRAN := http$(_COLON)//cran.rstudio.com
DATA_RAW_DIR = ../inst/data-raw

DATA_RAW := $(sort $(wildcard ${DATA_RAW_DIR}/*.r ${DATA_RAW_DIR}/*.R))
DATA_RDA := $(addprefix ../data/, $(addsuffix .rda, $(basename $(notdir ${DATA_RAW}))))
DATA_DOC := $(addprefix ../man/, $(addsuffix .Rd, $(basename $(notdir ${DATA_RAW}))))

.PHONY: all clean data deps docs resave

.NOTPARALLEL: $(DATA_RDA)

all: deps $(DATA_RDA) $(DATA_DOC)

data: $(DATA_RDA)

docs: $(DATA_DOC)

deps: ../tools/install_deps.R
	#	Install package dependencies
	Rscript $< $(dir $(<D)) $(CRAN)

resave: $(DATA_RDA)
	# Try to compress datasets beyond the default
	Rscript -e 'if (requireNamespace("tools", quietly = TRUE)) tools::resaveRdaFiles(paths = "data")'

../data/%.rda: $(DATA_RAW_DIR)/%.R
	#	Build datasets
	Rscript -e 'source("$<", echo = TRUE)'

$(DATA_DOC)&: ../tools/build_man.R $(DATA_RDA)
	#	Generate documentation for the datasets (and package)
	Rscript $< $(dir $(<D)) $(CRAN)

clean:
	#	Remove data files and associated man pages
	-rm -rf $(DATA_RDA)
	-rm -rf $(DATA_DOC)
