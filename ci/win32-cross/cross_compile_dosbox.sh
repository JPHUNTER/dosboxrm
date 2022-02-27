#!/bin/bash

set -e
set -x

INSTALL_PREFIX='/usr/i686-w64-mingw32'
TOOLCHAIN='i686-w64-mingw32'

export PATH="$INSTALL_PREFIX/bin:$PATH"

cd ../../dosbox-0.74-3
./autogen.sh
./configure --host="$TOOLCHAIN" --prefix="$INSTALL_PREFIX" --with-sdl-prefix="$INSTALL_PREFIX" \
  --enable-core-inline LDFLAGS="-static-libgcc -static-libstdc++ -s" LIBS="-lvorbisfile -lvorbis -logg"
make -j

