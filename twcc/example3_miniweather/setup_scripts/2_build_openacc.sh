#!/bin/bash
# 切換到腳本的上層目錄 (也就是 example3_miniweather 目錄)
cd "$(dirname "$0")/.." || exit

module purge
module load singularity || true

# sif
SIF=/work/waue0920/open_access/miniweather_nvhpc_20250409.sif

# 1. Build largeweather (NX=1800, NY=900)
echo "Building largeweather_openacc... (詳情請看 z_build_large.log)"
mkdir -p miniWeather/c/build_large
cd miniWeather/c/build_large

singularity exec --nv $SIF bash -c "
  cmake \
    -DCMAKE_CXX_COMPILER=mpic++ \
    -DCXXFLAGS=\"-O3 -Mvect -DNO_INFORM -std=c++11 -I/opt/pnetcdf-1.12.0/include\" \
    -DLDFLAGS=\"-L/opt/pnetcdf-1.12.0/lib -lpnetcdf\" \
    -DOPENACC_FLAGS=\"-acc -gpu=cc70,fastmath,loadcache:L1,ptxinfo -Minfo=accel\" \
    -DNX=1800 \
    -DNY=900 \
    .. && make -j4
" > ../../../z_build_large.log 2>&1

if [ -f openacc ]; then
    cp openacc ../../../largeweather_openacc
    echo "largeweather_openacc compiled successfully."
else
    echo "Build failed for largeweather_openacc. Check z_build_large.log"
fi

# 2. Build hugeweather (NX=3600, NY=1800) -- 對應之前的 hugeweather
cd ../../..
echo "Building hugeweather_openacc... (詳情請看 z_build_huge.log)"
mkdir -p miniWeather/c/build_huge
cd miniWeather/c/build_huge

singularity exec --nv $SIF bash -c "
  cmake \
    -DCMAKE_CXX_COMPILER=mpic++ \
    -DCXXFLAGS=\"-O3 -Mvect -DNO_INFORM -std=c++11 -I/opt/pnetcdf-1.12.0/include\" \
    -DLDFLAGS=\"-L/opt/pnetcdf-1.12.0/lib -lpnetcdf\" \
    -DOPENACC_FLAGS=\"-acc -gpu=cc70,fastmath,loadcache:L1,ptxinfo -Minfo=accel\" \
    -DNX=3600 \
    -DNY=1800 \
    .. && make -j4
" > ../../../z_build_huge.log 2>&1

if [ -f openacc ]; then
    cp openacc ../../../hugeweather_openacc
    echo "hugeweather_openacc compiled successfully."
else
    echo "Build failed for hugeweather_openacc. Check z_build_huge.log"
fi
