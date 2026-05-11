#!/bin/bash
module purge

# 1. 基础工具
module load cmake/3.26.4
module load python/3.12.2

# 2. Intel 主环境
module load intel/2024.2

# 3. 【关键！必须手动加载】Intel LLVM 编译器（icx/icpx）
module load compiler-intel-llvm/2024.2.1

# 4. 【关键！必须手动加载】Intel MPI
module load mpi/2021.13

# ====================== 强制 Intel MPI 调用 Intel 编译器 ======================
# 方法 A：通过环境变量告诉 Intel MPI 底层用 icx/icpx
export I_MPI_CC=icx
export I_MPI_CXX=icpx

# 方法 B：直接用 Intel MPI 给 Intel 编译器做的专用包装器（双保险）
export CC=mpiicx
export CXX=mpiicpx
# ================================================================================

export OMP_NUM_THREADS=1

echo -e "\n====================================="
echo "✅ 真正 Intel 编译器 + Intel MPI 加载成功！"
echo "====================================="
module list

# 🔍 三重验证，确保真的能用
echo -e "\n🔍 验证 1：查找 icx"
which icx

echo -e "\n🔍 验证 2：icx 版本"
icx --version

echo -e "\n🔍 验证 3：查找 mpiicx"
which mpiicx

echo -e "\n🔍 验证 4：mpiicx 版本"
mpiicx --version

