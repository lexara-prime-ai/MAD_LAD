# Variables
LLC = llc
GCC = gcc
LFLAGS = -lws2_32

# Allow input and output file paths to be passed in via arguments
OUTPUT_DIR ?= .
BASE_NAME = $(basename $(notdir $(SOURCE)))

# Object and executable file names based on BASE_NAME
OBJ = $(OUTPUT_DIR)/$(BASE_NAME).obj
EXE = $(OUTPUT_DIR)/$(BASE_NAME).exe

# Ensure SOURCE is provided as an argument
ifeq ($(SOURCE),)
$(error SOURCE is not defined. Please pass SOURCE as an argument, e.g., make SOURCE=<input>.ll)
endif

# Default target
all: $(EXE)

$(EXE): $(OBJ)
	$(GCC) $(OBJ) -o $(EXE) $(LFLAGS)

$(OBJ): $(SOURCE)
	$(LLC) -filetype=obj $(SOURCE) -o $(OBJ)

# Clean target
clean:
	rm -f $(OBJ) $(EXE)

.PHONY: all clean