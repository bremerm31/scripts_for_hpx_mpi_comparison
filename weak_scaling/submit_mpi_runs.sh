#!/bin/bash

source config.sh

#check that the length of nodes and submeshes are equal
if [ ! ${#nodes[@]} -eq ${#submeshes[@]} ]; then
  echo "Error: the size of arrays nodes and submshes are not equal"
  exit 1
fi

echo "Submitting all hpx runs for weak scaling study"
echo ""
echo "Path to build tree: " ${path_to_build_tree}
echo "Path to mesh locations: " ${path_to_mesh_locations}
echo "Path to run directory: " ${path_to_run_directory}
echo "Nodes: " ${nodes}
echo "Submesh sizes: " ${submeshes}
echo ""
echo "Run inputs:"
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
  m=${submeshes[i]};
  if [ ! -d "${path_to_mesh_locations}/${m}" ]; then
    mkdir ${path_to_mesh_locations}/${m}
  fi

  if [ ! -d "${path_to_run_directory}/${m}" ]; then
    mkdir ${path_to_run_directory}/${m}
  fi

  #go to script dir to all for relative paths to work
  cd ${script_dir}
  cd ${path_to_run_directory}/${m}
  job_name="dgswemv2_mpi_${m}"

  args="${parallelized_file_name}"
  commands="ibrun tacc_affinity ${path_to_build_tree}/examples/MANUFACTURED_SOLUTION_OMPI ${args}"
  mpi_ranks=$((${nodes[i]}*${ranks_per_locality}))

  echo "Submitting script for hpx run with m = ${submeshes[i]}"
  submit_stampede2_parallel "${job_name}" 01:00:00 ${nodes[i]} ${mpi_ranks} "${commands}"
done

cd ${script_dir}
