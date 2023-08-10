_COLON := :
CRAN := http$(_COLON)//cran.rstudio.com
DATA_RAW_DIR = ../inst/data-raw

DATA_RAW := $(sort $(wildcard ${DATA_RAW_DIR}/*.r ${DATA_RAW_DIR}/*.R))
DATA_RDA := $(addprefix ../data/, $(addsuffix .rda, $(basename $(notdir ${DATA_RAW}))))
DATA_DOC := $(addprefix ../man/, $(addsuffix .Rd, $(basename $(notdir ${DATA_RAW}))))

DESCRIPTION = $(subst $() $(),,$(file < ../DESCRIPTION))
PKG_NAME = $(subst Package$(_COLON),,$(filter Package$(_COLON)%, $(DESCRIPTION)))
PKG_VERSION = $(subst Version$(_COLON),,$(filter Version$(_COLON)%, $(DESCRIPTION)))

.PHONY: all clean data deps docs resave tarball

.NOTPARALLEL: $(DATA_RDA)

all: deps $(DATA_RDA) $(DATA_DOC)

clean:
	$(info Removing built data files, associated Rd files, and package tarball (if they exist))
	-$(foreach f, $(DATA_RDA) $(DATA_DOC) $(PKG_NAME)_$(PKG_VERSION).tar.gz, Rscript -e 'file.remove("$(f)")';)

data: $(DATA_RDA)

docs: $(DATA_DOC)

deps: ../tools/install_deps.R
	$(info Installing package dependencies)
	Rscript $< $(dir $(<D)) $(CRAN)

resave: $(DATA_RDA)
	$(info Finding optimal compression for bundled data)
	Rscript -e 'if (requireNamespace("tools", quietly = TRUE)) tools::resaveRdaFiles(paths = "data")'

tarball: $(PKG_NAME)_$(PKG_VERSION).tar.gz

../data/%.rda: $(DATA_RAW_DIR)/%.R
	$(info Building bundled data)
	Rscript -e 'source("$<", echo = TRUE)'

$(DATA_DOC)&: ../tools/build_man.R $(DATA_RDA)
	$(info Generating documentation)
	Rscript $< $(dir $(<D)) $(CRAN)

$(PKG_NAME)_$(PKG_VERSION).tar.gz: $(DATA_RDA) $(DATA_DOC)
	$(info Building source tarball with bundled data)
	$(eval BUILD_DIR := $(shell Rscript -e 'cat(normalizePath(tempfile("build"), winslash = "/", mustWork = FALSE))'))
	Rscript -e 'dir.create("$(BUILD_DIR)", recursive = TRUE)'
	Rscript -e 'file.copy(list.files("..", all.files = TRUE,  full.names = TRUE, no.. = TRUE), "$(BUILD_DIR)", recursive = TRUE)'
	Rscript -e 'if (dir.exists(file.path("$(BUILD_DIR)", "src"))) unlink(file.path("$(BUILD_DIR)", "src"), recursive = TRUE, force = TRUE)'
	R CMD build $(BUILD_DIR)
	-Rscript -e 'unlink("$(BUILD_DIR)", recursive = TRUE, force = TRUE)'
