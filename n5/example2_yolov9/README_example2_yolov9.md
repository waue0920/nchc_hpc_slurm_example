# n5: 延伸範例 YOLOv9 (PyTorch, torchrun)

本目錄展示了在國網中心 **晶創主機 (n5 / Nano5)** 環境下，如何透過 SLURM 將 YOLOv9 模型部署到多節點並且配置多顆 H100 進行分散式運算加速 (`torchrun`)。

整個專案的運作機制——包含了**資源申請 (`.sb`) 與執行還境配置 (`.sh`) 的職責完美分離架構**，以及如何利用 `conda` 或 `singularity` 建置出跨節點相容的深度學習環境，這一切概念與教學皆與 TWCC 平台共用。

👉 **為了避免重複造輪子，所有詳細的部署原理、架構說明、日誌解讀與操作步驟，請直接參考 TWCC 的範例說明文件：**
📌 [../../twcc/example2_yolov9/README_example2_yolov9.md](../../twcc/example2_yolov9/README_example2_yolov9.md)

唯一的差別在於，本目錄中的 `.sb` 腳本已經為您將 `#SBATCH` 等配置適配成符合 n5 主機 (例如加入了 `# needed in H100` 等排程設定)。您只需準備好自己的程式與資料集，就可以直接開始使用 H100 叢集煉丹！
