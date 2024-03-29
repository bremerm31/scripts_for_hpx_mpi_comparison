#!/bin/bash

source config.sh
check_inputs

#check that input_file_name exists in path_to_run_directory
if [ ! -f ${path_to_fort15}/${input_file_name} ]; then
  echo "Error: could not find ${input_file_name} in ${path_to_fort15}"
  exit 1
fi

if [ ! -f ${path_to_mesh_locations}/${mesh_file_name} ]; then
  echo "Error:could not find ${mesh_file_name} in ${path_to_mesh_locations}"
  exit 1
fi
master_input_file="${path_to_fort15}/${input_file_name}"
master_mesh_file="${path_to_mesh_locations}/${mesh_file_name}"
master_bcis_file="${path_to_mesh_locations}/${bcis_file_name}"

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
source ${scripts_dir}/submission_scripts.sh

set -e
commands=""
for ((i=0; i < "${#nodes[@]}"; ++i)); do
  n=${nodes[i]};

  curr_run_dir=${path_to_run_directory}/${node_type}/${parallelization}_${partitioning}/${n}
  curr_mesh_dir=${path_to_mesh_locations}/${node_type}/${parallelization}_${partitioning}/${n}

  mkdir -p ${curr_run_dir}
  mkdir -p ${curr_mesh_dir}

  #go to script dir to all for relative paths to work
  cd ${curr_run_dir}

  #copy master input file into the run directories
  cp ${master_input_file} .
  cp ${master_mesh_file} ${curr_mesh_dir}
  cp ${master_bcis_file} ${curr_mesh_dir}
  curr_input_file_name=${curr_run_dir}/${input_file_name}


  line="file_name: ${curr_mesh_dir}/inlet.14"
  sed -i "/file_name/c\  ${line}" ${input_file_name}

  num_sockets=$(( ${sockets_per_node}*${n} ))
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
  partitioner_exe="${path_to_dgswemv2}/build_release_skx-old/partitioner/partitioner"
  commands="${commands}${partitioner_exe} ${args} &"$'\n'

done
commands="${commands}wait"
job_name="part_${node_type}"

echo ${commands}
eval ${commands}

#submit_stampede2-skx_serial "${job_name}" 12:00:00 "${commands}"
