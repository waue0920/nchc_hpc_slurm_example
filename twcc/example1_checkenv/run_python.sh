#!/bin/bash

### 必要參數設定 ###
HOSTNAME=$(hostname | cut -d '.' -f 1)

### 切換到腳本所在目錄 ###
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR"

### 環境變數抓取 ###
MASTER_ADDR=$(scontrol show hostname $SLURM_NODELIST | head -n 1)
NGPU=$(nvidia-smi -L | wc -l)

# Port 檢測：檢查 9527 是否被佔用
MASTER_PORT=9527
if (echo >/dev/tcp/localhost/$MASTER_PORT) 2>/dev/null; then
    echo "[$HOSTNAME] ERROR: Port $MASTER_PORT is already in use on $(hostname)!"
    echo "[$HOSTNAME] Please choose a different port or terminate the process using that port."
    exit 1
fi

### 環境資訊輸出 ###
echo "[$HOSTNAME]============================================"
echo "[$HOSTNAME] Working Directory: $SCRIPT_DIR"
echo "[$HOSTNAME] SLURM_NODEID: $SLURM_NODEID"
echo "[$HOSTNAME] SLURM_NNODES: $SLURM_NNODES"
echo "[$HOSTNAME] GPU Count: $NGPU"
echo "[$HOSTNAME] Master Address: $MASTER_ADDR"
echo "[$HOSTNAME] Master Port: $MASTER_PORT"
echo "[$HOSTNAME]============================================"

### 選擇執行環境 (以下三種方法請選擇一種取消註解)

### 方法一： Conda 環境 (透過 activate)
eval "$(conda shell.bash hook)"  # 把整個 conda 環境功能載入當前 shell
conda activate base
python env.py

# ### 方法二： Singularity 容器環境
# SIF=/work/waue0920/open_access/yolo9t2_ngc2306.sif
# singularity exec --nv $SIF python env.py

# ### 方法三： Conda run (預設，不需要 activate)
# CONDA_EXE=$(which conda)             # 獲取 conda 可執行檔路徑，用 conda run 套用環境
# $CONDA_EXE run -n base --no-capture-output python env.py

### 檢查執行結果 ###
if [ $? -ne 0 ]; then
    echo "[$HOSTNAME] Error: env.py execution failed!"
    exit 1
fi

echo "[$HOSTNAME]============================================"
