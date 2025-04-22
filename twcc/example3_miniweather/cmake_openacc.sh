### readme
# 1. git clone the miniweather, then go to c/
# 2. into singularity shell mode
# 3. run the script, then make, to build binary openacc

cmake \
  -DCMAKE_CXX_COMPILER=mpic++ \
  -DCXXFLAGS="-O3 -Mvect -DNO_INFORM -std=c++11 -I/opt/pnetcdf-1.12.0/include" \
  -DLDFLAGS="-L/opt/pnetcdf-1.12.0/lib -lpnetcdf" \
  -DOPENACC_FLAGS:STRING="-acc -gpu=cc70,fastmath,loadcache:L1,ptxinfo -Minfo=accel" \
  -DNX=1800 \
  -DNY=900 \
  ..
