# Matar el Worker en cada nodo por su puerto
for ip in 10.43.97.135 10.43.97.136 10.43.97.141 10.43.97.146 10.43.97.148; do
    echo "=== Matando Worker :8888 en $ip ==="
    ssh estudiante@$ip "jps | grep Worker"
    ssh estudiante@$ip "jps | grep Worker | awk '{print \$1}' | xargs kill -9"
done