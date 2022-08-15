FROM mk-spark-base

RUN mkdir -p ${SHARED_WORKSPACE}

# Setting up Shared Volume
VOLUME ${SHARED_WORKSPACE}

# Opening the Ports
EXPOSE 8081 7077 8998 8888 8080

# Setting the Work Directory
WORKDIR ${APP}

CMD /usr/bin/spark-3.3.0-bin-hadoop3/bin/spark-class org.apache.spark.deploy.worker.Worker spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} >> /tmp/logs/spark-worker.out