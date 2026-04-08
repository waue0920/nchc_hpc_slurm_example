## 0. precondition

* login f1-ilgn01.nchc.org.tw
* assume "~/nchc_hpc_slurm_example" is the default project dir
> cd ~
> git clone https://github.com/waue0920/nchc_hpc_slurm_example.git

## 1. go to workspace

> cd ~/nchc_hpc_slurm_example/f1/example2_benchmark/

## 2. build and run benchmark

> singularity shell miniweather.sif
> bash ./cmake.sh
> bash ./gen_benchmark.sh
> exit

## 3. submit benchmark job

> sbatch try_benchmark.sb
