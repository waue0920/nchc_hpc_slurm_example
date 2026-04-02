## 0. precondition

* login  f1-ilgn01.nchc.org.tw
* assume "~/nchc_hpc_slurm_example" is the default project dir
> cd ~
> git clone https://github.com/waue0920/nchc_hpc_slurm_example.git

## 1. go to workspace

> cd ~/nchc_hpc_slurm_example/f1/example1_checkenv/

## 2. run slurm job

> sbatch 1check_gpu_single.sb
> sacct
> cat  z_1check.log

## 3. then, run and check

> sbatch 2check_env_sh.sb
> sbatch 3check_env_py.sb


