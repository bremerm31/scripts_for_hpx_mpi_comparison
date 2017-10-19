#!/bin/bash


#submit_peano_serial generates temporary slurm submission files
#  and submits them
#Inputs:
#  Job Name
#  Time
#  Script
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
