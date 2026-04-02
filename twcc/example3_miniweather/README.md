# 範例 3: MiniWeather (C++ & OpenACC) 在 TWCC 上的分散式運算

這個範例展示了如何在 TWCC 環境中，使用 Singularity 容器與 NVHPC SDK (包含 MPI 與 OpenACC) 編譯並執行大規模的 `miniWeather` 氣象模擬專案。

## 1. 準備程式碼與編譯
仿照前一個範例，我們不再將數百 MB 的二進位執行檔存入 Git。請使用 `setup_scripts/` 腳本自動取得原始碼並透過 Singularity 進行 CMake 編譯。

請依序執行以下腳本：
```bash
./setup_scripts/1_clone_miniweather.sh
```

接下來你可以提交建置任務，把編譯工作丟給計算節點：
```bash
sbatch setup_scripts/2_build_openacc.sb
```
> **注意**：這會在 `miniWeather/` 資料夾內編譯，並把 `largeweather_openacc` 與 `hugeweather_openacc` 產出到當前目錄。

## 2. 執行任務 (遵守職責分離原則)

我們嚴格分離了 SLURM 排程 (`*.sb`) 與環境配置 (`*.sh`)。
以下是準備好的測試範例：

*   **單節點單卡測試**:
    ```bash
    sbatch 1_miniweather_1x1.sb
    ```
    對應的 `1_miniweather_1x1.sh` 載入了 `$SIF` 並執行 `srun ... mpirun ./largeweather_openacc`。

*   **單節點多卡擴展**:
    ```bash
    sbatch 2_hugeweather_srun_2gpu.sb
    ```

*   **多節點 MPI 分散式運算 (2 節點 4 卡)**:
    ```bash
    sbatch 3_miniweather_mpi_2node.sb
    ```

## 3. 檢查輸出
執行完畢後，MiniWeather 會產出 `output.nc` 檔案，這是一個 netCDF 格式的資料，可以用 ParaView 等工具進行視覺化。
所有的運算 Log 會記錄於 `z_*.log`。
