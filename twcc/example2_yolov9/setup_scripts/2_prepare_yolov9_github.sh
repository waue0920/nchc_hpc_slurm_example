#!/bin/bash
# 2_prepare_yolov9_github.sh
# 準備 YOLOv9 原始碼與預訓練權重 (.pt) 到 ./yolov9 裡面
# 注意：使用者有需求「不要使用 YOLOv9 的 Github 版 requirements.txt，但拿資料跟 pretrain 的 pt 可以」

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_DIR=$(dirname "$SCRIPT_DIR")
YOLO_DIR="$BASE_DIR/yolov9"

mkdir -p "$YOLO_DIR"
cd "$BASE_DIR"

echo "========================================="
echo "1. 取得 YOLOv9 的程式碼 (只取源碼結構，不採信預設依賴)"
echo "========================================="

if [ ! -f "yolov9/train_dual.py" ]; then
    echo "[*] Git clone YOLOv9 (WongKinYiu)..."
    # 直接 clone 整個 repo 到 yolov9 目錄
    git clone https://github.com/WongKinYiu/yolov9.git "$YOLO_DIR"
    
    cd "$YOLO_DIR"
    
    # 【核心需求保護】將官方的 requirements.txt 移走或重新命名，防止誤用
    if [ -f "requirements.txt" ]; then
        mv requirements.txt requirements_github_ignored.txt
        echo "已將原版 YOLOv9 Github 的 requirements.txt 更名為 requirements_github_ignored.txt"
    fi
else
    echo "[OK] yolov9 目錄與原始碼已存在，跳過 Git clone。"
    cd "$YOLO_DIR"
fi


echo "========================================="
echo "2. 至 Github 抓取 Pretrain Weights (.pt 分散式訓練使用)"
echo "========================================="

if [ ! -d "weights" ]; then
    mkdir weights
fi

# 下載 YOLOv9-c 作為初始訓練權重示範
if [ ! -f "weights/yolov9-c.pt" ]; then
    echo "[*] 正在從 YOLOv9 release 下載 weights/yolov9-c.pt (Object Detection) ..."
    wget -c https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-c.pt -O weights/yolov9-c.pt
    echo "[OK] yolov9-c.pt 下載完成。"
else
    echo "[OK] weights/yolov9-c.pt 已存在，跳過下載。"
fi

# 下載 YOLOv9-c-seg.pt 作為 Segmentation 初始訓練權重示範
if [ ! -f "weights/yolov9-c-seg.pt" ]; then
    echo "[*] 正在從 YOLOv9 release 下載 weights/yolov9-c-seg.pt (Segmentation) ..."
    wget -c https://github.com/WongKinYiu/yolov9/releases/download/v0.1/yolov9-c-seg.pt -O weights/yolov9-c-seg.pt
    echo "[OK] yolov9-c-seg.pt 下載完成。"
else
    echo "[OK] weights/yolov9-c-seg.pt 已存在，跳過下載。"
fi

echo "========================================="
echo "程式與權重準備完成！請繼續執行 3_prepare_coco_dataset.sh"
echo "========================================="
