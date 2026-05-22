for HOST in 10.43.97.141 10.43.97.135 10.43.97.136 10.43.97.148 10.43.97.146
do
  echo "Installing Java 17 on $HOST..."

  ssh estudiante@$HOST "
    sudo dnf install -y java-17-openjdk java-17-openjdk-devel
  "
done