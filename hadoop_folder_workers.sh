for HOST in 10.43.97.141 10.43.97.135 10.43.97.136 10.43.97.148 10.43.97.146 10.43.97.145
do
  echo "Configuring Hadoop folders on $HOST..."

  ssh estudiante@$HOST "
    sudo mkdir -p /mnt/HadoopHDFS/DataNode && \
    sudo chown -R estudiante:estudiante /mnt/HadoopHDFS
    sudo chmod -R 777 /mnt/HadoopHDFS/DataNode
  "
done