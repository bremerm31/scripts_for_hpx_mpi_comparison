#!/bin/bash

source config.sh

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

echo "Submitting script for mesh with ${submeshes} partitions"

mkdir -p ${path_to_mesh_locations}/${node_type}/${parallelization}
mkdir -p ${path_to_run_directory}/${node_type}/${parallelization}

#go to script dir to all for relative paths to work
cd ${path_to_run_directory}
job_name="gen_${submeshes}_${node_type}"

mkdir -p ${path_to_mesh_locations}
mkdir -p ${path_to_run_directory}
commands="cd ${path_to_mesh_locations} && ${path_to_build_tree}/mesh_generators/rectangular_mesh_generator ${submeshes} ${submeshes}"

echo ${commands}
${commands}
#submit_stampede2-knl_serial "${job_name}" 24:00:00 "${commands}"

cd ${script_dir}
