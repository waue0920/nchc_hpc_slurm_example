#!/bin/bash
# 切換到腳本的上層目錄
cd "$(dirname "$0")/.." || exit

echo "檢查編譯結果..."
echo "-----------------------------------"

MISSING=0

check_file() {
    if [ -f "$1" ]; then
        echo "[OK] 檔案存在: $1"
        if [ -x "$1" ]; then
            echo "     --> 具有執行權限"
        else
            echo "     --> 不具執行權限，嘗試修正..."
            chmod +x "$1"
        fi
    else
        echo "[ERROR] 缺少檔案: $1"
        MISSING=1
    fi
}

check_file "largeweather_openacc"

# 檢查一下是否也有建立 hugeweather_openacc
check_file "hugeweather_openacc"

echo "-----------------------------------"
if [ "$MISSING" -eq 1 ]; then
    echo "⚠️  編譯似乎不完整。如果在 sbatch log 內看到錯誤，請檢查是否有成功掛載 GPU 與 module 的資源。"
else
    echo "✅  所有執行檔狀態良好！您可以開始使用 sbatch 提交測試腳本了！"
fi
