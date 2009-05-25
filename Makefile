# Makefile for the 2cc train set

MAKEFILELOCAL=Makefile.local
MAKEFILECONFIG=Makefile.config

SHELL = /bin/sh

include ${MAKEFILECONFIG}

# OS detection: Cygwin vs Linux
ISCYGWIN = $(shell [ ! -d /cygdrive/ ]; echo $$?)
NFORENUM = $(shell [ \( $(ISCYGWIN) -eq 1 \) ] && echo renum.exe || echo renum)
GRFCODEC =  $(shell [ \( $(ISCYGWIN) -eq 1 \) ] && echo grfcodec.exe || echo grfcodec)

# this overrides definitions from above:
-include ${MAKEFILELOCAL}

# Now, the fun stuff:

# Target for all:
all : obj

test : 
	@echo "Call of nforenum:             $(NFORENUM) $(NFORENUM_FLAGS)"
	@echo "Call of grfcodec:             $(GRFCODEC) $(GRFCODEC_FLAGS)"
	@echo "Local installation directory: $(GRFDIR)"

obj : grf
	@echo "Not updating MD5sums yet".
	@echo "Please fix them yourself!"

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
