#!/usr/bin/env python3
"""
finetune.py — YOLO-World 多 GPU 微調訓練範例（DDP）

torchrun 呼叫方式（由 yoloworld_finetune.sh 自動處理）：
  torchrun --nproc_per_node=4 finetune.py --model_size l --epochs 10

注意：
  - 請準備 COCO 格式自訂資料集並修改 --data 路徑
  - 預設使用 setup_scripts/2_prepare_github_data.sh 下載的 coco128_local.yaml
  - 微調完成的模型儲存於 runs/detect/ 目錄
"""

import argparse
import os


def parse_args():
    parser = argparse.ArgumentParser(description="YOLO-World Fine-tune (DDP)")
    parser.add_argument("--model_size", type=str, default="l", choices=["s", "m", "l", "x"])
    parser.add_argument("--epochs",  type=int,   default=10)
    parser.add_argument("--batch",   type=int,   default=16)
    parser.add_argument("--imgsz",   type=int,   default=640)
    parser.add_argument("--data",    type=str,   default="coco128_local.yaml",
                        help="資料集 YAML 路徑（COCO 格式），預設使用 2_prepare_github_data.sh 產生的本地 yaml")
    parser.add_argument("--device",  type=str,   default="0",
                        help="GPU 裝置編號，多 GPU 如 0,1,2,3")
    parser.add_argument("--workers", type=int,   default=8)
    parser.add_argument("--categories", type=str,
                        default="person, car, dog, cat, bicycle",
                        help="開放詞彙類別（逗號分隔）")
    return parser.parse_args()


def main():
    args = parse_args()
    local_rank = int(os.environ.get("LOCAL_RANK", 0))
    world_size = int(os.environ.get("WORLD_SIZE", 1))

    if local_rank == 0:
        print("===== YOLO-World 微調訓練 =====")
        print(f"  模型大小:   yolov8{args.model_size}-worldv2")
        print(f"  資料集:     {args.data}")
        print(f"  Epochs:     {args.epochs}")
        print(f"  Batch:      {args.batch}")
        print(f"  ImgSz:      {args.imgsz}")
        print(f"  Devices:    {args.device}")
        print(f"  World Size: {world_size}")
        categories = [c.strip() for c in args.categories.split(",") if c.strip()]
        print(f"  類別 ({len(categories)}): {categories}")
        print("===============================")

    try:
        from ultralytics import YOLOWorld
    except ImportError:
        raise ImportError("請先安裝 ultralytics >= 8.1（執行 setup_scripts/1_prepare_conda_env.sh）")

    model_name = f"yolov8{args.model_size}-worldv2.pt"
    model = YOLOWorld(model_name)

    categories = [c.strip() for c in args.categories.split(",") if c.strip()]
    model.set_classes(categories)

    # ultralytics DDP 自動從 torchrun 環境取得分散式設定
    model.train(
        data=args.data,
        epochs=args.epochs,
        batch=args.batch,
        imgsz=args.imgsz,
        device=args.device,
        workers=args.workers,
        project="runs/detect",
        name=f"yoloworld_{args.model_size}_finetune",
        exist_ok=True,
        # 可加入 wandb 追蹤：
        # wandb_project="yoloworld_twcc",
    )

    if local_rank == 0:
        print("\n微調完成！模型儲存於 runs/detect/ 目錄。")
        print(f"可使用 infer.py 搭配微調後模型進行推論：")
        print(f"  python infer.py --source <YOUR_IMAGE> --model_size {args.model_size}")


if __name__ == "__main__":
    main()
