#!/bin/bash

WALK6_TEMPLATE_PATH="./walk6.sb"

if [ ! -f "$WALK6_TEMPLATE_PATH" ]; then
  echo "找不到 walk6.sb，請確認檔案存在於同一目錄下。"
  exit 1
fi

NODE_LIST=(1 2 4 8)
TASK_LIST=(1 2 4 8 16 32)

for NODES in "${NODE_LIST[@]}"; do
  DIR="node${NODES}"
  mkdir -p "$DIR"
  
  # 根據 ntasks 的大小選擇分區
  ntasks=$((32 * $NODES))
  if [ $ntasks -gt 112 ]; then
    partition="ct448"
  else
    partition="ct112"
  fi
  
  # 生成 TASKLIST
  tasklist_str=""
  for nt in "${TASK_LIST[@]}"; do
    tasklist_str+="$((nt * $NODES)) "
  done
  
  sed \
    -e "s/^#SBATCH --nodes=.*/#SBATCH --nodes=${NODES}/" \
    -e "s/^#SBATCH --ntasks=.*/#SBATCH --ntasks=${ntasks}/" \
    -e "s/^#SBATCH --job-name=.*/#SBATCH --job-name=mw_w6_${NODES}n/" \
    -e "s/^#SBATCH --partition=.*/#SBATCH --partition=${partition}/" \
    -e "s/\[node1\]/[node${NODES}]/g" \
    -e "s/TASKLIST=.*/TASKLIST=($tasklist_str)/" \
    "$WALK6_TEMPLATE_PATH" > "$DIR/walk6.sb"
  echo "✓ 已建立 $DIR/walk6.sb"
done

