#!/bin/bash

path_to_build_tree=${WORK}/dgswemv2/build_release
path_to_mesh_locations=${WORK}/hpx_v_mpi/weak_scaling_meshes
path_to_run_directory=${WORK}/hpx_v_mpi/weak_scaling_runs
declare -a nodes=(2 4 8 16 32 64 128 256 512 1024 2048)
declare -a submeshes=(450 636 900 1273 1800 2546 3600 5091 7200 10182 14400)
