#!/bin/bash
## HemePure AVX512 + OMP 优化编译脚本 (Intel 编译器)

set -e

source ./env.sh

echo "========================================"
echo "🚀 Building with AVX512 + OpenMP (Intel)"
echo "========================================"

#=====================
# 编译依赖
#=====================
build_dep() {
  echo -e "\n🚀 Building dependencies..."
  cd dep
  rm -rf build && mkdir build && cd build
  cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_BUILD_TYPE=Release

  make -j
  cd ../..
  echo "✅ Dependencies done"
}

#=====================
# 编译主程序 - AVX512 + OpenMP (Intel 编译器)
#=====================
build_src() {
  echo -e "\n🚀 Building main HemePure with AVX512 + OMP..."
  cd src
  FOLDER=build_AVX512_OMP
  rm -rf $FOLDER && mkdir $FOLDER && cd $FOLDER

  # 开启 AVX512（一次处理8个double = 64字节）显著减少 ld/sd 指令数量
  # 开启 OpenMP 支持多线程并行
  # 保持默认边界条件配置（与 build_PP_Benchmark 一致）
  cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DHEMELB_USE_GMYPLUS=OFF \
    -DHEMELB_USE_MPI_WIN=OFF \
    -DHEMELB_USE_SSE3=OFF \
    -DHEMELB_USE_AVX2=OFF \
    -DHEMELB_USE_AVX512=ON \
    -DCMAKE_CXX_FLAGS="-qopenmp -xCORE-AVX512 -O3 -fno-alias"

  make -j8
  cd ../..
  echo "✅ HemePure build_AVX512_OMP done"
}

#=====================
# 开始编译
#=====================
build_dep
build_src

echo -e "\n🎉 AVX512 + OpenMP BUILD SUCCESSFUL (Intel)"
echo "Binary location: src/build_AVX512_OMP/hemepure"