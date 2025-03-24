#!/bin/bash

### 參數設定區 ###
WORKDIR=~/nchc_hpc_slurm_example/f1/example1_checkenv

## 工作目錄
HOSTNAME=$(hostname | cut -d '.' -f 1)
echo "[$HOSTNAME]==================="
echo "[$HOSTNAME][0] !First: the workspace"
cd $WORKDIR
echo "[$HOSTNAME][0] WORKDIR=$WORKDIR"

## 設定 NCCL
export NCCL_DEBUG=INFO

## SLURM 環境
NPROC_PER_NODE=${SLURM_GPUS_ON_NODE:-1}
NNODES=${SLURM_NNODES:-1}
NODE_RANK=${SLURM_NODEID:-0}
if [ -z "$MASTER_ADDR" ]; then
    echo "oh! why MASTER_ADDR not found!"
    MASTER_ADDR=$(scontrol show hostname $SLURM_NODELIST | head -n 1)
fi

#NGPU=$SLURM_GPUS_ON_NODE #這個值常抓不到
#NGPU=$NPROC_PER_NODE # NPROC_PER_NODE是gpu數但在這邊也抓錯
if [ -z "$NGPU" ]; then
    echo "oh! why NPROC_PER_NODE not found!"
    NGPU=$(nvidia-smi -L | wc -l)  # 等於 $SLURM_GPUS_ON_NODE
fi

MASTER_PORT=9527
DEVICE_LIST=$(seq -s, 0 $(($NGPU-1)) | paste -sd, -) # 0,1,...n-1
NNODES=${SLURM_NNODES:-1}               # 節點總數，默認為 1
NODE_RANK=${SLURM_NODEID}            # 當前節點的 rank，默認為 0

echo "[$HOSTNAME][1] Debug Information:"
echo "-------------------"
echo "[$HOSTNAME][1] SLURM_NODEID: $NODE_RANK"
echo "[$HOSTNAME][1] SLURM_NNODES: $NNODES"
echo "[$HOSTNAME][1] SLURM_GPUS_ON_NODE: $NGPU"
echo "[$HOSTNAME][1] Device: $DEVICE_LIST"
echo "[$HOSTNAME][1] MASTER_ADDR: $MASTER_ADDR"
echo "[$HOSTNAME][1] MASTER_PORT: $MASTER_PORT"
echo "[$HOSTNAME][1] Current Hostname: $(hostname)"
echo "-------------------"
### 環境檢查區 ###
## Debug: 確認 Python 路徑與版本
echo "[$HOSTNAME][2] Python Path and Version:"
echo "-------------------"
which python
python --version
echo "[$HOSTNAME][2] PYTHONPATH: $PYTHONPATH"
echo "-------------------"


echo "[$HOSTNAME][2] Activated Conda Environment:"
echo "-------------------"
python -c "import sys; print('\n'.join(sys.path))"
wandb login
python -c 'import wandb'
python -c 'import torch; print(torch.__version__)'
echo "[$HOSTNAME][3] env.py"
python env.py
echo "-------------------"


## 檢查執行結果
if [ $? -ne 0 ]; then
  echo "Error: TRAIN_CMD execution failed on node $(hostname)" >&2
  exit 1
fi

echo "[$HOSTNAME]==================="
