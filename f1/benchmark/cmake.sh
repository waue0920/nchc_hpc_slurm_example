#!/bin/bash

set -e  # 有錯就中止

SRC_DIR=$(pwd)

# 共用參數
COMMON_FLAGS="-DNX=200 -DNZ=100 -DSIM_TIME=1000"
LDFLAGS="-L/usr/lib/x86_64-linux-gnu -lpnetcdf"

# ========== MPI ==========
echo "=== Building MPI version ==="
BUILD_DIR=build_mpi
mkdir -p $BUILD_DIR && cd $BUILD_DIR

cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_MODE=mpi \
      $COMMON_FLAGS \
      -DCMAKE_CXX_COMPILER=mpic++ \
      -DCMAKE_CXX_FLAGS="-O3 -march=native" \
      -DLDFLAGS="$LDFLAGS" \
      $SRC_DIR

make -j
mv miniweather ../miniweather-mpi
cd $SRC_DIR

# ========== OpenMP ==========
echo "=== Building OpenMP version ==="
BUILD_DIR=build_openmp
mkdir -p $BUILD_DIR && cd $BUILD_DIR

cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_MODE=openmp \
      $COMMON_FLAGS \
      -DCMAKE_CXX_COMPILER=g++ \
      -DCMAKE_CXX_FLAGS="-O3 -march=native -fopenmp" \
      -DLDFLAGS="$LDFLAGS" \
      $SRC_DIR

make -j
mv miniweather ../miniweather-openmp
cd $SRC_DIR

# ========== OpenACC ==========
echo "=== Building OpenACC version ==="
BUILD_DIR=build_openacc
mkdir -p $BUILD_DIR && cd $BUILD_DIR

cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_MODE=openacc \
      $COMMON_FLAGS \
      -DCMAKE_CXX_COMPILER=nvc++ \
      -DCMAKE_CXX_FLAGS="-O3 -acc -ta=multicore -Minfo=accel -march=native" \
      -DLDFLAGS="$LDFLAGS" \
      $SRC_DIR

make -j
mv miniweather ../miniweather-openacc
cd $SRC_DIR

echo "✅ All builds completed!"
ls -lh miniweather-*
