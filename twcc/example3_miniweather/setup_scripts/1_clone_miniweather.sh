#!/bin/bash
if [ ! -d "miniWeather" ]; then
    git clone https://github.com/mrnorman/miniWeather.git
    echo "miniWeather cloned successfully."
else
    echo "miniWeather is already cloned."
fi
