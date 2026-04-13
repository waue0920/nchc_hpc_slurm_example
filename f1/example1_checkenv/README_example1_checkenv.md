## 0. Precondition

* Login: `f1-ilgn01.nchc.org.tw`
* Default project directory: `~/nchc_hpc_slurm_example`
```bash
cd ~
git clone https://github.com/waue0920/nchc_hpc_slurm_example.git
```

## 1. Go to Workspace

```bash
cd ~/nchc_hpc_slurm_example/f1/example1_checkenv/
```

## 2. Slurm Job Examples

此範例包含四種不同的環境檢查方式：

### (1) 基礎 CPU 與節點資訊檢查
檢查 Slurm 分配的節點、CPU 數量及相關環境參數。
```bash
sbatch 1check_cpu_single.sb
# 查看結果
cat z_1check.log
```

### (2) Shell 環境變數檢查 (使用 srun)
透過 `srun` 執行 `env.sh`，確認跨節點的 Shell 環境配置。
```bash
sbatch 2check_env_sh.sb
# 查看結果
cat z_2check.log
```

### (3) Python 環境檢查 (使用 Singularity 容器)
在 Singularity 容器環境中執行 Python，檢查容器內的庫路徑與版本。
```bash
sbatch 3check_env_py.sb
# 查看結果
cat z_3check.log
```

### (4) Python 執行三部曲 (Conda/Singularity/Conda Run)
在 `4check_env_py.sb` 中提供三種不同的 Python 執行策略（三選一使用）：
* **方法一 (Conda Activate)**: 傳統載入 `miniconda3` 並 `activate` 環境。
* **方法二 (Singularity)**: 使用容器環境執行，適合依賴複雜的情況。
* **方法三 (Conda Run)**: **推薦使用**，語法最簡潔，適合跨節點快速調用。

```bash
sbatch 4check_env_py.sb
# 查看結果
cat z_4check.log
```

## 3. Useful Commands

* `squeue -u $USER`: 查看目前排隊中的任務。
* `scancel <JOB_ID>`: 取消特定的任務。
* `sacct`: 查看歷史任務紀錄。
