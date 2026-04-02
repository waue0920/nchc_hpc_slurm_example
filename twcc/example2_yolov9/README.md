# Phase 2: YOLOv9 分散式訓練範例 (NCHC TWCC)

本專案目錄示範了如何在 TWCC (台灣 AI 雲) 的 SLURM 排程系統上，進行 PyTorch (YOLOv9) 的多節點與多 GPU 分散式訓練。

本範例結合了在 `example1_checkenv` 中確認過的最佳實踐，包含：**將資源申請 (`.sb`) 與環境載入及執行邏輯 (`.sh`) 完全分離**，並保留了使用者對 TWCC 環境 (如 Conda, Singularity) 的選擇彈性。

---

## 📂 目錄結構與架構

```text
example2_yolov9/
├── setup_scripts/          # 【前置準備區】包含環境安裝、資料集下載、程式碼 clone 等腳本
│   ├── requirements.txt    # 給 Conda 環境專用的依賴清單
│   ├── 1_prepare_conda_env.sh
│   ├── 2_prepare_yolov9_github.sh
│   ├── 3_prepare_coco_dataset.sh
│   └── 4_check_yolo9_all.sh
│
├── yolov9/                 # 【實際運算區】(將由 setup_scripts 自動產生)
│   ├── coco/               # COCO 資料集存放處
│   ├── weights/            # 預訓練權重 (.pt) 存放處
│   └── train_dual.py       # 取自 GitHub 的執行檔...
│
├── *.sb                    # 【SLURM 提交檔】用來申請硬體資源 (CPU/GPU/Node)，並呼叫 .sh
└── *.sh                    # 【封裝執行檔】負責載入 Python 環境，並組織 torchrun 分散式訓練指令
```

---

## 🚀 執行步驟

### 第一步：前置準備作業 (在 Login 節點上手動執行)
為避免在分散式計算節點上重複下載檔案而產生衝突或權限問題，請務必先在登入節點上將環境整理完畢。

請先切換至 `setup_scripts/` 資料夾，並依序執行腳本：

1. `./1_prepare_conda_env.sh`: 建立並安裝需要的 Conda 環境 (`newyolo9t2`)，並根據根目錄的 `requirements.txt` 安裝相關套件。
2. `./2_prepare_yolov9_github.sh`: 下載 YOLOv9 原始碼，並自動下載 pretrain weights (`yolov9-c.pt` 與 `yolov9-c-seg.pt`) 到相對應的資料夾。
3. `./3_prepare_coco_dataset.sh`: 自動下載輕量版的 COCO128 與 COCO128-seg 測試資料集至 `yolov9/coco/` 內。
4. `./4_check_yolo9_all.sh`: 檢查上述步驟的狀態。

確認終端機顯示所有項目皆為 `[OK]` 後，即可開始提交 SLURM 工作！

### 第二步：提交訓練任務
回到本目錄，開始利用 `sbatch` 將運算工作提交至計算節點：
```bash
sbatch 1torch2run_object.sb
sbatch 2torch2run_segment_local.sb
sbatch 3torch2run_segment_2node.sb
```
> 您可以使用 `squeue -u <Your_Username>` 觀察正在發配/執行的任務，或是查看排程目錄下的 `z_*.log` 即時輸出。

---

## ⚙️ 執行環境支援 (Environment)

在 `*.sh` 腳本中，預設支援下列兩種主要環境掛載方式 (請根據腳本內的註解將其反註解即可切換)：

1. **Conda**: 使用第一步 `1_prepare_conda_env.sh` 所建立的虛擬環境 (`conda run -n yolo9t2 ...`)
2. **Singularity**: 呼叫外部已包裝好的映像檔，如 `singularity exec --nv ...`，適用於 TWCC NGC 官方容器環境。