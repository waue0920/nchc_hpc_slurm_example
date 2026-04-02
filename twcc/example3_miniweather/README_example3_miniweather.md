# 範例 3: MiniWeather (C++ & OpenACC) 在 TWCC 上的分散式運算

這個範例展示了如何在 TWCC 環境中，使用 Singularity 容器與 NVHPC SDK (包含 MPI 與 OpenACC) 編譯並執行大規模的 `miniWeather` 氣象模擬專案。

## 0. 開發環境須知

在開始之前，請務必先閱讀根目錄的 [AGENTS.md](../../AGENTS.md)（國網中心 HPC AI 助理指示），裡面載明了多項重要的 HPC 使用規範，例如「嚴禁在登入節點直接執行 `.sh` 運算或編譯腳本」以及「`.sb` 與 `.sh` 檔案的職責分離原則」。

如果你不想透過 `sbatch` 提交排程，而是想要一個可以即時除錯與編譯的環境，請使用 `salloc` 指令向 SLURM 申請一個互動式的**開發環境**（進入計算節點）：
```bash
salloc --nodes=1 --cpus-per-task=4 --gres=gpu:1 --partition=gtest --time=01:00:00 bash
# 成功分配並進入計算節點後，你就可以直接在上面執行 .sh 腳本（如下方的編譯動作）而不會佔用登入節點資源了。
```

## 1. 準備程式碼與編譯
仿照前一個範例，我們不再將數百 MB 的二進位執行檔存入 Git。請使用 `setup_scripts/` 腳本自動取得原始碼並透過 Singularity 進行 CMake 編譯。

請依序執行以下腳本：
```bash
./setup_scripts/1_clone_miniweather.sh
```

接下來有兩種編譯方式可供選擇：

**方法一：使用 `sbatch` 背景排程編譯（推薦）**
把編譯工作當作排程任務丟給計算節點：
```bash
sbatch setup_scripts/2_build_openacc.sb
```

**方法二：使用 `salloc` 進入開發環境並手動編譯**
如果你想要即時看到編譯過程的輸出，或遇到錯誤想要除錯，可以申請互動式計算節點後再執行編譯腳本：
```bash
# 1. 申請開發節點環境 (請換成您的計畫 ID 與 Partition)
salloc -A GOV113119 --nodes=1 --cpus-per-task=4 --gres=gpu:1 --partition=gtest bash

# 2. 假設分配到了計算節點 (例如畫面提示 Granted job allocation 上的節點 gn1001)，透過 ssh 登入
ssh gn1001

# 3. 切換到專案的目錄
cd /您的工作區路徑/nchc_hpc_slurm_example/twcc/example3_miniweather

# 4. 直接手動呼叫執行腳本進行編譯
./setup_scripts/2_build_openacc.sh
```

> **注意**：無論哪種方法，這都會在 `miniWeather/` 資料夾內進行兩次編譯，並把編譯好的 `largeweather_openacc` 與 `hugeweather_openacc` 產出到當前目錄。

如果你想確認是否編譯成功，可以執行檢查腳本：
```bash
./setup_scripts/3_check_all.sh
```

## 2. 執行任務 (MPI 與 OpenACC 容器化排程解析)

這部分我們保留了最原始的單一 `.sb` 檔案結構，因為若是將 `.sb` 呼叫 `.sh` 再呼叫 `srun` 或 `mpirun`，容易在 MPI 架構下產生**巢狀或通訊層**錯誤。

這四個腳本是一個**循序漸進的教材**，展示了在 HPC 環境下，如何正確（以及不正確）地把 Singularity (Apptainer) 容器與 MPI 分散式運算結合。請務必依序閱讀與執行並觀察結果（Log 檔）：

*   **基礎：單節點單卡測試**:
    ```bash
    sbatch 1_miniweather_1x1.sb
    ```
    - 最基本的執行方式，利用 `srun -N 1` 分配 1 顆 GPU 並喚醒 Singularity 容器執行。

*   **進階：單節點多卡 (srun 做法)**:
    ```bash
    sbatch 2_miniweather_srun_1x2.sb
    ```
    - 展示如何利用 SLURM 內建的 `srun` 作為任務發派器（Task Launcher）。
    - 寫法：`srun ... singularity run ... ./程式`
    - 主機端的 `srun` 負責管理資源分配，每一個被喚醒的 task 單純只是去跑容器內的一份執行檔，效能最好且最穩定。

*   **進階：單節點多卡 (mpirun 做法)**:
    ```bash
    sbatch 3_miniweather_mpirun_1x2.sb
    ```
    - 展示如何使用傳統的 `mpirun`（OpenMPI / NVHPC）來啟動任務。
    - 寫法：`singularity run ... mpirun -np 2 ./程式`
    - 在「單一節點」內，利用容器內的 `mpirun` 管控任務勉強可行（雖然可能會有 Warning 且效能稍差），但只要不跨節點，還是能正常算出結果。

*   **反面教材：多節點跨卡 (千萬別這麼做！)**:
    ```bash
    sbatch 4_miniweather_srun_2x2_failed.sb
    ```
    - 這是一個**刻意保留的錯誤示範**！
    - 寫法：`srun -N 2 ... singularity run ... mpirun ./程式`
    - **為什麼會錯？** 當外層已經用 `srun` 展開了跨節點的分佈結構，但進到容器內後又呼叫了一次 `mpirun`（巢狀發派）。加上 Singularity 容器內部因為隔離，找不到 Host 端的 SLURM Daemon（缺 `srun` 執行檔），導致 OpenMPI 發生 `ORTE / FORCE-TERMINATE` 崩潰。
    - **正確解法：** 面對多節點 MPI 容器任務，**只能**使用第 2 個範例的主機端 `srun` Outside-in 架構（即 `srun --mpi=pmix` 將任務交給 SLURM，容器內純粹只放 `./程式` 不要放 `mpirun`）。

## 3. 檢查輸出
執行上方 1, 2, 3 腳本順利完畢後，MiniWeather 會產出 `output.nc` 檔案，這是一個 netCDF 格式的資料，可以用 ParaView 等工具進行視覺化。
所有的運算 Log 會記錄於 `z_*.log`。對於第 4 個錯誤示範腳本，請打開 `z_4nodes-miniweather.log` 以觀摩經典的 MPI ORTE 報錯。
