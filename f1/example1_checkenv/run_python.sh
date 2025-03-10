#!/bin/bash

### 參數設定區 ###
## 工作目錄
WORKDIR=/home/waue0920/yolov9
cd $WORKDIR

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

echo "Debug Information:"
echo "==================="
echo "SLURM_NODEID: $NODE_RANK"
echo "SLURM_NNODES: $NNODES"
echo "SLURM_GPUS_ON_NODE: $NGPU"
echo "Device: $DEVICE_LIST"
echo "MASTER_ADDR: $MASTER_ADDR"
echo "MASTER_PORT: $MASTER_PORT"
echo "Current Hostname: $(hostname)"
echo "==================="
### 環境檢查區 ###
## Debug: 確認 Python 路徑與版本
echo "Python Path and Version:"
echo "==================="
which python
python --version
echo "PYTHONPATH: $PYTHONPATH"
echo "==================="


echo "Activated Conda Environment:"
echo "==================="
python -c "import sys; print('\n'.join(sys.path))"
python -c 'import torch; print(torch.__version__)'
echo "==================="
echo "env.py"
python env.py
echo "==================="


## 檢查執行結果
if [ $? -ne 0 ]; then
  echo "Error: TRAIN_CMD execution failed on node $(hostname)" >&2
  exit 1
fi
