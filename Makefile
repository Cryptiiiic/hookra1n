build_release: | clean release
build_debug: | clean debug
.PHONY: build_release

release:
	xcrun clang -arch x86_64 -DNDEBUG -Os -std=gnu11 -Wno-sizeof-pointer-div -isysroot $(shell xcrun --sdk macosx --show-sdk-path) $(wildcard src/*.c) -Iinclude -shared -masm=intel -L/usr/local/lib -lsubstitute -o hookra1n.dylib
debug:
	xcrun clang -arch x86_64 -DDEBUG -g -O0 -std=gnu11 -Wno-sizeof-pointer-div -isysroot $(shell xcrun --sdk macosx --show-sdk-path) $(wildcard src/*.c) -Iinclude -shared -masm=intel -L/usr/local/lib -lsubstitute -o hookra1n.dylib
clean:
	rm -rf hookra1n.dylib
