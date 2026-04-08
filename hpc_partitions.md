# NCHC HPC 平台與計算節點分區 (Partitions)

國網中心 (NCHC) 擁有多種高效能計算平台，每個平台針對不同的計算需求（如 CPU、GPU 或是 ARM 架構）提供對應的叢集資源。提交 SLURM 任務時，需在 `.sb` 腳本中透過 `#SBATCH --partition=<partition_name>` 來指定任務要進入的計算節點分區。

## 整理表
| 平台 | 節點類型 | partition | 最長執行時間 (小時) | 單一計畫可用核心/GPU數量 | 每位用戶最多可同時提交的任務 |
|---|---|---|---|---|---|
| T3 | CPU將下線 | `ctest` | 2 | 1~1120 | 80 (排隊) / 6 (執行) |
| T3 | CPU將下線 | `ct56` | 96 | 1~56 | 250 (排隊) / 80 (執行) |
| T3 | CPU將下線| `ct2k-amd` | 168 | 128~2048 | 12 (排隊) / 6 (執行) |
| F1 CPU | CPU (一般) | `ct112` | 96 | 1~112 | 32 |
| F1 CPU | CPU (一般) | `ct448` | 96 | 113~448 | 32 |
| F1 CPU | CPU (一般) | `ct1k` | 64 | 449~1120 | 9 |
| F1 CPU | CPU (大記憶體) | `cf112` | 96 | 1~112 | 16 |
| F1 ARM | ARM CPU | `arm-dev` | 2 | 1~1440 | 2 |
| F1 ARM | ARM CPU | `arm144` | 48 | 1~144 | 12 |
| TWCC | GPU | `gtest` | 0.5 | (測試用) 5 GPU | 5 |
| TWCC | GPU | `gp1d` | 24 | (依需求) | 20 |
| TWCC | GPU | `gp2d` | 48 | (依需求) | 20 |
| TWCC | GPU | `gp4d` | 96 | (依需求) | 20 |
| TWCC | GPU | `express` | 96 | 256 | 20 |
| H100 (Nano5) | GPU | `dev` | 2 | 8 | 2 |
| H100 (Nano5) | GPU | `normal` | 48 | 16 | - |
| H200 (Nano5) | GPU | `normal2` | 48 | 16 | - |
| H100 (Nano5) | GPU | `4nodes` | 12 | 32 | - |


以下是本專案支援的國網 HPC 平台及其常用的 Partition 列表：

## 1. 台灣 AI 雲 (TWCC - Taiwan AI Cloud) `[twcc 目錄]`
https://man.twcc.ai/@twccdocs/doc-twnia2-main-zh/https%3A%2F%2Fman.twcc.ai%2F%40twccdocs%2Fguide-twnia2-queue-zh
主要提供 GPU 計算資源（如 NVIDIA V100 等），適合大型深度學習與 AI 訓練模型。
*   `gtest`：測試用分區，適合短時間、低資源的程式除錯與測試。
*   `gp1d`：單節點 GPU 分區。
*   `gp2d`：雙節點 GPU 分區。
*   `gp4d`：四節點 GPU 分區，適用於多節點的分散式訓練 (DDP)。

## 2. 創進一號 CPU 叢集 ( F1 CPU) `[f1 目錄]`
https://man.twcc.ai/@f1-manual/partition
提供傳統的 x86 CPU 計算資源，適用於大型物理模擬、氣象運算、MPI 運算等。
*   `ct112`：可用核心數範圍 1~112。
*   `ct448`：可用核心數範圍 113~448。
*   `ct1k`：可用核心數範圍 449~1120。
*   `ct2k`：可用核心數範圍 1121~2240。
*   `ct4k`：可用核心數範圍 2241~4480。
*   `ct8k`：可用核心數範圍 4481~8960。

## 3. 創進一號 ARM CPU 叢集  (f1ARM) `[f1_arm 目錄]`
https://man.twcc.ai/@f1-manual/partition
提供基於 ARM 架構的計算節點，適合測試 ARM 平台的應用與高效能平行計算。
*   `arm-dev`：ARM 架構的開發與測試分區。
*   `arm144`：ARM 架構的生產分區，有著較大的核心數量（如 144 核心）。

## 4. 晶創主機 (Nano5 / N5 / H100) `[n5 目錄]`
https://man.twcc.ai/aPiCU8VXS7SZgFJBOoSqBQ
最新世代 GPU 叢集（配備 NVIDIA H100），專為大型語言模型 (LLM) 與極端計算需求的 AI 訓練打造。
*   `dev`：開發與輕量測試分區。
*   `normal`：常規排程分區，供需要龐大算力的正式任務使用。

## 5. 台灣杉三號 (Taiwania 3 / T3)
https://man.twcc.ai/@TWCC-III-manual/ryyo0tsuu
提供高效能純 CPU 計算資源與 AMD 專用機群。
*   `ctest`：可用核心數範圍 1~1120。
*   `ct56`：可用核心數範圍 1~56。
*   `ct224`：可用核心數範圍 57~224。
*   `ct560`：可用核心數範圍 225~560。
*   `ct2k`：可用核心數範圍 561~2240。
*   `ct8k`：可用核心數範圍 2241~8400。
*   `ct2k-amd`：可用核心數範圍 128~2048 (AMD 機群專用佇列)。

---
> **注意**：各分區的計算資源配額 (Quota)、最長執行時間 (Time Limit) 及計費標準各不相同，請依據使用者的計畫額度來選擇最適合的 Partition。
