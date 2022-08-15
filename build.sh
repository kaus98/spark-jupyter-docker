 # Builds images
docker build -f base.Dockerfile -t mk-spark-base .

docker build -f master.Dockerfile -t mk-spark-master .

docker build -f worker.Dockerfile -t mk-spark-worker .

docker build -f jupyter.Dockerfile -t mk-jupyter .

docker build -f ammonium.Dockerfile -t mk-amm .