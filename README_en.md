# NCHC HPC SLURM Examples

This repository provides a collection of SLURM batch script examples tailored for various GPU/HPC cluster environments at the National Center for High-performance Computing (NCHC), Taiwan.

## Supported Clusters

*   **twcc/**: Examples for Taiwania 2 (T2), suitable for multi-GPU cloud computing.
*   **n5/**: Examples for Nano5 (H100), optimized for NVIDIA H100 GPU workloads.
*   **f1/**: Examples for F1 (x86-64), suitable for standard HPC tasks.
*   **f1_arm/**: Examples for F1 (ARM64), experimental scripts for ARM-based architectures.

## Repository Structure

Each cluster directory follows a progressive learning path:

1.  **example1_checkenv (Environment Diagnostics)**
    *   Scripts to verify GPU visibility, CPU topology, and SLURM environment variables.
    *   Recommended for initial cluster access testing.
2.  **example2_yolov9 (AI Training)**
    *   Demonstrates multi-node, multi-GPU distributed training using PyTorch (`torchrun`) and YOLOv9.
3.  **example3_miniweather (HPC Workloads)**
    *   Uses the miniWeather simulation to showcase MPI, OpenMP, and OpenACC parallelization.

## Getting Started

### 1. Configure Account and Partition
Before submitting `.sb` (Slurm Batch) scripts, ensure you update the account and partition information:
```bash
#SBATCH --account="GOV113038"    # Replace with your NCHC project account
#SBATCH --partition=gtest        # Select the correct partition for the cluster
```

### 2. Submitting a Job
Use the `sbatch` command to submit your job:
```bash
sbatch 1check_gpu_single.sb
```

### 3. Monitoring Output
Standard logs are usually written to `z_slurm-xxx.log` or as specified in the script headers.

## Key Technologies
*   **Singularity (Apptainer)**: Used for consistent runtime environments. Ensure `.sif` image paths (typically under `/work1/`) are accessible.
*   **MPI Coordination**: Optimized for **InfiniBand (ib0)** and uses **PMIx** for multi-node process management.

## Contributors
*   NCHC Team and associated training program instructors.