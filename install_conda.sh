#!/bin/bash
set -e

for HOST in 10.43.97.135 10.43.97.136 10.43.97.148 10.43.97.146 
do
  echo "Installing Conda environment for PySpark on $HOST."

  ssh estudiante@$HOST bash -s <<'EOF'
set -e
mkdir -p ~/conda_install
cd ~/conda_install
wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
sudo bash Miniforge3-Linux-x86_64.sh -b -p /opt/miniforge3
source /opt/miniforge3/bin/activate
conda init bash
source ~/.bashrc
sudo mkdir -p /opt/conda_envs/pyspark_env
cd /opt/conda_envs/pyspark_env
sudo tar -xzf /nfs/condor/conda_envs/pyspark_env.tar.gz
sudo ./bin/conda-unpack
/opt/conda_envs/pyspark_env/bin/python --version
EOF

  echo "Conda environment for PySpark installed on $HOST."

done
