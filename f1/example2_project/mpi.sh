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

cd /home/waue0920/nchc_hpc_slurm_example/f1/miniWeather/

CMD="./miniweather-mpi"

$CMD

echo "==============================="
