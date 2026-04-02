# NCHC HPC 平台與計算節點分區 (Partitions)

國網中心 (NCHC) 擁有多種高效能計算平台，每個平台針對不同的計算需求（如 CPU、GPU 或是 ARM 架構）提供對應的叢集資源。提交 SLURM 任務時，需在 `.sb` 腳本中透過 `#SBATCH --partition=<partition_name>` 來指定任務要進入的計算節點分區。

以下是本專案支援的 4 個國網 HPC 平台及其常用的 Partition 列表：

## 1. 台灣 AI 雲 (TWCC - Taiwan AI Cloud) `[twcc 目錄]`
主要提供 GPU 計算資源（如 NVIDIA V100 等），適合大型深度學習與 AI 訓練模型。
*   `gtest`：測試用分區，適合短時間、低資源的程式除錯與測試。
*   `gp1d`：單節點 GPU 分區。
*   `gp2d`：雙節點 GPU 分區。
*   `gp4d`：四節點 GPU 分區，適用於多節點的分散式訓練 (DDP)。

## 2. 台灣杉一號 CPU 叢集 (Taiwania 1 CPU) `[f1 目錄]`
提供傳統的 x86 CPU 計算資源，適用於大型物理模擬、氣象運算、MPI 運算等。
*   `ct112`：一般運算分區，提供高核心數的 CPU 資源（如 112 核心）。

## 3. 台灣杉 ARM 叢集 (Taiwania ARM) `[f1_arm 目錄]`
提供基於 ARM 架構的計算節點，適合測試 ARM 平台的應用與高效能平行計算。
*   `arm-dev`：ARM 架構的開發與測試分區。
*   `arm144`：ARM 架構的生產分區，有著較大的核心數量（如 144 核心）。

## 4. 創進一號 / H100 叢集 (Forerunner / H100) `[h100 目錄]`
最新世代 GPU 叢集（配備 NVIDIA H100），專為大型語言模型 (LLM) 與極端計算需求的 AI 訓練打造。
*   `dev`：開發與輕量測試分區。
*   `normal`：常規排程分區，供需要龐大算力的正式任務使用。

---
> **注意**：各分區的計算資源配額 (Quota)、最長執行時間 (Time Limit) 及計費標準各不相同，請依據使用者的計畫額度來選擇最適合的 Partition。
