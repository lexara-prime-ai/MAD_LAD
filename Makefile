# Variables
LLC = llc
GCC = gcc
LFLAGS = -lws2_32
OBJ = server.obj
EXE = server.exe
SOURCE = basic_web_server.ll

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
