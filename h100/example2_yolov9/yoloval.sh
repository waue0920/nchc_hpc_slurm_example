#!/bin/bash

# 切換到工作目錄
WORKDIR=/home/waue0920/yolov9
cd $WORKDIR

# 設置必要的環境變數
export NCCL_DEBUG=INFO

# 從 SLURM 環境變數抓取參數
GPUS_NUM=$(nvidia-smi -L | wc -l)  # 等於 $SLURM_GPUS_ON_NODE
NNODES=${SLURM_NNODES:-1}               # 節點總數，默認為 1
NODE_RANK=${SLURM_NODEID}            # 當前節點的 rank，默認為 0

# 確定 MASTER_ADDR 無法slurm參數來，需要透過 sbatch.sb 去 export 參數過來
MASTER_PORT=9527  # 固定的通信端口

# 打印當前節點資訊
echo "Running on node $(hostname)"
echo "SLURM_NODEID=$NODE_RANK"
echo "SLURM_NNODES=$NNODES"
echo "SLURM_GPUS_ON_NODE=$SLURM_GPUS_ON_NODE"
echo "MASTER_ADDR=$MASTER_ADDR"
echo "MASTER_PORT=$MASTER_PORT"

# 訓練命令 (動態設置 nproc_per_node 和 nnodes)
TRAIN_CMD="python val.py --data data/coco.yaml --img 640 --batch 32 --conf 0.001 --iou 0.7 --device 0 --weights yolo.pt --save-json --name yolov9_c_c_640_val"

# 打印即將執行的命令行
echo "Executing command: $TRAIN_CMD"

# 執行訓練命令，並檢查是否成功
$TRAIN_CMD
if [ $? -ne 0 ]; then
	echo "Error: TRAIN_CMD execution failed on node $(hostname)" >&2
	exit 1
fi
