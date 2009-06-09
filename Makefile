# Makefile for the 2cc train set

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

GRF_BUILDNAME= $(shell [ -n "$(REPO_TAGS)" ] && echo $(REPO_TAGS)$(GRF_MODIFIED) || echo $(GRF_NIGHTLYNAME)-r$(GRF_REVISION)$(GRF_MODIFIED))
GRF_TITLE    = $(GRF_NAME) $(GRF_BUILDNAME)
DIR_NAME     = $(GRF_NAME)-$(GRF_BUILDNAME)
TAR_FILENAME = $(DIR_NAME).$(TAR_SUFFIX)
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
	@echo "===="

$(OBG_FILE) : $(GRF_FILENAMES)
	@echo "Generating $(OBG_FILE)"
	@echo -e \
		"[metadata]\n"\
		"name        = $(GRF_NAME)\n"\
		"shortname   = $(GRF_SHORTNAME)\n"\
		"version     = $(GRF_REVISION)\n"\
		"description = $(GRF_DESCRIPTION) [$(GRF_TITLE)]\n"\
		"palette     = $(GRF_PALETTE)\n"\
		"\n"\
		"[files]\n"\
		$(join $(foreach var,$(FILETYPE),"$(var)\t" ), $(foreach var,$(FILENAMES),"=\t$(var).grf\n"))"\n" \
		"[md5s]" > $(OBG_FILE)
	for i in $(FILENAMES); do echo "$$i.grf = "`$(MD5SUM) $$i.grf | cut -f1 -d\  ` >> $(OBG_FILE); done
	@echo -e \
		"\n[origin]\n"\
		"$(GRF_ORIGIN)\n"\
		 >> $(OBG_FILE)
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
clean:
	@echo "Cleaning source tree"
	@-rm -rf *.bak *.orig log $(NFO_FILENAMES) $(GRF_FILENAMES) $(wildcard *.$(TAR_SUFFIX)) $(addsuffix /.*orig,$(MAINDIRS)) $(GRF_NAME)-$(GRF_NIGHTLYNAME)-r* $(OBG_FILE)
	@echo


$(DIR_NAME): $(BUNDLE_FILES)
	@-mkdir $@ 2>/dev/null
	@-for i in $(REPO_DIRS); do [ ! -e $@/$$i ] && mkdir $@/$$i 2>/dev/null; done
	@echo $(BUNDLE_FILES)
	@-for i in $(BUNDLE_FILES); do cp $$i $(DIR_NAME)/$$i; done
	
tar: $(BUNDLE_FILES) $(DIR_NAME)
	@echo "Making tar for use ingame"
	$(TAR) $(TAR_FLAGS) $(TAR_FILENAME) $(DIR_NAME)
zip : tar
	@echo "creating zip'ed tar archive"
	cat $(TAR_FILENAME) | $(ZIP) $(ZIP_FLAGS) > $(ZIP_FILENAME)
bzip: tar
	@echo "creating bzip2'ed tar archive"
	$(BZIP) $(BZIP_FLAGS) $(TAR_FILENAME)

bundle: $(DIR_NAME) tar bzip zip
	@echo "Creating bundle."

# Installation process
install: tar
	@echo "Installing grf to $(INSTALLDIR)"
	-cp $(TAR_FILENAME) $(INSTALLDIR)/$(TAR_FILENAME)
	@echo
	
remake: clean all
