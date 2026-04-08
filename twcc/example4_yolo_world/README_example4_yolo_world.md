# Phase 4: YOLO-World 開放詞彙物件偵測範例 (NCHC TWCC)

本目錄示範如何在 TWCC SLURM 環境中，利用 **YOLO-World** 進行「開放詞彙 (Open-Vocabulary)」物件偵測。
YOLO-World 透過文字 Prompt 動態指定偵測類別，無需重新訓練即可偵測任意物件，非常適合快速驗證與跨域應用。

本範例同樣遵循 **「資源申請 (`.sb`) 與執行邏輯 (`.sh`) 分離」** 的架構原則。

---

## 📂 目錄結構

```text
example4_yolo_world/
├── setup_scripts/
│   ├── 1_prepare_conda_env.sh       # 建立 Conda 環境並安裝套件
│   ├── 2_prepare_github_data.sh     # Clone repo、下載權重與資料集
│   └── 3_check.sh                   # 全面檢查環境、權重、資料集
│
├── 1_yoloworld_infer_single.sb      # 單節點單 GPU 推論 (Inference)
├── 2_yoloworld_finetune_multigpu.sb # 單節點多 GPU 微調訓練 (Fine-tune)
│
├── yoloworld_infer.sh               # 推論封裝腳本
├── yoloworld_finetune.sh            # 微調封裝腳本
│
├── infer.py                         # YOLO-World 推論程式
└── finetune.py                      # YOLO-World 微調程式
```

---

## 🚀 執行步驟

### 第一步：前置準備（在 Login 節點執行）

```bash
cd setup_scripts/
bash 1_prepare_conda_env.sh      # 建立 yolo_world_env 環境
bash 2_prepare_github_data.sh    # Clone repo、下載權重、下載 COCO128
bash 3_check.sh                  # 確認所有項目 [OK]
```

> **重要**：嚴禁在 Login 節點直接執行推論或訓練。
> 如需互動式除錯，請先用 `salloc` 申請計算節點：
> ```bash
> salloc --nodes=1 --cpus-per-task=4 --gres=gpu:1 --partition=gtest -A <計畫ID>
> ```

### 第二步：提交 SLURM 任務

```bash
# 推論任務（單節點單 GPU，約 2~5 分鐘）
sbatch 1_yoloworld_infer_single.sb

# 微調任務（單節點多 GPU，需自備資料集）
sbatch 2_yoloworld_finetune_multigpu.sb
```

> 使用 `squeue -u $USER` 監控任務，`z_*.log` 查看即時輸出。

---

## ⚙️ 執行環境支援

腳本支援兩種環境（在 `.sh` 內切換）：

1. **Conda**（預設）：使用 `setup_scripts/1_prepare_conda_env.sh` 建立的 `yolo_world_env`
2. **Singularity**：反註解 `.sh` 中的 `EXEC_ENV` Singularity 段落即可

---

## 📝 關鍵參數說明

| 參數 | 說明 | 預設值 |
|------|------|--------|
| `CATEGORIES` | 偵測類別（逗號分隔，支援任意詞彙） | `person, car, dog, cat, bicycle` |
| `CONF_THRES` | 信心閾值 | `0.05` |
| `MODEL_SIZE` | YOLO-World 模型大小 (`s/m/l/x`) | `l` |
| `EPOCHS` | 微調訓練 epochs | `10` |
| `BATCH_SIZE` | 批次大小 | `16` |
