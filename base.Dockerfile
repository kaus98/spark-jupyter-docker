FROM debian:stretch

# RUN apt-get update -y && apt-get install -y software-properties-common gcc && \
    # add-apt-repository -y ppa:deadsnakes/ppa 
    # apt-get install -y python3.8 python3-pip curl wget unzip procps openjdk-8-jdk coreutils && \
    # ln -s /usr/bin/python3 /usr/bin/python && \
    # apt-get install -y r-base && \

# Prepare dirs
RUN mkdir -p /tmp/logs/ && chmod a+w /tmp/logs/ && mkdir /app && chmod a+rwx /app && mkdir /data && chmod a+rwx /data
ENV JAVA_HOME=/usr
ENV SPARK_HOME=/usr/bin/spark-3.3.0-bin-hadoop3
ENV PATH=$SPARK_HOME:$PATH:/bin:$JAVA_HOME/bin:$JAVA_HOME/jre/bin
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON=/usr/bin/python
ENV PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
ENV APP=/app
ENV SHARED_WORKSPACE=/opt/workspace
RUN mkdir -p ${SHARED_WORKSPACE}


#Install Python=3.8
RUN apt update && \
    apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
    libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev curl \
    wget libbz2-dev && \
    wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz && \
    tar -xf Python-3.8.0.tgz && cd Python-3.8.0 && \
    ./configure --enable-optimizations && \
    make -j 8 && make altinstall && \
    cd .. && rm -rf ./Python-3.8.0* && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.8 get-pip.py && rm -rf ./get-pip.py && \
    pip3 install numpy scipy matplotlib && \
    rm -f /usr/bin/python && ln -s /usr/local/bin/python3.8 /usr/bin/python

# System packages
RUN apt-get clean && apt-get update -y && \
    apt-get install -y curl wget unzip procps openjdk-8-jdk coreutils && \
    rm -rf /var/lib/apt/lists/*

# Install Spark
RUN curl https://dlcdn.apache.org/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz -o spark.tgz && \
    tar -xf spark.tgz && \
    mv spark-3.3.0-bin-hadoop3 /usr/bin/ && \
    mkdir /usr/bin/spark-3.3.0-bin-hadoop3/logs && \
    rm spark.tgz

# Install Scala in Docker
ARG SCALA_VERSION=2.12.12
RUN mkdir -p ${SHARED_WORKSPACE}/data && \
    mkdir -p /usr/share/man/man1 && \
    curl https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb -k -o scala.deb && \
    apt install -y ./scala.deb && \
    rm -rf scala.deb /var/lib/apt/lists/*

# Setup Ammonium Inside Docker
RUN curl -L -o /usr/local/bin/amm https://git.io/vASZm && chmod +x /usr/local/bin/amm

VOLUME ${SHARED_WORKSPACE}