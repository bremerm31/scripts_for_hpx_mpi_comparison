#!/bin/bash

source config.sh

echo "Submitting all hpx runs for strong scaling study"
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
  job_name="dgswemv2_hpx_${n}"

  args="${parallelized_file_name} --hpx:threads=68"
  commands="ibrun ${path_to_build_tree}/examples/MANUFACTURED_SOLUTION_HPX ${args}"


  echo "Submitting script for hpx run with n = ${nodes[i]}"
  submit_stampede2_parallel "${job_name}" 01:00:00 ${nodes[i]} ${nodes[i]} "${commands}"
done

cd ${script_dir}
