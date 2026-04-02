#!/bin/bash

module purge
module load singularity || true

# sif
SIF=/work/waue0920/open_access/miniweather_nvhpc_20250409.sif

# Build largeweather (NX=1800, NY=900)
echo "Building largeweather_openacc..."
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
"

if [ -f miniWeather ]; then
    cp miniWeather ../../../largeweather_openacc
    echo "largeweather_openacc compiled successfully."
else
    echo "Build failed for largeweather_openacc."
fi
