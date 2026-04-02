#!/bin/bash
# 1_prepare_conda_env.sh
# 準備 Conda 環境與安裝您提供的 requirements.txt

# 載入 conda 指令
eval "$(conda shell.bash hook)"

ENV_NAME="newyolo9t2"

# 1. 檢查並建立 Conda 環境
if ! conda info --envs | grep -q "^$ENV_NAME "; then
    echo "========================================="
    echo "1. 建立 Conda 環境: $ENV_NAME (Python 3.10)"
    echo "========================================="
    conda create -n $ENV_NAME python=3.10 -y
else
    echo "========================================="
    echo "1. Conda 環境 $ENV_NAME 已存在，跳過建立步驟。"
    echo "========================================="
fi

# 2. 啟動環境
conda activate $ENV_NAME

# 3. 根據您特調的 requirements.txt 安裝套件
# ※ 切記：這裡明確使用您提供的版本，不使用 YOLOv9 Github 原版的 requirements.txt
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REQ_FILE="$SCRIPT_DIR/requirements.txt"

if [ -f "$REQ_FILE" ]; then
    echo "========================================="
    echo "2. 使用本地特調的 requirements.txt 安裝套件..."
    echo "========================================="
    # 依照 requirements.txt 第一行的提示
    pip install --upgrade-strategy only-if-needed -r "$REQ_FILE"
else
    echo "[!] 找不到 $REQ_FILE，請確認檔案位置！"
    exit 1
fi

echo "========================================="
echo "環境準備完成！請繼續執行 2_prepare_yolov9_github.sh"
echo "========================================="
