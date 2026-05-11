#!/bin/bash
## HemePure AVX512 + OMP 优化编译脚本 (GCC version)

set -e

echo "========================================"
echo "🚀 Building with AVX512 + OpenMP (GCC)"
echo "========================================"

#=====================
# 编译依赖
#=====================
build_dep() {
  echo -e "\n🚀 Building dependencies..."
  cd dep
  rm -rf build && mkdir build && cd build
  cmake .. \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_BUILD_TYPE=Release

  make -j
  cd ../..
  echo "✅ Dependencies done"
}

#=====================
# 编译主程序 - AVX512 + OpenMP
#=====================
build_src() {
  echo -e "\n🚀 Building main HemePure with AVX512 + OMP..."
  cd src
  FOLDER=build_AVX512_OMP
  rm -rf $FOLDER && mkdir $FOLDER && cd $FOLDER

  # 开启 AVX512（一次处理8个double = 64字节）显著减少 ld/sd 指令数量
  # 开启 OpenMP 支持多线程并行
  cmake .. \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DHEMELB_USE_GMYPLUS=OFF \
    -DHEMELB_USE_MPI_WIN=OFF \
    -DHEMELB_USE_SSE3=OFF \
    -DHEMELB_USE_AVX2=OFF \
    -DHEMELB_USE_AVX512=ON \
    -DHEMELB_OUTLET_BOUNDARY=LADDIOLET \
    -DHEMELB_WALL_OUTLET_BOUNDARY=LADDIOLETBFL \
    -DHEMELB_USE_VELOCITY_WEIGHTS_FILE=OFF \
    -DCMAKE_CXX_FLAGS="-fopenmp -mavx512f -O3 -fno-alias -march=native"

  make -j8
  cd ../..
  echo "✅ HemePure build_AVX512_OMP done"
}

#=====================
# 开始编译
#=====================
build_dep
build_src

echo -e "\n🎉 AVX512 + OpenMP BUILD SUCCESSFUL"
echo "Binary location: src/build_AVX512_OMP/hemepure"