#!/usr/bin/env bash

set -e

mkdir -p build/local

CMAKE_ARGS=()

# CMake-level configuration
CMAKE_ARGS+=("-DCMAKE_BUILD_TYPE=Release")
CMAKE_ARGS+=("-DCMAKE_POSITION_INDEPENDENT_CODE=ON")

# If Ninja is installed, prefer it to Make
if [ -x "$(command -v ninja)" ]
then
  CMAKE_ARGS+=("-GNinja")
fi

# Use-specified CMake arguments go last to allow overridding defaults
CMAKE_ARGS+=($@)

cd build/local && cmake ../.. \
    "${CMAKE_ARGS[@]}"

# Cross-platform parallel build
if [ "$(uname)" == "Darwin" ]; then
  cmake --build . -- "-j$(sysctl -n hw.ncpu)"
elif [ "$(uname)" == "Linux" ]; then
  cmake --build . -- "-j$(nproc)"
else
  cmake --build .
fi
