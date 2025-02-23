#!/bin/bash
set -euxo pipefail

export MODEL=dolly-v2-3b
export QUANTIZATION=q3f16_0

rustup target add aarch64-apple-ios
rustup target add x86_64-apple-ios

mkdir -p build/ && cd build/

cmake ../..\
  -DCMAKE_BUILD_TYPE=Release\
  -DCMAKE_SYSTEM_NAME=iOS\
  -DCMAKE_SYSTEM_VERSION=16.0\
  -DCMAKE_OSX_SYSROOT=iphoneos\
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"\
  -DCMAKE_OSX_DEPLOYMENT_TARGET=16.0\
  -DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON\
  -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON\
  -DCMAKE_INSTALL_PREFIX=.\
  -DCMAKE_CXX_FLAGS="-O3"\
  -DMLC_LLM_INSTALL_STATIC_LIB=ON\
  -DUSE_METAL=ON
make mlc_llm_static
cmake --build . --target install --config release -j
cd ..

rm -rf build/tvm_home
ln -s ../3rdparty/tvm build/tvm_home

python prepare_model_lib.py
