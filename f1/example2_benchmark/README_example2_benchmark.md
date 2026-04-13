# MPI Ring & Disk I/O Benchmark Example

本範例展示了如何在 NCHC Slurm 環境中執行一個結合 **MPI 網路環狀通訊 (Ring Communication)** 與 **磁碟 I/O (Disk I/O)** 的效能測試程式。

## 測試內容
1.  **Network Benchmark**: 透過 64 個 MPI Ranks 進行環狀資料交換，測量叢集內部的聚合頻寬 (Aggregate Bandwidth)。
2.  **Disk I/O Benchmark**: 分別針對 `/home/$USER` (全域儲存)、`/work1/$USER` (高效能全域儲存) 與 `/tmp` (節點本機磁碟) 進行 512 MB 的讀寫測試，並產出 MB/s 效能數據。

## 自動化流程說明
為了簡化操作並確保執行環境一致，我們採用了 **"Job 內編譯"** 的策略：
-   當你提交 `.sb` 檔案後，Slurm 會在分配到的計算節點上先執行 `module load`。
-   接著自動執行 `mpicc` 編譯原始碼，產出最符合該節點環境的執行檔。
-   最後透過 `srun --mpi=pmix` 正確展開 64 個任務進行測試。

## 如何執行測試

請根據你想測試的節點與核心配置，選擇對應的指令：

### 1. 測試 4 節點 (每節點 16 核心，共 64 Ranks)
```bash
sbatch run_4n_16c.sb
```

### 2. 測試 2 節點 (每節點 32 核心，共 64 Ranks)
```bash
sbatch run_2n_32c.sb
```

### 3. 測試 16 節點 (每節點 4 核心，共 64 Ranks)
```bash
sbatch run_16n_4c.sb
```

## 如何查看結果
測試完成後，請檢查對應的 `.log` 檔案（例如 `run_4n_16c.log`）：

```bash
cat run_4n_16c.log
```

你將會在日誌中看到如下的輸出範例：
-   **Network**: `=> Aggregate Bandwidth  : 159.131 GB/s`
-   **Disk I/O**: 
    -   `HOME Storage [/home/...] Write Speed: 4115.82 MB/s`
    -   `LOCAL /tmp [/tmp] Write Speed: 1572.28 MB/s`

## 檔案說明
-   `mpi_ring_benchmark.c`: 結合網路與磁碟測試的 C 原始碼。
-   `run.sh`: 核心執行腳本，負責載入模組、編譯與啟動 MPI。
-   `run_*.sb`: Slurm 批次指令檔，定義資源需求。
-   `compile.sh`: (選用) 供手動測試編譯環境使用。
