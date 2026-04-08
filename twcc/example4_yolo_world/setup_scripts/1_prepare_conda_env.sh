#!/bin/bash
# ============================================================
# 1_prepare_conda_env.sh
# 在 Login 節點上建立 YOLO-World 所需的 Conda 環境
# 請直接執行: bash 1_prepare_conda_env.sh
# ============================================================

ENV_NAME="yolo_world_env"
PYTHON_VER="3.10"

echo "===================================="
echo "建立 Conda 環境: $ENV_NAME (Python $PYTHON_VER)"
echo "===================================="

eval "$(conda shell.bash hook)"

if conda env list | grep -q "^${ENV_NAME}"; then
    echo "[SKIP] 環境 $ENV_NAME 已存在，跳過建立步驟。"
else
    conda create -y -n "$ENV_NAME" python="$PYTHON_VER"
    echo "[OK] 環境建立完成。"
fi

conda activate "$ENV_NAME"

echo "===================================="
echo "安裝 PyTorch (CUDA 12.1)"
echo "===================================="
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

echo "===================================="
echo "安裝 ultralytics (YOLO-World 已整合其中)"
echo "===================================="
pip install ultralytics supervision

echo "===================================="
echo "安裝輔助套件"
echo "===================================="
pip install wandb Pillow opencv-python-headless

echo "===================================="
echo "[完成] 所有套件安裝完畢！"
echo "執行 bash 2_prepare_github_data.sh 下載程式碼與資料。"
echo "===================================="
