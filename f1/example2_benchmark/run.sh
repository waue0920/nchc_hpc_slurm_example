#!/bin/bash
# run.sh - 單純負責環境載入與執行（遵守職責分離）

# 載入和編譯時一樣的 MPI 環境模組
module purge
module load compiler/gnu/8.3.0
module load mpi/openmpi/4.1.1-gnu

echo "-> Current SLURM Configuration:"
echo "   Node List = $SLURM_NODELIST"
echo "   Total MPI Tasks = $SLURM_NTASKS"

# 真正的 MPI 執行指令
echo "-> Launching MPI Ring Benchmark..."
srun ./mpi_ring_benchmark
