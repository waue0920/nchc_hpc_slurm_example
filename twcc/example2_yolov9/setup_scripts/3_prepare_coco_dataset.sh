#!/bin/bash
# 3_prepare_coco_dataset.sh
# 此腳本負責去抓取資料集，包含 COCO128 (用於物件偵測) 與 COCO128-seg (用於實例分割)

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_DIR=$(dirname "$SCRIPT_DIR")

# 根據需求，我們將統一資料集放在 example2_yolov9/yolov9/coco 裡面
YOLO_DIR="$BASE_DIR/yolov9"
DATASETS_DIR="$YOLO_DIR/coco"

mkdir -p "$DATASETS_DIR"
cd "$DATASETS_DIR"

echo "========================================="
echo "準備下載並解壓縮 COCO Datasets ..."
echo "========================================="

# 1. 準備 Object Detection Dataset (COCO128)
if [ ! -d "coco128" ]; then
    echo "[*] 下載 COCO128 (約 6.6MB) 作為 Object Detection 測試用途..."
    wget -nc https://github.com/ultralytics/yolov5/releases/download/v1.0/coco128.zip -O coco128.zip
    
    echo "[*] 解壓縮 coco128..."
    unzip -q coco128.zip
    rm coco128.zip
    
    echo "[OK] COCO128 資料集已存放在 $DATASETS_DIR/coco128"
else
    echo "[OK] $DATASETS_DIR/coco128 目錄已存在，跳過下載。"
fi

# 2. 準備 Segmentation Dataset (COCO128-seg)
if [ ! -d "coco128-seg" ]; then
    echo "[*] 下載 COCO128-seg (約 7MB) 作為 Segmentation 測試用途..."
    wget -nc https://github.com/ultralytics/yolov5/releases/download/v1.0/coco128-seg.zip -O coco128-seg.zip
    
    echo "[*] 解壓縮 coco128-seg..."
    unzip -q coco128-seg.zip
    rm coco128-seg.zip
    
    echo "[OK] COCO128-seg 資料集已存放在 $DATASETS_DIR/coco128-seg"
else
    echo "[OK] $DATASETS_DIR/coco128-seg 目錄已存在，跳過下載。"
fi

echo "========================================="
echo "產生 Dataset YAML 配置檔 ..."
echo "========================================="

# 確保 data 目錄存在
mkdir -p "$YOLO_DIR/data"

# 建立給物件偵測用的 yaml
echo "[*] 建立 data/coco128.yaml ..."
cat << 'YAMLEOF' > "$YOLO_DIR/data/coco128.yaml"
# YOLOv9 COCO128 dataset
path: coco/coco128  # dataset root dir (相對於 yolov9 目錄)
train: images/train2017
val: images/train2017

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
YAMLEOF

# 建立給實例分割用的 yaml
echo "[*] 建立 data/coco128-seg.yaml ..."
cat << 'YAMLEOF' > "$YOLO_DIR/data/coco128-seg.yaml"
# YOLOv9 COCO128 Segmentation dataset
path: coco/coco128-seg  # dataset root dir (相對於 yolov9 目錄)
train: images/train2017
val: images/train2017

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
YAMLEOF

echo "[OK] YAML 設定檔產生完畢！"
echo "========================================="
echo "Dataset 準備完成！請繼續執行 4_check_yolo9_all.sh"
echo "========================================="
