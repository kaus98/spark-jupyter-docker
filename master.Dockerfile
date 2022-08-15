FROM mk-spark-base

RUN mkdir -p ${SHARED_WORKSPACE}
VOLUME ${SHARED_WORKSPACE}

EXPOSE 8081 7077 8998 8888 8080

WORKDIR ${APP}

CMD /usr/bin/spark-3.3.0-bin-hadoop3/bin/spark-class org.apache.spark.deploy.master.Master >> /tmp/logs/spark-master.out