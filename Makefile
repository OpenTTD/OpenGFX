# Generic NewGRF Makefile

# Name of the Makefile which contains all the settings which describe
# how to make this newgrf. It defines all the paths, the grf name,
# the files for a bundle etc.
MAKEFILE=Makefile
MAKEFILE_DEP=Makefile.dep

# Include the project's configuration file
include Makefile.config

# this overrides definitions from above by individual settings
# (if applicable):
-include Makefile.dist
-include Makefile.local

# include the universal Makefile definitions for NewGRF Projects
include scripts/Makefile.def

# Check dependencies for building all:
all: $(TARGET_FILES) $(DOC_FILES)
	
# Rules used by all projects
include scripts/Makefile.common

# Include the project type specific Makefiles. They take care of
# their conditional inclusion themselves
-include scripts/Makefile_nfo # nfo-style projects
-include scripts/Makefile_nml # nml-style projects
-include scripts/Makefile_obg # additionally for graphic base sets
-include scripts/Makefile_obs # sound base sets

# Include repo-specific rules (if applicable)
-include Makefile.in
-include scripts/Makefile.in

# Include rules for bundle generation
include scripts/Makefile.bundles

# Include dependencies (if applicable)
-include Makefile.dep
-include $(patsubst %.grf,%.src.dep,$(GRF_FILES))
-include $(patsubst %.grf,%.gfx.dep,$(GRF_FILES))