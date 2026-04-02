
# NCHC 晶創主機 (Nano5 / n5) 範例

本目錄下的範例專為國網中心**晶創主機 (Nano5, 平台代號 n5)** 設計，該平台搭載了頂級的 NVIDIA H100 GPU，主要用於大型 AI 模型訓練與最嚴苛的運算任務。

## 導引
* `example1_checkenv/` : 基礎環境檢查，執行 Python 腳本確認資源配置與驅動程式。
* `example2_yolov9/`   : slurm scripts perform project yolov9 (多節點 GPU 分散式訓練範例)。

## QuickStart

### 0. 登入到晶創主機環境
請參考國網中心提供的使用者指南進行登入，連線進入 `n5` 登入節點。

### 1. 認識環境與參數
與 TWCC 或其他平台相同，提交前請確定您的計畫代碼（透過 `wallet` 查詢），並確保使用了 Nano5 特有的 GPU 分區。

常用的可用 partition 可以透過 `sinfo` 查詢（例如 `dev`, `normal` 等），詳情請參考專案根目錄的 [AGENTS.md](../AGENTS.md) 及 [hpc_partitions.md](../hpc_partitions.md)。

> **注意：** 晶創主機 (n5) 提供的是強大的 NVIDIA H100 運算卡，送出任務時請務必帶上 `--gres=gpu:N` 宣告您所需要的 GPU 數量。

### 2. Hello World (環境檢查)

1. 送出基礎測試：
    ```bash
    sbatch example1_checkenv/check_env.sb
    ```
2. 觀察並確認系統是否正確抓到 H100 GPU。日誌將輸出在與腳本相同的目錄下。

## 注意事項與規範
1. **嚴禁在登入節點執行訓練**：所有的執行動作都必須透過 SLURM (`sbatch` 或透過 `salloc` 開發節點) 送出，切勿把登入節點當作開發機，否則帳號可能會遭到停權！
2. **職責分離**：建議您可以學習 `example2` 的作法把環境載入腳本 (`.sh`) 與資源申請腳本 (`.sb`) 拆分，來保持程式碼簡潔與可維護性。
