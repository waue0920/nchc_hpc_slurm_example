#!/bin/bash
# ============================================================
# 2_prepare_github_data.sh
# 下載 YOLO-World 相關程式碼、預訓練權重與測試資料集
# 請在 Login 節點上直接執行：bash 2_prepare_github_data.sh
# ============================================================

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# 範例根目錄（setup_scripts 的上一層）
EXAMPLE_DIR=$(dirname "$SCRIPT_DIR")

ENV_NAME="yolo_world_env"
eval "$(conda shell.bash hook)"
conda activate "$ENV_NAME"

echo "===================================="
echo "工作目錄: $EXAMPLE_DIR"
echo "===================================="

# ============================================================
# 1. Clone YOLO-World 官方 Repo
# ============================================================
YOLOWORLD_DIR="$EXAMPLE_DIR/YOLO-World"

echo "[1/4] Clone YOLO-World 官方 Repo..."
if [ -d "$YOLOWORLD_DIR" ]; then
    echo "  [SKIP] $YOLOWORLD_DIR 已存在，執行 git pull 更新..."
    git -C "$YOLOWORLD_DIR" pull
else
    git clone https://github.com/AILab-CVC/YOLO-World.git "$YOLOWORLD_DIR"
    echo "  [OK] Clone 完成：$YOLOWORLD_DIR"
fi

# ============================================================
# 2. 安裝 YOLO-World repo 額外依賴（mmcv 系列）
# ============================================================
echo ""
echo "[2/4] 安裝 YOLO-World repo 依賴（mmcv / mmdet / mmengine）..."
pip install -q openmim
mim install -q mmengine
mim install -q "mmcv>=2.0.0"
mim install -q mmdet
pip install -q -r "$YOLOWORLD_DIR/requirements.txt" 2>/dev/null || true
echo "  [OK] 依賴安裝完成。"

# ============================================================
# 3. 下載預訓練權重（yolov8s/m/l/x-worldv2.pt）
# ============================================================
WEIGHTS_DIR="$EXAMPLE_DIR/weights"
mkdir -p "$WEIGHTS_DIR"

echo ""
echo "[3/4] 下載預訓練權重..."

declare -A WEIGHT_URLS=(
    ["yolov8s-worldv2.pt"]="https://github.com/ultralytics/assets/releases/download/v8.3.0/yolov8s-worldv2.pt"
    ["yolov8m-worldv2.pt"]="https://github.com/ultralytics/assets/releases/download/v8.3.0/yolov8m-worldv2.pt"
    ["yolov8l-worldv2.pt"]="https://github.com/ultralytics/assets/releases/download/v8.3.0/yolov8l-worldv2.pt"
    ["yolov8x-worldv2.pt"]="https://github.com/ultralytics/assets/releases/download/v8.3.0/yolov8x-worldv2.pt"
)

for FNAME in "${!WEIGHT_URLS[@]}"; do
    FPATH="$WEIGHTS_DIR/$FNAME"
    if [ -f "$FPATH" ]; then
        echo "  [SKIP] $FNAME 已存在"
    else
        echo "  下載 $FNAME ..."
        wget -q --show-progress -O "$FPATH" "${WEIGHT_URLS[$FNAME]}"
        echo "  [OK] $FNAME"
    fi
done

# ============================================================
# 4. 下載測試資料集（COCO128，快速功能驗證用）
# ============================================================
DATA_DIR="$EXAMPLE_DIR/datasets"
mkdir -p "$DATA_DIR"

echo ""
echo "[4/4] 下載 COCO128 測試資料集..."

COCO128_ZIP="$DATA_DIR/coco128.zip"
COCO128_DIR="$DATA_DIR/coco128"

if [ -d "$COCO128_DIR" ]; then
    echo "  [SKIP] coco128 已存在：$COCO128_DIR"
else
    wget -q --show-progress \
        -O "$COCO128_ZIP" \
        "https://ultralytics.com/assets/coco128.zip"
    unzip -q "$COCO128_ZIP" -d "$DATA_DIR"
    rm "$COCO128_ZIP"
    echo "  [OK] COCO128 解壓至：$COCO128_DIR"
fi

# 產生對應的 data.yaml（指向本地路徑）
DATA_YAML="$EXAMPLE_DIR/coco128_local.yaml"
cat > "$DATA_YAML" <<EOF
# COCO128 本地資料集設定（由 2_prepare_github_data.sh 自動產生）
path: $DATA_DIR/coco128
train: images/train2017
val:   images/train2017  # coco128 無獨立 val，暫以 train 替代

nc: 80
names:
  0: person
  1: bicycle
  2: car
  3: motorcycle
  4: airplane
  5: bus
  6: train
  7: truck
  8: boat
  9: traffic light
  10: fire hydrant
  11: stop sign
  12: parking meter
  13: bench
  14: bird
  15: cat
  16: dog
  17: horse
  18: sheep
  19: cow
  20: elephant
  21: bear
  22: zebra
  23: giraffe
  24: backpack
  25: umbrella
  26: handbag
  27: tie
  28: suitcase
  29: frisbee
  30: skis
  31: snowboard
  32: sports ball
  33: kite
  34: baseball bat
  35: baseball glove
  36: skateboard
  37: surfboard
  38: tennis racket
  39: bottle
  40: wine glass
  41: cup
  42: fork
  43: knife
  44: spoon
  45: bowl
  46: banana
  47: apple
  48: sandwich
  49: orange
  50: broccoli
  51: carrot
  52: hot dog
  53: pizza
  54: donut
  55: cake
  56: chair
  57: couch
  58: potted plant
  59: bed
  60: dining table
  61: toilet
  62: tv
  63: laptop
  64: mouse
  65: remote
  66: keyboard
  67: cell phone
  68: microwave
  69: oven
  70: toaster
  71: sink
  72: refrigerator
  73: book
  74: clock
  75: vase
  76: scissors
  77: teddy bear
  78: hair drier
  79: toothbrush
EOF
echo "  [OK] 本地 data yaml 產生至: $DATA_YAML"

echo ""
echo "===================================="
echo "[完成] 所有準備作業完畢！"
echo "  Repo:      $YOLOWORLD_DIR"
echo "  權重:      $WEIGHTS_DIR"
echo "  資料集:    $COCO128_DIR"
echo "  Data YAML: $DATA_YAML"
echo ""
echo "請執行 bash 3_check.sh 確認所有項目 [OK]"
echo "===================================="
