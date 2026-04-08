#!/bin/bash
# ============================================================
# 3_check.sh
# 全面檢查 YOLO-World 環境、程式碼、權重、資料集是否就緒
# 請在 Login 節點上直接執行：bash 3_check.sh
# ============================================================

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
EXAMPLE_DIR=$(dirname "$SCRIPT_DIR")
ENV_NAME="yolo_world_env"

eval "$(conda shell.bash hook)"
conda activate "$ENV_NAME"

PASS=0
FAIL=0

check() {
    local label="$1"
    local cmd="$2"
    if eval "$cmd" &>/dev/null; then
        echo "  [OK]   $label"
        PASS=$((PASS+1))
    else
        echo "  [FAIL] $label"
        FAIL=$((FAIL+1))
    fi
}

check_file() {
    local label="$1"
    local path="$2"
    if [ -e "$path" ]; then
        echo "  [OK]   $label"
        PASS=$((PASS+1))
    else
        echo "  [FAIL] $label  (找不到: $path)"
        FAIL=$((FAIL+1))
    fi
}

# ============================================================
echo "===================================="
echo "【1】Python 套件檢查"
echo "===================================="
check "Python 3.10+"   "python -c 'import sys; assert sys.version_info >= (3,10)'"
check "torch+CUDA"     "python -c 'import torch; assert torch.cuda.is_available()'"
check "ultralytics"    "python -c 'from ultralytics import YOLOWorld'"
check "supervision"    "python -c 'import supervision'"
check "wandb"          "python -c 'import wandb'"
check "opencv"         "python -c 'import cv2'"
check "mmengine"       "python -c 'import mmengine'"
check "mmdet"          "python -c 'import mmdet'"

# ============================================================
echo ""
echo "===================================="
echo "【2】程式碼 Repo 檢查"
echo "===================================="
check_file "YOLO-World repo"    "$EXAMPLE_DIR/YOLO-World"
check_file "YOLO-World README"  "$EXAMPLE_DIR/YOLO-World/README.md"

# ============================================================
echo ""
echo "===================================="
echo "【3】預訓練權重檢查"
echo "===================================="
check_file "yolov8s-worldv2.pt"  "$EXAMPLE_DIR/weights/yolov8s-worldv2.pt"
check_file "yolov8m-worldv2.pt"  "$EXAMPLE_DIR/weights/yolov8m-worldv2.pt"
check_file "yolov8l-worldv2.pt"  "$EXAMPLE_DIR/weights/yolov8l-worldv2.pt"
check_file "yolov8x-worldv2.pt"  "$EXAMPLE_DIR/weights/yolov8x-worldv2.pt"

# ============================================================
echo ""
echo "===================================="
echo "【4】資料集檢查"
echo "===================================="
check_file "COCO128 images"     "$EXAMPLE_DIR/datasets/coco128/images/train2017"
check_file "COCO128 labels"     "$EXAMPLE_DIR/datasets/coco128/labels/train2017"
check_file "coco128_local.yaml" "$EXAMPLE_DIR/coco128_local.yaml"

# ============================================================
echo ""
echo "===================================="
echo "【5】YOLO-World 功能快速驗證（載入模型 + set_classes）"
echo "===================================="
check "YOLOWorld 模型載入" \
    "python -c \"
from ultralytics import YOLOWorld
m = YOLOWorld('$EXAMPLE_DIR/weights/yolov8l-worldv2.pt')
m.set_classes(['person','car','dog'])
print('model OK')
\""

# ============================================================
echo ""
echo "===================================="
TOTAL=$((PASS+FAIL))
echo "檢查結果：$PASS / $TOTAL 項通過"
if [ $FAIL -eq 0 ]; then
    echo "✅ 全部通過！可以提交 SLURM 任務："
    echo "   sbatch 1_yoloworld_infer_single.sb"
    echo "   sbatch 2_yoloworld_finetune_multigpu.sb"
else
    echo "❌ 有 $FAIL 項未通過，請依序確認："
    echo "   1. bash 1_prepare_conda_env.sh  → 修復套件問題"
    echo "   2. bash 2_prepare_github_data.sh → 修復 Repo / 權重 / 資料集問題"
fi
echo "===================================="
