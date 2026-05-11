#!/bin/bash
#SBATCH -J Heme_tiny_56p1t
#SBATCH -p iris
#SBATCH -N 1
#SBATCH -n 56                   # 56进程×1线程（标准基线）
#SBATCH -t 1:00:00
#SBATCH -o log_%j.out
#SBATCH --exclusive

source /global/exafs/users/rdmaworkshop10/lc/HemeLB/optimized/HemePure/env.sh

BASE=/global/exafs/users/rdmaworkshop10/lc/HemeLB
EXE=/global/exafs/users/rdmaworkshop10/lc/HemeLB/optimized/HemePure_OMP/src/build_PP_Benchmark/hemepure
INPUT=$BASE/Bifurcation-TINY/input_PP.xml
OUT=/global/exafs/users/rdmaworkshop10/lc/HemeLB/optimized/result/test_tiny_56p_1t

rm -rf $OUT

export OMP_NUM_THREADS=1

mpirun -np 56 \
  -genv I_MPI_PIN_DOMAIN=numa \
  -genv I_MPI_PIN_ORDER=compact \
  $EXE -in $INPUT -out $OUT
