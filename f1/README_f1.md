# This is the NCHC HPC Course 2025 for F1

* Lecture 
   -  https://ppt.cc/fu9IUx

---

## 目錄結構與範例說明 (Directory Structure)

* **`example1_checkenv/`** 
  基礎環境檢查範例：檢查 GPU/CPU 可用資源、模組載入狀態與 Python 環境測試。
* **`example2_benchmark/`** 
  基準測試範例：如何透過 Singularity 環境、CMake 腳本進行程式碼的編譯以及提交 SLURM (`.sb`) 任務做效能壓力測試。
* **`example3_miniweather/`** 
  完整的 `miniWeather` 專案範例：涵蓋實際的 HPC 分散式運算 (MPI / OpenMP / OpenACC)，以及搭配 Singularity 容器的排程任務與執行腳本最佳實踐。
