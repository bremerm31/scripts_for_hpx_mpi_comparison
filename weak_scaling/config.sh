#!/bin/bash

node_type="knl" #knl or skx
parallelization="mpi" #hpx or mpi
partitioning="hierarch" #flat or hierarch

path_to_build_tree=${WORK}/dgswemv2/build_release_${node_type}
path_to_mesh_locations=${SCRATCH}/hpx_v_mpi/weak_scaling
path_to_run_directory=${WORK}/hpx_v_mpi/weak_scaling

declare -a nodes=(1 2 4 8 16 32 64 128 256)
declare -a submeshes=(318 450 636 900 1273 1800 2546 3600 5091)

#partitioner arguments
#input_fie_name should be located in path_to_run_directory
mesh_file_name="rectangular_mesh.14"
path_to_fort15="/work/02578/bremer/stampede2/hpx_v_mpi/strong_scaling"
input_file_name="fort.15"
parallelized_file_name="fort_parallelized.15"

if [ "${node_type}" == "knl" ]; then
  cores_per_socket=68
  sockets_per_node=1
fi
if [ "${node_type}" == "skx" ]; then
  cores_per_socket=24
  sockets_per_node=2
fi

if [ "${parallelization}" == "hpx" ]; then
  ranks_per_socket=1
  submeshes_per_rank=$((2*${cores_per_socket}))
fi

if [ "${parallelization}" == "mpi" ]; then
  ranks_per_socket=${cores_per_socket}
  submeshes_per_rank=1
fi


#################################################
# check inputs
function check_inputs {

    error=0

    if [ "${node_type}" != "skx" ] && [ "${node_type}" != "knl" ]; then
	echo "Error: node_type set to: ${node_type}"
	echo "       Only current valid options are: skx, knl"
	error=1
    fi

    if [ "${parallelization}" != "hpx" ] && [ "${parallelization}" != "mpi" ]; then
	echo "Error: parallelization set to: ${parallelization}"
	echo "       Only current valid options are: hpx, mpi"
	error=1
    fi

    if [ "${partitioning}" != "flat" ] && [ "${partitioning}" != "hierarch" ]; then
	echo "Error: partitioning set to: ${partitioning}"
	echo "       Only current valid options are: flat, hierarch"
	error=1
    fi

    if [ ! ${#nodes[@]} -eq ${#submeshes[@]} ]; then
	echo "Error: the size of arrays nodes and submeshes are not equal"
        error=1
    fi

    if [ ${error} -eq 1 ]; then
	echo "Please fix the above errors"
	exit 1
    fi
}
