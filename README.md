# NCHC HPC SLURM 範例庫

本專案提供國家高速網路與計算中心 (NCHC) 各大 GPU/HPC 叢集環境的 SLURM 任務派送腳本範例。旨在幫助使用者快速上手不同硬體架構下的平行運算與分散式訓練。

## 叢集環境介紹

*   **twcc/**: 台灣衫二號 (T2) 範例，適用於多 GPU 雲端運算環境。
*   **h100/**: 晶創主機 (Nano5) 範例，針對 NVIDIA H100 GPU 優化。
*   **f1/**: 創進一號 (x86-64) 範例，適用於標準高效能運算任務。
*   **f1_arm/**: 創進一號 (ARM64) 範例，針對 ARM 架構進行優化的運算腳本。

## 目錄結構與範例說明

每個叢集目錄下通常包含以下三個階段的範例：

1.  **example1_checkenv (環境檢查)**
    *   用於確認節點的 GPU 狀態、CPU 核心數與系統路徑。
    *   適合第一次登入叢集時進行初步測試。
2.  **example2_yolov9 (AI 訓練範例)**
    *   展示如何在多節點、多 GPU 環境下使用 PyTorch (torchrun) 進行 YOLOv9 物件偵測訓練。
3.  **example3_miniweather (HPC 運算範例)**
    *   使用 miniWeather 模擬程式，展示 MPI、OpenMP 與 OpenACC 的平行運算配置。

## 快速開始

### 1. 修改帳號與分區
在使用 `.sb` (Slurm Batch) 腳本前，請務必根據您的計畫修改帳號與分區：
```bash
#SBATCH --account="GOV113038"    # 請替換為您的計畫帳號 (如: GOV113038 或 GOV113119)
#SBATCH --partition=gtest        # 根據叢集選擇正確的分區 (如: gtest, gp2d, dev, ct112)
```

### 2. 派送任務
使用 `sbatch` 指令提交任務：
```bash
sbatch 1check_gpu_single.sb
```

### 3. 查看結果
預設日誌會輸出至 `z_slurm-xxx.log` 或腳本內指定的輸出檔案。

## 注意事項
*   本專案廣泛運用 **Singularity (Apptainer)** 容器技術。請確保相關 `.sif` 鏡像檔路徑正確（通常位於 `/work1/` 下）。
*   多節點通訊已預設針對 **InfiniBand (ib0)** 進行優化。

## 貢獻者
*   NCHC 團隊與相關教育訓練課程。
