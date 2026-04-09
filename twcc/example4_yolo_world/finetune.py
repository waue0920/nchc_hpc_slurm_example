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

# ===================================================================
# 【HPC 多節點/跨主機 DDP 動態修正 Patch】
# 目的：解決 Ultralytics 8.x 官方處理外部 torchrun 啟動時的三個底層 Bug：
# 1. args.device 長度蓋過系統的實際 WORLD_SIZE (導致跨節點進程數錯亂)
# 2. 把全域 RANK 當作 LOCAL_RANK 傳入 torch.cuda.set_device (導致 device ordinal 報錯)
# 3. DistributedDataParallel 的 device_ids 使用全域 RANK 而非 LOCAL_RANK
#    (跨節點時 RANK >= 本機 GPU 數，造成 _streams[device] IndexError)
# 此處覆寫可避免修改安裝環境 (site-packages)，維持教材的絕對可移植性。
# ===================================================================
try:
    import torch
    import torch.nn as nn
    from ultralytics.engine.trainer import BaseTrainer

    # ------ Patch 1: 覆寫 train() ------
    # 強迫吃系統環境變數裡的 WORLD_SIZE 取代 device 長度
    orig_train = BaseTrainer.train
    def patched_train(self):
        world_size = int(os.environ.get("WORLD_SIZE", 1))
        if world_size > 1 and "LOCAL_RANK" in os.environ:
            self._do_train(world_size)  # torchrun 啟動模式，直接跳過 args 判斷
        else:
            orig_train(self)            # 退回單機/原生模式
    BaseTrainer.train = patched_train

    # ------ Patch 2: 覆寫 _setup_ddp() ------
    # 解開 RANK 與 LOCAL_RANK 的混淆
    def patched_setup_ddp(self, world_size):
        import torch.distributed as dist
        from datetime import timedelta
        local_rank = int(os.environ.get("LOCAL_RANK", 0))
        rank = int(os.environ.get("RANK", 0))
        # 關鍵修正：指派設備必須用 local_rank
        torch.cuda.set_device(local_rank)
        self.device = torch.device("cuda", local_rank)
        os.environ["TORCH_NCCL_BLOCKING_WAIT"] = "1"
        dist.init_process_group(
            backend="nccl" if dist.is_nccl_available() else "gloo",
            timeout=timedelta(seconds=10800),
            rank=rank,                 # group 通訊仍需要全域 rank
            world_size=world_size,
        )
    BaseTrainer._setup_ddp = patched_setup_ddp

    # ------ Patch 3: 覆寫 _setup_train() ------
    # 原始碼在 _setup_train 中執行：
    #   self.model = DDP(self.model, device_ids=[RANK], ...)
    # 跨節點時 RANK (全域) 可能 >= 本機 GPU 數量，導致：
    #   torch/nn/parallel/_functions.py _get_stream → _streams[device] IndexError
    # 修正：在原始 _setup_train 執行完畢後，用 LOCAL_RANK 重新包裝 DDP
    orig_setup_train = BaseTrainer._setup_train
    def patched_setup_train(self, world_size):
        orig_setup_train(self, world_size)
        # 只在多 GPU (DDP) 模式下重新包裝
        if world_size > 1:
            local_rank = int(os.environ.get("LOCAL_RANK", 0))
            # 拆掉原始用錯誤 device_ids 包裝的 DDP，取出原始 module
            raw_model = self.model.module if hasattr(self.model, "module") else self.model
            self.model = nn.parallel.DistributedDataParallel(
                raw_model,
                device_ids=[local_rank],
                find_unused_parameters=True,
            )
    BaseTrainer._setup_train = patched_setup_train

except ImportError:
    pass
# ===================================================================

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

    # 由於我們有安裝 wandb，Ultralytics 會自動啟用，但 project name 不能包含破折號/斜線
    os.environ["WANDB_MODE"] = "disabled"  # 對於示範用途先禁用 wandb 避免報錯，或者您可以自行註冊 wandb 帳號

    # ultralytics DDP 自動從 torchrun 環境取得分散式設定
    model.train(
        data=args.data,
        epochs=args.epochs,
        batch=args.batch,
        imgsz=args.imgsz,
        device=args.device,
        workers=args.workers,
        amp=False,                # 關閉自動混合精度避免 PyTorch 2.0.1+NCCL 報錯 "Unconvertible NCCL type"
        deterministic=False,      # 關閉確定性演算法，避免 CUDA 11.7 不支援 CuBLAS 的確定性而報錯
        project="runs_detect",    # 修正重點: 移除斜線 `/` 避免 wandb 引發錯誤
        name=f"yoloworld_{args.model_size}_finetune",
        exist_ok=True,
    )

    if local_rank == 0:
        print("\n微調完成！模型儲存於 runs/detect/ 目錄。")
        print(f"可使用 infer.py 搭配微調後模型進行推論：")
        print(f"  python infer.py --source <YOUR_IMAGE> --model_size {args.model_size}")


if __name__ == "__main__":
    main()
