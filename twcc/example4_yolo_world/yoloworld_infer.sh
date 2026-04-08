#!/bin/bash
# ============================================================
# yoloworld_infer.sh
# YOLO-World 推論封裝腳本
# 由 1_yoloworld_infer_single.sb 透過 srun 呼叫
# ============================================================

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR"

# ---- SLURM 環境 ----
NGPU=$(nvidia-smi -L | wc -l)
echo "Debug Information:"
echo "==================="
echo "Hostname:      $(hostname)"
echo "GPU 數量:       $NGPU"
echo "SLURM_JOB_ID:  $SLURM_JOB_ID"
echo "SLURM_NODEID:  $SLURM_NODEID"
echo "==================="

# ---- 環境載入（三選一）----

# 方法一：Conda（預設）
eval "$(conda shell.bash hook)"
conda activate yolo_world_env
EXEC_ENV=""

# 方法二：Singularity
# SIF=/work1/<YOUR_ACCOUNT>/containers/yolo_world.sif
# EXEC_ENV="singularity exec --nv $SIF"

# 方法三：Conda run
# EXEC_ENV="conda run -n yolo_world_env --no-capture-output"

echo "Python: $($EXEC_ENV python --version)"
echo "==================="

# ---- 執行推論 ----
INFER_CMD="$EXEC_ENV python infer.py"
echo "執行推論命令:"
echo "$INFER_CMD"
echo "==================="
$INFER_CMD

if [ $? -ne 0 ]; then
    echo "Error: infer.py 執行失敗 (node: $(hostname))" >&2
    exit 1
fi
echo "推論完成！結果已輸出至 infer_output/ 目錄。"
