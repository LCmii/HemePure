#!/bin/bash
## HemePure 完整编译脚本（Intel 优化版）
## 功能 100% 和你原来一样，只切换到 Intel MPI

set -e

#=====================
# 加载环境
#=====================
source ./env.sh

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
  cd ../../
  echo "✅ Dependencies done"
}

#=====================
# 编译主程序（你的原版配置完全保留）
#=====================
build_src() {
  echo -e "\n🚀 Building main HemePure..."
  cd src
  FOLDER=build_PV
  rm -rf $FOLDER && mkdir $FOLDER && cd $FOLDER

  cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DHEMELB_USE_GMYPLUS=OFF \
    -DHEMELB_USE_MPI_WIN=OFF \
    -DHEMELB_USE_SSE3=ON \
    -DHEMELB_USE_AVX2=ON \
    -DHEMELB_OUTLET_BOUNDARY=LADDIOLET \
    -DHEMELB_WALL_OUTLET_BOUNDARY=LADDIOLETBFL \
    -DHEMELB_USE_VELOCITY_WEIGHTS_FILE=OFF

  make -j8
  cd ../../
  echo "✅ HemePure build_PV done"
}

#=====================
# 编译 Benchmark（你的原版配置完全保留）
#=====================
build_benchmark() {
  echo -e "\n🚀 Building Benchmark..."
  cd src
  FOLDER=build_PP_Benchmark
  rm -rf $FOLDER && mkdir $FOLDER && cd $FOLDER

  cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DHEMELB_USE_GMYPLUS=OFF \
    -DHEMELB_USE_MPI_WIN=OFF \
    -DHEMELB_USE_SSE3=ON \
    -DHEMELB_USE_AVX2=ON

  make -j8
  cd ../../
  echo "✅ HemePure build_PP_Benchmark done"
}

#=====================
# 开始编译
#=====================
build_dep
build_src
build_benchmark

echo -e "\n🎉 ALL COMPILED SUCCESSFULLY (Intel + Intel MPI)"
echo "Binary location: src/build_PP_Benchmark/hemepure"

