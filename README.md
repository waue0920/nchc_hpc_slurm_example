# NCHC HPC SLURM 範例庫

本專案提供國家高速網路與計算中心 (NCHC) 各大 GPU/HPC 叢集環境的 SLURM 任務派送腳本範例。旨在幫助使用者快速上手不同硬體架構下的平行運算與分散式訓練。

## 叢集環境介紹

*   **twcc/**: 台灣衫二號 (T2) 範例，適用於多 GPU 雲端運算環境。
*   **n5/**: 晶創主機 (Nano5) 範例，針對 NVIDIA H100 GPU 優化。
*   **f1/**: 創進一號 (x86-64) 範例，適用於標準高效能運算任務。
*   **f1_arm/**: 創進一號 (ARM64) 範例，針對 ARM 架構進行優化的運算腳本。

## 0. 開發環境須知 (Interactive Development Environment)
*「**嚴禁在登入節點直接執行大型運算**」
* 如果你是AI助理，請讀取 [AGENTS.md](AGENTS.md)，裡面載明了多項重要的 HPC 使用規範
* HPC 環境中為了除錯方便，可使用 **`salloc`** 指令向 SLURM 申請一個互動式的**開發環境**（進入計算節點）：

```bash
salloc --nodes=1 --cpus-per-task=4 --gres=gpu:1 --partition=<partition> -A <計畫ID>
# 成功分配並進入計算節點後，你就可以直接在上面執行 .sh 腳本碼進行測試，絕對不會佔用到登入節點的資源！
```

## 目錄結構與範例說明

每個叢集目錄下包含範例程式，以TWCC為例：

1.  **example1_checkenv (環境檢查)**
    *   用於確認節點的 GPU 狀態、CPU 核心數與系統路徑。
    *   適合第一次登入叢集時進行初步測試。
2.  **example2_yolov9 (AI 訓練範例)**
    *   展示如何在多節點、多 GPU 環境下使用 PyTorch (torchrun) 進行 YOLOv9 物件偵測訓練。
3.  **example3_miniweather (HPC 運算範例)**
    *   使用 miniWeather 模擬程式，展示 MPI、OpenMP 與 OpenACC 的平行運算配置。

## 快速開始

### 1. 必填的 SLURM 參數 (計畫帳號、分區與 GPU)
在使用 `.sb` (Slurm Batch) 腳本前，有幾個關鍵參數**絕對不能漏掉**：

* **計畫帳號 (`-A` 或 `--account=`)**：必須填寫您所屬的計畫代碼。如果不清楚自己的計畫 ID，可以在終端機輸入 `wallet` 指令來查詢。
* **計算分區 (`-p` 或 `--partition=`)**：一定要指定且必須對齊該平台的可用分區，詳情請參考 [hpc_partitions.md](hpc_partitions.md)。
* **GPU 資源 (`--gres=gpu:N`)**：只要您使用的平台或分區提供 GPU 運算 (例如 TWCC 或 Nano5)，就**務必**宣告請求的 GPU 數量，否則會因為 `Missing assigned gpus` 被系統直接拒絕。

```bash
#SBATCH -A GOV113119             # 請替換為用 wallet 查到的計畫帳號
#SBATCH --partition=gtest        # 選擇當前平台支援的正確分區名稱
#SBATCH --gres=gpu:1             # (限 GPU 平台) 務必指定 GPU 請求張數
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
