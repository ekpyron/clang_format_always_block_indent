#!/bin/bash -e

ROOTDIR="$(realpath "$(dirname "$0")")"

mkdir -p build
pushd build

rm -rf llvm
mkdir llvm
pushd llvm

cmake \
	-G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${ROOTDIR}"/build \
	-DLLVM_BUILD_STATIC=ON \
	-DLLVM_BUILD_TOOLS=OFF \
	-DLLVM_ENABLE_LIBEDIT=OFF \
	-DLLVM_ENABLE_LIBPFM=OFF \
	-DLLVM_ENABLE_LIBXML2=OFF \
	-DLLVM_ENABLE_OCAMLDOC=OFF \
	-DLLVM_ENABLE_PLUGINS=OFF \
	-DLLVM_ENABLE_TERMINFO=OFF \
	-DLLVM_ENABLE_ZLIB=OFF \
	-DLLVM_ENABLE_ZSTD=OFF \
	-DLLVM_INCLUDE_BENCHMARKS=OFF \
	-DLLVM_INCLUDE_DOCS=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INCLUDE_TOOLS=OFF \
	-DLLVM_INCLUDE_UTILS=OFF \
	../../llvm-project/llvm
ninja
sed -i -e 's/EXISTS "\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}\/bin\/llvm-tblgen"/FALSE/' utils/TableGen/cmake_install.cmake
ninja install

popd

rm -rf clang
mkdir clang
pushd clang

# clang builds have issues with some locale settings
export LC_ALL=C
export LC_ADDRESS=C
export LC_MEASUREMENT=C
export LC_MONETARY=C
export LC_NAME=C
export LC_NUMERIC=C
export LC_PAPER=C
export LC_TELEPHONE=C
export LC_TIME=C
cmake \
	-G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${ROOTDIR}"/build \
	-DCMAKE_PREFIX_PATH="${ROOTDIR}"/build \
    -DCLANG_LINK_CLANG_DYLIB=OFF \
    -DLLVM_BUILD_STATIC=ON \
    -DENABLE_LINKER_BUILD_ID=ON \
    -DLLVM_BUILD_DOCS=OFF \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_ENABLE_RTTI=OFF \
    -DLLVM_ENABLE_SPHINX=OFF \
    -DLIBCLANG_BUILD_STATIC=ON \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DCLANG_ENABLE_LIBXML2=OFF \
    -DCLANG_INCLUDE_TESTS=OFF \
    -DCLANG_PLUGIN_SUPPORT=OFF \
    -DLLVM_EXTERNAL_LIT=/usr/bin/lit \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_LINK_LLVM_DYLIB=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DCLANG_ENABLE_ARCMT=OFF \
    -DLLVM_LIBRARY_DIR="${ROOTDIR}"/build/lib \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
    -DLLVM_MAIN_SRC_DIR="${ROOTDIR}/llvm-project/llvm" \
    -DCMAKE_CXX_FLAGS="-s -flto" \
    -DSPHINX_WARNINGS_AS_ERRORS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS=-static \
    -DLLVM_INCLUDE_TESTS=OFF \
    ../../llvm-project/clang
ninja ${MAKEFLAGS} clang-format
install -m755 bin/clang-format "${ROOTDIR}"/build


popd
popd
