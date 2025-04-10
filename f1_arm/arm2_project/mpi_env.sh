#!/bin/bash

echo "==============================="
echo "       節點資訊 :  $(hostname)"
echo "==============================="
echo "-----------------"
echo " * . SLURM 環境參數"
echo "-----------------"
env | grep SLURM

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

## 方法1: 這種呼叫法， output.nc 會出現在 miniWeather 中
#cd ~/nchc_hpc_slurm_example/f1/miniWeather/
#CMD="./miniweather-mpi"

## 方法2: 這種呼叫法， output.nc 會出現在當前目錄
CMD="~/nchc_hpc_slurm_example/f1/miniWeather/miniweather-mpi"

## 執行
$CMD
echo "==============================="
