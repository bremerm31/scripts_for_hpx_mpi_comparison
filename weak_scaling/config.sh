#!/bin/bash

path_to_build_tree=${WORK}/dgswemv2/build_release
path_to_mesh_locations=${SCRATCH}/hpx_v_mpi/weak_scaling/large_grain/hpx
path_to_run_directory=${WORK}/hpx_v_mpi/weak_scaling/large_grain/hpx
declare -a nodes=(2 4 8 16 32 64 128 256 512 1024 2048)
declare -a submeshes=(450 636 900 1273 1800 2546 3600 5091 7200 10182 14400)

#partitioner arguments
#input_fie_name should be located in path_to_run_directory
input_file_name="fort.15"
ranks_per_locality=1
cores_per_locality=68
submeshes_per_thread=2
