## 0. precondition

* login  f1-ilgn01.nchc.org.tw
* assume "~/nchc_hpc_slurm_example" is the default project dir
> cd ~
> git clone https://github.com/waue0920/nchc_hpc_slurm_example.git
* assume "~/nchc_hpc_slurm_example/f1/miniWeather" is the miniweather project
> cd ~/nchc_hpc_slurm_example/f1/
> git clone https://github.com/mrnorman/miniWeather

## 1. prepare the code 

> cd ~/nchc_hpc_slurm_example/f1/miniWeather/c/
> mkdir build_large
> cd build_large
> cat > cmake_gnu.sh <<EOL
> cmake \
>   -DCMAKE_CXX_COMPILER=mpic++ \
>   -DOPENMP_FLAGS="-fopenmp" \
>   -DOPENACC_FLAGS="-fopenacc" \
>   -DOPENMP45_FLAGS="-fopenmp" \
>   -DCXXFLAGS="-O3 -march=native -I/usr/lib/x86_64-linux-gnu/fortran/gfortran-mod-15" \
>   -DLDFLAGS="-L/usr/lib/x86_64-linux-gnu -lpnetcdf" \
>   -DNX=1600 \
>   -DNZ=800 \
>   -DSIM_TIME=1000 \
>   ..
> EOL

## 2. compiler

> singularity shell /work1/waue0920/open_access/miniweather.sif 
> bash ./cmake_gnu.sh 
> make
> ls 
> exit

> cd ../../
> ln ./c/build_large/mpi ./largeweather-mpi

## 3. run slurm job

> cd ~/nchc_hpc_slurm_example/f1/example2_project
> sbatch walk6_2x2_sb.sb

## 4. view the result

> singularity shell /work1/waue0920/open_access/miniweather.sif
> ncview output.nc
