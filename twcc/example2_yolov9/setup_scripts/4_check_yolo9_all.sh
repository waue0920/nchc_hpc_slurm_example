#!/bin/bash
# 4_check_yolo9_all.sh
# 檢查上述 1~3 的前置準備工作是否完整

echo "========================================="
echo "=== 開始檢查 YOLOv9 Training 準備狀態 ==="
echo "========================================="

# 1. 檢查 Conda 環境
eval "$(conda shell.bash hook)"
ENV_NAME="newyolo9t2"
if conda info --envs | grep -q "^$ENV_NAME "; then
    echo "[OK] (1/4) Conda 環境 '$ENV_NAME' 存在。"
else
    echo "[FAIL] (1/4) Conda 環境 '$ENV_NAME' 找不到！請重新執行 1_prepare_conda_env.sh"
    FAIL_FLAG=1
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_DIR=$(dirname "$SCRIPT_DIR")
YOLO_DIR="$BASE_DIR/yolov9"

# 2. 檢查 YOLOv9 Source Code (依賴使用者需求，只用他的結構)
if [ -f "$YOLO_DIR/train_dual.py" ]; then
    echo "[OK] (2/4) YOLOv9 source code (train_dual.py 等腳本) 存在。"
else
    echo "[FAIL] (2/4) YOLOv9 source code 不存在！請執行 2_prepare_yolov9_github.sh"
    FAIL_FLAG=1
fi

# 3. 檢查 Pretrained Model Weights (.pt) 從 GitHub 抓取下來的
if [ -f "$YOLO_DIR/weights/yolov9-c.pt" ]; then
    echo "[OK] (3/4) Pretrain model (weights/yolov9-c.pt) 存在。"
else
    echo "[FAIL] (3/4) Pretrain model 不存在！請執行 2_prepare_yolov9_github.sh"
    FAIL_FLAG=1
fi

# 4. 檢查 Dataset
if [ -d "$YOLO_DIR/coco/coco128" ] || [ -d "$YOLO_DIR/coco" ]; then
    echo "[OK] (4/4) Dataset 存在 ($YOLO_DIR/coco/)"
else
    echo "[FAIL] (4/4) Dataset 不存在！請檢查 3_prepare_coco_dataset.sh"
    FAIL_FLAG=1
fi

echo "========================================="
if [ -z "$FAIL_FLAG" ]; then
    echo "恭喜！所有的前置準備工作皆已完成 (All Checked)。"
    echo "您可以放心進入 Phase 2 的分散式訓練 (例如修改 .sh 的 WORKDIR 並 sbatch)。"
else
    echo "警告：有些準備步驟尚未完成，請修復上述 [FAIL] 項目！"
fi
echo "========================================="
