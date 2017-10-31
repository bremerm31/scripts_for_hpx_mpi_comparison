#!/bin/bash

source config.sh

#check that input_file_name exists in path_to_run_directory
if [ ! -f ${path_to_run_directory}/${input_file_name} ]; then
  echo "Error: could not find ${input_file_name} in ${path_to_run_directory}"
  exit 1
fi
master_input_file="${path_to_run_directory}/${input_file_name}"

echo "Partitioning all meshes for strong scaling study"
echo ""
echo "Path to build tree: " ${path_to_build_tree}
echo "Path to mesh locations: " ${path_to_mesh_locations}
echo "Path to run directory: " ${path_to_run_directory}
echo "Nodes: " ${nodes}
echo "Submesh sizes: " ${submeshes}
echo ""
echo "Partitioner inputs:"
echo "Input file name: " ${input_file_name}
echo "Ranks per locality: " ${ranks_per_locality}
echo "Cores per locality: " ${cores_per_locality}
echo "Submeshes per thread: " ${submeshes_per_thread}
echo ""
echo "Press enter to continue with these setting (or ctrl-c to exit)."

read answer

#Add slurm submission functions
source ../submission_scripts.sh

#Get current dir
script_dir=${PWD}

set -e
for ((i=0; i < "${#nodes[@]}"; ++i)); do
  n=${nodes[i]};
  if [ ! -d "${path_to_mesh_locations}/${n}" ]; then
    mkdir ${path_to_mesh_locations}/${n}
  fi

  if [ ! -d "${path_to_run_directory}/${n}" ]; then
    mkdir ${path_to_run_directory}/${n}
  fi

  #go to script dir to all for relative paths to work
  cd ${script_dir}
  cd ${path_to_run_directory}/${n}
  job_name="part_${n}"

  #copy master input file into the run directories
  cp ${master_input_file} .
  line="file_name: ${path_to_mesh_locations}/${n}/rectangular_mesh.14"
  sed -i "/file_name/c\  ${line}" ${input_file_name}

  #copy mesh file into run directory
  cp ${path_to_mesh_locations}/rectangular_mesh.14 ${path_to_mesh_locations}/${n}

  number_of_partitions=$((${cores_per_locality}*${submeshes_per_thread}*${nodes[i]}))
  args="${input_file_name} ${number_of_partitions} ${nodes[i]} ${ranks_per_locality}"
  commands="${path_to_build_tree}/partitioner/partitioner ${args}"


  echo "Submitting script for mesh partitioning with n = ${n}"
  submit_stampede2_serial "${job_name}" 24:00:00 "${commands}"
done

cd ${script_dir}
