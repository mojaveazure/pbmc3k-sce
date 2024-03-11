#	Macro to encode a colon
override _COLON := :

#	Build options
CRAN := http$(_COLON)//cran.rstudio.com
DATA_RAW_DIR = ../inst/data-raw
override DEPENDENCY_OPTS+=--no-staged-install
RESAVE =

#	Determine data inputs and outputs
override DATA_RAW := $(sort $(wildcard $(DATA_RAW_DIR)/*.r $(DATA_RAW_DIR)/*.R))
override DATA_RDA := $(addprefix ../data/, $(addsuffix .rda, $(basename $(notdir $(DATA_RAW)))))
override DATA_DOC := $(addprefix ../man/, $(addsuffix .Rd, $(basename $(notdir $(DATA_RAW)))))

#	Get package information
override DESCRIPTION = $(subst $() $(),,$(file < ../DESCRIPTION))
override PKG_NAME = $(subst Package$(_COLON),,$(filter Package$(_COLON)%, $(DESCRIPTION)))
override PKG_VERSION = $(subst Version$(_COLON),,$(filter Version$(_COLON)%, $(DESCRIPTION)))

#	Set dependency installation options
override INSTALL_OPTS := $(shell Rscript -e 'opts <- unlist(strsplit("$(DEPENDENCY_OPTS)", "[[:space:]]"))' \
	-e 'opts = paste0("c(", paste(dQuote(opts, FALSE), collapse = ", "), ")")' \
	-e 'cat(opts)' \
)
override REPOS := $(shell Rscript -e 'repos <- unname(getOption("repos", "@CRAN@"))' \
	-e 'repos <- gsub("@CRAN@", "$(CRAN)", repos)' \
	-e 'repos <- paste0("c(", paste(dQuote(repos, FALSE), collapse = ", "), ")")' \
	-e 'cat(repos)' \
)

#	Determine if package data should be resaved
ifdef RESAVE
	override RESAVE = resave
endif

#	Determine if R scripts run quietly
ifneq (,$(findstring s,$(firstword -$(MAKEFLAGS))))
	override ECHO = FALSE
else
	override ECHO = TRUE
endif

.PHONY: all clean clean-data clean-docs clean-tarball data deps docs tarball

.NOTPARALLEL: $(DATA_RDA)

all: deps $(DATA_RDA) $(RESAVE) $(DATA_DOC)

clean: clean-data clean-docs clean-tarball

clean-data:
	$(info Removing built data files (if they exist))
	-Rscript $(foreach f, $(DATA_RDA), -e 'invisible(file.remove("$(f)"))')

clean-docs:
	$(info Removing data Rd files (if they exist))
	-Rscript $(foreach f, $(DATA_DOC), -e 'invisible(file.remove("$(f)"))')

clean-tarball:
	$(info Removing package tarball (if it exists))
	-Rscript -e 'invisible(file.remove("$(PKG_NAME)_$(PKG_VERSION).tar.gz"))'

data: $(DATA_RDA)

deps:
	$(info Installing package dependencies)
	Rscript -e 'if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes", repos = $(REPOS), INSTALL_opts = $(INSTALL_OPTS))' \
		-e 'remotes::install_deps("..", dependencies = TRUE, repos = $(REPOS), upgrade = FALSE, INSTALL_opts = $(INSTALL_OPTS))'

docs: $(DATA_DOC)

tarball: $(PKG_NAME)_$(PKG_VERSION).tar.gz

../data/%.rda: $(DATA_RAW_DIR)/%.R
	$(info Building bundled data)
	Rscript -e 'source("$<", echo = $(ECHO))'

$(DATA_DOC)&: $(DATA_RDA)
	$(info Generating documentation)
	@$(MAKE) clean-docs
	Rscript -e 'if (!requireNamespace("roxygen2", quietly = TRUE)) install.packages("roxygen2", repos = $(REPOS), INSTALL_opts = $(INSTALL_OPTS))' \
		-e 'if (!requireNamespace("pkgbuild", quietly = TRUE)) install.packages("pkgbuild", repos = $(REPOS), INSTALL_opts = $(INSTALL_OPTS))' \
		-e 'roxygen2::roxygenize("..")'

$(PKG_NAME)_$(PKG_VERSION).tar.gz: $(DATA_RDA) $(RESAVE) $(DATA_DOC)
	$(info Building source tarball with bundled data)
	$(eval BUILD_DIR := $(shell Rscript -e 'cat(normalizePath(tempfile("build"), winslash = "/", mustWork = FALSE))'))
	Rscript -e 'dir.create("$(BUILD_DIR)", recursive = TRUE)' \
		-e 'invisible(file.copy(list.files("..", all.files = TRUE, full.names = TRUE, no.. = TRUE), "$(BUILD_DIR)", recursive = TRUE))' \
		-e 'src <- file.path("$(BUILD_DIR)", "src")' \
		-e 'if (dir.exists(src)) unlink(src, recursive = TRUE, force = TRUE)'
	R CMD build $(BUILD_DIR)
	Rscript -e 'unlink("$(BUILD_DIR)", recursive = TRUE, force = TRUE)'

resave: $(DATA_RDA)
	$(info Finding optimal compression for bundled data)
	Rscript -e 'resave <- unlist(strsplit("$?", "[[:space:]]"))' \
		-e 'if (requireNamespace("tools", quietly = TRUE)) tools::resaveRdaFiles(resave)'
	@Rscript -e 'writeLines(character(), "$@")'
