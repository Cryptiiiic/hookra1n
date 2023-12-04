build_release: | clean release
build_debug: | clean debug
.PHONY: build_release

release:
	xcrun clang -DNDEBUG -Os -std=gnu11 -flto=thin -Wno-sizeof-pointer-div -isysroot $(shell xcrun --sdk macosx --show-sdk-path) $(wildcard src/*.c) -Iinclude -shared -o hookra1n.dylib -arch x86_64 -Iexternal/rd_route external/rd_route/rd_route.c -masm=att
	mv hookra1n{,_x86_64}.dylib
	xcrun clang -DNDEBUG -Os -std=gnu11 -flto=thin -Wno-sizeof-pointer-div -isysroot $(shell xcrun --sdk macosx --show-sdk-path) $(wildcard src/*.c) -Iinclude -shared -o hookra1n.dylib -arch arm64 -L/usr/local/lib -lsubstitute
	mv hookra1n{,_arm64}.dylib
	strip -x hookra1n_x86_64.dylib
	strip -x hookra1n_arm64.dylib
	codesign -f -s - hookra1n_x86_64.dylib
	codesign -f -s - hookra1n_arm64.dylib
	lipo -create -arch x86_64 hookra1n_x86_64.dylib -arch arm64 hookra1n_arm64.dylib -output hookra1n.dylib
	codesign -f -s - hookra1n.dylib
	rm -rf hookra1n_arm64.dylib hookra1n_x86_64.dylib || true
debug:
	xcrun clang -DDEBUG -g -O0 -fsanitize=address -fsanitize-address-use-after-scope -fno-omit-frame-pointer -std=gnu11 -Wno-sizeof-pointer-div -isysroot $(shell xcrun --sdk macosx --show-sdk-path) $(wildcard src/*.c) -Iinclude -shared -o hookra1n.dylib -arch x86_64 -Iexternal/rd_route external/rd_route/rd_route.c -masm=intel
	mv hookra1n{,_x86_64}.dylib
	xcrun clang -DDEBUG -g -O0 -fsanitize=address -fsanitize-address-use-after-scope -fno-omit-frame-pointer -std=gnu11 -Wno-sizeof-pointer-div -isysroot $(shell xcrun --sdk macosx --show-sdk-path) $(wildcard src/*.c) -Iinclude -shared -o hookra1n.dylib -arch arm64 -L/usr/local/lib -lsubstitute
	mv hookra1n{,_arm64}.dylib
	codesign -f -s - hookra1n_x86_64.dylib
	codesign -f -s - hookra1n_arm64.dylib
	lipo -create -arch x86_64 hookra1n_x86_64.dylib -arch arm64 hookra1n_arm64.dylib -output hookra1n.dylib
	codesign -f -s - hookra1n.dylib
	rm -rf hookra1n_arm64.dylib hookra1n_x86_64.dylib || true
clean:
	rm -rf hookra1n.dylib hookra1n_arm64.dylib hookra1n_x86_64.dylib || true
