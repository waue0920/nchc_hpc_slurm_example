#!/bin/bash

# 環境設定
module purge
module load singularity || true

# SIF路徑
SIF=/work/waue0920/open_access/miniweather_nvhpc_20250409.sif
SINGULARITY="singularity run --nv $SIF"

# MPI 環境變數配置
export OMPI_MCA_btl_tcp_if_include=ib0
export OMPI_MCA_pml=ob1
export OMPI_MCA_btl=self,tcp
export PMIX_MCA_gds=^ds12
export OMPI_MCA_btl_base_warn_component_unused=0
export OMPI_MCA_btl_vader_single_copy_mechanism=none
export OMPI_MCA_rmaps_base_mapping_policy=slot
export OMPI_MCA_hwloc_base_binding_policy=none
export OMPI_MCA_mpi_leave_pinned=true
export OMPI_MCA_rmaps_base_oversubscribe=true

# 計算節點 GPU Fallback (AGENTS.md rule)
NGPU=${SLURM_GPUS_ON_NODE:-$(nvidia-smi -L | wc -l)}
echo "Number of GPUs on node: $NGPU"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"

echo "==============================="

# 執行指令
cmd="srun -N $SLURM_JOB_NUM_NODES --gres=gpu:$NGPU --mpi=pmix --gpus-per-task=1 --gpu-bind=closest env CUDA_VISIBLE_DEVICES=0 $SINGULARITY mpirun ./largeweather_openacc"
echo $cmd
$cmd
