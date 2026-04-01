#!/bin/bash
echo ""
echo ""
echo "==============================="
echo "  hi 計算節點來了 :  $(hostname)"
echo "======($(hostname) 開始)======"
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

echo "檢查完成！"
echo "=====($(hostname) 結束)======"
echo ""
echo ""