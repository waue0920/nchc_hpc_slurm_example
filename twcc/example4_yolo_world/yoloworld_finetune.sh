#!/bin/bash
# ============================================================
# yoloworld_finetune.sh
# YOLO-World 多 GPU 微調封裝腳本（torchrun DDP）
# 由 2_yoloworld_finetune_multigpu.sb 透過 srun 呼叫
# ============================================================

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR"

# ---- SLURM 環境變數 ----
if [ -z "$NGPU" ]; then
    NGPU=$(nvidia-smi -L | wc -l)
fi
NNODES=${SLURM_NNODES:-1}
NODE_RANK=${SLURM_NODEID:-0}
if [ -z "$MASTER_ADDR" ]; then
    MASTER_ADDR=$(scontrol show hostname $SLURM_NODELIST | head -n 1)
fi
MASTER_PORT=$(( 10000 + (${SLURM_JOB_ID:-9527} % 50000) ))
DEVICE_LIST=$(seq -s, 0 $(($NGPU-1)))

echo "Debug Information:"
echo "==================="
echo "Hostname:     $(hostname)"
echo "NNODES:       $NNODES"
echo "NODE_RANK:    $NODE_RANK"
echo "NGPU:         $NGPU"
echo "DEVICE_LIST:  $DEVICE_LIST"
echo "MASTER_ADDR:  $MASTER_ADDR"
echo "MASTER_PORT:  $MASTER_PORT"
echo "==================="

# ---- 環境載入（三選一）----

# 方法一：Conda（預設）
eval "$(conda shell.bash hook)"
conda activate yolo_world_env
EXEC_ENV=""

# 方法二：Singularity
# SIF=/work1/<YOUR_ACCOUNT>/containers/yolo_world.sif
# EXEC_ENV="singularity exec --nv $SIF"

echo "Python: $($EXEC_ENV python --version)"
echo "==================="

# ---- 微調超參數 ----
EPOCHS=10
BATCH_SIZE=16
IMG_SIZE=640
MODEL_SIZE="l"   # s / m / l / x

# ---- torchrun 微調命令 ----
FT_CMD="$EXEC_ENV torchrun \
    --nproc_per_node=$NGPU \
    --nnodes=$NNODES \
    --node_rank=$NODE_RANK \
    --master_addr=$MASTER_ADDR \
    --master_port=$MASTER_PORT \
    finetune.py \
    --model_size $MODEL_SIZE \
    --epochs $EPOCHS \
    --batch $BATCH_SIZE \
    --imgsz $IMG_SIZE \
    --device $DEVICE_LIST"

echo "執行微調命令:"
echo "$FT_CMD"
echo "==================="
$FT_CMD

if [ $? -ne 0 ]; then
    echo "Error: finetune.py 執行失敗 (node: $(hostname))" >&2
    exit 1
fi
echo "微調完成！模型已儲存至 runs/detect/ 目錄。"
