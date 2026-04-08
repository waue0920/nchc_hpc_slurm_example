#!/bin/bash
# ============================================================
# 1_prepare_conda_env.sh
# 在 Login 節點上建立 YOLO-World 所需的 Conda 環境
# 借鏡 example2_yolov9 穩定且在 TWCC 經過驗證的 requirements.txt！
# 請直接執行: bash 1_prepare_conda_env.sh
# ============================================================

ENV_NAME="yolo_world_env"
PYTHON_VER="3.10"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# 結合 YOLOv9 穩定環境核心，與 YOLO-World 所需的套件清單
GOLDEN_REQ="$SCRIPT_DIR/requirements.txt"

echo "===================================="
echo "建立 Conda 環境: $ENV_NAME (Python $PYTHON_VER)"
echo "===================================="

eval "$(conda shell.bash hook)"
unset PYTHONPATH

if conda env list | grep -q "^${ENV_NAME}"; then
    echo "[SKIP] 環境 $ENV_NAME 已存在，先將其刪除以確保純淨..."
    conda env remove -y -n "$ENV_NAME"
fi

echo "重新建立乾淨的 $ENV_NAME ..."
conda create -y -n "$ENV_NAME" python="$PYTHON_VER" pip
conda activate "$ENV_NAME"
conda install -y pip >/dev/null 2>&1

echo "===================================="
echo "核心依賴: 使用 YOLOv9 經 TWCC 驗證的穩固 requirements.txt"
echo "包含穩定版 PyTorch 2.0.1 等深度學習基底"
echo "===================================="
if [ -f "$GOLDEN_REQ" ]; then
    python -m pip install --upgrade-strategy only-if-needed -r "$GOLDEN_REQ"
else
    echo "[!] 找不到 TWCC 穩定版依賴 $GOLDEN_REQ，請確認 example2_yolov9 是否存在！"
    exit 1
fi

echo "===================================="
echo "[完成] 所有套件安裝完畢！完全不依賴特權與 mim，全部由 pip 管理！"
echo "執行 bash 2_prepare_github_data.sh 下載程式碼與資料。"
echo "===================================="

