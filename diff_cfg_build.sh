#!/bin/bash

# 确保使用 Intel oneAPI 编译器 (icx/icpx)
# 如果环境变量未设置，请取消下面两行的注释
# export CC=mpiicx
# export CXX=mpiicpx

# ==============================
# 版本1：纯标量（无任何向量）
# ==============================
build_benchmark_NO_VECTOR() {
  echo -e "\n🚀 版本 1：纯标量（无向量）"
  cd src
  FOLDER=build_PP_Benchmark_NO_VECTOR
  rm -rf $FOLDER && mkdir $FOLDER && cd $FOLDER

  cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_CXX_FLAGS="-mno-avx512f -mno-avx512bw -mno-avx512vl -mno-avx2 -mno-avx -mno-sse3 -fno-vectorize" \
    -DCMAKE_C_FLAGS="-mno-avx512f -mno-avx512bw -mno-avx512vl -mno-avx2 -mno-avx -mno-sse3 -fno-vectorize" \
    -DHEMELB_USE_SSE3=OFF \
    -DHEMELB_USE_AVX2=OFF \
    -DHEMELB_USE_AVX512=OFF

  make -j8
  cd ../../
}

# ==============================
# 版本2：SSE3
# ==============================
build_benchmark_SSE3() {
  echo -e "\n🚀 版本 2：SSE3"
  cd src
  FOLDER=build_PP_Benchmark_SSE3
  rm -rf $FOLDER && mkdir $FOLDER && cd $FOLDER

  cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_CXX_FLAGS="-msse3 -mno-avx512f -mno-avx512bw -mno-avx512vl -mno-avx2 -mno-avx -fno-vectorize" \
    -DCMAKE_C_FLAGS="-msse3 -mno-avx512f -mno-avx512bw -mno-avx512vl -mno-avx2 -mno-avx -fno-vectorize" \
    -DHEMELB_USE_SSE3=ON \
    -DHEMELB_USE_AVX2=OFF \
    -DHEMELB_USE_AVX512=OFF

  make -j8
  cd ../../
}

# ==============================
# 版本3：AVX2 (+FMA)
# ==============================
build_benchmark_AVX2() {
  echo -e "\n🚀 版本 3：AVX2"
  cd src
  FOLDER=build_PP_Benchmark_AVX2
  rm -rf $FOLDER && mkdir $FOLDER && cd $FOLDER

  cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_CXX_FLAGS="-mavx2 -mfma -mno-avx512f -mno-avx512bw -mno-avx512vl -fno-vectorize" \
    -DCMAKE_C_FLAGS="-mavx2 -mfma -mno-avx512f -mno-avx512bw -mno-avx512vl -fno-vectorize" \
    -DHEMELB_USE_SSE3=ON \
    -DHEMELB_USE_AVX2=ON \
    -DHEMELB_USE_AVX512=OFF

  make -j8
  cd ../../
}

# ==============================
# 版本4：AVX-512 (针对 8280: f/bw/vl)
# ==============================
build_benchmark_AVX512() {
  echo -e "\n🚀 版本 4：AVX512"
  cd src
  FOLDER=build_PP_Benchmark_AVX512
  rm -rf $FOLDER && mkdir $FOLDER && cd $FOLDER

  cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_CXX_FLAGS="-mavx512f -mavx512bw -mavx512vl -fno-vectorize" \
    -DCMAKE_C_FLAGS="-mavx512f -mavx512bw -mavx512vl -fno-vectorize" \
    -DHEMELB_USE_SSE3=ON \
    -DHEMELB_USE_AVX2=ON \
    -DHEMELB_USE_AVX512=ON

  make -j8
  cd ../../
}

# 开始编译
build_benchmark_NO_VECTOR
build_benchmark_SSE3
build_benchmark_AVX2
build_benchmark_AVX512

