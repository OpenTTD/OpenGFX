#
# This file is part of the NML build framework
# NML build framework is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
# NML build framework is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with NML build framework. If not, see <http://www.gnu.org/licenses/>.
#

SHELL := /bin/bash

include Makefile.config

##################################################################
#
# Makefile.config defines these minimal definitions:
#
# PROJECT_FILENAME
# REPO_BRANCH_VERSION
#
# BASE_FILENAME
# GFX_SCRIPT_LIST_FILES
#
# LICENSE_FILE
# CHANGELOG_FILE
# README_FILE
#
#
##################################################################

# Directory structure
SCRIPT_DIR          ?= scripts

# Define the filenames of the grf and nml file. They must be in the main directoy
GRF_FILES            ?= $(addsuffix .grf,$(BASE_FILENAME))
NML_FILES            ?= $(addsuffix .nml,$(BASE_FILENAME))
PNML_FILES           ?= $(addsuffix .pnml,$(BASE_FILENAME))
DOC_FILES            ?= $(LICENSE_FILE) $(CHANGELOG_FILE) $(README_FILE)
LNG_FILES            ?= lang/*.lng
GFX_FILES            ?=

# List of all files which will get shipped
# documentation files: readme, changelog and license, usually $(DOC_FILES)
# grf file: the above defined grf file, usualls $(GRF_FILES)
# Add any additional, not usual files here, too, including
# their relative path to the root of the repository
BUNDLE_FILES           ?= $(GRF_FILES) $(DOC_FILES) $(OBG_FILENAME)
BANANAS_INI            ?= bananas.ini

# Replacement strings in the source and in the documentation
# You may only change the values, not add new definitions
# (unless you know where to add them in other places, too)
REPLACE_TITLE       := {{REPO_TITLE}}
REPLACE_GRFID       := {{GRF_ID}}
REPLACE_REVISION    := {{REPO_REVISION}}
REPLACE_FILENAME    := {{FILENAME}}

# target 'all' must be first target
all: bundle_tar

-include Makefile.in

# misc. convenience targets like 'langcheck'
-include $(SCRIPT_DIR)/Makefile_misc

# general definitions (no rules!)
-include Makefile.dist
.PHONY: all clean distclean
.PHONY: bananas doc gfx grf lng nml obg
.PHONY: bundle     bundle_tar bundle_bzip bundle_gzip bundle_xz   bundle_zip
.PHONY: bundle_src check      bundle_bsrc bundle_gsrc bundle_xsrc bundle_zsrc 

# We want to disable the default rules. It's not c/c++ anyway
.SUFFIXES:

# Don't delete intermediate files
.PRECIOUS: %.nml %.scm %.png
.SECONDARY: %.nml %.scm %.png

FORCE:

-include *.dep


################################################################
#
# Program definitions / search paths
#
################################################################

# Make
MAKE           ?= make
MAKE_FLAGS     ?= -r

# Version control system
HG                  ?= hg
DEFAULT_BRANCH_NAME ?= default
HG_ARCHIVE_FLAGS    ?= -X .hgtags -X .hgignore -X .devzone -X scripts/make_changelog.sh

# Text processing and scripting
AWK            ?= awk
GREP           ?= grep
PYTHON         ?= python
UNIX2DOS       ?= unix2dos
UNIX2DOS_FLAGS ?= $(shell [ -n $(UNIX2DOS) ] && $(UNIX2DOS) -q --version 2>/dev/null && echo "-q" || echo "")

# Graphics processing
GIMP           ?= gimp
GIMP_FLAGS     ?= -n -i

# NML
NML            ?= nmlc
NML_FLAGS      ?= -c
ifdef REQUIRED_NML_BRANCH
	NML_BRANCH = $(shell nmlc --version | head -n1 | cut -d. -f1-2)
endif
ifdef MIN_NML_REVISION
	NML_REVISION = $(shell nmlc --version | head -n1 | cut -dr -f2 | cut -d: -f1)
endif

ifdef PNML_FILES
	CC             ?= gcc
	CC_FLAGS       ?= -C -E -nostdinc -x c-header
endif

# GRF tools
GRFID          ?= grfid
GRFID_FLAGS    ?= -m
MUSA           ?= musa.py
# The license is set via bananas.ini, do not supply a "custom" license.
MUSA_FLAGS     ?= -x license.txt

# Bundle
TAR            ?= tar
TAR_FLAGS      ?= -cf
# OSX has nice extended file attributes which create their own file within tars. We don't want those, thus don't copy them
CP_FLAGS       ?= $(shell [ "$(OSTYPE)" = "Darwin" ] && echo "-rfX" || echo "-rf")

# Compression tools for bundles
ZIP            ?= zip
ZIP_FLAGS      ?= -9rq
GZIP           ?= gzip
GZIP_FLAGS     ?= -9f
BZIP           ?= bzip2
BZIP_FLAGS     ?= -9fk
XZ             ?= xz
XZ_FLAGS       ?= -efk

# Remove the @ when you want a more verbose output.
_V ?= @
_E ?= @echo


################################################################
#
# Working copy / bundle version detection.
#
################################################################

include Makefile.vcs

ifneq ($(HG),)

# HG revision
REPO_REVISION  = $(shell HGPLAIN= $(HG) id -n | cut -d+ -f1)

# HG Hash
REPO_HASH      = $(shell HGPLAIN= $(HG) id -i | cut -d+ -f1)

# HG Date
REPO_DATE      = $(shell HGPLAIN= $(HG) log -r$(REPO_HASH) --template='{date|shortdate}')

# Whether there are local changes
REPO_MODIFIED  = $(shell [ "`HGPLAIN= $(HG) id | cut -c13`" = "+" ] && echo "M" || echo "")

# Branch name
REPO_BRANCH    = $(shell HGPLAIN= $(HG) id -b)

# Any tag which is not 'tip'
REPO_TAGS      = $(shell HGPLAIN= $(HG) id -t | grep -v "tip")

# Makefile.vcs contains all the data depending on the version reported by HG.
# It is renewed *before* processing any real targets, *only* if the version of the working copy changes.
#
# Everything that uses the version strings (to compile them into some file), should have Makefile.vcs as prerequisite.
#
Makefile.vcs: FORCE
	$(_E) "[VCS] $@"
	$(_V) echo "REPO_REVISION  ?= $(REPO_REVISION)" > $@.new
	$(_V) echo "REPO_HASH      ?= $(REPO_HASH)" >> $@.new
	$(_V) echo "REPO_DATE      ?= $(REPO_DATE)" >> $@.new
	$(_V) echo "REPO_MODIFIED  ?= $(REPO_MODIFIED)" >> $@.new
	$(_V) echo "REPO_BRANCH    ?= $(REPO_BRANCH)" >> $@.new
	$(_V) echo "REPO_TAGS      ?= $(REPO_TAGS)" >> $@.new
	$(_V) cmp -s $@.new $@ || cp $@.new $@
	$(_V) -rm -f $@.new

endif

# Days of commit since 2000-1-1 00-00
REPO_DAYS_SINCE_2000 ?= $(shell $(PYTHON) -c "from datetime import date; print (date(`echo "$(REPO_DATE)" | sed s/-/,/g | sed s/,0/,/g`)-date(2000,1,1)).days")

# Filename addition, if we're not building the default branch
REPO_BRANCH_STRING ?= $(shell if [ "$(REPO_BRANCH)" = "$(DEFAULT_BRANCH_NAME)" ]; then echo ""; else echo "-$(REPO_BRANCH)"; fi)

# The version reported to OpenTTD. Usually days since 2000 + branch offset
NEWGRF_VERSION ?= $(shell let x="$(REPO_DAYS_SINCE_2000) + 65536 * $(REPO_BRANCH_VERSION)"; echo "$$x")

# The shown version is either a tag, or in the absence of a tag the revision.
REPO_VERSION_STRING ?= $(shell [ -n "$(REPO_TAGS)" ] && echo $(REPO_TAGS)$(REPO_MODIFIED) || echo $(REPO_DATE)$(REPO_BRANCH_STRING) \($(NEWGRF_VERSION):$(REPO_HASH)$(REPO_MODIFIED)\))

# The title consists of name and version
REPO_TITLE     ?= $(REPO_NAME) $(REPO_VERSION_STRING)

distclean:: clean
maintainer-clean:: distclean


################################################################
#
# Target nml
#
# Pre-processing and generation of $(NML_FILES)
#
################################################################

nml: $(NML_FILES)

%.nml: %.pnml Makefile.vcs
	$(_E) "[CPP] $@"
	$(_V) $(CC) -D REPO_REVISION=$(NEWGRF_VERSION) -D NEWGRF_VERSION=$(NEWGRF_VERSION) $(CC_USER_FLAGS) $(CC_FLAGS) -MMD -MF $@.dep -MT $@ -o $@ $<

clean::
	$(_E) "[CLEAN NML]"
	$(_V)-rm -rf $(NML_FILES)


################################################################
#
# Target gfx
#
# Pre-processing and generation of png files.
# The instructions for generating png files are defined via $(GFX_SCRIPT_LIST_FILES)
#
# - $(GFX_SCRIPT_LIST_FILES) specifies a list of source xcf2png files.
# - From this file a list of rules to generate png files are created *before* processing any real targets.
# - NML generares png prerequisited for all image files.
# - The generated png files ($(GFX_FILES)) are additionally order-prerequisites to all grf files,
#   in case no NML dependencies were generated yet.
#
################################################################

ifdef GFX_SCRIPT_LIST_FILES

ifneq ($(GIMP),)

# Always include to force creation, if not existing
include Makefile.gfx

gfx: Makefile.gfx

# Generation of processing rules for png files.
# The rules are only updated, if there are any changes to them. (This is also the case for the .scm files)
#
# Make "Makefile.gfx $(GFX_FILES)" an ordering "|"-prerequisite of any target that may depend on generated png files.
#
Makefile.gfx: $(GFX_SCRIPT_LIST_FILES) Makefile Makefile.config
	$(_E) "[GFX-DEP] $@"
	$(_V) echo "" > $@
	$(_V)\
		for j in $(GFX_SCRIPT_LIST_FILES); do\
			for i in `cat $$j | grep "\([pP][cCnN][xXgG]\)" | grep -v "^#" | cut -d\  -f1 | sed "s/\.\([pP][cCnN][xXgG]\)//"`; do\
				echo "$$i.scm: $$j" >> $@;\
				echo "GFX_FILES += $$i.png" >> $@;\
				cat $(SCRIPT_DIR)/gimpscript > $$i.scm.new;\
				grep $$i.png $$j | sed -f $(SCRIPT_DIR)/gimp.sed >> $$i.scm.new;\
				echo "(gimp-quit 0)" >> $$i.scm.new;\
				cmp -s $$i.scm.new $$i.scm || cp $$i.scm.new $$i.scm;\
				rm -f $$i.scm.new;\
			done;\
		done
	$(_V) cat $(GFX_SCRIPT_LIST_FILES) | grep "\([pP][cCnN][xXgG]\)" | grep -v "^#" | sed "s/[ ] */ /g" | cut -d\  -f1-2 | sed "s/ /: /g" >> $@

# create the png file. And make sure it's re-created even when present in the repo
%.png: %.scm
	$(_E) "[GIMP] $@"
	$(_V) $(GIMP) $(GIMP_FLAGS) -b - <$< >/dev/null

clean::
	$(_E) "[CLEAN GFX]"
	$(_V) for j in $(GFX_SCRIPT_LIST_FILES); do for i in `cat $$j | grep "\([pP][cCnN][xXgG]\)" | cut -d\  -f1 | sed "s/\.\([pP][cCnN][xXgG]\)//"`; do rm -rf $$i.scm; done; done
	$(_V) rm -rf Makefile.gfx

clean-gfx::
	$(_E) "[CLEAN-GFX]"
	$(_V) for j in $(GFX_SCRIPT_LIST_FILES); do for i in `cat $$j | grep "\([pP][cCnN][xXgG]\)" | cut -d\  -f1 | sed "s/\.\([pP][cCnN][xXgG]\)//"`; do rm -rf $$i.png; done; done

else

gfx: Makefile.gfx

Makefile.gfx: FORCE
	$(_E) "[GIMP disabled]"

endif
endif


################################################################
#
# Target grf
#
# Compile grf files from nml, png and lang sources.
#
################################################################

grf: $(GFX_FILES) $(GRF_FILES)

custom_tags.txt: Makefile.vcs
	$(_E) "[LNG] $@"
	$(_V) echo "VERSION        :$(REPO_VERSION_STRING)" > $@
	$(_V) echo "VERSION_STRING :$(REPO_VERSION_STRING)" >> $@
	$(_V) echo "TITLE          :$(REPO_TITLE)" >> $@
	$(_V) echo "FILENAME       :$(GRF_FILES)" >> $@
	$(_V) echo "REPO_DATE      :$(REPO_DATE)" >> $@
	$(_V) echo "REPO_HASH      :$(REPO_HASH)" >> $@
	$(_V) echo "REPO_BRANCH    :$(REPO_BRANCH)" >> $@
	$(_V) echo "NEWGRF_VERSION :$(NEWGRF_VERSION)" >> $@
	$(_V) echo "DAYS_SINCE_2K  :$(REPO_DAYS_SINCE_2000)" >> $@

%.grf: %.nml $(LNG_FILES) custom_tags.txt | Makefile.gfx $(GFX_FILES)
	$(_E) "[NML] $@"
ifeq ($(NML),)
	$(_E) "No NML compiler found!"
	$(_V) false
endif
ifdef REQUIRED_NML_BRANCH
ifneq ($(REQUIRED_NML_BRANCH),$(NML_BRANCH))
	$(_E) "Wrong NML version. This NewGRF requires an NML from the $(REQUIRED_NML_BRANCH) branch, but $(NML_BRANCH) found."
	$(_V) false
endif
endif
ifdef MIN_NML_REVISION
ifeq ($(shell [ "$(NML_REVISION)" -lt "$(MIN_NML_REVISION)" ] && echo "true" || echo "false"),true)
	$(_E) "Too old NML revision. At least r$(MIN_NML_REVISION) is required, but r$(NML_REVISION) found."
	$(_V) false
endif
endif
	$(_V) $(NML) $(NML_FLAGS) -M --MF=$@.dep --grf $@ $<

clean::
	$(_E) "[CLEAN GRF]"
	$(_V)-rm -rf $(GRF_FILES)
	$(_V)-rm -rf $(GRF_FILES).cache
	$(_V)-rm -rf $(GRF_FILES).cacheindex
	$(_V)-rm -rf parsetab.py
	$(_V)-rm -rf .nmlcache

maintainer-clean::
	$(_E) "[MAINTAINER-CLEAN GRF]"
	$(_V) -rm -rf $(MD5_SRC_FILENAME)


################################################################
#
# Target doc
#
# Generate documentation files.
#
################################################################

doc: $(DOC_FILES)

%.txt: %.ptxt Makefile.vcs
	$(_E) "[DOC] $@"
	$(_V) cat $< \
		| sed -e "s/$(REPLACE_TITLE)/$(REPO_TITLE)/" \
		| sed -e "s/$(REPLACE_GRFID)/$(GRF_ID)/" \
		| sed -e "s/$(REPLACE_REVISION)/$(NEWGRF_VERSION)/" \
		| sed -e "s/$(REPLACE_FILENAME)/$(OUTPUT_FILENAME)/" \
		> $@
	$(_V) [ -z "$(UNIX2DOS)" ] || $(UNIX2DOS) $(UNIX2DOS_FLAGS) $@

clean::
	$(_E) "[CLEAN DOC]"
	$(_V) -for i in $(patsubst %.txt,%,$(DOC_FILES)); do [ -f $$i.ptxt ] && [ -f $$i.txt ] && rm -rf $$i.txt || true; done


################################################################
#
# Target obg
#
# Create the baseset meta data file.
#
################################################################

ifdef OBG_FILENAME

obg: $(OBG_FILENAME)

%.obg: $(GFX_FILES) $(GRF_FILES) $(LNG_FILES) Makefile.vcs
	$(_E) "[ASSEMBLING] $@"
	@echo "[metadata]" > $@
	@echo "name        = $(REPO_NAME)" >> $@
	@echo "shortname   = $(REPO_SHORTNAME)" >> $@
	@echo "version     = $(NEWGRF_VERSION)" >> $@
	@echo "palette     = $(REPO_PALETTE)" >> $@
	@echo "blitter     = $(REPO_BLITTER)" >> $@
	$(_V) $(SCRIPT_DIR)/translations.sh | sed 's/{TITLE}/$(REPO_TITLE)/' >> $@

	@echo "" >> $@
	@echo "[files]" >> $@
	$(_V) $(_V)for i in $(BASE_FILENAME); do echo "`echo $$i | cut -d_ -f2` = $$i.grf" >> $@; done

	@echo "" >> $@
	@echo "[md5s]" >> $@
	$(_V)for i in $(GRF_FILES); do printf "%-18s = %s\n" $$i `$(GRFID) $(GRFID_FLAGS) $$i` >> $@; done

	@echo "" >> $@
	@echo "[origin]" >> $@
	@echo "$(REPO_ORIGIN)" >> $@

clean::
	$(_E) "[CLEAN OBG]"
	$(_V) -rm -f $(OBG_FILENAME)

endif

################################################################
#
# Target bundle and bundle_tar
#
# Create a tar bundle from the grf and documentation files, useable for OpenTTD.
#
################################################################

FILE_VERSION_STRING ?= $(shell [ -n "$(REPO_TAGS)" ] && echo "$(REPO_TAGS)$(REPO_MODIFIED)" || echo "$(REPO_BRANCH_STRING)v$(NEWGRF_VERSION)$(REPO_MODIFIED)")
DIR_NAME           := $(PROJECT_FILENAME)-$(FILE_VERSION_STRING)
TAR_FILENAME       := $(DIR_NAME).tar

bundle: $(DIR_NAME)
bundle_tar: $(TAR_FILENAME)

$(DIR_NAME): $(GFX_FILES) $(BUNDLE_FILES)
	$(_E) "[BUNDLE] $@"
	$(_V) if [ -e $@ ]; then rm -rf $@; fi
	$(_V) mkdir $@
	$(_V) cp $(CP_FLAGS) $(BUNDLE_FILES) $@

$(TAR_FILENAME): $(DIR_NAME)
	$(_E) "[BUNDLE TAR] $@"
	$(_V) $(TAR) $(TAR_FLAGS) $@ $(DIR_NAME)

clean::
	$(_E) "[CLEAN BUNDLE]"
	$(_V) -rm -rf $(DIR_NAME)
	$(_V) -rm -f $(TAR_FILENAME)


################################################################
#
# Taget bundle_*
#
# Create compressed bundles.
#
################################################################

ZIP_FILENAME       := $(DIR_NAME).zip
BZIP_FILENAME      := $(TAR_FILENAME).bz2
GZIP_FILENAME      := $(TAR_FILENAME).gz
XZ_FILENAME        := $(TAR_FILENAME).xz

bundle_zip: $(ZIP_FILENAME)
%.zip: %.tar
	$(_E) "[BUNDLE ZIP] $@"
	$(_V) $(ZIP) $(ZIP_FLAGS) $@ $< >/dev/null

bundle_bzip: $(BZIP_FILENAME)
%.tar.bz2: %.tar
	$(_E) "[BUNDLE BZIP] $@"
	$(_V) $(BZIP) $(BZIP_FLAGS) $^

bundle_gzip: $(GZIP_FILENAME)
# gzip has no option -k, so we cat the tar to keep it
%.tar.gz: %.tar
	$(_E) "[BUNDLE GZIP] $@"
	$(_V) cat $^ | $(GZIP) $(GZIP_FLAGS) > $@

bundle_xz: $(XZ_FILENAME)
%.tar.xz: %.tar
	$(_E) "[BUNDLE XZ] $@"
	$(_V) $(XZ) $(XZ_FLAGS) $^

clean::
	$(_E) "[CLEAN BUNDLE ARCHIVES]"
	$(_V) -rm -f $(ZIP_FILENAME) $(BZIP_FILENAME) $(GZIP_FILENAME) $(XZ_FILENAME)


################################################################
#
# Taget bananas
#
# Upload bundle to BaNaNaS.
#
################################################################

bananas: $(DIR_NAME)
	$(_E) "[BaNaNaS]"
	$(_V) sed 's/^version *=.*/version = $(FILE_VERSION_STRING)/' $(BANANAS_INI) > $(DIR_NAME).bananas.ini
	$(_V) $(MUSA) $(MUSA_FLAGS) -r -c $(DIR_NAME).bananas.ini $(DIR_NAME)

clean::
	$(_E) "[CLEAN BANANAS]"
	$(_V) -rm -rf $(DIR_NAME).bananas.ini


################################################################
#
# Target check
#
# Check GRFID checksums against previously saved values.
#
################################################################

# Current checksums
MD5_FILENAME       := $(DIR_NAME).md5
# Checksums from source bunlde
MD5_SRC_FILENAME   := $(DIR_NAME).check.md5

$(MD5_SRC_FILENAME) $(MD5_FILENAME): $(GFX_FILES) $(GRF_FILES)
	$(_E) "[GRFID] $@"
	$(_V) -rm -f $@
	$(_V)for i in $(GRF_FILES); do printf "%-18s = %s\n" $$i `$(GRFID) $(GRFID_FLAGS) $$i` >> $@; done

clean::
	$(_E) "[CLEAN GRFID]"
	$(_V) -rm -f $(MD5_FILENAME)

check: $(MD5_FILENAME)
	$(_V) if [ -f $(MD5_SRC_FILENAME) ]; then echo "[CHECKING md5sums]"; else echo "Required file '$(MD5_SRC_FILENAME)' which to test against not found!"; false; fi
	$(_V) if [ -z "`diff $(MD5_FILENAME) $(MD5_SRC_FILENAME)`" ]; then echo "Checksums are equal"; else echo "Differences in checksums:"; echo "`diff $(MD5_FILENAME) $(MD5_SRC_FILENAME)`"; false; fi
	$(_V) rm $(MD5_FILENAME)


################################################################
#
# Target bundle_src
#
# Create source bundle
#
################################################################

ifneq ($(HG),)

DIR_NAME_SRC       := $(DIR_NAME)-source
TAR_FILENAME_SRC   := $(DIR_NAME_SRC).tar
ZIP_FILENAME_SRC   := $(DIR_NAME_SRC).zip

bundle_src: $(TAR_FILENAME_SRC)

$(DIR_NAME_SRC): $(MD5_SRC_FILENAME)
	$(_E) "[BUNDLE SRC] $@"
ifneq ($(REPO_MODIFIED),)
	$(_E) "Cannot create source bundle with uncommitted changes! Aborting."
	$(_V) false
else
	$(_V) if [ -e $@ ]; then rm -rf $@; fi
	$(_V) mkdir $@
	$(_V) HGPLAIN= $(HG) archive $(HG_ARCHIVE_FLAGS) $@
	$(_V) cp $(CP_FLAGS) $(MD5_SRC_FILENAME) Makefile.vcs $@
	$(_V) echo "# Disable VCS version detection" > $@/Makefile.dist
	$(_V) echo "HG =" >> $@/Makefile.dist
endif

$(TAR_FILENAME_SRC): $(DIR_NAME_SRC)
	$(_E) "[BUNDLE SRC TAR] $@"
	$(_V) $(TAR) $(TAR_FLAGS) $@ $(DIR_NAME_SRC)

bundle_bsrc: $(TAR_FILENAME_SRC).bz2
bundle_gsrc: $(TAR_FILENAME_SRC).gz
bundle_xsrc: $(TAR_FILENAME_SRC).xz

bundle_zsrc: $(ZIP_FILENAME_SRC)
$(ZIP_FILENAME_SRC): $(DIR_NAME_SRC)
	$(_E) "[BUNDLE SRC ZIP] $@"
	$(_V) $(ZIP) $(ZIP_FLAGS) $@ $< >/dev/null

clean::
	$(_E) "[CLEAN BUNDLE SRC]"
	$(_V) -rm -rf $(TAR_FILENAME_SRC)
	$(_V) -rm -rf $(TAR_FILENAME_SRC).bz2
	$(_V) -rm -rf $(TAR_FILENAME_SRC).gz
	$(_V) -rm -rf $(TAR_FILENAME_SRC).xz
	$(_V) -rm -rf $(ZIP_FILENAME_SRC)

maintainer-clean::
	$(_E) "[MAINTAINER-CLEAN BUNDLE SRC]"
	$(_V) -rm -rf $(MD5_SRC_FILENAME)

endif


################################################################
#
# Target install
#
# Install the GRF
#
################################################################

# If we are not given an install dir explicitly we'll try to
#    find the default one for the OS we have
ifndef INSTALL_DIR

# Determine the OS we run on and set the default install path accordingly
OSTYPE:=$(shell uname -s)

# Check for OSX
ifeq ($(OSTYPE),Darwin)
INSTALL_DIR :=$(HOME)/Documents/OpenTTD/baseset/$(PROJECT_FILENAME)
endif

# Check for Windows / MinGW32
ifeq ($(shell echo "$(OSTYPE)" | cut -d_ -f1),MINGW32)
# If CC has been set to the default implicit value (cc), check if it can be used. Otherwise use a saner default.
ifeq "$(origin CC)" "default"
	CC=$(shell which cc 2>/dev/null && echo "cc" || echo "gcc")
endif
WIN_VER = $(shell echo "$(OSTYPE)" | cut -d- -f2 | cut -d. -f1)
ifeq ($(WIN_VER),5)
	INSTALL_DIR :=C:\Documents and Settings\All Users\Shared Documents\OpenTTD\baseset\$(PROJECT_FILENAME)
else
	INSTALL_DIR :=C:\Users\Public\Documents\OpenTTD\baseset\$(PROJECT_FILENAME)
endif
endif

# Check for Windows / Cygwin
ifeq ($(shell echo "$(OSTYPE)" | cut -d_ -f1),CYGWIN)
INSTALL_DIR :=$(shell cygpath -A -O)/OpenTTD/baseset/$(PROJECT_FILENAME)
endif

# If non of the above matched, we'll assume we're on a unix-like system
ifeq ($(OSTYPE),Linux)
INSTALL_DIR := $(HOME)/.openttd/baseset/$(PROJECT_FILENAME)
endif

endif

DOCDIR ?= $(INSTALL_DIR)

install: $(DIR_NAME)
ifeq ($(INSTALL_DIR),"")
	$(_E) "No install dir defined! Aborting."
	$(_E) "Try calling 'make install -D INSTALL_DIR=path/to/install_dir'"
	$(_V) false
endif
	$(_E) "[INSTALL] to $(INSTALL_DIR)"
	$(_V) install -d $(INSTALL_DIR)
	$(_V) install -m644 $(GRF_FILES) $(OBG_FILENAME) $(INSTALL_DIR)
ifndef DO_NOT_INSTALL_LICENSE
	$(_V) install -d $(DOCDIR)
	$(_V) install -m644 $(LICENSE_FILE) $(DOCDIR)
endif
ifndef DO_NOT_INSTALL_CHANGELOG
	$(_V) install -d $(DOCDIR)
	$(_V) install -m644 $(CHANGELOG_FILE) $(DOCDIR)
endif
ifndef DO_NOT_INSTALL_README
	$(_V) install -d $(DOCDIR)
	$(_V) install -m644 $(README_FILE) $(DOCDIR)
endif


################################################################
#
# Taget help
#
# Print help on make targets.
#
################################################################

help:
	$(_E) "all:         Build the entire NewGRF and its documentation"
	$(_E) "install:     Install into the default NewGRF directory ($(INSTALL_DIR))"
ifdef DOC_FILES
	$(_E) "doc:         Build the documentation ($(DOC_FILES))"
endif
ifdef GFX_SCRIPT_LIST_FILES
	$(_E) "gfx:         Build the graphics dependencies"
endif
	$(_E) "grf:         Build the grf files only ($(GRF_FILES))"
ifdef PNML_FILES
	$(_E) "nml:         Generate the combined nml files only ($(NML_FILES))"
endif
ifdef OBG_FILENAME
	$(_E) "obg:         Generate the baseset meta data ($(OBG_FILENAME))"
endif
	$(_E)
	$(_E) "clean:       Clean all built files"
	$(_E) "distclean:   Clean really everything"
	$(_E) "maintainer-clean:"
	$(_E) "             Reset the repository to prestine state and delete files which can be generated"
	$(_E)
	$(_E) "Bundles for distribution:"
	$(_E) "bundle_tar:  Build the distritubion bundle as tar archive ($(DIR_NAME).tar)"
	$(_E) "bundle_zip:  Build the distritubion bundle and compress with zip ($(DIR_NAME).tar.zip)"
	$(_E) "bundle_xz:   Build the distritubion bundle and compress with xz ($(DIR_NAME).tar.xz)"
	$(_E) "bundle_gzip: Build the distritubion bundle and compress with gzip ($(DIR_NAME).tar.gz)"
	$(_E) "bundle_bzip: Build the distribution bundle and compress with bzip2 ($(DIR_NAME).tar.bz2)"
	$(_E)
ifneq ($(HG),)
	$(_E) "bundle_src:  Build the source bundle as tar archive for distribution"
	$(_E) "bundle_bsrc: Build the source bundle as tar archive compressed with bzip2"
	$(_E) "bundle_gsrc: Build the source bundle as tar archive compressed with gzip"
	$(_E) "bundle_xsrc: Build the source bundle as tar archive compressed with xz"
	$(_E) "bundle_zsrc: Build the source bundle as tar archive compressed with zip"
	$(_E)
endif
	$(_E) "Release:"
	$(_E) "bananas:     Upload bundle to BaNaNaS
	$(_E)
	$(_E) "Valid command line variables are:"
	$(_E) "Helper programmes:"
	$(_E) "MAKE MAKE_FLAGS.        defaults: $(MAKE) $(MAKE_FLAGS)"
ifdef PNML_FILES
	$(_E) "CC CC_FLAGS.            defaults: $(CC) $(CC_FLAGS)"
endif
	$(_E) "AWK                     defaults: $(AWK)"
	$(_E) "GREP                    defaults: $(GREP)"
	$(_E) "GRFID GRFID_FLAGS.      defaults: $(GRFID) $(GRFID_FLAGS)"
	$(_E) "UNIX2DOS UNIX2DOS_FLAGS defaults: $(UNIX2DOS) $(UNIX2DOS_FLAGS)"
ifdef GFX_SCRIPT_LIST_FILES
	$(_E) "GIMP GIMP_FLAGS         defaults: $(GIMP) $(GIMP_FLAGS)"
endif
	$(_E) "CP_FLAGS (for cp command):        $(CP_FLAGS)"
	$(_E)
	$(_E) "NML NML_FLAGS.          defaults: $(NML) $(NML_FLAGS)"
	$(_E)
	$(_E) "archive and compression programmes:"
	$(_E) "TAR TAR_FLAGS   .       defaults: $(TAR) $(TAR_FLAGS)"
	$(_E) "ZIP ZIP_FLAGS.          defaults: $(ZIP) $(ZIP_FLAGS)"
	$(_E) "GZIP GZIP_FLAGS         defaults: $(GZIP) $(GZIP_FLAGS)"
	$(_E) "BZIP BZIP_FLAGS         defaults: $(BZIP) $(BZIP_FLAGS)"
	$(_E) "XZ XZ_FLAGS             defaults: $(XZ) $(XZ_FLAGS)"
	$(_E)
	$(_E) "INSTALL_DIR             defaults: $(INSTALL_DIR)"
	$(_E) "    Sets the default installation directory for Basesets"

