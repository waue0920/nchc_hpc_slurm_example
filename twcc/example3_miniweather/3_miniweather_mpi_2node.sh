#!/bin/bash

module purge
module load singularity || true

SIF=/work/waue0920/open_access/miniweather_nvhpc_20250409.sif
SINGULARITY="singularity run --nv $SIF"

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

NGPU=${SLURM_GPUS_ON_NODE:-$(nvidia-smi -L | wc -l)}
echo "Number of GPUs on node: $NGPU"

cmd="srun -N $SLURM_JOB_NUM_NODES --gres=gpu:$NGPU --mpi=pmix --gpus-per-task=1 --gpu-bind=closest env CUDA_VISIBLE_DEVICES=0,1 $SINGULARITY mpirun ./largeweather_openacc"
echo $cmd
$cmd
