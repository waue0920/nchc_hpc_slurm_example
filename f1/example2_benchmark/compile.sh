#!/bin/bash
# compile.sh - 負責編譯 MPI 程式

module purge
module load gcc/10.4.0
module load apps/chem/gromacs/2023.4/openmpi/5.0.1

echo "Compiling mpi_ring_benchmark.c ..."
mpicc -O3 mpi_ring_benchmark.c -o mpi_ring_benchmark
echo "Done! The executable './mpi_ring_benchmark' is ready."
