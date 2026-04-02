#!/bin/bash

### 參數設定區 ###
## 工作目錄
# 動態取得腳本所在目錄，並切換進入 setup_scripts 幫我們準備好的 yolov9 內部
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WORKDIR="$SCRIPT_DIR/yolov9"
cd "$WORKDIR"

## 設定 NCCL # NCCL除錯用，log量會暴增
# export NCCL_DEBUG=TRACE
# export NCCL_DEBUG_SUBSYS=ALL

## SLURM 環境
NPROC_PER_NODE=${SLURM_GPUS_ON_NODE:-1}
NNODES=${SLURM_NNODES:-1}
NODE_RANK=${SLURM_NODEID:-0}
if [ -z "$MASTER_ADDR" ]; then
    MASTER_ADDR=$(scontrol show hostname $SLURM_NODELIST | head -n 1)
fi

#NGPU=$SLURM_GPUS_ON_NODE #這個值常抓不到
#NGPU=$NPROC_PER_NODE # NPROC_PER_NODE是gpu數但在這邊也抓錯
if [ -z "$NGPU" ]; then
    NGPU=$(nvidia-smi -L | wc -l)  # 等於 $SLURM_GPUS_ON_NODE
fi

# 使用 SLURM_JOBID 動態產生 Port 號，避免多任務 Port 衝突且保證多節點端口一致
MASTER_PORT=$(( 10000 + (${SLURM_JOB_ID:-9527} % 50000) ))

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

### 環境選擇區 (三選一，為了支援多節點派發) ### 

# 方法一： Conda 環境 (透過 activate)
eval "$(conda shell.bash hook)"
conda activate newyolo9t2
EXEC_ENV=""

# 方法二： Singularity 容器環境
# SIF=/work/waue0920/open_access/yolo9t2_ngc2306_20241226.sif
# EXEC_ENV="singularity exec --nv $SIF"

# 方法三： Conda run
# CONDA_EXE=$(which conda)
# EXEC_ENV="$CONDA_EXE run -n newyolo9t2 --no-capture-output"


### 環境檢查區 ### 
## Debug: 確認 Python 路徑與版本
echo "Python Path and Version:"
echo "==================="
$EXEC_ENV python --version
echo "==================="

### 執行訓練命令 ###
## 超參數設定
NBatch=16    # v100 超過 254會failed
NEpoch=10       # 約 20 mins / per Epoch
NWorker=16       # cpu = gpu x 4, worker < cpu

## 訓練 train_dual.py 命令 (動態設置 nproc_per_node 和 nnodes)
TRAIN_CMD="$EXEC_ENV torchrun --nproc_per_node=$NGPU --nnodes=$NNODES --node_rank=$NODE_RANK --master_addr=$MASTER_ADDR --master_port=$MASTER_PORT \
         train_dual.py --workers $NWorker --device $DEVICE_LIST --batch $NBatch \
         --data data/coco128.yaml --img 640 --cfg models/detect/yolov9-c.yaml \
         --weights weights/yolov9-c.pt --name yolov9-c --hyp hyp.scratch-high.yaml --min-items 0 \
         --epochs $NEpoch --close-mosaic 15"


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
