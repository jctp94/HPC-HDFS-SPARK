# HPC-HDFS-SPARK

**Pontificia Universidad Javeriana — Computación de Alto Desempeño**
Taller: Integración de Hadoop HDFS + Apache Spark
Docente: John Corredor, PhD | Fecha: 2026-05-14

**Integrantes:** Juan S. Bravo · Felix D. Cordova · Jonatan A. Gallo · Jose A. Jaime · Josman A. Ramirez · Jesús D. Romero · Juan C. Torres

---

## Objetivo

Implementar un clúster Hadoop HDFS funcional sobre VMs Rocky Linux y comparar su rendimiento frente a NFS como capa de almacenamiento para cargas distribuidas con Apache Spark.

---

## Arquitectura del Clúster

| Nodo | IP | Rol |
|------|----|-----|
| cadcliente02 | 10.43.97.145 | NameNode / Spark Master |
| cadhead02 | 10.43.97.146 | DataNode 1 |
| cad02-w003 | 10.43.97.148 | DataNode 2 |
| cad02-w002 | 10.43.97.136 | DataNode 3 |
| cad02-w001 | 10.43.97.135 | DataNode 4 |
| cad02-w000 | 10.43.97.141 | DataNode 5 |
| cad02-nfs01 | 10.43.97.149 | NFS (binarios compartidos) |

**Stack:** Hadoop 3.5.0 · Spark 3.5.2 · Python 3.11.15 · PySpark · Java 17 · Miniforge3

Capacidad total del clúster HDFS: **119.65 GB** (6 nodos × ~20 GB).
Spark: **20 cores** y **60 GB RAM** distribuidos entre los 5 workers.

---

## Configuración del Clúster (pasos)

1. **SSH sin contraseña** — `ssh-keygen` + `ssh-copy-id` entre master y workers.
2. **Instalación de Hadoop** — descarga desde Apache CDN, descompresión en NFS compartido.
3. **Instalación de Java 17** — `install_java_17.sh` corre `dnf install java-17-openjdk` en todos los nodos.
4. **Archivos de configuración Hadoop:**
   - `core-site.xml` → URI del NameNode (`hdfs://10.43.97.145:9000`)
   - `hadoop-env.sh` → `JAVA_HOME`
   - `workers` → lista de IPs de DataNodes
   - `hdfs-site.xml` → ruta de almacenamiento en cada DataNode (`/mnt/HadoopHDFS/DataNode`)
   - `.bashrc` → variables de entorno del clúster
5. **Creación de carpetas** — `hadoop_folder_workers.sh` crea `/mnt/HadoopHDFS/DataNode` en cada worker.
6. **Formato y arranque:**
   ```bash
   $HADOOP_HOME/bin/hdfs namenode -format
   $HADOOP_HOME/sbin/start-dfs.sh
   ```
7. **Verificación** — `jps` en cada nodo + interfaz web en `http://10.43.97.145:9870`.

---

## Scripts de Administración

| Script | Descripción |
|--------|-------------|
| `install_java_17.sh` | Instala Java 17 (OpenJDK) en todos los nodos vía SSH |
| `install_conda.sh` | Instala Miniforge y desempaqueta `pyspark_env` desde NFS |
| `hadoop_folder_workers.sh` | Crea y configura carpetas DataNode en los workers |
| `stop_workers.sh` | Mata procesos Spark Worker en todos los nodos |

---

## Notebooks de Experimentos

### `00_setup_verificacion.ipynb` — Verificación del Entorno
Valida versiones (Python 3.11, PySpark 3.5.2, Pandas 3.0), crea SparkSession contra el clúster real y crea la estructura de directorios HDFS: `/experimentos/exp1_io`, `/exp2_wordcount`, `/exp3_sql`, `/exp4_fallos`.

### `01_exp_io_hdfs_vs_local.ipynb` — Benchmark I/O: HDFS vs NFS

Genera CSVs sintéticos (1 MB → 2 GB) y mide throughput de escritura y lectura.

| Tamaño | Write → HDFS | Read HDFS | Read NFS |
|--------|-------------|----------|---------|
| 1 MB | 0.2 MB/s | 0.9 MB/s | 0.9 MB/s |
| 30 MB | — | ~93 MB/s | ~114 MB/s |
| 100 MB | — | 93.9 MB/s | 114.8 MB/s |
| 2 GB | 195.5 MB/s | **268.6 MB/s** | 254.1 MB/s |

**Conclusión:** NFS supera a HDFS en archivos medianos (30–100 MB); HDFS es superior en archivos grandes (≥2 GB) gracias al paralelismo de los DataNodes.

### `02_exp_wordcount.ipynb` — WordCount: Python vs Spark

Corpus sintético de 56.6 MB (500 000 líneas, 44 palabras del dominio HPC). Cuatro métodos comparados:

| Método | Tiempo | Speedup vs Python |
|--------|--------|-------------------|
| Spark SQL (HDFS) | **1.57 s** | **2.12×** |
| Python puro | 3.32 s | 1.00× |
| Spark RDD (HDFS) | 9.43 s | 0.35× |
| Spark DataFrame (HDFS) | 10.52 s | 0.32× |

**Conclusión:** Spark SQL gana gracias al optimizador Catalyst. Python puro supera a RDD/DataFrame porque el overhead de Spark domina para datasets pequeños. Resultado persistido en HDFS como Parquet.

---

## Comandos HDFS de Referencia

```bash
hdfs dfs -ls /                  # listar directorio raíz
hdfs dfs -mkdir /dir            # crear directorio
hdfs dfs -put archivo.csv /dir/ # subir archivo local a HDFS
hdfs dfs -get /dir/archivo ./   # descargar archivo de HDFS
hdfs dfs -cat /dir/archivo      # mostrar contenido
hdfs dfs -cp /src /dst          # copiar dentro de HDFS
hdfs dfs -mv /src /dst          # mover/renombrar en HDFS
hdfs dfs -rmr /dir              # eliminar directorio recursivo
hdfs dfs -du -h /dir            # tamaño de archivos
hdfs fsck /ruta -files -blocks  # inspeccionar bloques y replicación
```

---

## Conclusiones

- SSH sin contraseña es prerequisito indispensable para la coordinación del clúster.
- NFS centraliza los binarios de Spark en `/nfs/condor/apps`, simplificando el mantenimiento.
- La resolución de nombres por `/etc/hosts` es crítica; elimina dependencia de DNS externo.
- HDFS escala mejor que NFS para archivos de gran tamaño gracias a la distribución de bloques (128 MB por bloque, replicación ×3 por defecto).
- Spark SQL es la abstracción más eficiente para WordCount; RDD y DataFrame no compensan su overhead en datasets pequeños.

---

## Referencias

- Ghemawat et al. (2003). *The Google File System.* ACM SOSP.
- Shvachko et al. (2010). *The Hadoop Distributed File System.* IEEE MSST.
- Dean & Ghemawat (2004). *MapReduce.* OSDI.
- White, T. (2015). *Hadoop: The Definitive Guide* (4th ed.). O'Reilly.
- Apache Software Foundation. [HDFS Architecture](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html)
