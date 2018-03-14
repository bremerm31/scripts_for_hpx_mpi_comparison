#!/bin/bash

source config.sh
check_inputs

echo "Generating all meshes for strong scaling study"
echo ""
echo "Path to build tree: " ${path_to_build_tree}
echo "Path to mesh locations: " ${path_to_mesh_locations}
echo "Path to run directory: " ${path_to_run_directory}
echo ""
echo "Node Type: " ${node_type}
echo "Nodes: " ${nodes}
echo "Sockets per node: " ${sockets_per_node}
echo "Cores per socket: " ${cores_per_socket}
echo ""
echo "Submesh sizes: " ${submeshes}
echo ""
echo "Parallelization: " ${parallelization}
echo "Partitioning strategy: " ${partitioning}
echo ""
echo "Press enter to continue with these setting (or ctrl-c to exit)."

read answer

#Add slurm submission functions
source ../submission_scripts.sh

#Get current dir
script_dir=${PWD}

set -e
launcher="submit_stampede2-${node_type}_parallel"

for ((i=0; i < "${#nodes[@]}"; ++i)); do
  n=${nodes[i]};

  #go to script dir to all for relative paths to work
  cd ${script_dir}
  cd ${path_to_run_directory}/${node_type}/${parallelization}_${partitioning}/${n}
  job_name="dgswemv2_${parallelization}_${n}"

  args="${parallelized_file_name}"
  commands="ibrun tacc_affinity ${path_to_build_tree}/examples/MANUFACTURED_SOLUTION_OMPI ${args}"
  mpi_ranks=$((${cores_per_socket}*${sockets_per_node}*${nodes[i]}))

  echo "Submitting script for mpi run with n = ${nodes[i]}"
  ${launcher} "${job_name}" 01:00:00 ${nodes[i]} ${mpi_ranks} "${commands}"
done

cd ${script_dir}
