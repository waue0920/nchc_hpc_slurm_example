#!/bin/bash
# run.sh - 負責編譯、環境載入與執行

# 1) 先載入環境模組 (確保後續的編譯與執行都能找到正確的 mpicc/srun)
module purge
module load gcc/11.2.0
module load apps/chem/gromacs/2023.4/openmpi/5.0.1

echo "-> Environment Loaded."
echo "   Current SLURM Configuration:"
echo "   Node List = $SLURM_NODELIST"
echo "   Total MPI Tasks = $SLURM_NTASKS"

# 2) 執行編譯 (此時環境已就緒)
echo "-> Starting Compilation..."
mpicc -O3 mpi_ring_benchmark.c -o mpi_ring_benchmark
echo "-> Compilation Done."

# 3) 真正的 MPI 執行指令
echo "-> Launching MPI Ring Benchmark with PMIX..."
srun --mpi=pmix ./mpi_ring_benchmark
