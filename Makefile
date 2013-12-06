FLASCC:=/cygdrive/c/Temp/Crossbridge_1.0.1/sdk
FLASCC_for_java:=$(shell cygpath $(FLASCC) -m)

ALCEXTRA=/cygdrive/c/reps/alcextra
GLS3D=/cygdrive/c/reps/GLS3D
GLS3D_win=$(shell cygpath $(GLS3D) -m)


CXX = $(FLASCC)/usr/bin/g++

SDL_LIB = -L$(FLASCC)/usr/lib -lSDL

SDL_INCLUDE = -I$(FLASCC)/usr/include/SDL

CXXFLAGS = -Wall -O0 -g -c $(SDL_INCLUDE)
LDFLAGS = $(SDL_LIB)



LDFLAGS=-L$(ALCEXTRA)/install/usr/lib/ -swf-version=17 -symbol-abc=Console.abc -jvmopt=-Xmx4G -emit-swf -swf-size=640x480

OGL_LIBS=-l$(GLS3D)/install/usr/lib/libGL.abc -l/cygdrive/c/Temp/lesson01/lesson01/myfs.abc -L$(GLS3D)/install/usr/lib/ -lGL -lz -lvgl -lfreetype -lvorbis -logg -lz

SRC = .
BUILD = build

OUT = out
EXE = $(OUT)/main.swf

all: ffs console $(EXE)

console:
	java -jar $(FLASCC_for_java)/usr/lib/asc2.jar -merge -md -AS3 -strict -optimize \
		-import $(FLASCC_for_java)/usr/lib/builtin.abc \
		-import $(FLASCC_for_java)/usr/lib/playerglobal.abc \
		-import $(GLS3D_win)/install/usr/lib/libGL.abc \
		-import $(FLASCC_for_java)/usr/lib/ISpecialFile.abc \
		-import $(FLASCC_for_java)/usr/lib/IBackingStore.abc \
		-import $(FLASCC_for_java)/usr/lib/IVFS.abc \
		-import $(FLASCC_for_java)/usr/lib/InMemoryBackingStore.abc \
		-import $(FLASCC_for_java)/usr/lib/AlcVFSZip.abc \
		-import $(FLASCC_for_java)/usr/lib/CModule.abc \
		-import $(FLASCC_for_java)/usr/lib/C_Run.abc \
		-import $(FLASCC_for_java)/usr/lib/BinaryData.abc \
		-import $(FLASCC_for_java)/usr/lib/PlayerKernel.abc \
		-import myfs.abc \
		Console.as -outdir ./ -out Console



ffs:
	java -jar  $(FLASCC_for_java)/usr/lib/asc2.jar -merge -md -AS3 -strict -optimize \
	-import $(FLASCC_for_java)/usr/lib/builtin.abc \
	-import $(FLASCC_for_java)/usr/lib/playerglobal.abc \
	-import $(FLASCC_for_java)/usr/lib/BinaryData.abc \
	-import $(FLASCC_for_java)/usr/lib/ISpecialFile.abc \
	-import $(FLASCC_for_java)/usr/lib/IBackingStore.aBC \
	-import $(FLASCC_for_java)/usr/lib/IVFS.abc \
	-import $(FLASCC_for_java)/usr/lib/InMemoryBackingStore.abc \
	-import $(FLASCC_for_java)/usr/lib/PlayerKernel.abc \
	ttt*.as -outdir ./ -out myfs


$(EXE): $(BUILD)/main.o | $(OUT)
	$(CXX) $< $(LDFLAGS) $(SDL_LIB) $(OGL_LIBS)  -o $@

$(BUILD)/main.o: $(SRC)/main.cpp | $(BUILD)
	$(CXX) $(CXXFLAGS) $< -o $@

# Make sure the build directory exists
$(BUILD):
	mkdir -p $(BUILD)

# Make sure the output directory exists
$(OUT):
	mkdir -p $(OUT)

.PHONY: clean
clean:
	rm $(BUILD)/*.o && rm $(EXE)

