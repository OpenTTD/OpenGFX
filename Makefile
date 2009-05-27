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
-include ${MAKEFILELOCAL}

# Now, the fun stuff:

# Target for all:
all : obj

test : 
	@echo "Call of nforenum:             $(NFORENUM) $(NFORENUM_FLAGS)"
	@echo "Call of grfcodec:             $(GRFCODEC) $(GRFCODEC_FLAGS)"
	@echo "Local installation directory: $(INSTALLDIR)"
	@echo "Repository revision:          r$(GRF_REVISION)"
	@echo "GRF title:                    $(GRF_TITLE)"
	@echo "===="

obj : grf
	@echo "Generating $(OBG_FILE)"
	@echo "Not updating MD5sums yet".
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
		"[md5]" >> $(OBG_FILE)
	for i in $(FILENAMES); do echo "$$i.grf = "`$(MD5SUM) $$i.grf | cut -f1 -d\  ` >> $(OBG_FILE); done
	@echo -e \
		"\n[origin]\n"\
		"$(GRF_ORIGIN)\n"\
		 >> $(OBG_FILE)
	@echo "$(OBG_FILE) generated."
	

# Compile GRF
grf : renumber
	@echo "Compiling GRFs:"
	for i in $(FILENAMES); do $(GRFCODEC) ${GRFCODEC_FLAGS} $$i.nfo; done
	@echo
	
# NFORENUM process copy of the NFO
renumber : 
	@echo "NFORENUM processing:"
	-for i in $(FILENAMES); do $(NFORENUM) ${NFORENUM_FLAGS} $$i.nfo; done
	@echo
	
# Prepare the nfo file	
nfo : 
	@echo renaming preliminary files
	for i in $(FILENAMES); do cp $(SPRITEDIR)/$$i.pnfo $(SPRITEDIR)/$$i.nfo; done
	@echo "Adding version information to source..."
	@echo "Not yet implemented. Please check!"
#	cat $(NFODIR)/*.nfo > $(SPRITEDIR)/$(GRF_FILENAME).nfo.pre
# replace the place holders for version and name by the respective variables:
#	sed s/{{VERSION}}/'$(GRF_VERSION)'/ $(SPRITEDIR)/$(GRF_FILENAME).nfo.pre | sed s/{{NAME}}/'$(GRF_NAME)'/ > $(SPRITEDIR)/$(GRF_FILENAME).nfo
	@echo	
		
# Clean the source tree
clean:
	@echo "Cleaning source tree:"
	@echo "Remove backups:"
	-rm *.bak
	-rm *.orig
	-rm log
	-rm $(SPRITEDIR)/*.bak
	-rm $(NFODIR)/*.bak
	-rm $(NFODIR)/*/*.orig
	-rm $(NFODIR)/*.orig
	-rm $(SPRITEDIR)/*.pre
	-for i in $(MAINDIRS); do rm $$i/*.orig; done
	@echo
	@echo "Remove compiled .grf:"
	-rm *.grf
	@echo
	@echo "Removing old logs:"
	-rm *.log

# Installation process
install:
	@echo "Installing grf to $(INSTALLDIR)"
	-cp $(GRF_FILENAME).grf $(INSTALLDIR)/$(GRF_FILENAME).grf
	@echo
