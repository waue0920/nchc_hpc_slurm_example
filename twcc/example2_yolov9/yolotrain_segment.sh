#!/bin/bash

### 參數設定區 ###
## 工作目錄
WORKDIR=/home/waue0920/yolov9
cd $WORKDIR

## 設定 NCCL 
export NCCL_DEBUG=INFO
#export NCCL_DEBUG_SUBSYS=ALL

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
wandb login
python -c 'import wandb'
python -c 'import torch; print(torch.__version__)'
echo "==================="
echo "env.py"
python env.py
echo "==================="

### 執行訓練命令 ###
## 超參數設定
NBatch=256    # v100 超過 254會failed
NEpoch=50       # 約 20 mins / per Epoch
NWorker=16       # cpu = gpu x 4, worker < cpu


## 訓練 segment/train_dual.py 命令 (動態設置 nproc_per_node 和 nnodes)
TRAIN_CMD="torchrun --nproc_per_node=$NGPU --nnodes=$NNODES --node_rank=$NODE_RANK --master_addr=$MASTER_ADDR --master_port=$MASTER_PORT \
         segment/train_dual.py --workers $NWorker --device $DEVICE_LIST --batch $NBatch \
         --data data/coco.yaml --img 640 --cfg models/segment/yolov9-c-dseg.yaml \
         --weights '' --name gelan-c-seg --hyp hyp.scratch-high.yaml --no-overlap \
         --epochs $NEpoch --close-mosaic 10"


## 印出完整的訓練命令
echo "Executing Training Command:"
echo "$TRAIN_CMD"
echo "==================="
$TRAIN_CMD


## 檢查執行結果
if [ $? -ne 0 ]; then
  echo "Error: TRAIN_CMD execution failed on node $(hostname)" >&2
  exit 1
fi

