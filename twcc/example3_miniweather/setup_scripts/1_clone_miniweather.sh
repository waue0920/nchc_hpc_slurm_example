#!/bin/bash
# 切換到腳本的上層目錄 (也就是 example3_miniweather 目錄)
cd "$(dirname "$0")/.." || exit

if [ ! -d "miniWeather" ]; then
    git clone https://github.com/mrnorman/miniWeather.git
    echo "miniWeather cloned successfully."
else
    echo "miniWeather is already cloned."
fi
