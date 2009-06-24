# Makefile for OpenGFX set

MAKEFILELOCAL=Makefile.local
MAKEFILECONFIG=Makefile.config

SHELL = /bin/sh

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

# Now, the fun stuff:

# Target for all:
all : $(OBG_FILE)

test : 
	@echo "Call of nforenum:             $(NFORENUM) $(NFORENUM_FLAGS)"
	@echo "Call of grfcodec:             $(GRFCODEC) $(GRFCODEC_FLAGS)"
	@echo "Local installation directory: $(INSTALLDIR)"
	@echo "Repository revision:          r$(GRF_REVISION)"
	@echo "GRF title:                    $(GRF_TITLE)"
	@echo "GRF filenames:                $(GRF_FILENAMES)"
	@echo "nfo files:                    $(NFO_FILENAMES)"
	@echo "pnfo files:                   $(PNFO_FILENAMES)"
	@echo "Bundle files:                 $(BUNDLE_FILES)"
	@echo "Bundle filenames:             Tar=$(TAR_FILENAME) Zip=$(ZIP_FILENAME) Bz2=$(BZIP_FILENAME)"
	@echo "Dirs (nightly/release/base):  $(DIR_NIGHTLY) / $(DIR_RELEASE) / $(DIR_BASE)"
	@echo "===="

$(OBG_FILE) : $(GRF_FILENAMES)
	@echo "Generating $(OBG_FILE)"
	@echo "[metadata]" > $(OBG_FILE)
	@echo "name        = $(GRF_NAME)" >> $(OBG_FILE)
	@echo "shortname   = $(GRF_SHORTNAME)" >> $(OBG_FILE)
	@echo "version     = $(GRF_REVISION)" >> $(OBG_FILE)
	@echo "description = $(GRF_DESCRIPTION) [$(GRF_TITLE)]" >> $(OBG_FILE)
	@echo "palette     = $(GRF_PALETTE)" >> $(OBG_FILE)

	@echo "" >> $(OBG_FILE)
	@echo "[files]" >> $(OBG_FILE)
	@for i in $(subst =, ,$(join $(foreach var,$(FILETYPE),"$(var)=" ), $(foreach var,$(GRF_FILENAMES),"$(var)"))); do printf "%-8s = %s\n" $$i >> $(OBG_FILE); done

	@echo "" >> $(OBG_FILE)
	@echo "[md5s]" >> $(OBG_FILE)
	@for i in $(GRF_FILENAMES); do printf "%-18s = %s\n" $$i `$(MD5SUM) $$i | cut -f1 -d\  ` >> $(OBG_FILE); done

	@echo "" >> $(OBG_FILE)
	@echo "[origin]" >> $(OBG_FILE)
	@echo "$(GRF_ORIGIN)" >> $(OBG_FILE)
	@echo "$(OBG_FILE) generated."
	

# Compile GRF
%.grf : $(SPRITEDIR)/%.nfo
	@echo "$@"
	@echo "$?"
	@echo "Compiling $@"
#	for i in $(FILENAMES); do $(GRFCODEC) ${GRFCODEC_FLAGS} $$i.nfo; done
	-$(GRFCODEC) $(GRFCODEC_FLAGS) $(notdir $<)
	@echo
	
# NFORENUM process copy of the NFO
%.nfo : %.pnfo
	@echo "this is $?, all is $@, dependency $<"
	@echo "Preparing $?"
	cp $< $@
	@echo "NFORENUM processing $@"
#	-for i in $(FILENAMES); do $(NFORENUM) ${NFORENUM_FLAGS} $$i.nfo; done
	-$(NFORENUM) $(NFORENUM_FLAGS) $@
	
%.pnfo:

# Prepare the nfo file	
#$(PNFO_FILENAMES) : 
#	@echo "Preparing $@"
#	cp $@ $(subst $@,.$(PNFO_SUFFIX),.$(NFO_SUFFIX))
#	for i in $(FILENAMES); do cp $(SPRITEDIR)/$$i.pnfo $(SPRITEDIR)/$$i.nfo; done
#	@echo "Adding version information to source..."
#	@echo "Not yet implemented. Please check!"
#	cat $(NFODIR)/*.nfo > $(SPRITEDIR)/$(GRF_FILENAME).nfo.pre
# replace the place holders for version and name by the respective variables:
#	sed s/{{VERSION}}/'$(GRF_VERSION)'/ $(SPRITEDIR)/$(GRF_FILENAME).nfo.pre | sed s/{{NAME}}/'$(GRF_NAME)'/ > $(SPRITEDIR)/$(GRF_FILENAME).nfo
#	@echo	
		
# Clean the source tree
# Clean the source tree
clean:
	@echo "Cleaning source tree:"
	@echo "Remove backups:"
	-rm -rf *.orig *.pre *.bak *.grf *~ $(GRF_FILENAME)* $(SPRITEDIR)/$(GRF_FILENAME).*
	
$(DIR_NIGHTLY) $(DIR_RELEASE) : $(BUNDLE_FILES)
	@echo "Creating dir $@."
	@-mkdir $@ 2>/dev/null
	@-rm $@/* 2>/dev/null
	@echo "Copying files: $(BUNDLE_FILES)"
	@-for i in $(BUNDLE_FILES); do cp $$i $@; done	
#	Uncomment that line, when docs/readme.txt exists which automatically can be updated wrt version
#	@-cat $(READMEFILE) | sed -e "s/$(GRF_TITLE_DUMMY)/$(GRF_TITLE)/" > $@/$(notdir $(READMEFILE))
bundle: $(DIR_NIGHTLY)

%.$(TAR_SUFFIX): % $(BUNDLE_FILES)
	# Create the release bundle with all files in one tar
	@echo "Basename: $(basename $@) (and $(DIR_NIGHTLY) and $(DIR_RELEASE))"
	$(TAR) $(TAR_FLAGS) $@ $(basename $@)
	@echo "Creating tar for publication"
	@echo
bundle_tar: $(TAR_FILENAME)

bundle_zip: $(ZIP_FILENAME)
$(ZIP_FILENAME): $(DIR_NAME)
	@echo "creating zip'ed tar archive"
	$(ZIP) $(ZIP_FLAGS) $(ZIP_FILENAME) $(DIR_NAME)

bundle_bzip: $(BZIP_FILENAME)
$(BZIP_FILENAME): $(TAR_FILENAME)
	@echo "creating bzip2'ed tar archive"
	$(BZIP) $(BZIP_FLAGS) $(TAR_FILENAME)

# Installation process
install: $(TAR_FILENAME) $(INSTALLDIR)
	@echo "Installing grf to $(INSTALLDIR)"
	-cp $(TAR_FILENAME) $(INSTALLDIR)
	@echo
	
release: $(DIR_RELEASE) $(DIR_RELEASE).$(TAR_SUFFIX)
	@echo "Creating release bundle $(DIR_RELEASE) and tar"
release-install: release
	@echo "Installing $(DIR_RELEASE) to $(INSTALLDIR)"
	-cp $(DIR_RELEASE).$(TAR_SUFFIX) $(INSTALLDIR)
	@echo
release_zip: $(DIR_RELEASE)
	$(ZIP) $(ZIP_FLAGS) $(ZIP_FILENAME) $@
	
$(INSTALLDIR):
	@echo "$(error Installation dir does not exist. Check your makefile.local)"
	
remake: clean all
