#!/bin/bash

# 切換到工作目錄
WORKDIR=/home/waue0920/yolov9
cd $WORKDIR

# 設置必要的環境變數
export NCCL_DEBUG=INFO

# 打印當前節點資訊
echo "Running on node $(hostname)"
echo "SLURM_NODEID=$SLURM_NODEID"
echo "SLURM_PROCID=$SLURM_PROCID"
echo "MASTER_ADDR=$MASTER_ADDR"

# 訓練命令
TRAIN_CMD="python -m torch.distributed.launch --nproc_per_node=8 --nnodes=2 \
	--node_rank=$SLURM_NODEID --master_addr=$MASTER_ADDR --master_port=9527 \
	train_dual.py --workers 16 --sync-bn --batch 64 --data data/coco.yaml --img 640 \
	--cfg models/detect/yolov9-c.yaml --weights '' --name yolov9-c \
	--hyp hyp.scratch-high.yaml --min-items 0 --epochs 500 --close-mosaic 15"

# 打印即將執行的命令行
echo "Executing command: $TRAIN_CMD"

# 執行訓練命令
#$TRAIN_CMD
