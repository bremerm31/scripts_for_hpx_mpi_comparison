#!/bin/bash

source config.sh
check_inputs

echo "Submitting all hpx runs for weak scaling study"
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
for ((i=0; i < "${#nodes[@]}"; ++i)); do
  n=${nodes[i]};

  curr_run_dir=${path_to_run_directory}/${node_type}/${parallelization}_${partitioning}/${n}

  curr_input_file=${curr_run_dir}/${parallelized_file_name}

  #check that input_file_name exists in path_to_run_directory
  if [ ! -f ${curr_input_file} ]; then
      echo "Error: could not find ${parallelized_file_name} in ${curr_run_dir}"
      exit 1
  fi

  cd ${curr_run_dir}
  job_name="dgswemv2_${parallelization}_${n}"

  args="${curr_input_file}"
  if [ "${parallelization}" == "hpx" ]; then
      args="${args} --hpx:threads=${cores_per_socket}"
  fi

  if [ "${parallelization}" == "hpx" ]; then
      executable="${path_to_build_tree}/examples/MANUFACTURED_SOLUTION_HPX"
      processes=$(( ${n}*${sockets_per_node} ))
  elif [ "${parallelization}" == "mpi" ]; then
      executable="${path_to_build_tree}/examples/MANUFACTURED_SOLUTION_OMPI"
      processes=$((${cores_per_socket}*${sockets_per_node}*${n}))
  fi

  launcher="submit_stampede2-${node_type}_parallel"

  commands="ibrun ${executable} ${args}"

  echo "Submitting script for ${parallelization} run with ${n} nodes"
  ${launcher} "${job_name}" 01:00:00 ${n} ${processes} "${commands}"
done

cd ${script_dir}
