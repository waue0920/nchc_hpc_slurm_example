#!/bin/bash
# compile.sh - 負責編譯 MPI 程式 (不跑運算)

# 由於 Taiwania 1 CPU 通常預設搭配 Intel MPI 或 OpenMPI，此處先載入 OpenMPI 模組作為範例 (視實際環境可能改 intel/2018)
module purge
module load compiler/gnu/8.3.0
module load mpi/openmpi/4.1.1-gnu

echo "Compiling mpi_ring_benchmark.c ..."
mpicc -O3 mpi_ring_benchmark.c -o mpi_ring_benchmark
echo "Done! The executable './mpi_ring_benchmark' is ready."
