#!/bin/bash


#submit_peano_serial generates temporary slurm submission files
#  and submits them
#Inputs:
#  (1) Job Name
#  (2) Time
#  (3) Script
function submit_peano_serial {

cat > slurm.sub <<EOL
#!/bin/bash
#--------------------------------------------
# Scripts generated for serial submission of
# SLURM script on ICES' Peano cluster
#--------------------------------------------

#SBATCH -p normal
#SBATCH -N 1
#SBATCH -n 1

#SBATCH -J ${1}
#SBATCH -o ${1}.%j
#SBATCH -t ${2}

module load gnu/5.4.0

EOL

echo "${3}" >> slurm.sub

echo "Submitting job..."
sbatch slurm.sub
}

#submit_stampede2-knl_serial generates temporary slurm submission files and submits them
#Inputs:
#  (1) Job Name
#  (2) Time (in hours:minutes:seconds format)
#  (3) Script
function submit_stampede2-knl_serial {

cat > slurm.sub <<EOL
#!/bin/bash
#--------------------------------------------
# Scripts generated for serial submission of
# SLURM script on TACC's Stampede2 cluster
#--------------------------------------------

#SBATCH -p normal
#SBATCH -N 1
#SBATCH -n 1

#SBATCH -J ${1}
#SBATCH -o ${1}.%j
#SBATCH -t ${2}

#SBATCH -A TG-DMS080016N         # Specify allocation to charge against

module load gcc

EOL

echo "${3}" >> slurm.sub

echo "Submitting job..."
#cat slurm.sub
sbatch slurm.sub
}


#submit_stampede2-knl_parallel generates temporary slurm submission files and submits them
#Inputs:
#  (1) Job Name
#  (2) Time (in hours:minutes:seconds format)
#  (3) Number of nodes (N)
#  (4) Number of processes (n)
#  (5) Script
function submit_stampede2-knl_parallel {

#need to select the appropriate queue based on required number of nodes
queue=$([ "${3}" -gt "256" ] && echo "large" || echo "normal")

if [ "${3}" -gt "2048" ]; then
  echo "Error: Unable to submit jobs with more than 2048 nodes"
  exit 1
fi

cat > slurm.sub <<EOL
#!/bin/bash
#--------------------------------------------
# Scripts generated for parallel submission of
# SLURM script on TACC's Stampede2 cluster
#--------------------------------------------

#SBATCH -p ${queue}
#SBATCH -N ${3}
#SBATCH -n ${4}

#SBATCH -J ${1}
#SBATCH -o ${1}.%j
#SBATCH -t ${2}

#SBATCH -A TG-DMS080016N         # Specify allocation to charge against

module load gcc

EOL

echo "${5}" >> slurm.sub

echo "Submitting job..."
cat slurm.sub
sbatch slurm.sub
}

#submit_stampede2-skx_serial generates temporary slurm submission files and submits them
#Inputs:
#  (1) Job Name
#  (2) Time (in hours:minutes:seconds format)
#  (3) Script
function submit_stampede2-skx_serial {

cat > slurm.sub <<EOL
#!/bin/bash
#--------------------------------------------
# Scripts generated for serial submission of
# SLURM script on TACC's Stampede2 cluster
#--------------------------------------------

#SBATCH -p skx-normal
#SBATCH -N 1
#SBATCH -n 1

#SBATCH -J ${1}
#SBATCH -o ${1}.%j
#SBATCH -t ${2}

#SBATCH -A TG-DMS080016N         # Specify allocation to charge against

module load gcc

EOL

echo "${3}" >> slurm.sub

echo "Submitting job..."
cat slurm.sub
sbatch slurm.sub
}


#submit_stampede2-skx_parallel generates temporary slurm submission files and submits them
#Inputs:
#  (1) Job Name
#  (2) Time (in hours:minutes:seconds format)
#  (3) Number of nodes (N)
#  (4) Number of processes (n)
#  (5) Script
function submit_stampede2-skx_parallel {

#need to select the appropriate queue based on required number of nodes
queue=$([ "${3}" -gt "128" ] && echo "skx-large" || echo "skx-normal")

if [ "${3}" -gt "868" ]; then
  echo "Error: Unable to submit jobs with more than 868 nodes"
  exit 1
fi

cat > slurm.sub <<EOL
#!/bin/bash
#--------------------------------------------
# Scripts generated for parallel submission of
# SLURM script on TACC's Stampede2 cluster
#--------------------------------------------

#SBATCH -p ${queue}
#SBATCH -N ${3}
#SBATCH -n ${4}

#SBATCH -J ${1}
#SBATCH -o ${1}.%j
#SBATCH -t ${2}

#SBATCH -A TG-DMS080016N         # Specify allocation to charge against

module load gcc

EOL

echo "${5}" >> slurm.sub

echo "Submitting job..."
cat slurm.sub
sbatch slurm.sub
}
