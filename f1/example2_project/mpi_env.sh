#!/bin/bash

echo "==============================="
echo "       節點資訊 :  $(hostname)"
echo "==============================="
echo "-----------------"
echo " * . SLURM 環境參數"
echo "-----------------"
env | grep SLURM

cd /home/waue0920/nchc_hpc_slurm_example/f1/miniWeather/

export MASTER_ADDR
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


CMD="./miniweather-mpi"

$CMD

echo "==============================="
