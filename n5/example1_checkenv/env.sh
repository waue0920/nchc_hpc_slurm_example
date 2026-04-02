#!/bin/bash

echo "==============================="
echo "       節點資訊 :  $(hostname)"
echo "==============================="
echo " * . GPU 資源檢查"
echo "-----------------"
echo "SLURM_JOB_GPUS=$SLURM_JOB_GPUS"
echo "SLURM_GPUS_PER_NODE=$SLURM_GPUS_PER_NODE"
echo "SLURM_GPUS_ON_NODE=$SLURM_GPUS_ON_NODE"
echo "* 可用 GPU 檢查 (nvidia-smi)"
nvidia-smi --list-gpus

echo ""
echo "-----------------"
echo " * . SLURM 環境參數"
echo "-----------------"
env | grep SLURM

echo "-----------------"
echo " * . 所有環境變數"
echo "-----------------"
env

echo "檢查完成！"
echo "==============================="
