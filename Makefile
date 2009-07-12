# Makefile for OpenGFX set

MAKEFILELOCAL=Makefile.local
MAKEFILECONFIG=Makefile.config

SHELL = /bin/sh

# Add some OS detection and guess an install path (use the system's default)
OSTYPE=$(shell uname -s)
ifeq ($(OSTYPE),Linux)
INSTALLDIR=$(HOME)/.openttd/data
else 
ifeq ($(OSTYPE),Darwin)
INSTALLDIR=$(HOME)/Documents/OpenTTD/data
else
ifeq ($(shell echo "$(OSTYPE)" | cut -d_ -f1),MINGW32)
INSTALLDIR=C:\Documents and Settings\$(USERNAME)\My Documents\OpenTTD\data
else
INSTALLDIR=
endif
endif
endif

GRF_REVISION = $(shell hg parent --template="{rev}\n")

include ${MAKEFILECONFIG}

# OS detection: Cygwin vs Linux
ISCYGWIN = $(shell [ ! -d /cygdrive/ ]; echo $$?)
NFORENUM = $(shell [ \( $(ISCYGWIN) -eq 1 \) ] && echo renum.exe || echo renum)
GRFCODEC = $(shell [ \( $(ISCYGWIN) -eq 1 \) ] && echo grfcodec.exe || echo grfcodec)

# this overrides definitions from above:
GRF_MODIFIED = $(shell [ -n "`hg status \"." | grep -v '^?'`" ] && echo "M" || echo "")
# " \" (syntax highlighting line
REPO_TAGS    = $(shell hg parent --template="{tags}" | grep -v "tip" | cut -d\  -f1)

-include ${MAKEFILELOCAL}

REPO_DIRS    = $(dir $(BUNDLE_FILES))

-include ${MAKEFILELOCAL}

vpath
vpath %.pfno $(SPRITEDIR)
vpath %.nfo $(SPRITEDIR)

# Now, the fun stuff:

# Target for all:
all : $(OBG_FILE)

test : 
	$(_E) "Call of nforenum:             $(NFORENUM) $(NFORENUM_FLAGS)"
	$(_E) "Call of grfcodec:             $(GRFCODEC) $(GRFCODEC_FLAGS)"
	$(_E) "Local installation directory: $(INSTALLDIR)"
	$(_E) "Repository revision:          r$(GRF_REVISION)"
	$(_E) "GRF title:                    $(GRF_TITLE)"
	$(_E) "GRF filenames:                $(GRF_FILENAMES)"
	$(_E) "Documentation filenames:      $(DOC_FILENAMES)"
	$(_E) "nfo files:                    $(NFO_FILENAMES)"
	$(_E) "pnfo files:                   $(PNFO_FILENAMES)"
	$(_E) "Bundle files:                 $(BUNDLE_FILES)"
	$(_E) "Bundle filenames:             Tar=$(TAR_FILENAME) Zip=$(ZIP_FILENAME) Bz2=$(BZIP_FILENAME)"
	$(_E) "Dirs (nightly/release/base):  $(DIR_NIGHTLY) / $(DIR_RELEASE) / $(DIR_BASE)"
	$(_E) "===="

$(OBG_FILE) : $(GRF_FILENAMES)
	$(_E) "[Generating:] $(OBG_FILE)"
	@echo "[metadata]" > $(OBG_FILE)
	@echo "name        = $(GRF_NAME)" >> $(OBG_FILE)
	@echo "shortname   = $(GRF_SHORTNAME)" >> $(OBG_FILE)
	@echo "version     = $(GRF_REVISION)" >> $(OBG_FILE)
	@echo "description = $(GRF_DESCRIPTION) [$(GRF_TITLE)]" >> $(OBG_FILE)
	@echo "palette     = $(GRF_PALETTE)" >> $(OBG_FILE)

	@echo "" >> $(OBG_FILE)
	@echo "[files]" >> $(OBG_FILE)
	$(_V)for i in $(subst =, ,$(join $(foreach var,$(FILETYPE),"$(var)=" ), $(foreach var,$(GRF_FILENAMES),"$(var)"))); do printf "%-8s = %s\n" $$i >> $(OBG_FILE); done

	@echo "" >> $(OBG_FILE)
	@echo "[md5s]" >> $(OBG_FILE)
	$(_V)for i in $(GRF_FILENAMES); do printf "%-18s = %s\n" $$i `$(MD5SUM) $$i | cut -f1 -d\  ` >> $(OBG_FILE); done

	@echo "" >> $(OBG_FILE)
	@echo "[origin]" >> $(OBG_FILE)
	@echo "$(GRF_ORIGIN)" >> $(OBG_FILE)
	$(_E) "[Done] Basegraphics successfully generated."
	

# Compile GRF
%.$(GRF_SUFFIX) : $(SPRITEDIR)/%.$(NFO_SUFFIX)
	$(_E) "[Generating] $@"
	$(_V)$(GRFCODEC) $(GRFCODEC_FLAGS) $@
	$(_E)
	
# NFORENUM process copy of the NFO
.SECONDARY: %.$(NFO_SUFFIX)
.PRECIOUS: %.$(NFO_SUFFIX)
%.$(NFO_SUFFIX) : %.$(PNFO_SUFFIX)
	$(_E) "[Checking] $@"
	$(_V) cp $< $@
	$(_E) "[nforenum] $@"
	$(_V)-$(NFORENUM) $(NFORENUM_FLAGS) $@
	
# Clean the source tree
clean:
	$(_E) "[Cleaning]"
	$(_V)-rm -rf *.orig *.pre *.bak *.grf *~ $(GRF_FILENAME)* $(SPRITEDIR)/$(GRF_FILENAME).* $(SPRITEDIR)/*.bak $(SPRITEDIR)/*.nfo $(DOC_FILENAMES)
	
$(DIR_NIGHTLY) $(DIR_RELEASE) : $(BUNDLE_FILES)
	$(_E) "[Generating:] $@/."
	$(_V)if [ -e $@ ]; then rm -rf $@; fi
	$(_V)mkdir $@
	$(_V)-for i in $(BUNDLE_FILES); do cp $$i $@; done	
bundle: $(DIR_NIGHTLY)

%.$(TXT_SUFFIX): %.$(PTXT_SUFFIX)
	$(_E) "[Generating:] $@"
	$(_V) cat $< \
		| sed -e "s/$(GRF_TITLE_DUMMY)/$(GRF_TITLE)/" \
		| sed -e "s/$(OBG_FILE_DUMMY)/$(OBG_FILE)/" \
		| sed -e "s/$(REVISION_DUMMY)/$(GRF_REVISION)/" \
		> $@

%.$(TAR_SUFFIX): % $(BUNDLE_FILES)
# Create the release bundle with all files in one tar
	$(_E) "[Generating:] $@"
	$(_V)$(TAR) $(TAR_FLAGS) $@ $(basename $@)
	$(_E)

bundle_tar: $(TAR_FILENAME)
bundle_zip: $(ZIP_FILENAME)
$(ZIP_FILENAME): $(TAR_FILENAME) $(DOC_FILENAMES)
	$(_E) "[Generating:] $@"
	$(_V)$(ZIP) $(ZIP_FLAGS) $@ $^
bundle_bzip: $(BZIP_FILENAME)
$(BZIP_FILENAME): $(TAR_FILENAME)
	$(_E) "[Generating:] $@"
	$(_V)$(BZIP) $(BZIP_FLAGS) $<

# Installation process
install: $(TAR_FILENAME) $(INSTALLDIR)
	$(_E) "[INSTALL] to $(INSTALLDIR)"
	$(_V)-cp $(TAR_FILENAME) $(INSTALLDIR)
	$(_E)
	
release: $(DIR_RELEASE) $(DIR_RELEASE).$(TAR_SUFFIX)
	$(_E) "[RELEASE] $(DIR_RELEASE)"
release-install: release
	$(_E) "[INSTALL] to $(INSTALLDIR)"
	$(_V)-cp $(DIR_RELEASE).$(TAR_SUFFIX) $(INSTALLDIR)
	$(_E)
release_zip: $(DIR_RELEASE).$(TAR_SUFFIX) $(DOC_FILENAMES)
	$(_E) "[Generating:] $(ZIP_FILENAME)"	
	$(_V)$(ZIP) $(ZIP_FLAGS) $(ZIP_FILENAME) $^
	
$(INSTALLDIR):
	$(_E) "$(error Installation dir does not exist. Check your makefile.local)"
	
remake: clean all
