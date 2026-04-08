#!/usr/bin/env python3
"""
infer.py — YOLO-World 開放詞彙推論範例

使用方式（供 yoloworld_infer.sh 呼叫）：
  python infer.py
  python infer.py --categories "person,bicycle,traffic light" --source /path/to/images

YOLO-World 特色：
  - 無需微調即可偵測任意文字描述的類別
  - 支援中英文混合描述（部分模型版本）
  - 適合快速跨域驗證
"""

import argparse
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description="YOLO-World Open-Vocabulary Inference")
    parser.add_argument(
        "--categories",
        type=str,
        default="person, car, dog, cat, bicycle",
        help="逗號分隔的偵測類別（支援任意詞彙）",
    )
    parser.add_argument(
        "--source",
        type=str,
        default="https://ultralytics.com/images/bus.jpg",
        help="輸入圖片路徑、目錄或 URL",
    )
    parser.add_argument(
        "--model_size",
        type=str,
        default="s",
        choices=["s", "m", "l", "x"],
        help="YOLO-World 模型大小",
    )
    parser.add_argument("--conf",   type=float, default=0.05, help="信心閾值")
    parser.add_argument("--iou",    type=float, default=0.5,  help="NMS IoU 閾值")
    parser.add_argument("--output", type=str,   default="infer_output", help="輸出目錄")
    return parser.parse_args()


def main():
    args = parse_args()
    categories = [c.strip() for c in args.categories.split(",") if c.strip()]
    print(f"偵測類別 ({len(categories)} 個): {categories}")

    try:
        from ultralytics import YOLOWorld
    except ImportError:
        raise ImportError("請先執行 setup_scripts/1_prepare_conda_env.sh 安裝 ultralytics >= 8.1")

    # 為了確保 SLURM 執行時找得到剛剛下載的 weights
    model_name = f"weights/yolov8{args.model_size}-worldv2.pt"
    print(f"載入模型: {model_name}")
    model = YOLOWorld(model_name)

    # 設定開放詞彙類別（Zero-shot，無需微調）
    model.set_classes(categories)
    print(f"已設定開放詞彙類別: {categories}")

    print(f"開始推論，來源: {args.source}")
    results = model.predict(
        source=args.source,
        conf=args.conf,
        iou=args.iou,
        save=True,
        project=args.output,
        name="predict",
        exist_ok=True,
    )

    print("\n===== 推論結果統計 =====")
    total_dets = 0
    for i, r in enumerate(results):
        n = len(r.boxes) if r.boxes is not None else 0
        total_dets += n
        print(f"  圖片 {i+1}: 偵測到 {n} 個物件")
        if r.boxes is not None and n > 0:
            for box in r.boxes:
                cls_id = int(box.cls[0])
                conf   = float(box.conf[0])
                label  = categories[cls_id] if cls_id < len(categories) else str(cls_id)
                print(f"    - {label}: {conf:.3f}")

    print(f"\n共偵測到 {total_dets} 個物件")
    output_path = Path(args.output) / "predict"
    print(f"結果已儲存至: {output_path.resolve()}")
    print("========================")


if __name__ == "__main__":
    main()
