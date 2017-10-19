#!/bin/bash

source config.sh

if [ ! ${#nodes[@]} -eq ${#submeshes[@]} ]; then
  echo "Error: the size of arrays nodes and submshes are not equal"
  exit 1
fi

echo "Generating all meshes for weak scaling study"
echo ""
echo "Path to build tree: " ${path_to_build_tree}
echo "Path to mesh locations: " ${path_to_mesh_locations}
echo "Path to run directory: " ${path_to_run_directory}
echo "Nodes: " ${nodes}
echo "Submesh sizes: " ${submeshes}
echo ""
echo "Press enter to continue with these setting (or ctrl-c to exit)."

read answer

#Add slurm submission functions
source ../submission_scripts.sh

#Get current dir
script_dir=${PWD}

set -e
for m in "${submeshes[@]}"; do
  if [ ! -d "${path_to_mesh_locations}/${m}" ]; then
    mkdir ${path_to_mesh_locations}/${m}
  fi

  if [ ! -d "${path_to_run_directory}/${m}" ]; then
    mkdir ${path_to_run_directory}/${m}
  fi
  echo "Submitting script for mesh with ${m} partitions"

  #go to script dir to all for relative paths to work
  cd ${script_dir}
  cd ${path_to_run_directory}/${m}
  job_name="gen_${m}"

  commands="cd ${path_to_mesh_locations}/${m}"$'\n'"${path_to_build_tree}/mesh_generators/rectangular_mesh_generator ${m} ${m}"

  submit_peano_serial "${job_name}" 24:00:00 "${commands}"
done

cd ${script_dir}
