#!/bin/bash
#SBATCH -J Heme_AVX512_OMP
#SBATCH -p iris
#SBATCH -N 1
#SBATCH -n 28                  # 28进程 x 2线程 = 56 线程
#SBATCH -t 1:00:00
#SBATCH -o log_avx512_omp_%j.out
#SBATCH --exclusive

source ./env.sh

EXE=./src/build_AVX512_OMP/hemepure
INPUT=./cases/Bifurcation-TINY/input_PP.xml
OUT=./result/test_avx512_omp

rm -rf $OUT

# OpenMP 配置
# - 使用 2 线程/进程 (28 * 2 = 56 线程)
# - OMP_PROC_BIND=close: 将线程绑定到相近的核心
# - OMP_PLACES=cores: 使用核心作为 place
export OMP_NUM_THREADS=2
export OMP_PROC_BIND=close
export OMP_PLACES=cores

# 内存策略优化
export KMP_AFFINITY=granularity=fine,balanced

# Intel MPI 优化配置
# - 使用 PUNAME 绑定（每个进程绑定到对应 NUMA 节点）
# - compact 顺序：连续进程绑定到连续核心
mpirun -np 28 \
  -genv I_MPI_PIN_DOMAIN=numa \
  -genv I_MPI_PIN_ORDER=compact \
  -genv OMP_NUM_THREADS=2 \
  $EXE -in $INPUT -out $OUT