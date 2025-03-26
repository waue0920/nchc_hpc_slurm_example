#!/bin/bash

echo "==============================="
echo "       節點資訊 :  $(hostname)"
echo "==============================="
echo " * . GPU 資源檢查"
echo "-----------------"
echo "SLURM_JOB_GPUS=$SLURM_JOB_GPUS"
echo "* 可用 GPU 檢查 (nvidia-smi)"

echo ""
echo "-----------------"
echo " * . SLURM 環境參數"
echo "-----------------"
env | grep SLURM

## 方法1: 這種呼叫法， output.nc 會出現在 miniWeather 中
cd ~/nchc_hpc_slurm_example/f1/miniWeather/
CMD="./miniweather-mpi"

## 方法2: 這種呼叫法， output.nc 會出現在當前目錄
#CMD="~/nchc_hpc_slurm_example/f1/miniWeather/miniweather-mpi"

## 執行
$CMD
echo "==============================="
