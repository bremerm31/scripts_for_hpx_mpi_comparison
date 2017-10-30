#!/bin/bash

## HPX configuration
path_to_build_tree=${WORK}/dgswemv2/build_release
path_to_mesh_locations=${SCRATCH}/hpx_v_mpi/strong_scaling/hpx
path_to_run_directory=${WORK}/hpx_v_mpi/strong_scaling/hpx
declare -a nodes=(1 2 4 8 16 32 64)
submeshes=300

#partitioner arguments
#input_fie_name should be located in path_to_run_directory
input_file_name="fort.15"
parallelized_file_name="fort_parallelized.15"
ranks_per_locality=1
cores_per_locality=68
submeshes_per_thread=2


## MPI configuration
#path_to_build_tree=${WORK}/dgswemv2/build_release
#path_to_mesh_locations=${SCRATCH}/hpx_v_mpi/weak_scaling/large_grain/mpi
#path_to_run_directory=${WORK}/hpx_v_mpi/weak_scaling/large_grain/mpi
#declare -a nodes=(2 4 8 16 32 64 128 256 512)
#declare -a submeshes=(450 636 900 1273 1800 2546 3600 5091 7200)

##partitioner arguments
##input_fie_name should be located in path_to_run_directory
#input_file_name="fort.15"
#parallelized_file_name="fort_parallelized.15"
#ranks_per_locality=68
#cores_per_locality=68
#submeshes_per_thread=1
