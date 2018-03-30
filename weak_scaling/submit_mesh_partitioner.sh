#!/bin/bash

source config.sh
check_inputs

#check that input_file_name exists in path_to_run_directory
if [ ! -f ${path_to_fort15}/${input_file_name} ]; then
  echo "Error: could not find ${input_file_name} in ${path_to_fort15}"
  exit 1
fi

master_input_file="${path_to_run_directory}/${input_file_name}"

echo "Partitioning all meshes for strong scaling study"
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
    m=${submeshes[i]};

    curr_run_dir=${path_to_run_directory}/${node_type}/${parallelization}_${partitioning}/${n}
    curr_mesh_dir=${path_to_mesh_locations}/${node_type}/${parallelization}_${partitioning}/${n}

    mkdir -p ${curr_run_dir}
    mkdir -p ${curr_mesh_dir}

    curr_mesh_file=${curr_mesh_dir}/${mesh_file_name}
    if [ ! -f ${curr_mesh_file} ]; then
	echo "Error:could not find ${mesh_file_name} in ${curr_mesh_dir}"
	exit 1
    fi

    #copy master input file into the run directories
    cd ${curr_run_dir}
    cp ${master_input_file} .

    curr_input_file_name=${curr_run_dir}/${input_file_name}

    line="file_name: ${curr_mesh_file}"
    sed -i "/file_name/c\  ${line}" ${input_file_name}

    num_sockets=$((${sockets_per_node}*${n}))
    number_of_partitions=$((${submeshes_per_rank}*${ranks_per_socket}*${num_sockets}))


    if [ "${partitioning}" == "flat" ]; then
	if [ "${parallelization}" == "mpi" ]; then
	    args="${curr_input_file_name} ${number_of_partitions} 1 ${number_of_partitions}"
	else #${parallelization} == hpx
	    args="${curr_input_file_name} ${number_of_partitions} 1 ${num_sockets}"
	fi
    else #${partitioning} == "hierarch"
	args="${curr_input_file_name} ${number_of_partitions} ${num_sockets} ${ranks_per_socket}"
    fi

    commands="${commands}${path_to_build_tree}/partitioner/partitioner ${args} &"$'\n'

done
commands="${commands}wait"
job_name="part_${parallelization}_${node_type}"
submit_stampede2-skx_serial "${job_name}" 12:00:00 "${commands}"

cd ${script_dir}
