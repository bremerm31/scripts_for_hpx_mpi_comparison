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
commands=""
for ((i=0; i < "${#nodes[@]}"; ++i)); do
    n=${nodes[i]}
    m=${submeshes[i]}

    curr_run_dir=${path_to_run_directory}/${node_type}/${parallelization}_${partitioning}/${n}
    curr_mesh_dir=${path_to_mesh_locations}/${node_type}/${parallelization}_${partitioning}/${n}

    mkdir -p ${curr_run_dir}
    mkdir -p ${curr_mesh_dir}

    tmp=$(cat <<EOF
cd ${curr_mesh_dir}
${path_to_build_tree}/mesh_generators/rectangular_mesh_generator ${m} ${m} &
EOF
)
    commands="${commands}"$'\n'$'\n'"${tmp}"
done
commands="${commands}"$'\n'"wait"

echo "${commands}"
#just run the job instead of submitting it
eval "${commands}"
#job_name="gen_${node_type}"
#submit_stampede2-knl_serial "${job_name}" 1:00:00 "${commands}"

cd ${script_dir}
