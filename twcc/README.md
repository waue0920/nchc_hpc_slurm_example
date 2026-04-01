# 導引
* example1/ : slurm scripts executing with python  
* example2/ : slurm scripts that perform project yolov9
* yolov9/   : yolov9 project that you need prepare program, data, pretrained_pt by yourself.


# QuickStart
## 0. 登入到國網中心HPC環境
* 此文件以 TWCC 為例
  - https://man.twcc.ai/@twccdocs/doc-twnia2-main-zh/https%3A%2F%2Fman.twcc.ai%2F%40twccdocs%2Fgetstarted-twnia2-submit-job-zh
    1. 申請 主機帳號、密碼、OTP 認證碼
        - https://man.twcc.ai/@twccdocs/doc-twnia2-main-zh/https%3A%2F%2Fman.twcc.ai%2F%40twccdocs%2Fguide-twnia2-prerequisite-for-connection-zh#%E4%B8%BB%E6%A9%9F%E5%B8%B3%E8%99%9F%E3%80%81%E5%AF%86%E7%A2%BC%E3%80%81OTP-%E8%AA%8D%E8%AD%89%E7%A2%BC
    2. 登入主機方法 (詳盡)
        - https://man.twcc.ai/@twccdocs/doc-twnia2-main-zh/https%3A%2F%2Fman.twcc.ai%2F%40twccdocs%2Fguide-twnia2-login-and-logout-zh


## 1. 認識環境

1. 查詢 可用錢包id 
```bash
wallet
```

* 記下可用的 Project_ID, ex GOV113119

2. 查詢有哪些 partition 可用
```bash
sinfo
```

```bash
$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
gtest        up      30:00      2   idle gn[1001-1002]
gp1d         up 1-00:00:00     25    mix gn[1003,1102-1104,1110-1113,1115,1118,1121-1125,1128,1221-1228,1230]
gp2d*        up 2-00:00:00     25    mix gn[1003,1102-1104,1110-1113,1115,1118,1121-1125,1128,1221-1228,1230]
gp4d         up 4-00:00:00     25    mix gn[1003,1102-1104,1110-1113,1115,1118,1121-1125,1128,1221-1228,1230]
express      up 4-00:00:00     25    mix gn[1003,1102-1104,1110-1113,1115,1118,1121-1125,1128,1221-1228,1230]
```

* 記下可用的 partition ，ex gtest, gp2d

## 2. hello world

3. 送出 hello world

```bash
sbatch example1_checkenv/1check_gpu_single.sb
```

```
~/nchc_hpc_slurm_example/twcc$

$ sbatch example1_checkenv/1check_gpu_single.sb
sbatch: INFO: It is recommended to specify `--nodes` and `--ntasks-per-node` together
Submitted batch job 881045

$ cat z_1check.log
```

* 此時會看到執行腳本的log ，會跟此 readme.md 放在一起

4. 其他有用指令
```
### 查看自己之前跑過的任務（但不會存太久)
sacct

### 查看目前正在跑的任務 (-U $USER 只看自己)
squeue -U $USER

### 移除正在跑的任務
scancel xxxxxx

```


## 3. 用hellow看世界

1. 2check_env_sh.sb
```bash
sbatch example1_checkenv/2check_env_sh.sb
```

* **補充說明**：
  - 這支腳本展示了如何使用 `srun` 將命令（`env.sh`）派發給所有申請的節點執行。
  - 在 TWCC 叢集中，原生 SLURM 的 `$SLURM_GPUS_ON_NODE` 無法正確取值，所以腳本中特別撰寫了 `NGPU=$(nvidia-smi -L | wc -l)` 的防呆處理，確保 `srun` 可以抓到正確的 GPU 數量，這點在後續派送 PyTorch 任務時非常重要。

2. 3check_env_py.sb
```bash
sbatch example1_checkenv/3check_env_py.sb
```

* **補充說明**：
  - 這支腳本進一步示範如何呼叫 **Singularity (Apptainer) 容器**。
  - 它建立了一個 `cmd="srun ... $SINGULARITY bash run_python.sh"` 變數字串來執行。這展現了我們在封排程腳本時，可以清楚將參數、容器與要執行的 Python 環境拆分與包裝。
  - 同時也示範了如何定義 `$MASTER_ADDR` 變數來抓取主要通訊節點位置（供未來分散式運算使用）。